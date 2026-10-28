//
//  CoffeeLibraryView.swift
//  Coffee Log
//

import SwiftUI
import SwiftData

struct CoffeeLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CoffeeBean.name) private var beans: [CoffeeBean]

    @State private var searchText = ""
    @State private var originFilter: String?
    @State private var roastFilter: String?
    @State private var showingAdd = false

    private var filteredBeans: [CoffeeBean] {
        beans.filter { bean in
            let matchesSearch = searchText.isEmpty
                || bean.name.localizedStandardContains(searchText)
                || bean.roaster.localizedStandardContains(searchText)
                || bean.originCountry.localizedStandardContains(searchText)
            return matchesSearch
                && (originFilter == nil || bean.originCountry == originFilter)
                && (roastFilter == nil || bean.roastLevel == roastFilter)
        }
    }

    private var origins: [String] { Set(beans.map(\.originCountry)).filter { !$0.isEmpty }.sorted() }
    private var roasts: [String] { Set(beans.map(\.roastLevel)).filter { !$0.isEmpty }.sorted() }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredBeans) { bean in
                    NavigationLink(value: bean) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(bean.name).font(.headline)
                            Text("\(bean.roaster) • \(bean.originCountry) • \(bean.roastLevel)")
                                .font(.subheadline).foregroundStyle(.secondary)
                            if !(bean.tastings ?? []).isEmpty {
                                Label(bean.averageRating.ratingText, systemImage: "star.fill")
                                    .font(.caption).foregroundStyle(.orange)
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    let current = filteredBeans
                    for index in offsets { modelContext.delete(current[index]) }
                }
            }
            .overlay {
                if beans.isEmpty {
                    ContentUnavailableView("No Coffees", systemImage: "leaf", description: Text("Add your first coffee to start your library."))
                } else if filteredBeans.isEmpty {
                    ContentUnavailableView.search
                }
            }
            .searchable(text: $searchText, prompt: "Name, roaster or origin")
            .navigationTitle("Coffee Library")
            .navigationDestination(for: CoffeeBean.self) { CoffeeDetailView(bean: $0) }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Menu("Filter", systemImage: originFilter != nil || roastFilter != nil
                         ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle") {
                        Picker("Origin", selection: $originFilter) {
                            Text("All Origins").tag(String?.none)
                            ForEach(origins, id: \.self) { Text($0).tag(String?.some($0)) }
                        }
                        Picker("Roast", selection: $roastFilter) {
                            Text("All Roasts").tag(String?.none)
                            ForEach(roasts, id: \.self) { Text($0).tag(String?.some($0)) }
                        }
                        Button("Clear All Filters", role: .destructive) {
                            originFilter = nil
                            roastFilter = nil
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Coffee", systemImage: "plus") { showingAdd = true }
                }
            }
            .sheet(isPresented: $showingAdd) { CoffeeFormView() }
        }
    }
}
