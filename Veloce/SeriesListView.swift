//
//  SeriesListView.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 5/3/26.
//

import SwiftData
import SwiftUI

struct SeriesListView: View {
    @Query(sort: \HotWheelSeries.name) private var allSeries: [HotWheelSeries]
    @Environment(\.modelContext) private var context

    @State private var isShowingAddView = false
    @State private var searchText = ""

    var filteredSeries: [HotWheelSeries] {
        if searchText.isEmpty { return allSeries }
        return allSeries.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredSeries) { series in
                    NavigationLink(
                        destination: Text(
                            "Details for \(series.name) coming soon!"
                        )
                    ) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(series.name)
                                .font(.headline)

                            HStack {
                                if let year = series.year {
                                    Text(String(year))
                                }
                                if let total = series.totalCars {
                                    Text("• \(total) cars in set")
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteSeries)
            }
            .navigationTitle("Series")
            .searchable(text: $searchText, prompt: "Search collections...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddView) {
                AddSeriesView()
            }
            .overlay {
                if allSeries.isEmpty {
                    ContentUnavailableView(
                        "No Series",
                        systemImage: "square.stack.3d.up",
                        description: Text(
                            "Tap the + to create a new collection."
                        )
                    )
                } else if filteredSeries.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
    }

    private func deleteSeries(offsets: IndexSet) {
        for index in offsets {
            let seriesToDelete = filteredSeries[index]
            context.delete(seriesToDelete)
        }
    }
}
