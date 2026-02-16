//
//  DashboardController.swift
//  ExpenseTracker_MVC
//
//  Created by Aravind sai Savaram on 16/02/26.
//

import SwiftUI
import CoreData
import Combine

@MainActor
final class DashboardController: ObservableObject {
    
    private let context: NSManagedObjectContext
    
    @Published var expenses: [Expense] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchExpenses()
    }
    
    func fetchExpenses() {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]
        
        do {
            expenses = try context.fetch(request)
        } catch {
            print("Failed to fetch expenses: \(error.localizedDescription)")
        }
    }
    
    func todayTotal() -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        return expenses
            .filter { $0.date ?? Date() >= today }
            .reduce(0) { $0 + $1.amount }
    }
    
    func monthTotal() -> Double {
        let startOfMonth = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: Date())
        )!
        return expenses
            .filter { $0.date ?? Date() >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }
}
