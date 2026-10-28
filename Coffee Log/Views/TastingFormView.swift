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

    @State private var rating = 3.5
    @State private var aroma = 5.0
    @State private var acidity = 5.0
    @State private var sweetness = 5.0
    @State private var body_ = 5.0
    @State private var aftertaste = 5.0
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

    private func isValidAmount(_ text: String) -> Bool { isBlank(text) || (number(text).map { $0 >= 0 } ?? false) }

    private var isValid: Bool {
        method == nil || ([dose, water, temperature].allSatisfy(isValidAmount) && (isBlank(brewTime) || brewSeconds != nil))
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
                    // No step, so any rating between 0 and 5 can be chosen.
                    slider("Rating", value: $rating, range: 0...5, step: nil)
                    DatePicker("Date", selection: $date)
                }
                Section("Tasting Attributes (1-10)") {
                    slider("Aroma", value: $aroma, range: 1...10, step: 1)
                    slider("Acidity", value: $acidity, range: 1...10, step: 1)
                    slider("Sweetness", value: $sweetness, range: 1...10, step: 1)
                    slider("Body", value: $body_, range: 1...10, step: 1)
                    slider("Aftertaste", value: $aftertaste, range: 1...10, step: 1)
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

    private func slider(_ title: LocalizedStringKey, value: Binding<Double>, range: ClosedRange<Double>, step: Double?) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(value.wrappedValue.formatted(.number.precision(.fractionLength(0...1)))).foregroundStyle(.secondary)
            }
            if let step {
                Slider(value: value, in: range, step: step)
            } else {
                Slider(value: value, in: range)
            }
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
            rating: (rating * 10).rounded() / 10,
            aroma: Int(aroma),
            acidity: Int(acidity),
            sweetness: Int(sweetness),
            body: Int(body_),
            aftertaste: Int(aftertaste),
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
