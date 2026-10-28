//
//  HomeView.swift
//  Coffee Log
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var beans: [CoffeeBean]
    @Query private var tastings: [Tasting]

    @State private var showingAddCoffee = false
    @State private var beanForNewTasting: CoffeeBean?
    @State private var showingBeanPicker = false

    private var analytics: CoffeeAnalytics { CoffeeAnalytics(beans: beans, tastings: tastings) }

    var body: some View {
        NavigationStack {
            List {
                Section("Today's Brew") {
                    if let today = analytics.todayCoffee, let latest = today.latestTasting {
                        NavigationLink(value: today) {
                            VStack(alignment: .leading) {
                                Text(today.name).font(.headline)
                                Text(latest.brewLog?.brewMethod?.name ?? "Untracked brew")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Text("No brews recorded yet").foregroundStyle(.secondary)
                    }
                }

                Section("Favorites") {
                    let favorites = analytics.favorites()
                    if favorites.isEmpty {
                        Text("Rate a coffee 4.5 or higher to see it here").foregroundStyle(.secondary)
                    }
                    ForEach(favorites) { bean in
                        NavigationLink(value: bean) {
                            Text("\(bean.name) (\(bean.roastLevel))")
                        }
                    }
                }

                Section("Quick Stats") {
                    LabeledValue("Average rating", analytics.averageRating.formatted(.number.precision(.fractionLength(1))))
                    LabeledValue("Favorite origin", analytics.favoriteOrigin)
                    LabeledValue("Top brew method", analytics.topBrewMethod)
                    LabeledValue("Flavor highlight", analytics.flavorHighlight)
                }
            }
            .navigationTitle("Coffee Explorer")
            .navigationDestination(for: CoffeeBean.self) { CoffeeDetailView(bean: $0) }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("Add", systemImage: "plus") {
                        Button("Add Coffee", systemImage: "leaf") { showingAddCoffee = true }
                        Button("Add Tasting", systemImage: "cup.and.saucer") { showingBeanPicker = true }
                            .disabled(beans.isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showingAddCoffee) { CoffeeFormView() }
            .sheet(isPresented: $showingBeanPicker) {
                BeanPickerView { beanForNewTasting = $0 }
            }
            .sheet(item: $beanForNewTasting) { TastingFormView(bean: $0) }
        }
    }
}

/// Lets the user choose which coffee a new tasting is for.
struct BeanPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CoffeeBean.name) private var beans: [CoffeeBean]
    let onSelect: (CoffeeBean) -> Void

    var body: some View {
        NavigationStack {
            List(beans) { bean in
                Button {
                    dismiss()
                    onSelect(bean)
                } label: {
                    VStack(alignment: .leading) {
                        Text(bean.name).foregroundStyle(.primary)
                        Text(bean.roaster).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Select Coffee")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
        #if os(macOS)
        .frame(minWidth: 320, minHeight: 360)
        #endif
    }
}
