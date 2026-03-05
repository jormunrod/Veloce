//
//  SeriesDetailView.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 5/3/26.
//

import SwiftData
import SwiftUI

struct SeriesDetailView: View {
    let series: HotWheelSeries

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingEditView = false
    @State private var isShowingDeleteConfirmation = false

    private var collectedCount: Int {
        series.cars?.count ?? 0
    }

    private var progressText: String {
        if let total = series.totalCars {
            return "\(collectedCount) / \(total) Collected"
        } else {
            return "\(collectedCount) Collected"
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(series.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    HStack {
                        if let year = series.year {
                            Label(String(year), systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(progressText)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(isComplete ? .green : .blue)
                    }

                    if let total = series.totalCars, total > 0 {
                        ProgressView(
                            value: Double(collectedCount),
                            total: Double(total)
                        )
                        .tint(isComplete ? .green : .blue)
                    }

                    if let notes = series.notes {
                        Divider()
                        Text("Notes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(notes)
                            .font(.body)
                    }
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            Section("Models in Collection") {
                let cars = series.cars?.sorted { $0.name < $1.name } ?? []

                if cars.isEmpty {
                    Text("No cars added to this series yet.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(cars) { car in
                        NavigationLink(destination: CarDetailView(car: car)) {
                            HStack(spacing: 12) {
                                if let imageData = car.imageData,
                                    let uiImage = UIImage(data: imageData)
                                {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 6)
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.secondary.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                        .overlay {
                                            Image(systemName: "car.fill")
                                                .foregroundStyle(.secondary)
                                        }
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(car.name)
                                        .font(.headline)

                                    HStack {
                                        Text(car.color)
                                        if let num = car.seriesNumber {
                                            Text("• #\(num)")
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Edit Series", systemImage: "pencil") {
                        isShowingEditView = true
                    }
                    Button(
                        "Delete Series",
                        systemImage: "trash",
                        role: .destructive
                    ) {
                        isShowingDeleteConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isShowingEditView) {
            AddSeriesView(seriesToEdit: series)
        }
        .alert("Delete Series", isPresented: $isShowingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                context.delete(series)
                dismiss()
            }
        } message: {
            Text(
                "Are you sure you want to delete this series? The cars inside will NOT be deleted, but they will lose their series tag."
            )
        }
    }

    private var isComplete: Bool {
        guard let total = series.totalCars else { return false }
        return collectedCount >= total
    }
}
