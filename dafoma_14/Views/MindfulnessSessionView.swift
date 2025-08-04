//
//  MindfulnessSessionView.swift
//  HealthQuest: Mind & Body Adventure
//
//  Created by Вячеслав on 8/4/25.
//

import SwiftUI

struct MindfulnessSessionView: View {
    let challenge: MindfulnessChallenge
    @ObservedObject var mindfulnessService: MindfulnessService
    @ObservedObject var gameViewModel: GameProgressViewModel
    @ObservedObject var userViewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient based on mindfulness type
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    if let session = mindfulnessService.currentSession {
                        // Active session view
                        ActiveSessionView(
                            session: session,
                            mindfulnessService: mindfulnessService,
                            gameViewModel: gameViewModel,
                            userViewModel: userViewModel
                        )
                    } else {
                        // Pre-session setup
                        PreSessionView(
                            challenge: challenge,
                            mindfulnessService: mindfulnessService
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(challenge.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    mindfulnessService.endSession()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onDisappear {
            if mindfulnessService.currentSession?.isCompleted == true {
                // Mark challenge as completed when session is finished
                if let currentLevel = gameViewModel.currentLevel {
                    gameViewModel.completeMindfulnessChallenge(challenge.id, in: currentLevel.number)
                    userViewModel.addExperience(75) // Mindfulness gives more XP
                }
            }
        }
    }
    
    private var gradientColors: [Color] {
        switch challenge.type {
        case .breathing:
            return [Color(hex: "#2490ad"), Color(hex: "#1a2962")]
        case .meditation:
            return [Color(hex: "#3c166d"), Color(hex: "#1a2962")]
        case .gratitude:
            return [Color(hex: "#fbaa1a").opacity(0.7), Color(hex: "#f0048d").opacity(0.7)]
        case .visualization:
            return [Color(hex: "#01ff00").opacity(0.6), Color(hex: "#2490ad")]
        }
    }
}

struct PreSessionView: View {
    let challenge: MindfulnessChallenge
    @ObservedObject var mindfulnessService: MindfulnessService
    
    var body: some View {
        VStack(spacing: 30) {
            // Challenge icon and info
            VStack(spacing: 20) {
                Image(systemName: challenge.type.icon)
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text(challenge.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(challenge.description)
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(Color(hex: "#fbaa1a"))
                    Text("\(challenge.duration) minutes")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#fbaa1a"))
                }
            }
            
            // Preparation instructions
            VStack(alignment: .leading, spacing: 15) {
                Text("Preparation:")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 10) {
                    PreparationStep(text: "Find a quiet, comfortable space")
                    PreparationStep(text: "Sit or lie down comfortably")
                    PreparationStep(text: "Put your device on silent mode")
                    PreparationStep(text: "Take a few deep breaths to settle in")
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            
            Spacer()
            
            // Start button
            Button("Begin Session") {
                mindfulnessService.startMindfulnessSession(challenge: challenge)
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "#01ff00"))
            .cornerRadius(15)
        }
    }
}

struct PreparationStep: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "#01ff00"))
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white)
        }
    }
}

struct ActiveSessionView: View {
    @ObservedObject var session: MindfulnessSession
    @ObservedObject var mindfulnessService: MindfulnessService
    @ObservedObject var gameViewModel: GameProgressViewModel
    @ObservedObject var userViewModel: UserViewModel
    
    var timeRemaining: String {
        let minutes = mindfulnessService.sessionTimeRemaining / 60
        let seconds = mindfulnessService.sessionTimeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var currentPhase: SessionPhase {
        let totalTime = session.duration
        let remaining = mindfulnessService.sessionTimeRemaining
        let elapsed = totalTime - remaining
        
        if elapsed < totalTime * 1 {
            return .beginning
        } else if elapsed > totalTime * 1 {
            return .end
        } else {
            return .middle
        }
    }
    
    var body: some View {
        VStack(spacing: 40) {
            if session.isCompleted {
                // Session completed view
                SessionCompletedView(
                    challenge: session.challenge,
                    gameViewModel: gameViewModel,
                    userViewModel: userViewModel
                )
            } else {
                // Active session UI
                VStack(spacing: 30) {
                    // Timer display
                    VStack(spacing: 10) {
                        Text(timeRemaining)
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text("remaining")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Circular progress
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 8)
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .trim(from: 0, to: 1 - (Double(mindfulnessService.sessionTimeRemaining) / Double(session.duration)))
                            .stroke(Color(hex: "#01ff00"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                        
                        // Breathing animation for breathing exercises
                        if session.challenge.type == .breathing {
                            BreathingAnimationView(mindfulnessService: mindfulnessService)
                        } else {
                            Image(systemName: session.challenge.type.icon)
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Guidance text
                    Text(mindfulnessService.getGuidanceText(for: session.challenge.type, phase: currentPhase))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .lineLimit(nil)
                    
                    Spacer()
                    
                    // Control buttons
                    HStack(spacing: 30) {
                        Button(action: {
                            mindfulnessService.endSession()
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("End")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            if mindfulnessService.isSessionActive {
                                mindfulnessService.pauseSession()
                            } else {
                                mindfulnessService.resumeSession()
                            }
                        }) {
                            HStack {
                                Image(systemName: mindfulnessService.isSessionActive ? "pause.fill" : "play.fill")
                                Text(mindfulnessService.isSessionActive ? "Pause" : "Resume")
                            }
                            .foregroundColor(.black)
                            .padding()
                            .background(Color(hex: "#fbaa1a"))
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}

struct BreathingAnimationView: View {
    @ObservedObject var mindfulnessService: MindfulnessService
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#01ff00").opacity(0.6), Color.clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(scale)
                .animation(.easeInOut(duration: breathingDuration), value: scale)
            
            Text(breathingPhaseText)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateBreathingAnimation()
        }
    }
    
    private var breathingPhase: BreathingPhase {
        return mindfulnessService.getBreathingPattern(for: mindfulnessService.sessionTimeRemaining)
    }
    
    private var breathingPhaseText: String {
        switch breathingPhase {
        case .inhale: return "Breathe In"
        case .hold: return "Hold"
        case .exhale: return "Breathe Out"
        }
    }
    
    private var breathingDuration: Double {
        switch breathingPhase {
        case .inhale: return 4.0
        case .hold: return 4.0
        case .exhale: return 6.0
        }
    }
    
    private func updateBreathingAnimation() {
        switch breathingPhase {
        case .inhale:
            scale = 1.3
        case .hold:
            // Keep current scale
            break
        case .exhale:
            scale = 0.8
        }
    }
}

struct SessionCompletedView: View {
    let challenge: MindfulnessChallenge
    @ObservedObject var gameViewModel: GameProgressViewModel
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            // Success animation
            VStack(spacing: 20) {
                Text("✨")
                    .font(.system(size: 80))
                
                Text("Session Complete!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Great job completing your \(challenge.type.rawValue.lowercased()) session!")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            
            // Rewards earned
            VStack(spacing: 15) {
                Text("Rewards Earned:")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(spacing: 10) {
                    RewardRow(icon: "star.fill", text: "+75 XP", color: "#fbaa1a")
                    RewardRow(icon: "checkmark.circle.fill", text: "Challenge Completed", color: "#01ff00")
                    RewardRow(icon: "brain.head.profile", text: "Mindfulness Progress", color: "#f0048d")
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            
            Text("Take a moment to notice how you feel right now.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct RewardRow: View {
    let icon: String
    let text: String
    let color: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: color))
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal)
    }
} 
