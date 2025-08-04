//
//  ContentView.swift
//  HealthQuest: Mind & Body Adventure
//
//  Created by Вячеслав on 8/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var gameViewModel = GameProgressViewModel()
    
    var body: some View {
        Group {
            if userViewModel.showOnboarding {
                OnboardingView(userViewModel: userViewModel)
            } else {
                MainTabView(userViewModel: userViewModel, gameViewModel: gameViewModel)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var gameViewModel: GameProgressViewModel
    
    var body: some View {
        TabView {
            AdventureGameView(gameViewModel: gameViewModel, userViewModel: userViewModel)
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("Adventure")
                }
            
            ProfileView(userViewModel: userViewModel, gameViewModel: gameViewModel)
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
        }
        .accentColor(Color(hex: "#fbaa1a"))
    }
}

#Preview {
    ContentView()
}
