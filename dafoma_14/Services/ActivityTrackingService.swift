//
//  ActivityTrackingService.swift
//  HealthQuest: Mind & Body Adventure
//
//  Created by Вячеслав on 8/4/25.
//

import Foundation
import SwiftUI

@MainActor
class ActivityTrackingService: ObservableObject {
    @Published var dailyActivities: [DailyActivity] = []
    @Published var currentMood: MoodLevel = .neutral
    @Published var dailyCheckIn: DailyCheckIn?
    @Published var totalSteps: Int = 0
    @Published var totalMinutesActive: Int = 0
    @Published var completedMiniGames: [MiniGameResult] = []
    
    private let activitiesKey = "HealthQuestActivities"
    private let moodKey = "HealthQuestMood"
    private let checkInKey = "HealthQuestCheckIn"
    
    init() {
        loadTodaysData()
    }
    
    // MARK: - Activity Tracking
    
    func logActivity(_ activity: ActivityLog) {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let existingIndex = dailyActivities.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyActivities[existingIndex].activities.append(activity)
            dailyActivities[existingIndex].totalMinutes += activity.duration
        } else {
            let newDay = DailyActivity(date: today, activities: [activity], totalMinutes: activity.duration)
            dailyActivities.append(newDay)
        }
        
        updateTotals()
        saveDailyActivities()
    }
    
    func logSteps(_ steps: Int) {
        totalSteps += steps
        let activity = ActivityLog(
            type: .walking,
            duration: steps / 100, // Rough estimate: 100 steps = 1 minute
            intensity: .moderate,
            description: "Logged \(steps) steps"
        )
        logActivity(activity)
    }
    
    func quickLogActivity(type: ActivityType, minutes: Int) {
        let activity = ActivityLog(
            type: type,
            duration: minutes,
            intensity: .moderate,
            description: "\(minutes) minutes of \(type.rawValue.lowercased())"
        )
        logActivity(activity)
    }
    
    // MARK: - Mood Tracking
    
    func updateMood(_ mood: MoodLevel, note: String = "") {
        currentMood = mood
        
        let today = Calendar.current.startOfDay(for: Date())
        if dailyCheckIn == nil || !Calendar.current.isDate(dailyCheckIn!.date, inSameDayAs: today) {
            dailyCheckIn = DailyCheckIn(date: today, mood: mood, energyLevel: .medium, note: note)
        } else {
            dailyCheckIn?.mood = mood
            dailyCheckIn?.note = note
        }
        
        saveMoodData()
    }
    
    func updateEnergyLevel(_ energy: EnergyLevel) {
        let today = Calendar.current.startOfDay(for: Date())
        if dailyCheckIn == nil || !Calendar.current.isDate(dailyCheckIn!.date, inSameDayAs: today) {
            dailyCheckIn = DailyCheckIn(date: today, mood: currentMood, energyLevel: energy)
        } else {
            dailyCheckIn?.energyLevel = energy
        }
        saveMoodData()
    }
    
    // MARK: - Mini Games
    
    func completeMiniGame(_ result: MiniGameResult) {
        completedMiniGames.append(result)
        
        // Convert mini-game to activity
        let activity = ActivityLog(
            type: result.gameType.activityType,
            duration: result.duration,
            intensity: .moderate,
            description: "Completed \(result.gameType.rawValue) mini-game"
        )
        logActivity(activity)
    }
    
    // MARK: - Data Management
    
    private func loadTodaysData() {
        // Load activities
        if let data = UserDefaults.standard.data(forKey: activitiesKey),
           let activities = try? JSONDecoder().decode([DailyActivity].self, from: data) {
            dailyActivities = activities
        }
        
        // Load mood
        if let data = UserDefaults.standard.data(forKey: moodKey),
           let checkIn = try? JSONDecoder().decode(DailyCheckIn.self, from: data) {
            let today = Calendar.current.startOfDay(for: Date())
            if Calendar.current.isDate(checkIn.date, inSameDayAs: today) {
                dailyCheckIn = checkIn
                currentMood = checkIn.mood
            }
        }
        
        updateTotals()
    }
    
    private func updateTotals() {
        let today = Calendar.current.startOfDay(for: Date())
        if let todayActivity = dailyActivities.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            totalMinutesActive = todayActivity.totalMinutes
            totalSteps = todayActivity.activities
                .filter { $0.type == .walking }
                .reduce(0) { $0 + ($1.duration * 100) } // Estimate steps from minutes
        }
    }
    
    private func saveDailyActivities() {
        if let encoded = try? JSONEncoder().encode(dailyActivities) {
            UserDefaults.standard.set(encoded, forKey: activitiesKey)
        }
    }
    
    private func saveMoodData() {
        if let checkIn = dailyCheckIn,
           let encoded = try? JSONEncoder().encode(checkIn) {
            UserDefaults.standard.set(encoded, forKey: moodKey)
        }
    }
    
    // MARK: - Statistics
    
    func getTodaysProgress(for type: ActivityType) -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        guard let todayActivity = dailyActivities.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) else {
            return 0.0
        }
        
        let minutesForType = todayActivity.activities
            .filter { $0.type == type }
            .reduce(0) { $0 + $1.duration }
        
        let target = getTargetMinutes(for: type)
        return min(Double(minutesForType) / Double(target), 1.0)
    }
    
    func getTotalActiveMinutes() -> Int {
        return totalMinutesActive
    }
    
    func getWeeklyStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var date = Date()
        
        for _ in 0..<7 {
            let dayStart = calendar.startOfDay(for: date)
            if dailyActivities.contains(where: { 
                calendar.isDate($0.date, inSameDayAs: dayStart) && $0.totalMinutes >= 30 
            }) {
                streak += 1
            } else {
                break
            }
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
        
        return streak
    }
    
    private func getTargetMinutes(for type: ActivityType) -> Int {
        switch type {
        case .cardio: return 30
        case .strength: return 20
        case .yoga: return 25
        case .walking: return 60
        case .cycling: return 45
        case .swimming: return 30
        case .meditation: return 15
        }
    }
}

// MARK: - Data Models

struct DailyActivity: Codable, Identifiable {
    let id = UUID()
    let date: Date
    var activities: [ActivityLog]
    var totalMinutes: Int
}

struct ActivityLog: Codable, Identifiable {
    let id = UUID()
    let type: ActivityType
    let duration: Int // in minutes
    let intensity: IntensityLevel
    let description: String
    let timestamp: Date = Date()
}

struct DailyCheckIn: Codable {
    let date: Date
    var mood: MoodLevel
    var energyLevel: EnergyLevel
    var note: String = ""
}

struct MiniGameResult: Codable, Identifiable {
    let id = UUID()
    let gameType: MiniGameType
    let score: Int
    let duration: Int // in minutes
    let completed: Date = Date()
}

enum MoodLevel: String, CaseIterable, Codable {
    case veryHappy = "Very Happy"
    case happy = "Happy"
    case neutral = "Neutral"
    case sad = "Sad"
    case stressed = "Stressed"
    
    var emoji: String {
        switch self {
        case .veryHappy: return "😄"
        case .happy: return "😊"
        case .neutral: return "😐"
        case .sad: return "😔"
        case .stressed: return "😰"
        }
    }
    
    var color: String {
        switch self {
        case .veryHappy: return "#01ff00"
        case .happy: return "#fbaa1a"
        case .neutral: return "#f7f7f7"
        case .sad: return "#3c166d"
        case .stressed: return "#f0048d"
        }
    }
}

enum EnergyLevel: String, CaseIterable, Codable {
    case high = "High Energy"
    case medium = "Medium Energy"
    case low = "Low Energy"
    
    var emoji: String {
        switch self {
        case .high: return "⚡"
        case .medium: return "🔋"
        case .low: return "🪫"
        }
    }
}

enum IntensityLevel: String, CaseIterable, Codable {
    case light = "Light"
    case moderate = "Moderate"
    case intense = "Intense"
}

enum MiniGameType: String, CaseIterable, Codable {
    case jumpingJacks = "Jumping Jacks"
    case squats = "Squats"
    case pushUps = "Push-ups"
    case plank = "Plank Hold"
    case dancing = "Dance Party"
    case breathing = "Breathing Game"
    
    var activityType: ActivityType {
        switch self {
        case .jumpingJacks, .dancing: return .cardio
        case .squats, .pushUps: return .strength
        case .plank: return .strength
        case .breathing: return .meditation
        }
    }
    
    var icon: String {
        switch self {
        case .jumpingJacks: return "figure.jumprope"
        case .squats: return "figure.strengthtraining.traditional"
        case .pushUps: return "figure.strengthtraining.functional"
        case .plank: return "figure.core.training"
        case .dancing: return "figure.dance"
        case .breathing: return "lungs.fill"
        }
    }
    
    var description: String {
        switch self {
        case .jumpingJacks: return "High-energy cardio workout"
        case .squats: return "Lower body strength training"
        case .pushUps: return "Upper body strength training"
        case .plank: return "Core stability challenge"
        case .dancing: return "Fun cardio dance session"
        case .breathing: return "Calming breathing exercise"
        }
    }
} 