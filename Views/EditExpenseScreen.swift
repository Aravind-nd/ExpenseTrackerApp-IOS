//
//  EditExpenseScreen.swift
//  ExpenseTracker_MVC
//
//  Created by Aravind sai Savaram on 16/02/26.
//



//
//  EditExpenseScreen.swift
//  ExpenseTracker_MVC
//

//
//  EditExpenseScreen.swift
//  ExpenseTracker_MVC
//
import SwiftUI
import CoreData
import Combine
import Foundation




protocol ExpenseRefreshingController {
    func fetchExpenses()
}

extension ExpenseListController: ExpenseRefreshingController {}
extension ExpenseListItemController: ExpenseRefreshingController {}

struct EditExpenseScreen: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var expense: Expense
    var listController: ExpenseRefreshingController  // <- generalized protocol

    // MARK: - State
    @State private var selectedCategory: String
    @State private var selectedDate: Date
    @State private var selectedPaymentMethod: String
    @State private var amount: Double
    @State private var note: String
    @State private var showAlert = false

    private let categories = ["Food", "Transport", "Shopping", "Bills", "Entertainment", "Health", "Other"]
    private let paymentMethods = ["Cash", "Card", "UPI"]

    private let decimalFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        return f
    }()

    init(expense: Expense, listController: ExpenseRefreshingController) {
        self.expense = expense
        self.listController = listController

        _selectedCategory = State(initialValue: expense.category ?? "Other")
        _selectedDate = State(initialValue: expense.date ?? Date())
        _selectedPaymentMethod = State(initialValue: expense.paymentMethod ?? "Cash")
        _amount = State(initialValue: expense.amount)
        _note = State(initialValue: expense.note ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {

                // Amount
                HStack {
                    Text("Amount").frame(width: 140, alignment: .leading).font(.title3.weight(.semibold))
                    Spacer()
                    TextField("0.00", value: $amount, formatter: decimalFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
                Divider()

                // Category
                HStack {
                    Text("Category").frame(width: 140, alignment: .leading).font(.title3.weight(.semibold))
                    Spacer()
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }.pickerStyle(.menu)
                }
                Divider()

                // Date
                HStack {
                    Text("Date").frame(width: 140, alignment: .leading).font(.title3.weight(.semibold))
                    Spacer()
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .labelsHidden()
                }
                Divider()

                // Payment Method
                HStack {
                    Text("Payment Method").frame(width: 140, alignment: .leading).font(.title3.weight(.semibold))
                    Spacer()
                    Picker("Payment Method", selection: $selectedPaymentMethod) {
                        ForEach(paymentMethods, id: \.self) { Text($0).tag($0) }
                    }.pickerStyle(.menu)
                }
                Divider()

                // Note
                HStack {
                    Text("Note").frame(width: 140, alignment: .leading).font(.title3.weight(.semibold))
                    Spacer()
                    TextField("Optional", text: $note).multilineTextAlignment(.trailing).frame(width: 200)
                }
                Divider()

                // Buttons
                HStack(spacing: 16) {
                    Button(role: .destructive) { deleteExpense() } label: { Text("Delete").foregroundColor(.white).padding().frame(maxWidth: .infinity).background(Color.red).cornerRadius(10) }
                    Button { saveChanges() } label: { Text("Save").foregroundColor(.white).padding().frame(maxWidth: .infinity).background(Color.blue).cornerRadius(10) }
                }
            }
            .padding()
        }
        .navigationTitle("Edit Expense")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $showAlert) {
            Button("OK") { dismiss() }
        } message: { Text("Expense updated successfully!") }
    }

    private func saveChanges() {
        expense.amount = amount
        expense.category = selectedCategory
        expense.date = selectedDate
        expense.paymentMethod = selectedPaymentMethod
        expense.note = note

        do {
            if viewContext.hasChanges { try viewContext.save() }
            listController.fetchExpenses()
            showAlert = true
        } catch { print("Failed to save: \(error.localizedDescription)") }
    }

    private func deleteExpense() {
        viewContext.delete(expense)
        do {
            try viewContext.save()
            listController.fetchExpenses()
            dismiss()
        } catch { print("Failed to delete: \(error.localizedDescription)") }
    }
}
