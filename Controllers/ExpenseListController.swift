////
////  ExpenseListController.swift
////  ExpenseTracker_MVC
////
////  Created by Aravind sai Savaram on 16/02/26.

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

        // Observe Core Data changes
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
                // Update the list on the main thread
                Task { @MainActor in
                    fetchExpenses()
                }
                break
            }
        }
    }

    func fetchExpenses() {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.predicate = nil  // fetch all, or you can filter by category if needed

        // Sorting
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

    // MARK: - Actions

    func deleteExpense(_ expense: Expense) {
        context.delete(expense)
        saveContext()
    }

    func saveContext() {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }

    func toggleSortOrder() {
        // isAscending is updated from the toggle binding
        fetchExpenses()
    }

    func changeSortKey(_ key: SortKey) {
        sortKey = key
        fetchExpenses()
    }
}
