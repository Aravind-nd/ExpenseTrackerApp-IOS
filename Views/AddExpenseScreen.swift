
//  AddExpenseScreen.swift
//  ExpenseTracker_MVC
//

import SwiftUI
import CoreData
import Combine

struct AddExpenseScreen: View {

    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var controller: AddExpenseController

    // MARK: - State
    @State private var amount: Double = 0.0
    @State private var isEditingAmount: Bool = false

    @State private var selectedCategory: String = "Select Category"
    @State private var selectedDate: Date = Date()
    @State private var selectedPaymentMethod: String = "Cash"
    @State private var note: String = ""
    @State private var showAlert: Bool = false

    // Add Category popup
    @State private var showingAddCategoryAlert = false
    @State private var newCategoryName = ""

    // MARK: - Init
    init(context: NSManagedObjectContext? = nil) {
        let ctx = context ?? PersistenceController.shared.container.viewContext
        _controller = StateObject(wrappedValue: AddExpenseController(context: ctx))
    }

    let paymentMethods = ["Cash", "Card", "UPI"]

    // MARK: - Formatters
    private let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.locale = Locale(identifier: "en_US")
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        return f
    }()

    private let decimalFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        return f
    }()

    // MARK: - Functions
    func handleSave() {
        do {
            try controller.saveExpense(
                amount: amount,
                category: selectedCategory,
                date: selectedDate,
                paymentMethod: selectedPaymentMethod,
                note: note
            )
            showAlert = true
        } catch {
            print("Failed to save expense: \(error)")
        }
    }

    func resetForm() {
        amount = 0.0
        selectedCategory = "Select Category"
        selectedDate = Date()
        selectedPaymentMethod = "Cash"
        note = ""
    }

    // MARK: - View
    var body: some View {
        VStack {
            Text("Add Expense")
                .font(.largeTitle)
                .fontWeight(.bold)

            Divider()

            VStack(spacing: 24) {

                // Amount
                HStack {
                    Text("Amount").font(.title3).fontWeight(.semibold)
                    Spacer()
                    TextField(
                        "$0.00",
                        value: $amount,
                        formatter: isEditingAmount ? decimalFormatter : currencyFormatter,
                        onEditingChanged: { editing in isEditingAmount = editing }
                    )
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 160)
                }

                Divider()

                // Category
                HStack {
                    Text("Category").font(.title3).fontWeight(.semibold)
                    Spacer()

                    Menu {
                        // Show all categories from CategoryManager
                        ForEach(CategoryManager.shared.currentCategories, id: \.self) { cat in
                            Button(cat) { selectedCategory = cat }
                        }
                        Divider()
                        Button("Add Category") { showingAddCategoryAlert = true }
                    } label: {
                        HStack {
                            Text(selectedCategory)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }

                Divider()

                // Date
                HStack {
                    Text("Date").font(.title3).fontWeight(.semibold)
                    Spacer()
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                }

                Divider()

                // Payment Method
                HStack {
                    Text("Payment Method").font(.title3).fontWeight(.semibold)
                    Spacer()
                    Picker("Payment Method", selection: $selectedPaymentMethod) {
                        ForEach(paymentMethods, id: \.self) { method in
                            Text(method)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Divider()

                // Note
                HStack {
                    Text("Note").font(.title3).fontWeight(.semibold)
                    Spacer()
                    TextField("Optional", text: $note)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 200)
                }
            }
            .padding()

            Spacer()

            // Buttons
            HStack(spacing: 16) {
                Button("Cancel") { resetForm() }
                    .frame(minWidth: 120, minHeight: 44)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                Button("Save") { handleSave() }
                    .frame(minWidth: 160, minHeight: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(amount <= 0 || selectedCategory == "Select Category")
            }
            .padding()
        }
        .alert("Success", isPresented: $showAlert) {
            Button("OK", role: .cancel) { resetForm() }
        } message: {
            Text("Expense successfully saved!")
        }
        // MARK: - Add Category Alert
        .alert("Add New Category", isPresented: $showingAddCategoryAlert) {
            TextField("Category Name", text: $newCategoryName)
            Button("Add") {
                CategoryManager.shared.addCategory(newCategoryName)
                selectedCategory = newCategoryName
                newCategoryName = ""
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a new category name")
        }
    }
}
