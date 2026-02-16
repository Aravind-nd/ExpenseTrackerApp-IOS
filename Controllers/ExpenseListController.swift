//
//  ExpenseListController.swift
//  ExpenseTracker_MVC
//
//  Created by Aravind sai Savaram on 16/02/26.
//

import Foundation
import CoreData
import SwiftUI
import Combine

@MainActor
final class ExpenseListController: ObservableObject {
    @Published var expenses: [Expense] = []

    private let context: NSManagedObjectContext

    @Published var sortKey: SortKey = .date
    @Published var isAscending: Bool = false

    enum SortKey: String, CaseIterable, Identifiable {
        case amount = "Amount"
        case date = "Date"
        var id: String { rawValue }
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchExpenses()

        // Optional: automatically update on context changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextObjectsDidChange),
            name: .NSManagedObjectContextObjectsDidChange,
            object: context
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func contextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let relevantKeys = [NSInsertedObjectsKey, NSUpdatedObjectsKey, NSDeletedObjectsKey]
        for key in relevantKeys {
            if let objects = userInfo[key] as? Set<NSManagedObject>,
               objects.contains(where: { $0 is Expense }) {
                fetchExpenses()
                break
            }
        }
    }

    func fetchExpenses() {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()

        // Sort dynamically based on sortKey and isAscending
        switch sortKey {
        case .amount:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.amount, ascending: isAscending)]
        case .date:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: isAscending)]
        }

        do {
            expenses = try context.fetch(request)
        } catch {
            print("Failed to fetch expenses: \(error.localizedDescription)")
            expenses = []
        }
    }

    func deleteExpense(_ expense: Expense) {
        context.delete(expense)
        do {
            try context.save()
            // fetchExpenses() optional because context observer will handle it
        } catch {
            print("Failed to delete expense: \(error.localizedDescription)")
        }
    }

    func toggleSortOrder() {
        isAscending.toggle()
        fetchExpenses()
    }

    func changeSortKey(_ key: SortKey) {
        sortKey = key
        fetchExpenses()
    }
}
