//
//  AnalyticsScreen.swift
//  ExpenseTracker_MVC
//
//  Created by Aravind sai Savaram on 16/02/26.
//

import SwiftUI
import Charts
import CoreData

struct CategorySpending: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let color: Color
}

struct DailySpending: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}
// MARK: - Analytics Card
struct AnalyticsCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
        .padding(.horizontal)
    }
}

// MARK: - Daily Line Chart
struct DailySpendingLineChart: View {
    let data: [DailySpending]

    var body: some View {
        Chart(data) { item in
            LineMark(
                x: .value("Date", item.date),
                y: .value("Amount", item.amount)
            )
            .foregroundStyle(.blue)

            PointMark(
                x: .value("Date", item.date),
                y: .value("Amount", item.amount)
            )
            .foregroundStyle(.blue)
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.day())
            }
        }
    }
}

// MARK: - Summary Section
struct SpendingSummary: View {
    let categories: [CategorySpending]
    let daily: [DailySpending]

    private var topCategory: CategorySpending? {
        categories.max(by: { $0.amount < $1.amount })
    }

    private var avgDaily: Double {
        daily.isEmpty ? 0 : daily.reduce(0) { $0 + $1.amount } / Double(daily.count)
    }

    private var total: Double {
        daily.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SummaryTile(
                    title: "Top Category",
                    value: topCategory?.category ?? "-",
                    icon: "crown.fill",
                    color: .orange
                )

                SummaryTile(
                    title: "Avg / Day",
                    value: avgDaily.formatted(.currency(code: "USD")),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
            }

            SummaryTile(
                title: "Total Spending",
                value: total.formatted(.currency(code: "USD")),
                icon: "creditcard.fill",
                color: .green
            )
        }
    }
}

// MARK: - Summary Tile
struct SummaryTile: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
struct AnalyticsScreen: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: true)]
    ) private var expenses: FetchedResults<Expense>

    @State private var selectedMonth: Date = Date()
    private let calendar = Calendar.current

    private let categoryColors: [String: Color] = [
        "Food": .orange,
        "Transport": .blue,
        "Shopping": .pink,
        "Bills": .green,
        "Entertainment": .purple,
        "Health": .red,
        "Other": .gray
    ]

    private var filteredExpenses: [Expense] {
        expenses.filter {
            guard let date = $0.date else { return false }
            return calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month)
        }
    }

    private var categoryData: [CategorySpending] {
        let grouped = Dictionary(grouping: filteredExpenses) { $0.category ?? "Other" }
        return grouped.map { key, values in
            CategorySpending(
                category: key,
                amount: values.reduce(0) { $0 + $1.amount },
                color: categoryColors[key] ?? .gray
            )
        }
    }

    private var dailyData: [DailySpending] {
        var dict: [Date: Double] = [:]
        for expense in filteredExpenses {
            guard let date = expense.date else { continue }
            let dayStart = calendar.startOfDay(for: date)
            dict[dayStart, default: 0] += expense.amount
        }
        return dict.map { DailySpending(date: $0.key, amount: $0.value) }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Month Picker
                HStack {
                    Text("Analytics for:")
                        .font(.headline)
                    DatePicker(
                        "",
                        selection: $selectedMonth,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                }
                .padding(.horizontal)

                AnalyticsCard(title: "Spending by Category") {
                    if categoryData.isEmpty {
                        Text("No expenses for this month.").foregroundColor(.secondary)
                    } else {
                        SpendingPieChart(data: categoryData)
                    }
                }

                AnalyticsCard(title: "Daily Spending") {
                    if dailyData.isEmpty {
                        Text("No expenses for this month.").foregroundColor(.secondary)
                    } else {
                        DailySpendingLineChart(data: dailyData)
                    }
                }

                AnalyticsCard(title: "Summary") {
                    SpendingSummary(categories: categoryData, daily: dailyData)
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Pie Chart
struct SpendingPieChart: View {
    let data: [CategorySpending]

    private var total: Double {
        data.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            Chart(data) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.35),
                    outerRadius: .ratio(0.6)
                )
                .foregroundStyle(item.color)
                .annotation(position: .overlay) {
                    let pct = item.amount / max(total, 1)
                    if pct > 0.1 {
                        Text("\(Int(pct * 100))%")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(width: 200, height: 200)
            .chartLegend(.hidden)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(data) { item in
                    let pct = item.amount / max(total, 1)
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        Text(item.category)
                            .font(.footnote)
                        Spacer()
                        Text("\(Int(pct * 100))%")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.top, 24)
        }
    }
}

// MARK: - Preview
#Preview {
    AnalyticsScreen()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}



#Preview {
    AnalyticsScreen()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
