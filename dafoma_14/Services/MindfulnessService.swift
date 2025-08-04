//
//  MindfulnessService.swift
//  HealthQuest: Mind & Body Adventure
//
//  Created by Вячеслав on 8/4/25.
//

import Foundation
import Combine

@MainActor
class MindfulnessService: ObservableObject {
    @Published var currentSession: MindfulnessSession?
    @Published var isSessionActive = false
    @Published var sessionTimeRemaining: Int = 0
    
    private var sessionTimer: Timer?
    
    func startMindfulnessSession(challenge: MindfulnessChallenge) {
        currentSession = MindfulnessSession(
            challenge: challenge,
            startTime: Date(),
            duration: challenge.duration * 60 // Convert minutes to seconds
        )
        sessionTimeRemaining = challenge.duration * 60
        isSessionActive = true
        
        startTimer()
    }
    
    func pauseSession() {
        sessionTimer?.invalidate()
        isSessionActive = false
    }
    
    func resumeSession() {
        guard currentSession != nil else { return }
        isSessionActive = true
        startTimer()
    }
    
    func endSession() {
        sessionTimer?.invalidate()
        currentSession = nil
        isSessionActive = false
        sessionTimeRemaining = 0
    }
    
    private func startTimer() {
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                if self.sessionTimeRemaining > 0 {
                    self.sessionTimeRemaining -= 1
                } else {
                    self.completeSession()
                }
            }
        }
    }
    
    private func completeSession() {
        sessionTimer?.invalidate()
        isSessionActive = false
        
        if let session = currentSession {
            // Mark session as completed
            session.isCompleted = true
        }
        
        // Reset state after a brief delay to show completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.currentSession = nil
            self.sessionTimeRemaining = 0
        }
    }
    
    func getGuidanceText(for type: MindfulnessType, phase: SessionPhase) -> String {
        switch type {
        case .breathing:
            return getBreathingGuidance(phase: phase)
        case .meditation:
            return getMeditationGuidance(phase: phase)
        case .gratitude:
            return getGratitudeGuidance(phase: phase)
        case .visualization:
            return getVisualizationGuidance(phase: phase)
        }
    }
    
    private func getBreathingGuidance(phase: SessionPhase) -> String {
        switch phase {
        case .beginning:
            return "Find a comfortable position and close your eyes. We'll start with deep, calming breaths."
        case .middle:
            return "Breathe in slowly for 4 counts... hold for 4... exhale for 6. Let your body relax with each breath."
        case .end:
            return "Take three final deep breaths. Notice how calm and centered you feel. Slowly open your eyes."
        }
    }
    
    private func getMeditationGuidance(phase: SessionPhase) -> String {
        switch phase {
        case .beginning:
            return "Sit comfortably with your spine straight. Close your eyes and begin to notice your natural breath."
        case .middle:
            return "If thoughts arise, acknowledge them gently and return your focus to your breath. There's no need to judge or change anything."
        case .end:
            return "Gradually bring your awareness back to your surroundings. Wiggle your fingers and toes before opening your eyes."
        }
    }
    
    private func getGratitudeGuidance(phase: SessionPhase) -> String {
        switch phase {
        case .beginning:
            return "Take a moment to settle in. Think of something you're grateful for today, no matter how small."
        case .middle:
            return "Bring to mind three things you appreciate in your life. Feel the warmth and joy these thoughts bring."
        case .end:
            return "Hold onto these feelings of gratitude. Let them fill your heart as you return to your day."
        }
    }
    
    private func getVisualizationGuidance(phase: SessionPhase) -> String {
        switch phase {
        case .beginning:
            return "Close your eyes and imagine a peaceful place where you feel completely safe and relaxed."
        case .middle:
            return "Explore this peaceful space with all your senses. What do you see, hear, feel, and smell? Make it as vivid as possible."
        case .end:
            return "Know that you can return to this peaceful place anytime you need it. Take a deep breath and slowly open your eyes."
        }
    }
    
    func getBreathingPattern(for timeRemaining: Int) -> BreathingPhase {
        let cycleLength = 14 // 4 in + 4 hold + 6 out
        let cyclePosition = timeRemaining % cycleLength
        
        if cyclePosition >= 10 {
            return .inhale
        } else if cyclePosition >= 6 {
            return .hold
        } else {
            return .exhale
        }
    }
}

class MindfulnessSession: ObservableObject {
    let challenge: MindfulnessChallenge
    let startTime: Date
    let duration: Int
    @Published var isCompleted = false
    
    init(challenge: MindfulnessChallenge, startTime: Date, duration: Int) {
        self.challenge = challenge
        self.startTime = startTime
        self.duration = duration
    }
}

enum SessionPhase {
    case beginning
    case middle
    case end
}

enum BreathingPhase {
    case inhale
    case hold
    case exhale
} 