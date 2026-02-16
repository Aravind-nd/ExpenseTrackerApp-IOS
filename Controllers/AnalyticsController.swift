//
//  AnalyticsController.swift
//  ExpenseTracker_MVC
//
//  Created by Aravind sai Savaram on 16/02/26.
//

import SwiftUI
import CoreData
import Combine

@MainActor
final class AnalyticsController: ObservableObject {
    
    private let context: NSManagedObjectContext
    private let calendar = Calendar.current
    
    @Published var expenses: [Expense] = []
    @Published var selectedMonth: Date = Date()
    
    // Colors for categories
    let categoryColors: [String: Color] = [
        "Food": .orange,
        "Transport": .blue,
        "Shopping": .pink,
        "Bills": .green,
        "Entertainment": .purple,
        "Health": .red,
        "Other": .gray
    ]
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchExpenses()
    }
    
    func fetchExpenses() {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: true)]
        
        do {
            expenses = try context.fetch(request)
        } catch {
            print("Failed to fetch expenses: \(error.localizedDescription)")
        }
    }
    
    // Filter expenses by selected month
    var filteredExpenses: [Expense] {
        expenses.filter {
            guard let date = $0.date else { return false }
            return calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month)
        }
    }
    
    // MARK: - Pie Chart Data
    var categoryData: [CategorySpending] {
        let grouped = Dictionary(grouping: filteredExpenses) { $0.category ?? "Other" }
        return grouped.map { key, values in
            CategorySpending(
                category: key,
                amount: values.reduce(0) { $0 + $1.amount },
                color: categoryColors[key] ?? .gray
            )
        }
    }
    
    // MARK: - Daily Line Chart Data
    var dailyData: [DailySpending] {
        var dict: [Date: Double] = [:]
        for expense in filteredExpenses {
            guard let date = expense.date else { continue }
            let dayStart = calendar.startOfDay(for: date)
            dict[dayStart, default: 0] += expense.amount
        }
        return dict.map { DailySpending(date: $0.key, amount: $0.value) }
            .sorted { $0.date < $1.date }
    }
}
