//
//  OnboardingView.swift
//  HealthQuest: Mind & Body Adventure
//
//  Created by Вячеслав on 8/4/25.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var selectedFitnessLevel: FitnessLevel = .beginner
    @State private var selectedActivities: Set<ActivityType> = []
    
    private let totalPages = 4
    
    var body: some View {
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
            
            VStack {
                // Progress indicator
                HStack {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentPage ? Color(hex: "#fbaa1a") : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 40 : 20, height: 6)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal)
                
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    WelcomePageView()
                        .tag(0)
                    
                    NameInputPageView(userName: $userName)
                        .tag(1)
                    
                    FitnessLevelPageView(selectedLevel: $selectedFitnessLevel)
                        .tag(2)
                    
                    ActivitySelectionPageView(selectedActivities: $selectedActivities)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(25)
                    }
                    
                    Spacer()
                    
                    Button(currentPage == totalPages - 1 ? "Start Adventure" : "Next") {
                        if currentPage == totalPages - 1 {
                            completeOnboarding()
                        } else {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#fbaa1a"))
                    .cornerRadius(25)
                    .disabled(!canProceed())
                    .opacity(canProceed() ? 1.0 : 0.6)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
    
    private func canProceed() -> Bool {
        switch currentPage {
        case 0: return true
        case 1: return !userName.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: return true
        case 3: return !selectedActivities.isEmpty
        default: return false
        }
    }
    
    private func completeOnboarding() {
        userViewModel.updateUserProfile(
            name: userName,
            fitnessLevel: selectedFitnessLevel,
            preferredActivities: Array(selectedActivities)
        )
        userViewModel.completeOnboarding()
    }
}

struct WelcomePageView: View {
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                Text("🌟")
                    .font(.system(size: 80))
                
                Text("HealthQuest")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Mind & Body Adventure")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "#fbaa1a"))
            }
            
            VStack(spacing: 15) {
                Text("Welcome to a unique journey where fitness meets adventure!")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Text("Complete physical challenges and mindfulness exercises to progress through magical worlds.")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
        }
    }
}

struct NameInputPageView: View {
    @Binding var userName: String
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                Text("👋")
                    .font(.system(size: 60))
                
                Text("What's your name, adventurer?")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Text("We'll use this to personalize your quest")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            VStack(spacing: 15) {
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .background(Color.white)
                    .cornerRadius(10)
                
                if !userName.isEmpty {
                    Text("Nice to meet you, \(userName)! 🎉")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#01ff00"))
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

struct FitnessLevelPageView: View {
    @Binding var selectedLevel: FitnessLevel
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                Text("💪")
                    .font(.system(size: 60))
                
                Text("What's your fitness level?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("This helps us customize your challenges")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            VStack(spacing: 15) {
                ForEach(FitnessLevel.allCases, id: \.self) { level in
                    Button(action: {
                        selectedLevel = level
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(level.rawValue)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(selectedLevel == level ? .black : .white)
                            
                            Text(level.description)
                                .font(.system(size: 14))
                                .foregroundColor(selectedLevel == level ? .black.opacity(0.7) : .white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            selectedLevel == level ? 
                            Color(hex: "#fbaa1a") : 
                            Color.white.opacity(0.1)
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedLevel == level ? 
                                    Color(hex: "#fbaa1a") : 
                                    Color.white.opacity(0.3), 
                                    lineWidth: 2
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 30)
        }
    }
}

struct ActivitySelectionPageView: View {
    @Binding var selectedActivities: Set<ActivityType>
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                Text("🎯")
                    .font(.system(size: 60))
                
                Text("Choose your favorite activities")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Text("Select activities you'd like to include in your adventure")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                ForEach(ActivityType.allCases, id: \.self) { activity in
                    Button(action: {
                        if selectedActivities.contains(activity) {
                            selectedActivities.remove(activity)
                        } else {
                            selectedActivities.insert(activity)
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: activity.icon)
                                .font(.system(size: 24))
                                .foregroundColor(
                                    selectedActivities.contains(activity) ? .black : .white
                                )
                            
                            Text(activity.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(
                                    selectedActivities.contains(activity) ? .black : .white
                                )
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedActivities.contains(activity) ? 
                            Color(hex: "#fbaa1a") : 
                            Color.white.opacity(0.1)
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedActivities.contains(activity) ? 
                                    Color(hex: "#fbaa1a") : 
                                    Color.white.opacity(0.3), 
                                    lineWidth: 2
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 30)
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 