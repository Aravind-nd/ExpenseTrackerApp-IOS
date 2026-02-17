//
//  ExpenseListScreen.swift
//  ExpenseTracker_MVC
//
//  Created by Aravind sai Savaram on 16/02/26.
//

import SwiftUI
import CoreData
import Combine

struct ExpenseListScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var controller: ExpenseListController
    @ObservedObject private var categoryManager = CategoryManager.shared

    init(context: NSManagedObjectContext) {
        _controller = StateObject(wrappedValue: ExpenseListController(context: context))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Header
                HStack {
                    Text("Expense List")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.leading)
                    Spacer()
                }
                .frame(height: 50)
                .background(Color.blue)

                // Categories scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categoryManager.currentCategories, id: \.self) { category in
                            // Only show categories that have expenses OR are default
                            let hasExpenses = controller.expenses.contains { $0.category == category }
                            if hasExpenses || categoryManager.defaultCategories.contains(category) {
                                NavigationLink(
                                    destination: ExpenseListItemScreen(context: viewContext, category: category)
                                ) {
                                    Text(category)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(categoryManager.color(for: category))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                // Sort controls
                HStack {
                    Picker("Sort by", selection: $controller.sortKey) {
                        ForEach(ExpenseListController.SortKey.allCases) { key in
                            Text(key.rawValue).tag(key)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 220)
                    .onChange(of: controller.sortKey) { newValue in
                        controller.changeSortKey(newValue)
                    }

                    Spacer()

                    Toggle(isOn: $controller.isAscending) {
                        Text(controller.isAscending ? "Ascending" : "Descending")
                            .font(.subheadline)
                    }
                    .toggleStyle(.switch)
                    .frame(width: 140)
                    .onChange(of: controller.isAscending) { _ in
                        controller.toggleSortOrder()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5)

                // Expense list
                if controller.expenses.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Currently no expenses added.")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Add a new expense to get started.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemGroupedBackground))
                } else {
                    List {
                        ForEach(controller.expenses) { expense in
                            NavigationLink(
                                destination: EditExpenseScreen(expense: expense, listController: controller)
                            ) {
                                HStack {
                                    HStack(spacing: 10) {
                                        Image(systemName: expense.symbolName ?? "creditcard.fill")
                                            .foregroundColor(categoryManager.color(for: expense.category ?? "Other"))
                                        Text(expense.note ?? "No note")
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(expense.amount, format: .currency(code: "USD"))
                                            .fontWeight(.semibold)
                                        if let date = expense.date {
                                            Text(date, style: .date)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete { indices in
                            indices.map { controller.expenses[$0] }.forEach(controller.deleteExpense)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .onAppear {
            // Update dynamic categories whenever this screen appears
            categoryManager.updateDynamicCategories(from: controller.expenses)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    ExpenseListScreen(context: context)
        .environment(\.managedObjectContext, context)
}
