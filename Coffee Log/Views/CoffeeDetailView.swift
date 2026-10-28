//
//  CoffeeDetailView.swift
//  Coffee Log
//

import SwiftUI
import SwiftData

struct CoffeeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let bean: CoffeeBean

    @State private var showingEdit = false
    @State private var showingAddTasting = false
    @State private var showingDeleteConfirm = false

    private var sortedTastings: [Tasting] {
        (bean.tastings ?? []).sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        List {
            Section("Coffee Information") {
                LabeledValue("Roaster", bean.roaster)
                LabeledValue("Origin", bean.originCountry + (bean.region.map { " • \($0)" } ?? ""))
                LabeledValue("Variety", bean.variety ?? "N/A")
                LabeledValue("Processing", bean.processingMethod)
                LabeledValue("Roast Level", bean.roastLevel)
                LabeledValue("Elevation", bean.elevationMeters.map { "\($0) m" } ?? "N/A")
                LabeledValue("Price", bean.price?.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")) ?? "N/A")
                LabeledValue("Average Rating", (bean.tastings ?? []).isEmpty ? "No tastings yet" : bean.averageRating.ratingText)
            }

            Section("Best Brew Recipe") {
                if let best = bean.bestRecipeTasting, let brew = best.brewLog {
                    VStack(alignment: .leading, spacing: 4) {
                        Text([brew.brewMethod?.name, brew.ratio, brew.temperature.map { "\($0.formatted())°C" }]
                            .compactMap { $0 }.joined(separator: " • "))
                            .font(.headline)
                        Text("Rating: \(best.rating.ratingText) • \((brew.dose ?? 0).formatted())g coffee, \((brew.water ?? 0).formatted())g water")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                } else {
                    Text("No brew recipe recorded yet").foregroundStyle(.secondary)
                }
            }

            Section("Tasting History (\((bean.tastings ?? []).count))") {
                ForEach(sortedTastings) { tasting in
                    NavigationLink {
                        TastingDetailView(tasting: tasting)
                    } label: {
                        TastingRow(tasting: tasting, showsCoffeeName: false)
                    }
                }
                .onDelete { offsets in
                    let current = sortedTastings
                    for index in offsets { modelContext.delete(current[index]) }
                }
            }
        }
        .navigationTitle(bean.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Tasting", systemImage: "plus") { showingAddTasting = true }
            }
            ToolbarItem(placement: .automatic) {
                Menu("More", systemImage: "ellipsis.circle") {
                    Button("Edit", systemImage: "pencil") { showingEdit = true }
                    Button("Delete", systemImage: "trash", role: .destructive) { showingDeleteConfirm = true }
                }
            }
        }
        .sheet(isPresented: $showingEdit) { CoffeeFormView(bean: bean) }
        .sheet(isPresented: $showingAddTasting) { TastingFormView(bean: bean) }
        .confirmationDialog("Delete \(bean.name)?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(bean)
                dismiss()
            }
        } message: {
            Text("Its tastings and inventory will be deleted too.")
        }
    }
}
