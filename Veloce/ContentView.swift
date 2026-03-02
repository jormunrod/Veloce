//
//  ContentView.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \HotWheel.name) private var cars: [HotWheel]
    @Environment(\.modelContext) private var context

    @State private var isShowingAddView = false
    @State private var isShowingDeleteAlert = false
    @State private var offsetsToDelete: IndexSet?

    @State private var searchText = ""
    @State private var showOnlyTreasureHunts = false

    var filteredCars: [HotWheel] {
        cars.filter { car in
            let matchesSearch =
                searchText.isEmpty
                || car.name.localizedCaseInsensitiveContains(searchText)
                || (car.series?.name ?? "").localizedCaseInsensitiveContains(
                    searchText
                ) || car.color.localizedCaseInsensitiveContains(searchText)

            let matchesTreasureHunt =
                showOnlyTreasureHunts ? car.isTreasureHunt : true

            return matchesSearch && matchesTreasureHunt
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredCars) { car in
                    NavigationLink(destination: CarDetailView(car: car)) {
                        HStack(spacing: 16) {
                            if let imageData = car.imageData,
                                let uiImage = UIImage(data: imageData)
                            {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 8)
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                    .overlay {
                                        Image(systemName: "car.fill")
                                            .foregroundColor(.secondary)
                                    }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(car.name)
                                    .font(.headline)

                                HStack {
                                    Text(car.series?.name ?? "No Series")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    if let year = car.yearReleased {
                                        Text("• \(String(year))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    if car.isTreasureHunt {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteCars)
            }
            .navigationTitle("My Collection")
            .searchable(
                text: $searchText,
                prompt: "Search models, series or colors..."
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Toggle(isOn: $showOnlyTreasureHunts) {
                            Label(
                                "Treasure Hunts Only",
                                systemImage: "flame.fill"
                            )
                        }
                    } label: {
                        Image(
                            systemName: showOnlyTreasureHunts
                                ? "line.3.horizontal.decrease.circle.fill"
                                : "line.3.horizontal.decrease.circle"
                        )
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddView) {
                AddCarView()
            }
            .overlay {
                if cars.isEmpty {
                    ContentUnavailableView(
                        "Empty Collection",
                        systemImage: "car",
                        description: Text("Tap the + to add your first model.")
                    )
                } else if filteredCars.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .alert("Delete Car", isPresented: $isShowingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    offsetsToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let offsets = offsetsToDelete {
                        for index in offsets {
                            let carToDelete = filteredCars[index]
                            context.delete(carToDelete)
                        }
                    }
                    offsetsToDelete = nil
                }
            } message: {
                Text(
                    "Are you sure you want to delete this car? This action cannot be undone."
                )
            }
        }
    }

    private func deleteCars(offsets: IndexSet) {
        offsetsToDelete = offsets
        isShowingDeleteAlert = true
    }
}
