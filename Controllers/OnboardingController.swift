//
//  OnboardingController.swift
//  ExpenseTracker_MVC
//
//  Created by Aravind sai Savaram on 16/02/26.
//

import Foundation
import SwiftUI
import CoreData
import Combine

@MainActor
final class OnboardingController: ObservableObject {
    
    // MARK: - Persistent State
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    // MARK: - Page State
    @Published var currentPage: Int = 0
    
    // MARK: - Navigation Logic
    func nextPage() {
        if currentPage < 1 {
            currentPage += 1
        }
    }
    
    func skip() {
        hasSeenOnboarding = true
    }
    
    func finish() {
        hasSeenOnboarding = true
    }
}
