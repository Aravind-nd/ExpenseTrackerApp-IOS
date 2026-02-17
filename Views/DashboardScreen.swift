//
//  DashboardScreen.swift
//  ExpenseTracker_MVC
//
//  Created by Aravind sai Savaram on 16/02/26.
//


import SwiftUI
import CoreData

struct DashboardScreen: View {
    let controller: DashboardController
    
    @FetchRequest(
        entity: Expense.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
        animation: .default
    )
    private var expenses: FetchedResults<Expense>

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            Text("Dashboard")
                                .font(.largeTitle.weight(.semibold))
                            Spacer()
                            NavigationLink(destination: AnalyticsScreen()) {
                                Image(systemName: "chart.pie.fill")
                                    .font(.title3)
                                    .padding(10)
                                    .background(Color.blue.opacity(0.15))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal)
                        
                        // Greeting
                        Text("Hello, Aravind 👋")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        
                        // Summary Cards
                        HStack(spacing: 16) {
                            SummaryCard(title: "Today", value: String(format: "$%.2f", controller.todayTotal()))
                            SummaryCard(title: "This Month", value: String(format: "$%.2f", controller.monthTotal()))
                        }
                        .padding(.horizontal)
                        
                        // Recent Expenses
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Expenses")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if expenses.isEmpty {
                                Text("No expenses yet.")
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
                            } else {
                                ForEach(expenses.prefix(5)) { expense in
                                    ExpenseRow(expense: expense)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        Spacer(minLength: 80)
                    }
                    .padding(.top)
                }
                .background(Color(.systemGroupedBackground))
                
                // Bottom Buttons
                HStack(spacing: 20) {
                    DashboardButton(system: "house.fill", text: "Dashboard", color: .blue.opacity(0.2))
                    
                    // Fixed NavigationLink
                    NavigationLink(destination: ExpenseListScreen(context: controller.context)) {
                        DashboardButton(system: "list.bullet", text: "Expense List", color: .green.opacity(0.2))
                    }
                    
                    NavigationLink(destination: AddExpenseScreen(context: controller.context)) {
                        DashboardButton(system: "plus.circle.fill", text: "Add Expense", color: .orange.opacity(0.2))
                    }
                }
                .padding()
                .background(Color(.systemBackground).shadow(radius: 2))
            }
        }
    }

    // MARK: - Components
    struct SummaryCard: View {
        let title: String
        let value: String
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.title3.weight(.bold))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 4))
        }
    }

    struct ExpenseRow: View {
        @ObservedObject var expense: Expense
        var body: some View {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(Image(systemName: expense.symbolName ?? "creditcard.fill").foregroundStyle(Color.blue))
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.note ?? "No note").font(.subheadline.weight(.semibold))
                    Text(expense.category ?? "Other").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text(expense.amount, format: .currency(code: "USD")).font(.subheadline.weight(.semibold))
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        }
    }

    struct DashboardButton: View {
        let system: String
        let text: String
        let color: Color
        var body: some View {
            VStack {
                Image(systemName: system).font(.title2)
                Text(text).font(.caption)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let controller = DashboardController(context: context)
    
    DashboardScreen(controller: controller)
        .environment(\.managedObjectContext, context)
}
