//
//  TastingDetailView.swift
//  Coffee Log
//

import SwiftUI
import SwiftData

struct TastingDetailView: View {
    let tasting: Tasting

    private func score(_ value: Int?) -> String { value.map { "\($0)/10" } ?? "N/A" }

    var body: some View {
        List {
            Section("Rating: \(tasting.rating.ratingText)") {
                LabeledValue("Date", tasting.timestamp.formatted(date: .long, time: .shortened))
                LabeledValue("Aroma", score(tasting.aroma))
                LabeledValue("Acidity", score(tasting.acidity))
                LabeledValue("Sweetness", score(tasting.sweetness))
                LabeledValue("Body", score(tasting.body))
                LabeledValue("Aftertaste", score(tasting.aftertaste))
                LabeledValue("Notes", tasting.notes.isEmpty ? "No notes" : tasting.notes)
            }

            Section("Flavor Tags") {
                if (tasting.flavors ?? []).isEmpty {
                    Text("No tags").foregroundStyle(.secondary)
                } else {
                    FlowLayout {
                        ForEach((tasting.flavors ?? []).sorted { $0.name < $1.name }) { TagChip(title: $0.name, isSelected: false) }
                    }
                    .padding(.vertical, 4)
                }
            }

            if let brew = tasting.brewLog {
                Section("Brew Method") {
                    LabeledValue("Method", brew.brewMethod?.name ?? "Unknown")
                    LabeledValue("Dose", brew.dose.map { "\($0.formatted())g" } ?? "N/A")
                    LabeledValue("Water", brew.water.map { "\($0.formatted())g" } ?? "N/A")
                    LabeledValue("Ratio", brew.ratio ?? "N/A")
                    LabeledValue("Grind Size", brew.grindSize?.name ?? "N/A")
                    LabeledValue("Temperature", brew.temperature.map { "\($0.formatted())°C" } ?? "N/A")
                    LabeledValue("Brew Time", brew.brewTimeText ?? "N/A")
                }
            }
        }
        .navigationTitle(tasting.coffeeBean?.name ?? "Tasting Details")
        .inlineNavigationTitle()
    }
}
