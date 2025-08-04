//
//  Level.swift
//  HealthQuest: Mind & Body Adventure
//
//  Created by Вячеслав on 8/4/25.
//

import Foundation

struct Level: Identifiable, Codable {
    let id = UUID()
    let number: Int
    let title: String
    let description: String
    let theme: LevelTheme
    let requiredExperience: Int
    var physicalChallenges: [PhysicalChallenge]
    var mindfulnessChallenges: [MindfulnessChallenge]
    let rewards: [String]
    var isUnlocked: Bool
    var isCompleted: Bool
    
    init(number: Int, title: String, description: String, theme: LevelTheme, requiredExperience: Int, physicalChallenges: [PhysicalChallenge], mindfulnessChallenges: [MindfulnessChallenge], rewards: [String]) {
        self.number = number
        self.title = title
        self.description = description
        self.theme = theme
        self.requiredExperience = requiredExperience
        self.physicalChallenges = physicalChallenges
        self.mindfulnessChallenges = mindfulnessChallenges
        self.rewards = rewards
        self.isUnlocked = number == 1
        self.isCompleted = false
    }
}

enum LevelTheme: String, CaseIterable, Codable {
    case forest = "Enchanted Forest"
    case mountain = "Mystic Mountains"
    case ocean = "Crystal Ocean"
    case desert = "Golden Desert"
    case city = "Future City"
    
    var backgroundColor: String {
        switch self {
        case .forest: return "#2490ad"
        case .mountain: return "#3c166d"
        case .ocean: return "#1a2962"
        case .desert: return "#fbaa1a"
        case .city: return "#f0048d"
        }
    }
    
    var emoji: String {
        switch self {
        case .forest: return "🌲"
        case .mountain: return "⛰️"
        case .ocean: return "🌊"
        case .desert: return "🏜️"
        case .city: return "🏙️"
        }
    }
}

struct PhysicalChallenge: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let activityType: ActivityType
    let targetValue: Double
    let unit: String
    var isCompleted: Bool
    
    init(title: String, description: String, activityType: ActivityType, targetValue: Double, unit: String) {
        self.title = title
        self.description = description
        self.activityType = activityType
        self.targetValue = targetValue
        self.unit = unit
        self.isCompleted = false
    }
}

struct MindfulnessChallenge: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let duration: Int // in minutes
    let type: MindfulnessType
    var isCompleted: Bool
    
    init(title: String, description: String, duration: Int, type: MindfulnessType) {
        self.title = title
        self.description = description
        self.duration = duration
        self.type = type
        self.isCompleted = false
    }
}

enum MindfulnessType: String, CaseIterable, Codable {
    case breathing = "Breathing Exercise"
    case meditation = "Meditation"
    case gratitude = "Gratitude Practice"
    case visualization = "Visualization"
    
    var icon: String {
        switch self {
        case .breathing: return "lungs.fill"
        case .meditation: return "brain.head.profile"
        case .gratitude: return "heart.text.square.fill"
        case .visualization: return "eye.fill"
        }
    }
} 