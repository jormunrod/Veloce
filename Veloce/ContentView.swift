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

    var body: some View {
        NavigationStack {
            List {
                ForEach(cars) { car in
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
                AddCarView()
            }
            .overlay {
                if cars.isEmpty {
                    ContentUnavailableView(
                        "Empty Collection",
                        systemImage: "car",
                        description: Text("Tap the + to add your first model.")
                    )
                }
            }
            .alert("Delete Car", isPresented: $isShowingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    offsetsToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let offsets = offsetsToDelete {
                        for index in offsets {
                            context.delete(cars[index])
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

#Preview {
    let previewContainer: ModelContainer = {
        do {
            let container = try ModelContainer(
                for: HotWheel.self,
                HotWheelSeries.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            let context = container.mainContext

            let experimotors = HotWheelSeries(name: "EXPERIMOTORS (2022)")
            let jImports = HotWheelSeries(name: "HW J-IMPORTS (2021)")

            context.insert(experimotors)
            context.insert(jImports)

            let car1 = HotWheel(
                name: "DRAGGIN' WAGON",
                series: experimotors,
                color: "BLUE",
                seriesNumber: "1/5",
                yearDesigned: 2022,
                yearReleased: 2022,
                yearReceived: 2023,
                cost: 1.80,
                hasCase: false
            )

            let car2 = HotWheel(
                name: "SUBARU WRX STI",
                series: jImports,
                color: "WHITE",
                serialNumberCase: "HKK62-M7C5",
                serialNumberCar: "HCV32",
                seriesNumber: "2/10",
                yearDesigned: 2021,
                yearReleased: 2021,
                yearReceived: 2024,
                cost: 2.50,
                hasCase: false
            )

            context.insert(car1)
            context.insert(car2)

            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()

    return ContentView()
        .modelContainer(previewContainer)
}
