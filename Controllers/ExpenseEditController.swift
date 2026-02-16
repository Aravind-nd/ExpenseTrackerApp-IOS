//
//  ExpenseEditController.swift
//  ExpenseTracker_MVC
//
//  Created by Aravind sai Savaram on 16/02/26.
//

import SwiftUI
import Combine
import CoreData

@MainActor
final class ExpenseController: ObservableObject {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Save changes to an existing expense
    func saveExpense(_ expense: Expense, amount: Double, category: String, date: Date, paymentMethod: String, note: String) throws {
        guard amount > 0 else { return }
        expense.amount = amount
        expense.category = category
        expense.date = date
        expense.paymentMethod = paymentMethod
        expense.note = note
        expense.symbolName = symbolForCategory(category)
        
        try context.save()
    }
    
    // Delete expense
    func deleteExpense(_ expense: Expense) throws {
        context.delete(expense)
        try context.save()
    }
    
    // Symbol mapping
    func symbolForCategory(_ category: String) -> String {
        switch category {
        case "Food": return "fork.knife"
        case "Transport": return "car.fill"
        case "Shopping": return "bag.fill"
        case "Bills": return "bolt.fill"
        case "Entertainment": return "film.fill"
        case "Health": return "cross.case.fill"
        default: return "creditcard.fill"
        }
    }
}
