//
//  AdventureGameView.swift
//  HealthQuest: Mind & Body Adventure
//
//  Created by Вячеслав on 8/4/25.
//

import SwiftUI

struct AdventureGameView: View {
    @ObservedObject var gameViewModel: GameProgressViewModel
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var mindfulnessService = MindfulnessService()
    @State private var selectedChallenge: MindfulnessChallenge?
    @State private var showMindfulnessSession = false
    
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
                        // Player Stats Header
                        PlayerStatsView(userViewModel: userViewModel)
                        
                        // Current Level Section
                        if let currentLevel = gameViewModel.currentLevel {
                            CurrentLevelView(
                                level: currentLevel,
                                gameViewModel: gameViewModel,
                                userViewModel: userViewModel,
                                mindfulnessService: mindfulnessService,
                                selectedChallenge: $selectedChallenge,
                                showMindfulnessSession: $showMindfulnessSession
                            )
                        }
                        
                        // Available Levels
                        AvailableLevelsView(gameViewModel: gameViewModel)
                        
                        // Daily Challenges
                        DailyChallengesView(userViewModel: userViewModel)
                    }
                    .padding()
                }
                .refreshable {
                    userViewModel.refreshActivityData()
                }
            }
            .navigationTitle("HealthQuest")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showMindfulnessSession) {
                if let challenge = selectedChallenge {
                    MindfulnessSessionView(
                        challenge: challenge,
                        mindfulnessService: mindfulnessService,
                        gameViewModel: gameViewModel,
                        userViewModel: userViewModel
                    )
                }
            }
        }
    }
}

struct PlayerStatsView: View {
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome back, \(userViewModel.user.name)!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Level \(userViewModel.user.currentLevel) • \(userViewModel.user.totalExperience) XP")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#fbaa1a"))
                }
                
                Spacer()
                
                VStack {
                    Text("🏆")
                        .font(.system(size: 30))
                    Text("\(userViewModel.user.achievedGoals.count)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Level Progress Bar
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Progress to Level \(userViewModel.user.currentLevel + 1)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(Int(userViewModel.getProgressToNextLevel() * 100))%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                ProgressView(value: userViewModel.getProgressToNextLevel())
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#fbaa1a")))
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(5)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct CurrentLevelView: View {
    let level: Level
    @ObservedObject var gameViewModel: GameProgressViewModel
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var mindfulnessService: MindfulnessService
    @Binding var selectedChallenge: MindfulnessChallenge?
    @Binding var showMindfulnessSession: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Quest")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(level.theme.emoji) \(level.title)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(level.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: gameViewModel.getLevelProgress(level),
                    color: Color(hex: "#fbaa1a")
                )
                .frame(width: 60, height: 60)
            }
            
            // Physical Challenges
            VStack(alignment: .leading, spacing: 10) {
                Text("Physical Challenges")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                ForEach(level.physicalChallenges) { challenge in
                    PhysicalChallengeRow(
                        challenge: challenge,
                        userViewModel: userViewModel,
                        gameViewModel: gameViewModel,
                        levelNumber: level.number
                    )
                }
            }
            
            // Mindfulness Challenges
            VStack(alignment: .leading, spacing: 10) {
                Text("Mindfulness Challenges")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                ForEach(level.mindfulnessChallenges) { challenge in
                    MindfulnessChallengeRow(
                        challenge: challenge,
                        selectedChallenge: $selectedChallenge,
                        showMindfulnessSession: $showMindfulnessSession
                    )
                }
            }
            
            // Complete Level Button
            if gameViewModel.isLevelComplete(level) && !level.isCompleted {
                Button("Complete Quest & Claim Rewards") {
                    gameViewModel.completeLevel(level.number, userViewModel: userViewModel)
                }
                .foregroundColor(.black)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#01ff00"))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(hex: level.theme.backgroundColor).opacity(0.3),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
    }
}

struct PhysicalChallengeRow: View {
    let challenge: PhysicalChallenge
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var gameViewModel: GameProgressViewModel
    let levelNumber: Int
    
    var currentProgress: Double {
        return userViewModel.getDailyGoalProgress(for: challenge.activityType)
    }
    
    var body: some View {
        HStack {
            Image(systemName: challenge.activityType.icon)
                .font(.system(size: 20))
                .foregroundColor(challenge.isCompleted ? Color(hex: "#01ff00") : Color(hex: "#fbaa1a"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(challenge.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(challenge.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                
                ProgressView(value: currentProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#fbaa1a")))
                    .background(Color.white.opacity(0.2))
            }
            
            Spacer()
            
            if challenge.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "#01ff00"))
            } else if currentProgress >= 1.0 {
                Button("Complete") {
                    gameViewModel.completePhysicalChallenge(challenge.id, in: levelNumber)
                    userViewModel.addExperience(50)
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#01ff00"))
                .cornerRadius(8)
            } else {
                Text("\(Int(currentProgress * 100))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

struct MindfulnessChallengeRow: View {
    let challenge: MindfulnessChallenge
    @Binding var selectedChallenge: MindfulnessChallenge?
    @Binding var showMindfulnessSession: Bool
    
    var body: some View {
        HStack {
            Image(systemName: challenge.type.icon)
                .font(.system(size: 20))
                .foregroundColor(challenge.isCompleted ? Color(hex: "#01ff00") : Color(hex: "#f0048d"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(challenge.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(challenge.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(challenge.duration) minutes")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#f0048d"))
            }
            
            Spacer()
            
            if challenge.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "#01ff00"))
            } else {
                Button("Start") {
                    selectedChallenge = challenge
                    showMindfulnessSession = true
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#f0048d"))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

struct AvailableLevelsView: View {
    @ObservedObject var gameViewModel: GameProgressViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Available Quests")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(gameViewModel.getAvailableLevels()) { level in
                        LevelCardView(level: level, gameViewModel: gameViewModel)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct LevelCardView: View {
    let level: Level
    @ObservedObject var gameViewModel: GameProgressViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(level.theme.emoji)
                .font(.system(size: 40))
            
            Text(level.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Text("Level \(level.number)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "#fbaa1a"))
            
            Spacer()
            
            CircularProgressView(
                progress: gameViewModel.getLevelProgress(level),
                color: Color(hex: level.theme.backgroundColor)
            )
            .frame(width: 30, height: 30)
        }
        .frame(width: 120, height: 140)
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(hex: level.theme.backgroundColor).opacity(0.3),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .onTapGesture {
            gameViewModel.selectLevel(level)
        }
    }
}

struct DailyChallengesView: View {
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Today's Activity")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                // Activity stats
                HStack(spacing: 15) {
                    DailyStatCard(
                        title: "Steps",
                        value: userViewModel.getTotalSteps(),
                        target: 10000,
                        icon: "figure.walk",
                        color: "#01ff00"
                    )
                    
                    DailyStatCard(
                        title: "Active Minutes",
                        value: userViewModel.getTotalActiveMinutes(),
                        target: 60,
                        icon: "timer",
                        color: "#f0048d"
                    )
                }
                
                // Mood check-in
                MoodCheckInView(userViewModel: userViewModel)
                
                // Quick activity logger
                QuickActivityLoggerView(userViewModel: userViewModel)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct DailyStatCard: View {
    let title: String
    let value: Int
    let target: Int
    let icon: String
    let color: String
    
    var progress: Double {
        return min(Double(value) / Double(target), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: color))
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Text("\(value)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text("/ \(target)")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
            
            CircularProgressView(progress: progress, color: Color(hex: color))
                .frame(width: 40, height: 40)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

struct MoodCheckInView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var showMoodSelector = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("How are you feeling?")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Update") {
                    showMoodSelector = true
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#fbaa1a"))
                .cornerRadius(8)
            }
            
            HStack {
                Text(userViewModel.activityService.currentMood.emoji)
                    .font(.system(size: 24))
                
                Text(userViewModel.activityService.currentMood.rawValue)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                if let energy = userViewModel.activityService.dailyCheckIn?.energyLevel {
                    Text(energy.emoji)
                        .font(.system(size: 20))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .sheet(isPresented: $showMoodSelector) {
            MoodSelectorView(userViewModel: userViewModel)
        }
    }
}

struct QuickActivityLoggerView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var showActivityLogger = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Quick Log Activity")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Log") {
                    showActivityLogger = true
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#01ff00"))
                .cornerRadius(8)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach([ActivityType.walking, ActivityType.cardio, ActivityType.strength, ActivityType.yoga], id: \.self) { activity in
                        QuickActivityButton(
                            activity: activity,
                            userViewModel: userViewModel
                        )
                    }
                }
                .padding(.horizontal, 5)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .sheet(isPresented: $showActivityLogger) {
            ActivityLoggerView(userViewModel: userViewModel)
        }
    }
}

struct QuickActivityButton: View {
    let activity: ActivityType
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        Button(action: {
            userViewModel.logActivity(type: activity, minutes: 15) // Quick 15-minute log
        }) {
            VStack(spacing: 4) {
                Image(systemName: activity.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text(activity.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 60, height: 50)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct MoodSelectorView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedMood: MoodLevel = .neutral
    @State private var selectedEnergy: EnergyLevel = .medium
    @State private var note = ""
    
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
                
                VStack(spacing: 30) {
                    VStack(spacing: 20) {
                        Text("How are you feeling?")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                            ForEach(MoodLevel.allCases, id: \.self) { mood in
                                Button(action: {
                                    selectedMood = mood
                                }) {
                                    VStack(spacing: 8) {
                                        Text(mood.emoji)
                                            .font(.system(size: 40))
                                        
                                        Text(mood.rawValue)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(selectedMood == mood ? .black : .white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        selectedMood == mood ? 
                                        Color(hex: mood.color) : 
                                        Color.white.opacity(0.1)
                                    )
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 20) {
                        Text("Energy Level")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            ForEach(EnergyLevel.allCases, id: \.self) { energy in
                                Button(action: {
                                    selectedEnergy = energy
                                }) {
                                    VStack(spacing: 8) {
                                        Text(energy.emoji)
                                            .font(.system(size: 32))
                                        
                                        Text(energy.rawValue)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(selectedEnergy == energy ? .black : .white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        selectedEnergy == energy ? 
                                        Color(hex: "#fbaa1a") : 
                                        Color.white.opacity(0.1)
                                    )
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Note (optional)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        TextField("How was your day?", text: $note)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Mood Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    userViewModel.updateMood(selectedMood, note: note)
                    userViewModel.activityService.updateEnergyLevel(selectedEnergy)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            selectedMood = userViewModel.activityService.currentMood
            selectedEnergy = userViewModel.activityService.dailyCheckIn?.energyLevel ?? .medium
        }
    }
}

struct ActivityLoggerView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedActivity: ActivityType = .walking
    @State private var minutes = 30
    @State private var steps = 1000
    @State private var intensity: IntensityLevel = .moderate
    
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
                
                VStack(spacing: 25) {
                    VStack(spacing: 20) {
                        Text("Log Your Activity")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Activity Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Activity Type")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                ForEach(ActivityType.allCases, id: \.self) { activity in
                                    Button(action: {
                                        selectedActivity = activity
                                    }) {
                                        HStack {
                                            Image(systemName: activity.icon)
                                                .foregroundColor(selectedActivity == activity ? .black : .white)
                                            Text(activity.rawValue)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(selectedActivity == activity ? .black : .white)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(selectedActivity == activity ? Color(hex: "#fbaa1a") : Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                        
                        // Duration/Steps Input
                        if selectedActivity == .walking {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Steps")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Button("-") {
                                        if steps > 100 { steps -= 100 }
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                                    
                                    Text("\(steps)")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                    
                                    Button("+") {
                                        steps += 100
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Duration (minutes)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Button("-") {
                                        if minutes > 5 { minutes -= 5 }
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                                    
                                    Text("\(minutes)")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                    
                                    Button("+") {
                                        minutes += 5
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                        }
                        
                        // Intensity Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Intensity")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 15) {
                                ForEach(IntensityLevel.allCases, id: \.self) { level in
                                    Button(action: {
                                        intensity = level
                                    }) {
                                        Text(level.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(intensity == level ? .black : .white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(intensity == level ? Color(hex: "#fbaa1a") : Color.white.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                    }
                    
                    Spacer()
                    
                    Button("Log Activity") {
                        if selectedActivity == .walking {
                            userViewModel.logSteps(steps)
                        } else {
                            userViewModel.logActivity(type: selectedActivity, minutes: minutes)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#01ff00"))
                    .cornerRadius(15)
                }
                .padding()
            }
            .navigationTitle("Log Activity")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
} 