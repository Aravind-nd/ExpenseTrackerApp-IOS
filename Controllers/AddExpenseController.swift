//
//  AddExpenseController.swift
//  ET
//

import SwiftUI
import Foundation
import CoreData
import Combine

@MainActor
final class AddExpenseController: ObservableObject {
    
    private let context: NSManagedObjectContext
    @Published var didSaveExpense: Bool = false
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Business Logic
    
    func symbolForCategory(_ category: String) -> String {
        switch category {
        case "Food":
            return "fork.knife"
        case "Transport":
            return "car.fill"
        case "Shopping":
            return "bag.fill"
        case "Bills":
            return "bolt.fill"
        case "Entertainment":
            return "film.fill"
        case "Other":
            return "questionmark.circle.fill"
        default:
            return "creditcard.fill"
        }
    }
    
    func saveExpense(
        amount: Double,
        category: String,
        date: Date,
        paymentMethod: String,
        note: String
    ) throws {
        
        guard amount > 0 else { return }
        guard category != "Select Category" else { return }
        
        let newExpense = Expense(context: context)
        newExpense.amount = amount
        newExpense.category = category
        newExpense.date = date
        newExpense.paymentMethod = paymentMethod
        newExpense.note = note
        newExpense.symbolName = symbolForCategory(category)
        
        try context.save()
        didSaveExpense = true
    }
}

