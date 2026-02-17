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
    let context = PersistenceController.shared.container.viewContext
    private let dashboardController =  DashboardController(context: PersistenceController.shared.container.viewContext)


    var body: some View {
        if onboardingController.hasSeenOnboarding {
           
            DashboardScreen(controller:dashboardController)
        } else {
            OnboardingViewScreen(controller: onboardingController)
        }
    }
}
#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
