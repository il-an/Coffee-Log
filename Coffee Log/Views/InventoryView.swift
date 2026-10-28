//
//  InventoryView.swift
//  Coffee Log
//

import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Inventory.quantityGrams) private var items: [Inventory]
    @Query private var beans: [CoffeeBean]

    @State private var editing: Inventory?
    @State private var showingAdd = false

    private var lowStock: [Inventory] { items.filter(\.isLowStock) }
    private var expiring: [Inventory] { items.filter(\.isExpiringSoon) }

    var body: some View {
        NavigationStack {
            List {
                if !lowStock.isEmpty || !expiring.isEmpty {
                    Section("Alerts") {
                        ForEach(lowStock) { Label("\($0.coffeeBean?.name ?? "Coffee") is running low", systemImage: "exclamationmark.triangle").foregroundStyle(.orange) }
                        ForEach(expiring) { Label("\($0.coffeeBean?.name ?? "Coffee") is expiring soon", systemImage: "clock.badge.exclamationmark").foregroundStyle(.red) }
                    }
                }
                Section("Stock") {
                    ForEach(items) { item in
                        Button { editing = item } label: { row(item) }
                            .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        for index in offsets { modelContext.delete(items[index]) }
                    }
                }
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("No Inventory", systemImage: "shippingbox", description: Text("Track how much of each coffee you have left."))
                }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Inventory", systemImage: "plus") { showingAdd = true }
                        .disabled(beans.allSatisfy { $0.inventory != nil })
                }
            }
            .sheet(isPresented: $showingAdd) { InventoryFormView(inventory: nil) }
            .sheet(item: $editing) { InventoryFormView(inventory: $0) }
        }
    }

    private func row(_ item: Inventory) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(item.coffeeBean?.name ?? "Unknown coffee").font(.headline)
                Spacer()
                Text("\(item.quantityGrams.formatted()) g").foregroundStyle(item.isLowStock ? .orange : .secondary)
            }
            if let depletion = item.estimatedDepletionDate {
                Text("Estimated to run out \(depletion.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let expiry = item.expirationDate {
                Text("Expires \(expiry.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption).foregroundStyle(item.isExpiringSoon ? .red : .secondary)
            }
        }
        .contentShape(Rectangle())
    }
}

/// Creates or edits an inventory record. Each coffee has at most one.
struct InventoryFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CoffeeBean.name) private var beans: [CoffeeBean]
    let inventory: Inventory?

    @State private var bean: CoffeeBean?
    @State private var quantity: String
    @State private var daily: String
    @State private var hasPurchaseDate: Bool
    @State private var purchaseDate: Date
    @State private var hasExpiration: Bool
    @State private var expirationDate: Date

    init(inventory: Inventory?) {
        self.inventory = inventory
        _bean = State(initialValue: inventory?.coffeeBean)
        _quantity = State(initialValue: inventory.map { $0.quantityGrams.formatted(.number.grouping(.never)) } ?? "")
        _daily = State(initialValue: inventory?.dailyConsumptionGrams.map { $0.formatted(.number.grouping(.never)) } ?? "")
        _hasPurchaseDate = State(initialValue: inventory?.purchaseDate != nil)
        _purchaseDate = State(initialValue: inventory?.purchaseDate ?? .now)
        _hasExpiration = State(initialValue: inventory?.expirationDate != nil)
        _expirationDate = State(initialValue: inventory?.expirationDate ?? Calendar.current.date(byAdding: .month, value: 2, to: .now) ?? .now)
    }

    private func number(_ text: String) -> Double? {
        Double(text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: "."))
    }

    /// Beans that can be picked: ones without stock, plus the one being edited.
    private var availableBeans: [CoffeeBean] {
        beans.filter { $0.inventory == nil || $0.inventory === inventory }
    }

    private var quantityValid: Bool { number(quantity).map { $0 >= 0 } ?? quantity.trimmingCharacters(in: .whitespaces).isEmpty }
    private var dailyValid: Bool { daily.trimmingCharacters(in: .whitespaces).isEmpty || (number(daily).map { $0 >= 0 } ?? false) }

    /// Describes why the chosen dates are invalid, or nil when they are fine.
    private var dateError: String? {
        let calendar = Calendar.current
        if hasPurchaseDate, calendar.startOfDay(for: purchaseDate) > calendar.startOfDay(for: .now) {
            return String(localized: "The purchase date can't be in the future.")
        }
        if hasPurchaseDate, hasExpiration, calendar.startOfDay(for: expirationDate) < calendar.startOfDay(for: purchaseDate) {
            return String(localized: "The expiration date must be on or after the purchase date.")
        }
        return nil
    }

    private var canSave: Bool {
        bean != nil && number(quantity) != nil && quantityValid && dailyValid && dateError == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Coffee", selection: $bean) {
                    Text("Select").tag(CoffeeBean?.none)
                    ForEach(availableBeans) { Text($0.name).tag(CoffeeBean?.some($0)) }
                }
                LabeledTextField("Quantity (grams)", text: $quantity, prompt: "e.g., 250", isValid: quantityValid).decimalKeyboard()
                LabeledTextField("Daily consumption (grams)", text: $daily, prompt: "e.g., 20", isValid: dailyValid).decimalKeyboard()
                Section {
                    Toggle("Purchase date", isOn: $hasPurchaseDate)
                    if hasPurchaseDate {
                        DatePicker("Purchased", selection: $purchaseDate, in: ...Date.now, displayedComponents: .date)
                    }
                    Toggle("Expiration date", isOn: $hasExpiration)
                    if hasExpiration {
                        DatePicker("Expires", selection: $expirationDate, displayedComponents: .date)
                    }
                } footer: {
                    if let dateError {
                        Text(dateError).foregroundStyle(.red)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(inventory == nil ? "Add Inventory" : "Edit Inventory")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save).disabled(!canSave)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 360)
        #endif
    }

    private func save() {
        guard let bean, let grams = number(quantity) else { return }
        let target = inventory ?? Inventory(quantityGrams: grams)
        target.quantityGrams = grams
        target.dailyConsumptionGrams = number(daily)
        target.purchaseDate = hasPurchaseDate ? purchaseDate : nil
        target.expirationDate = hasExpiration ? expirationDate : nil
        if inventory == nil { modelContext.insert(target) }
        target.coffeeBean = bean
        dismiss()
    }
}
