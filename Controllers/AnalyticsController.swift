
import SwiftUI
import CoreData
import Combine

@MainActor
final class AnalyticsController: ObservableObject {
    
    private let context: NSManagedObjectContext
    private let calendar = Calendar.current
    
    @Published var expenses: [Expense] = []
    @Published var selectedMonth: Date = Date()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchExpenses()
    }
    
    func fetchExpenses() {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: true)]
        
        do {
            expenses = try context.fetch(request)
            // Update dynamic categories whenever expenses change
            CategoryManager.shared.updateDynamicCategories(from: expenses)
        } catch {
            print("Failed to fetch expenses: \(error.localizedDescription)")
        }
    }
    
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
            let color = CategoryManager.shared.color(for: key) // get dynamic color
            return CategorySpending(
                category: key,
                amount: values.reduce(0) { $0 + $1.amount },
                color: color
            )
        }
        .sorted { $0.amount > $1.amount }
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
