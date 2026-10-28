//
//  JournalView.swift
//  Coffee Log
//

import SwiftUI
import SwiftData

struct JournalView: View {
    enum Range: String, CaseIterable, Identifiable {
        case week = "7 Days", month = "30 Days", all = "All Time"
        var id: Self { self }
        var days: Int? {
            switch self {
            case .week: 7
            case .month: 30
            case .all: nil
            }
        }
    }

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tasting.timestamp, order: .reverse) private var tastings: [Tasting]
    @State private var range = Range.week

    private var entries: [Tasting] {
        guard let days = range.days, let start = Calendar.current.date(byAdding: .day, value: -days, to: .now) else { return tastings }
        return tastings.filter { $0.timestamp >= start }
    }

    private var days: [(day: Date, tastings: [Tasting])] {
        Dictionary(grouping: entries) { Calendar.current.startOfDay(for: $0.timestamp) }
            .map { ($0.key, $0.value) }
            .sorted { $0.day > $1.day }
    }

    private func dayTitle(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return String(localized: "Today") }
        if Calendar.current.isDateInYesterday(date) { return String(localized: "Yesterday") }
        return date.formatted(date: .long, time: .omitted)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Range", selection: $range) {
                        ForEach(Range.allCases) { Text(LocalizedStringKey($0.rawValue)).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }

                if !entries.isEmpty {
                    let stats = CoffeeAnalytics(beans: [], tastings: entries)
                    Section("Summary") {
                        LabeledValue("Entries", "\(entries.count)")
                        LabeledValue("Avg Rating", stats.averageRating.formatted(.number.precision(.fractionLength(1))))
                        LabeledValue("Top Method", stats.topBrewMethod)
                        LabeledValue("Top Flavor", stats.flavorHighlight)
                    }
                }

                ForEach(days, id: \.day) { group in
                    Section(dayTitle(group.day)) {
                        ForEach(group.tastings) { tasting in
                            NavigationLink {
                                TastingDetailView(tasting: tasting)
                            } label: {
                                TastingRow(tasting: tasting)
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets { modelContext.delete(group.tastings[index]) }
                        }
                    }
                }
            }
            .overlay {
                if entries.isEmpty {
                    ContentUnavailableView("No Brews Logged", systemImage: "book", description: Text("Add a tasting to start building your diary."))
                }
            }
            .navigationTitle("Coffee Journal")
        }
    }
}
