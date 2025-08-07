//
//  GameProgressViewModel.swift
//  HealthQuest: Mind & Body Adventure
//
//  Created by Вячеслав on 8/4/25.
//

import Foundation
import SwiftUI

@MainActor
class GameProgressViewModel: ObservableObject {
    @Published var levels: [Level] = []
    @Published var currentLevel: Level?
    @Published var selectedLevel: Level?
    @Published var showLevelDetail = false
    
    private let levelsKey = "HealthQuestLevels"
    
    init() {
        loadLevels()
    }
    
    private func loadLevels() {
        if let levelsData = UserDefaults.standard.data(forKey: levelsKey),
           let savedLevels = try? JSONDecoder().decode([Level].self, from: levelsData) {
            self.levels = savedLevels
        } else {
            createDefaultLevels()
        }
        
        currentLevel = levels.first { !$0.isCompleted }
    }
    
    private func saveLevels() {
        if let encoded = try? JSONEncoder().encode(levels) {
            UserDefaults.standard.set(encoded, forKey: levelsKey)
        }
    }
    
    private func createDefaultLevels() {
        levels = [
            Level(
                number: 1,
                title: "Forest Awakening",
                description: "Begin your journey in the mystical Enchanted Forest",
                theme: .forest,
                requiredExperience: 0,
                physicalChallenges: [
                    PhysicalChallenge(title: "Nature Walk", description: "Take 5,000 steps", activityType: .walking, targetValue: 5000, unit: "steps"),
                    PhysicalChallenge(title: "Forest Energy", description: "Burn 150 calories", activityType: .cardio, targetValue: 150, unit: "calories")
                ],
                mindfulnessChallenges: [],
                rewards: ["Forest Explorer Badge", "100 XP", "New Avatar Outfit"]
            ),
            Level(
                number: 2,
                title: "Mountain Climb",
                description: "Ascend the challenging Mystic Mountains",
                theme: .mountain,
                requiredExperience: 500,
                physicalChallenges: [
                    PhysicalChallenge(title: "Mountain Hike", description: "Walk 8,000 steps", activityType: .walking, targetValue: 8000, unit: "steps"),
                    PhysicalChallenge(title: "Strength Training", description: "Complete strength exercises", activityType: .strength, targetValue: 30, unit: "minutes")
                ],
                mindfulnessChallenges: [
                    MindfulnessChallenge(title: "Peak Meditation", description: "Meditate on the mountain peak", duration: 10, type: .meditation)
                ],
                rewards: ["Mountain Conqueror Badge", "200 XP", "Mountain Theme Unlock"]
            ),
            Level(
                number: 3,
                title: "Ocean Depths",
                description: "Dive into the mysterious Crystal Ocean",
                theme: .ocean,
                requiredExperience: 1200,
                physicalChallenges: [
                    PhysicalChallenge(title: "Swimming Adventure", description: "Complete swimming workout", activityType: .swimming, targetValue: 45, unit: "minutes"),
                    PhysicalChallenge(title: "Ocean Endurance", description: "Burn 300 calories", activityType: .cardio, targetValue: 300, unit: "calories")
                ],
                mindfulnessChallenges: [
                    MindfulnessChallenge(title: "Ocean Visualization", description: "Visualize peaceful ocean waves", duration: 15, type: .visualization)
                ],
                rewards: ["Ocean Explorer Badge", "300 XP", "Underwater Avatar"]
            ),
            Level(
                number: 4,
                title: "Desert Journey",
                description: "Cross the vast Golden Desert",
                theme: .desert,
                requiredExperience: 2000,
                physicalChallenges: [
                    PhysicalChallenge(title: "Desert Marathon", description: "Walk 12,000 steps", activityType: .walking, targetValue: 12000, unit: "steps"),
                    PhysicalChallenge(title: "Yoga Practice", description: "Complete yoga session", activityType: .yoga, targetValue: 60, unit: "minutes")
                ],
                mindfulnessChallenges: [
                    MindfulnessChallenge(title: "Desert Gratitude", description: "Practice gratitude meditation", duration: 20, type: .gratitude)
                ],
                rewards: ["Desert Wanderer Badge", "400 XP", "Desert Theme Unlock"]
            ),
            Level(
                number: 5,
                title: "Future City",
                description: "Explore the technological marvels of the Future City",
                theme: .city,
                requiredExperience: 3000,
                physicalChallenges: [
                    PhysicalChallenge(title: "City Cycling", description: "Complete cycling workout", activityType: .cycling, targetValue: 90, unit: "minutes"),
                    PhysicalChallenge(title: "Urban Energy", description: "Burn 500 calories", activityType: .cardio, targetValue: 500, unit: "calories")
                ],
                mindfulnessChallenges: [
                    MindfulnessChallenge(title: "Future Meditation", description: "Meditate on possibilities", duration: 25, type: .meditation)
                ],
                rewards: ["Future Explorer Badge", "500 XP", "Cyberpunk Avatar", "Master Achievement"]
            )
        ]
        
        saveLevels()
    }
    
    func unlockLevel(_ levelNumber: Int) {
        if let index = levels.firstIndex(where: { $0.number == levelNumber }) {
            levels[index].isUnlocked = true
            saveLevels()
        }
    }
    
    func completeLevel(_ levelNumber: Int, userViewModel: UserViewModel) {
        if let index = levels.firstIndex(where: { $0.number == levelNumber }) {
            levels[index].isCompleted = true
            
            // Award experience points
            let xpReward = levelNumber * 100
            userViewModel.addExperience(xpReward)
            
            // Add achievements
            for reward in levels[index].rewards {
                userViewModel.addAchievement(reward)
            }
            
            // Unlock next level
            if levelNumber < levels.count {
                unlockLevel(levelNumber + 1)
            }
            
            // Update current level
            currentLevel = levels.first { !$0.isCompleted }
            
            saveLevels()
        }
    }
    
    func completePhysicalChallenge(_ challengeId: UUID, in levelNumber: Int) {
        if let levelIndex = levels.firstIndex(where: { $0.number == levelNumber }),
           let challengeIndex = levels[levelIndex].physicalChallenges.firstIndex(where: { $0.id == challengeId }) {
            levels[levelIndex].physicalChallenges[challengeIndex].isCompleted = true
            saveLevels()
        }
    }
    
    func completeMindfulnessChallenge(_ challengeId: UUID, in levelNumber: Int) {
        if let levelIndex = levels.firstIndex(where: { $0.number == levelNumber }),
           let challengeIndex = levels[levelIndex].mindfulnessChallenges.firstIndex(where: { $0.id == challengeId }) {
            levels[levelIndex].mindfulnessChallenges[challengeIndex].isCompleted = true
            saveLevels()
        }
    }
    
    func getLevelProgress(_ level: Level) -> Double {
        let totalChallenges = level.physicalChallenges.count + level.mindfulnessChallenges.count
        let completedChallenges = level.physicalChallenges.filter { $0.isCompleted }.count + 
                                  level.mindfulnessChallenges.filter { $0.isCompleted }.count
        
        guard totalChallenges > 0 else { return 0 }
        return Double(completedChallenges) / Double(totalChallenges)
    }
    
    func isLevelComplete(_ level: Level) -> Bool {
        let allPhysicalCompleted = level.physicalChallenges.allSatisfy { $0.isCompleted }
        let allMindfulnessCompleted = level.mindfulnessChallenges.allSatisfy { $0.isCompleted }
        return allPhysicalCompleted && allMindfulnessCompleted
    }
    
    func selectLevel(_ level: Level) {
        selectedLevel = level
        showLevelDetail = true
    }
    
    func getAvailableLevels() -> [Level] {
        return levels.filter { $0.isUnlocked }
    }
    
    func getTotalProgress() -> Double {
        let completedLevels = levels.filter { $0.isCompleted }.count
        return Double(completedLevels) / Double(levels.count)
    }
} 
