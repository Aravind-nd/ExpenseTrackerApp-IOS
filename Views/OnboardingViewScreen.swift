//
//  OnboardingViewScreen.swift
//  ExpenseTracker_MVC
//
//  Created by Aravind sai Savaram on 16/02/26.
//

import SwiftUI

struct OnboardingViewScreen: View {
    
    @ObservedObject var controller: OnboardingController
    
    var body: some View {
        ZStack {
            if controller.currentPage == 0 {
                OnboardingPage1(controller: controller)
            } else {
                OnboardingPage2(controller: controller)
            }
        }
        .overlay(
            HStack(spacing: 8) {
                Circle()
                    .fill(controller.currentPage == 0 ? Color.yellow : Color.gray.opacity(0.5))
                    .frame(width: 10, height: 10)
                
                Circle()
                    .fill(controller.currentPage == 1 ? Color.yellow : Color.gray.opacity(0.5))
                    .frame(width: 10, height: 10)
            }
            .padding(.bottom, 20),
            alignment: .bottom
        )
        .animation(.easeInOut, value: controller.currentPage)
    }
}

//
// MARK: - Page 1
//

struct OnboardingPage1: View {
    
    @ObservedObject var controller: OnboardingController
    
    var body: some View {
        ZStack {
            Image("background2")
                .resizable()
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 5) {
                Text("Welcome to")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                
                Text("Expense Tracker")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 32)
            
            Image("logo2")
                .resizable()
                .scaledToFit()
                .frame(height: 600)
                .padding(.bottom, 150)
            
            VStack(spacing: 20) {
                
                VStack(spacing: 12) {
                    
                    FeatureRow(icon: "checkmark.circle.fill", text: "Track your Spending")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Categorise Expenses")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Gain Insights")
                    
                }
                .frame(maxWidth: 420)
                
                Button {
                    controller.nextPage()
                } label: {
                    PrimaryButton(title: "Get Started")
                }
                
                Button {
                    controller.skip()
                } label: {
                    PrimaryButton(title: "Skip")
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 75)
            .padding(.horizontal, 70)
        }
    }
}

//
// MARK: - Page 2
//

struct OnboardingPage2: View {
    
    @ObservedObject var controller: OnboardingController
    
    var body: some View {
        ZStack {
            Image("background2")
                .resizable()
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 5) {
                Text("Insights & Reports")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                
                Text("Understand your spending habits")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.9))
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 32)
            
            Image("logo2")
                .resizable()
                .scaledToFit()
                .frame(height: 500)
                .padding(.bottom, 150)
            
            VStack(spacing: 20) {
                
                VStack(spacing: 12) {
                    
                    FeatureRow(icon: "chart.pie.fill", text: "View Spending by Category")
                    FeatureRow(icon: "calendar", text: "Analyze Daily & Monthly Trends")
                    FeatureRow(icon: "lightbulb.fill", text: "Get Tips to Save Money")
                    
                }
                .frame(maxWidth: 420)
                
                Button {
                    controller.finish()
                } label: {
                    PrimaryButton(title: "Next")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 75)
            .padding(.horizontal, 70)
        }
    }
}

//
// MARK: - Reusable Components
//

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.title)
                .frame(width: 28)
            
            Text(text)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PrimaryButton: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 50)
            .padding(.vertical, 12)
            .background(Color.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: 200)
    }
}
