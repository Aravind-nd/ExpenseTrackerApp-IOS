//
//  ContentView.swift
//  ExpenseTracker_MVC
//
//  Created by Aravind sai Savaram on 16/02/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
   
    @StateObject private var onboardingController = OnboardingController()

    var body: some View {
        if onboardingController.hasSeenOnboarding {
            DashboardScreen()
        } else {
            OnboardingViewScreen(controller: onboardingController)
        }
    }
}
#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
