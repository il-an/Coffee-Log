//
//  CoffeeFormView.swift
//  Coffee Log
//

import SwiftUI
import SwiftData

/// Creates a new coffee, or edits `bean` when one is passed in.
struct CoffeeFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let bean: CoffeeBean?

    @State private var name: String
    @State private var roaster: String
    @State private var origin: String
    @State private var processing: String
    @State private var roast: String
    @State private var region: String
    @State private var variety: String
    @State private var elevation: String
    @State private var price: String

    init(bean: CoffeeBean? = nil) {
        self.bean = bean
        _name = State(initialValue: bean?.name ?? "")
        _roaster = State(initialValue: bean?.roaster ?? "")
        _origin = State(initialValue: bean?.originCountry ?? "")
        _processing = State(initialValue: bean?.processingMethod ?? "")
        _roast = State(initialValue: bean?.roastLevel ?? "")
        _region = State(initialValue: bean?.region ?? "")
        _variety = State(initialValue: bean?.variety ?? "")
        _elevation = State(initialValue: bean?.elevationMeters.map(String.init) ?? "")
        _price = State(initialValue: bean?.price.map { $0.formatted(.number.grouping(.never)) } ?? "")
    }

    private func trimmed(_ text: String) -> String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var elevationValue: Int? { Int(trimmed(elevation)) }
    private var priceValue: Double? { Double(trimmed(price).replacingOccurrences(of: ",", with: ".")) }

    private var isValid: Bool {
        !trimmed(name).isEmpty && !trimmed(roaster).isEmpty && !trimmed(origin).isEmpty
            && !trimmed(processing).isEmpty && !trimmed(roast).isEmpty
            && (trimmed(elevation).isEmpty || elevationValue != nil)
            && (trimmed(price).isEmpty || priceValue != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Required Information") {
                    LabeledTextField("Coffee Name", text: $name, prompt: "e.g., Supernova Ethiopia")
                    LabeledTextField("Roaster", text: $roaster, prompt: "e.g., Northern Lights")
                    suggestionField("Origin Country", text: $origin, prompt: "e.g., Ethiopia", options: DefaultData.origins)
                    suggestionField("Processing Method", text: $processing, prompt: "e.g., Natural", options: DefaultData.processingMethods)
                    suggestionField("Roast Level", text: $roast, prompt: "e.g., Light", options: DefaultData.roastLevels)
                }
                Section("Additional Information (Optional)") {
                    LabeledTextField("Region", text: $region, prompt: "e.g., Sidamo")
                    LabeledTextField("Variety", text: $variety, prompt: "e.g., Heirloom, Gesha, Caturra")
                    LabeledTextField("Elevation (meters)", text: $elevation, prompt: "e.g., 2000", isValid: trimmed(elevation).isEmpty || elevationValue != nil).integerKeyboard()
                    LabeledTextField("Price", text: $price, prompt: "e.g., 22.50", isValid: trimmed(price).isEmpty || priceValue != nil).decimalKeyboard()
                }
            }
            .formStyle(.grouped)
            .navigationTitle(bean == nil ? "Add Coffee" : "Edit Coffee")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save", action: save).disabled(!isValid) }
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 480)
        #endif
    }

    /// A text field with a menu of common values next to it.
    private func suggestionField(_ title: LocalizedStringKey, text: Binding<String>, prompt: String, options: [String]) -> some View {
        HStack {
            LabeledTextField(title, text: text, prompt: prompt)
            Menu("Suggestions", systemImage: "chevron.down.circle") {
                ForEach(options, id: \.self) { option in
                    Button(option) { text.wrappedValue = option }
                }
            }
            .labelStyle(.iconOnly)
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
    }

    private func save() {
        let target = bean ?? CoffeeBean(name: "", roaster: "", originCountry: "", processingMethod: "", roastLevel: "")
        target.name = trimmed(name)
        target.roaster = trimmed(roaster)
        target.originCountry = trimmed(origin)
        target.processingMethod = trimmed(processing)
        target.roastLevel = trimmed(roast)
        target.region = trimmed(region).isEmpty ? nil : trimmed(region)
        target.variety = trimmed(variety).isEmpty ? nil : trimmed(variety)
        target.elevationMeters = elevationValue
        target.price = priceValue
        if bean == nil { modelContext.insert(target) }
        dismiss()
    }
}
