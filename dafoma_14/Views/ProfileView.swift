//
//  ProfileView.swift
//  HealthQuest: Mind & Body Adventure
//
//  Created by Вячеслав on 8/4/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var gameViewModel: GameProgressViewModel
    @State private var showEditProfile = false
    @State private var showAchievements = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "#2490ad"),
                        Color(hex: "#3c166d"),
                        Color(hex: "#1a2962")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        ProfileHeaderView(userViewModel: userViewModel)
                        
                        // Stats Overview
                        StatsOverviewView(userViewModel: userViewModel, gameViewModel: gameViewModel)
                        
                        // Achievements Section
                        AchievementsSection(userViewModel: userViewModel, showAchievements: $showAchievements)
                        
                        // Quest Progress
                        QuestProgressSection(gameViewModel: gameViewModel)
                        
                        // Settings
                        SettingsSection(showEditProfile: $showEditProfile)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(userViewModel: userViewModel)
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView(userViewModel: userViewModel)
            }
        }
    }
}

struct ProfileHeaderView: View {
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#fbaa1a"), Color(hex: "#f0048d")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(String(userViewModel.user.name.prefix(1).uppercased()))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 5) {
                Text(userViewModel.user.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Level \(userViewModel.user.currentLevel) • \(userViewModel.user.fitnessLevel.rawValue)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#fbaa1a"))
            }
            
            // XP Progress
            VStack(spacing: 8) {
                HStack {
                    Text("Experience Points")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(userViewModel.user.totalExperience) XP")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                ProgressView(value: userViewModel.getProgressToNextLevel())
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#fbaa1a")))
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(5)
                
                Text("Next Level: \((userViewModel.user.currentLevel) * 1000) XP")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct StatsOverviewView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var gameViewModel: GameProgressViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Statistics")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                StatCard(
                    title: "Quests Completed",
                    value: "\(gameViewModel.levels.filter { $0.isCompleted }.count)",
                    icon: "flag.checkered",
                    color: "#01ff00"
                )
                
                StatCard(
                    title: "Total Achievements",
                    value: "\(userViewModel.user.achievedGoals.count)",
                    icon: "trophy.fill",
                    color: "#fbaa1a"
                )
                
                StatCard(
                    title: "Today's Steps",
                    value: "\(userViewModel.getTotalSteps())",
                    icon: "figure.walk",
                    color: "#f0048d"
                )
                
                StatCard(
                    title: "Weekly Streak",
                    value: "\(userViewModel.getWeeklyStreak()) days",
                    icon: "flame.fill",
                    color: "#01ff00"
                )
                
                StatCard(
                    title: "Overall Progress",
                    value: "\(Int(gameViewModel.getTotalProgress() * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: "#3c166d"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: color))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct AchievementsSection: View {
    @ObservedObject var userViewModel: UserViewModel
    @Binding var showAchievements: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recent Achievements")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    showAchievements = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#fbaa1a"))
            }
            
            if userViewModel.user.achievedGoals.isEmpty {
                Text("Complete your first quest to earn achievements!")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 10) {
                    ForEach(Array(userViewModel.user.achievedGoals.prefix(3)), id: \.self) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct AchievementRow: View {
    let achievement: String
    
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#fbaa1a"))
            
            Text(achievement)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#01ff00"))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

struct QuestProgressSection: View {
    @ObservedObject var gameViewModel: GameProgressViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quest Progress")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            ForEach(gameViewModel.levels.prefix(5)) { level in
                QuestProgressRow(level: level, gameViewModel: gameViewModel)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct QuestProgressRow: View {
    let level: Level
    @ObservedObject var gameViewModel: GameProgressViewModel
    
    var body: some View {
        HStack {
            Text(level.theme.emoji)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(level.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                ProgressView(value: gameViewModel.getLevelProgress(level))
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: level.theme.backgroundColor)))
                    .background(Color.white.opacity(0.2))
            }
            
            Spacer()
            
            if level.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "#01ff00"))
            } else if level.isUnlocked {
                Text("\(Int(gameViewModel.getLevelProgress(level) * 100))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

struct SettingsSection: View {
    @Binding var showEditProfile: Bool
    @State private var isShowingHealthAlert = false
    @State private var healthSyncMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Settings")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Button(action: {
                showEditProfile = true
            }) {
                SettingsRow(title: "Edit Profile", icon: "person.circle", color: "#fbaa1a")
            }
            
            Button(action: {
                requestHealthDataSync()
            }) {
                SettingsRow(title: "Sync Health Data", icon: "heart.fill", color: "#f0048d")
            }
            
            Button(action: {
                // Reset progress action
            }) {
                SettingsRow(title: "Reset Progress", icon: "arrow.clockwise", color: "#01ff00")
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .alert("Health Data Sync", isPresented: $isShowingHealthAlert) {
            Button("OK") { }
        } message: {
            Text(healthSyncMessage)
        }
    }
    
    private func requestHealthDataSync() {
        // Simulate health data sync functionality
        healthSyncMessage = "Health data sync is now enabled. Your activity data will be synchronized with your device's health app."
        isShowingHealthAlert = true
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let color: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: color))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

struct EditProfileView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String
    @State private var fitnessLevel: FitnessLevel
    @State private var selectedActivities: Set<ActivityType>
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        self._name = State(initialValue: userViewModel.user.name)
        self._fitnessLevel = State(initialValue: userViewModel.user.fitnessLevel)
        self._selectedActivities = State(initialValue: Set(userViewModel.user.preferredActivities))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#2490ad"),
                        Color(hex: "#3c166d"),
                        Color(hex: "#1a2962")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Name Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("Enter your name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                        
                        // Fitness Level Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Fitness Level")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            ForEach(FitnessLevel.allCases, id: \.self) { level in
                                Button(action: {
                                    fitnessLevel = level
                                }) {
                                    HStack {
                                        Text(level.rawValue)
                                            .foregroundColor(fitnessLevel == level ? .black : .white)
                                        Spacer()
                                        if fitnessLevel == level {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.black)
                                        }
                                    }
                                    .padding()
                                    .background(fitnessLevel == level ? Color(hex: "#fbaa1a") : Color.white.opacity(0.05))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                        
                        // Preferred Activities Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Preferred Activities")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                ForEach(ActivityType.allCases, id: \.self) { activity in
                                    Button(action: {
                                        if selectedActivities.contains(activity) {
                                            selectedActivities.remove(activity)
                                        } else {
                                            selectedActivities.insert(activity)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: activity.icon)
                                                .foregroundColor(selectedActivities.contains(activity) ? .black : .white)
                                            Text(activity.rawValue)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(selectedActivities.contains(activity) ? .black : .white)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(selectedActivities.contains(activity) ? Color(hex: "#fbaa1a") : Color.white.opacity(0.05))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .foregroundColor(.white)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func saveProfile() {
        userViewModel.updateUserProfile(
            name: name,
            fitnessLevel: fitnessLevel,
            preferredActivities: Array(selectedActivities)
        )
        presentationMode.wrappedValue.dismiss()
    }
}

struct AchievementsView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#2490ad"),
                        Color(hex: "#3c166d"),
                        Color(hex: "#1a2962")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 10) {
                        if userViewModel.user.achievedGoals.isEmpty {
                            VStack(spacing: 20) {
                                Text("🏆")
                                    .font(.system(size: 60))
                                
                                Text("No achievements yet!")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("Complete quests and challenges to earn your first achievement.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        } else {
                            ForEach(userViewModel.user.achievedGoals, id: \.self) { achievement in
                                AchievementDetailRow(achievement: achievement)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct AchievementDetailRow: View {
    let achievement: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(hex: "#fbaa1a"))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Achievement unlocked!")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#01ff00"))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
} 