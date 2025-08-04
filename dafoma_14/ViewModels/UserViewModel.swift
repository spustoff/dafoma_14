//
//  UserViewModel.swift
//  HealthQuest: Mind & Body Adventure
//
//  Created by Вячеслав on 8/4/25.
//

import Foundation
import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User
    @Published var showOnboarding: Bool
    @Published var activityService = ActivityTrackingService()
    
    private let userDefaultsKey = "HealthQuestUser"
    
    init() {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: userData) {
            self.user = savedUser
            self.showOnboarding = !savedUser.profileSetupCompleted
        } else {
            self.user = User()
            self.showOnboarding = true
        }
        
        // Activity service is automatically initialized
    }
    
    func saveUser() {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func completeOnboarding() {
        user.profileSetupCompleted = true
        showOnboarding = false
        saveUser()
    }
    
    func updateUserProfile(name: String, fitnessLevel: FitnessLevel, preferredActivities: [ActivityType]) {
        user.name = name
        user.fitnessLevel = fitnessLevel
        user.preferredActivities = preferredActivities
        saveUser()
    }
    
    func addExperience(_ amount: Int) {
        user.totalExperience += amount
        
        // Level up logic
        let newLevel = calculateLevel(from: user.totalExperience)
        if newLevel > user.currentLevel {
            user.currentLevel = newLevel
        }
        
        saveUser()
    }
    
    func addAchievement(_ achievement: String) {
        if !user.achievedGoals.contains(achievement) {
            user.achievedGoals.append(achievement)
            saveUser()
        }
    }
    
    private func calculateLevel(from experience: Int) -> Int {
        // Simple leveling formula: every 1000 XP = 1 level
        return max(1, experience / 1000 + 1)
    }
    
    // MARK: - Activity Tracking
    
    func logActivity(type: ActivityType, minutes: Int) {
        activityService.quickLogActivity(type: type, minutes: minutes)
        addExperience(minutes * 2) // 2 XP per minute of activity
    }
    
    func logSteps(_ steps: Int) {
        activityService.logSteps(steps)
        addExperience(steps / 10) // 1 XP per 10 steps
    }
    
    func updateMood(_ mood: MoodLevel, note: String = "") {
        activityService.updateMood(mood, note: note)
        addExperience(10) // Bonus XP for mood tracking
    }
    
    func refreshActivityData() {
        // Data is automatically updated in ActivityTrackingService
        activityService.objectWillChange.send()
    }
    
    func getProgressToNextLevel() -> Double {
        let currentLevelXP = (user.currentLevel - 1) * 1000
        let nextLevelXP = user.currentLevel * 1000
        let progressXP = user.totalExperience - currentLevelXP
        
        return Double(progressXP) / Double(nextLevelXP - currentLevelXP)
    }
    
    func getDailyGoalProgress(for activityType: ActivityType) -> Double {
        return activityService.getTodaysProgress(for: activityType)
    }
    
    func getTotalActiveMinutes() -> Int {
        return activityService.getTotalActiveMinutes()
    }
    
    func getTotalSteps() -> Int {
        return activityService.totalSteps
    }
    
    func getWeeklyStreak() -> Int {
        return activityService.getWeeklyStreak()
    }
} 