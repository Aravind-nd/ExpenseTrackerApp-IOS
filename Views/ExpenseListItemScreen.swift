//
//  ExpenseListItemScreen.swift
//  ExpenseTracker_MVC
//

//
//  ExpenseListItemScreen.swift
//  ExpenseTracker_MVC
//

//
//  ExpenseListItemScreen.swift
//  ExpenseTracker_MVC
//

import SwiftUI
import CoreData

struct ExpenseListItemScreen: View {
    @StateObject private var controller: ExpenseListItemController
    @Environment(\.managedObjectContext) private var viewContext

    init(context: NSManagedObjectContext, category: String) {
        _controller = StateObject(wrappedValue: ExpenseListItemController(context: context, category: category))
    }

    var body: some View {
        VStack(spacing: 16) {

            // Sort controls
            HStack {
                Picker("Sort by", selection: $controller.sortKey) {
                    ForEach(ExpenseListItemController.SortKey.allCases) { key in
                        Text(key.rawValue).tag(key)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: controller.sortKey) { _ in
                    controller.fetchExpenses()
                }

                Spacer()

                Toggle(isOn: $controller.isAscending) {
                    Text(controller.isAscending ? "Ascending" : "Descending")
                        .font(.subheadline)
                }
                .toggleStyle(.switch)
                .frame(width: 140)
                .onChange(of: controller.isAscending) { _ in
                    controller.fetchExpenses()
                }
            }
            .padding(.horizontal)

            // Expense list
            ScrollView {
                LazyVStack(spacing: 12) {
                    if controller.expenses.isEmpty {
                        Text("No expenses in \(controller.expenses.first?.category ?? controller.expenses.first?.category ?? "this category")")
                            .foregroundStyle(.secondary)
                            .padding(.top, 40)
                    }

                    ForEach(controller.expenses) { expense in
                        NavigationLink(
                            destination: EditExpenseScreen(expense: expense, listController: controller)
                        ) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: expense.symbolName ?? "creditcard.fill")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 24))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(expense.note ?? "No note")
                                        .font(.headline)
                                    if let date = expense.date {
                                        Text(date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }

                                Spacer()

                                Text(expense.amount, format: .currency(code: "USD"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemGray6))
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .swipeActions {
                            Button(role: .destructive) {
                                controller.deleteExpense(expense)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(controller.expenses.first?.category ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    NavigationStack {
        ExpenseListItemScreen(context: context, category: "Food")
            .environment(\.managedObjectContext, context)
    }
}
