//
//  TastingFormView.swift
//  Coffee Log
//

import SwiftUI
import SwiftData

struct TastingFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let bean: CoffeeBean

    @Query(sort: \Flavor.name) private var allFlavors: [Flavor]
    @Query(sort: \BrewMethod.name) private var methods: [BrewMethod]
    @Query private var grindSizes: [GrindSize]

    // Numeric entries start at a default and can be edited freely.
    @State private var rating = "3.5"
    @State private var aroma = "5"
    @State private var acidity = "5"
    @State private var sweetness = "5"
    @State private var body_ = "5"
    @State private var aftertaste = "5"
    @State private var date = Date.now
    @State private var notes = ""
    @State private var selectedFlavorIDs: Set<UUID> = []

    @State private var method: BrewMethod?
    @State private var grind: GrindSize?
    @State private var dose = ""
    @State private var water = ""
    @State private var temperature = ""
    @State private var brewTime = ""
    @State private var newFlavor = ""

    private func number(_ text: String) -> Double? {
        Double(text.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: "."))
    }

    private func isBlank(_ text: String) -> Bool { text.trimmingCharacters(in: .whitespaces).isEmpty }

    private var ratingValue: Double? {
        guard let value = number(rating), (0...5).contains(value) else { return nil }
        return value
    }

    /// An attribute score: blank means "not rated", otherwise a whole number from 1 to 10.
    private func score(_ text: String) -> Int? {
        guard let value = Int(text.trimmingCharacters(in: .whitespaces)), (1...10).contains(value) else { return nil }
        return value
    }

    private func isValidScore(_ text: String) -> Bool { isBlank(text) || score(text) != nil }
    private func isValidAmount(_ text: String) -> Bool { isBlank(text) || (number(text).map { $0 >= 0 } ?? false) }

    private var isValid: Bool {
        ratingValue != nil
            && [aroma, acidity, sweetness, body_, aftertaste].allSatisfy(isValidScore)
            && (method == nil || ([dose, water, temperature].allSatisfy(isValidAmount) && (isBlank(brewTime) || brewSeconds != nil)))
    }

    /// Parses "m:ss" or plain seconds.
    private var brewSeconds: Int? {
        let parts = brewTime.split(separator: ":").map { Int($0.trimmingCharacters(in: .whitespaces)) }
        switch parts.count {
        case 1: return parts[0]
        case 2: if let m = parts[0], let s = parts[1] { return m * 60 + s } else { return nil }
        default: return nil
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Overall Rating") {
                    LabeledTextField("Rating (0-5)", text: $rating, prompt: "3.5", isValid: ratingValue != nil)
                        .decimalKeyboard()
                    DatePicker("Date", selection: $date)
                }
                Section {
                    LabeledTextField("Aroma", text: $aroma, prompt: "5", isValid: isValidScore(aroma)).integerKeyboard()
                    LabeledTextField("Acidity", text: $acidity, prompt: "5", isValid: isValidScore(acidity)).integerKeyboard()
                    LabeledTextField("Sweetness", text: $sweetness, prompt: "5", isValid: isValidScore(sweetness)).integerKeyboard()
                    LabeledTextField("Body", text: $body_, prompt: "5", isValid: isValidScore(body_)).integerKeyboard()
                    LabeledTextField("Aftertaste", text: $aftertaste, prompt: "5", isValid: isValidScore(aftertaste)).integerKeyboard()
                } header: {
                    Text("Tasting Attributes (1-10)")
                } footer: {
                    Text("Leave a field blank to skip it.")
                }
                Section("Flavor Tags") {
                    FlowLayout {
                        ForEach(allFlavors) { flavor in
                            TagChip(title: flavor.name, isSelected: selectedFlavorIDs.contains(flavor.id)) {
                                if !selectedFlavorIDs.insert(flavor.id).inserted {
                                    selectedFlavorIDs.remove(flavor.id)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    HStack {
                        TextField("New flavor", text: $newFlavor)
                            .onSubmit(addFlavor)
                        Button("Add", action: addFlavor)
                            .disabled(newFlavor.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                Section("Brew Method (Optional)") {
                    Picker("Method", selection: $method) {
                        Text("None").tag(BrewMethod?.none)
                        ForEach(methods) { Text($0.name).tag(BrewMethod?.some($0)) }
                    }
                }
                if method != nil {
                    Section("Brew Details") {
                        LabeledTextField("Dose (grams)", text: $dose, prompt: "20", isValid: isValidAmount(dose)).decimalKeyboard()
                        LabeledTextField("Water (grams)", text: $water, prompt: "320", isValid: isValidAmount(water)).decimalKeyboard()
                        Picker("Grind Size", selection: $grind) {
                            Text("Not set").tag(GrindSize?.none)
                            ForEach(sortedGrindSizes) { Text($0.name).tag(GrindSize?.some($0)) }
                        }
                        LabeledTextField("Temperature (°C)", text: $temperature, prompt: "94", isValid: isValidAmount(temperature)).decimalKeyboard()
                        LabeledTextField("Brew Time", text: $brewTime, prompt: "2:40", isValid: isBlank(brewTime) || brewSeconds != nil)
                    }
                }
                Section("Notes") {
                    TextEditor(text: $notes).frame(minHeight: 100)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(bean.name)
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save", action: save).disabled(!isValid) }
            }
        }
        #if os(macOS)
        .frame(minWidth: 480, minHeight: 640)
        #endif
    }

    /// Orders grind sizes from fine to coarse using the default list, with custom ones last.
    private var sortedGrindSizes: [GrindSize] {
        grindSizes.sorted {
            let a = DefaultData.grindSizes.firstIndex(of: $0.name) ?? .max
            let b = DefaultData.grindSizes.firstIndex(of: $1.name) ?? .max
            return a == b ? $0.name < $1.name : a < b
        }
    }

    private func addFlavor() {
        let name = newFlavor.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        if let existing = allFlavors.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
            selectedFlavorIDs.insert(existing.id)
        } else {
            let flavor = Flavor(name: name)
            modelContext.insert(flavor)
            selectedFlavorIDs.insert(flavor.id)
        }
        newFlavor = ""
    }

    private func save() {
        let tasting = Tasting(
            rating: ratingValue ?? 0,
            aroma: score(aroma),
            acidity: score(acidity),
            sweetness: score(sweetness),
            body: score(body_),
            aftertaste: score(aftertaste),
            notes: notes,
            timestamp: date
        )
        modelContext.insert(tasting)
        tasting.coffeeBean = bean
        tasting.flavors = allFlavors.filter { selectedFlavorIDs.contains($0.id) }

        if let method {
            let log = BrewLog(
                brewMethod: method,
                dose: number(dose),
                water: number(water),
                temperature: number(temperature),
                brewTime: brewSeconds,
                grindSize: grind
            )
            modelContext.insert(log)
            tasting.brewLog = log

            // Deduct the coffee used from the bean's stock.
            if let used = log.dose, let inventory = bean.inventory {
                inventory.quantityGrams = max(0, inventory.quantityGrams - used)
            }
        }
        dismiss()
    }
}
