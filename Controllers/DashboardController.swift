import SwiftUI
import CoreData
import Combine

@MainActor
final class DashboardController: ObservableObject {
    
    let context: NSManagedObjectContext
    
    @Published var expenses: [Expense] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        // Observe changes in Core Data
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .sink { [weak self] _ in
                self?.fetchExpenses()
            }
            .store(in: &cancellables)
        
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
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return expenses
            .filter { if let date = $0.date {
                return date >= today && date < endOfDay
            }
            return false}
            .reduce(0) { $0 + $1.amount }
    }
    
    func monthTotal() -> Double {
        let startOfMonth = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: Date())
        )!
        let startOfNextMonth = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: startOfMonth
        )!
        
        return expenses
            .filter { if let date = $0.date {
                return date >= startOfMonth && date < startOfNextMonth
            }
            return false}
            .reduce(0) { $0 + $1.amount }
    }
}

