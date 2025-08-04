//
//  User.swift
//  HealthQuest: Mind & Body Adventure
//
//  Created by Вячеслав on 8/4/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id = UUID()
    var name: String
    var fitnessLevel: FitnessLevel
    var preferredActivities: [ActivityType]
    var currentLevel: Int
    var totalExperience: Int
    var achievedGoals: [String]
    var profileSetupCompleted: Bool
    
    init(name: String = "", fitnessLevel: FitnessLevel = .beginner, preferredActivities: [ActivityType] = []) {
        self.name = name
        self.fitnessLevel = fitnessLevel
        self.preferredActivities = preferredActivities
        self.currentLevel = 1
        self.totalExperience = 0
        self.achievedGoals = []
        self.profileSetupCompleted = false
    }
}

enum FitnessLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var description: String {
        switch self {
        case .beginner:
            return "Just starting my fitness journey"
        case .intermediate:
            return "I exercise regularly"
        case .advanced:
            return "I'm an experienced athlete"
        }
    }
}

enum ActivityType: String, CaseIterable, Codable {
    case cardio = "Cardio"
    case strength = "Strength"
    case yoga = "Yoga"
    case meditation = "Meditation"
    case walking = "Walking"
    case cycling = "Cycling"
    case swimming = "Swimming"
    
    var icon: String {
        switch self {
        case .cardio: return "heart.fill"
        case .strength: return "dumbbell.fill"
        case .yoga: return "figure.yoga"
        case .meditation: return "brain.head.profile"
        case .walking: return "figure.walk"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        }
    }
} 