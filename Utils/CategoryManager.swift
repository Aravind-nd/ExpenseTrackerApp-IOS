//
//  CategoryManager.swift
//  ExpenseTracker_MVC
//
//  Created by Aravind sai Savaram on 17/02/26.
//

import SwiftUI
import Combine
import CoreData

@MainActor
final class CategoryManager: ObservableObject {
    
    static let shared = CategoryManager() // singleton, optional

    // Default categories never removed
    let defaultCategories = ["Food", "Transport", "Shopping", "Bills", "Entertainment", "Health", "Other"]

    // Dynamic categories added by user
    @Published private(set) var dynamicCategories: [String] = []

    // Category colors
    @Published private(set) var categoryColors: [String: Color] = [
        "Food": .orange,
        "Transport": .blue,
        "Shopping": .pink,
        "Bills": .green,
        "Entertainment": .purple,
        "Health": .red,
        "Other": .gray
    ]

    // Combined list
    var currentCategories: [String] {
        defaultCategories + dynamicCategories
    }

    private init() {}

    // Call this whenever expenses are added, edited, or deleted
    func updateDynamicCategories(from expenses: [Expense]) {
        let expenseCategories = Set(expenses.compactMap { $0.category })
        let dynamic = expenseCategories.subtracting(defaultCategories)
        dynamicCategories = Array(dynamic).sorted()
    }

    // Return color for a category (default or dynamic)
    func color(for category: String) -> Color {
        if let existingColor = categoryColors[category] {
            return existingColor
        } else {
            let newColor = Color(
                red: Double.random(in: 0.3...0.9),
                green: Double.random(in: 0.3...0.9),
                blue: Double.random(in: 0.3...0.9)
            )
            categoryColors[category] = newColor
            return newColor
        }
    }

    // Add a new dynamic category manually (e.g., from AddExpenseScreen)
    func addCategory(_ name: String) {
        guard !name.isEmpty,
              !defaultCategories.contains(name),
              !dynamicCategories.contains(name)
        else { return }
        dynamicCategories.append(name)
        _ = color(for: name) // assign a color automatically
    }
}
