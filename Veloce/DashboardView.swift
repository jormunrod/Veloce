//
//  DashboardView.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct DashboardView: View {
    @Query private var cars: [HotWheel]
    @Environment(\.modelContext) private var context

    @State private var isImporting = false
    @State private var showExportSuccess = false
    @State private var exportMessage = ""

    private var totalCars: Int {
        cars.count
    }

    private var totalValue: Double {
        cars.compactMap { $0.cost }.reduce(0, +)
    }

    private var treasureHunts: Int {
        cars.filter { $0.isTreasureHunt }.count
    }

    private var protectedCars: Int {
        cars.filter { $0.hasCase }.count
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    StatCard(
                        title: "Total Cars",
                        value: "\(totalCars)",
                        icon: "car.2.fill",
                        color: .blue
                    )
                    StatCard(
                        title: "Total Value",
                        value: String(format: "€%.2f", totalValue),
                        icon: "eurosign.circle.fill",
                        color: .green
                    )
                    StatCard(
                        title: "Treasure Hunts",
                        value: "\(treasureHunts)",
                        icon: "flame.fill",
                        color: .orange
                    )
                    StatCard(
                        title: "In Protectors",
                        value: "\(protectedCars)",
                        icon: "shield.fill",
                        color: .purple
                    )
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Backup Now", systemImage: "arrow.down.doc.fill")
                        {
                            createAutomaticBackup()
                        }
                        Button(
                            "Restore Backup",
                            systemImage: "arrow.up.doc.fill"
                        ) {
                            isImporting = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json]
            ) { result in
                switch result {
                case .success(let url):
                    importData(from: url)
                case .failure(let error):
                    print("Error importing: \(error.localizedDescription)")
                }
            }
            .alert("Backup Successful", isPresented: $showExportSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(exportMessage)
            }
            .overlay {
                if cars.isEmpty {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "chart.bar",
                        description: Text("Add cars to see statistics.")
                    )
                }
            }
        }
    }

    private func createAutomaticBackup() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let dateString = formatter.string(from: Date())
        let filename = "VeloceBackup_\(dateString).json"

        let dtos = cars.map { car in
            HotWheelDTO(
                name: car.name,
                seriesName: car.series?.name,
                color: car.color,
                serialNumberCase: car.serialNumberCase,
                serialNumberCar: car.serialNumberCar,
                seriesNumber: car.seriesNumber,
                yearDesigned: car.yearDesigned,
                yearReleased: car.yearReleased,
                yearReceived: car.yearReceived,
                cost: car.cost,
                hasCase: car.hasCase,
                isTreasureHunt: car.isTreasureHunt,
                notes: car.notes,
                imageData: car.imageData
            )
        }

        do {
            let data = try JSONEncoder().encode(dtos)

            guard
                let documentsDirectory = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                ).first
            else { return }

            let backupsDirectory = documentsDirectory.appendingPathComponent(
                "Backups"
            )

            if !FileManager.default.fileExists(atPath: backupsDirectory.path) {
                try FileManager.default.createDirectory(
                    at: backupsDirectory,
                    withIntermediateDirectories: true
                )
            }

            let fileURL = backupsDirectory.appendingPathComponent(filename)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
             
            exportMessage =
                "Saved to On My iPhone ➔ Veloce ➔ Backups ➔ \(filename)"
            showExportSuccess = true

        } catch {
            print("Failed to create backup: \(error.localizedDescription)")
        }
    }

    private func importData(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        guard let data = try? Data(contentsOf: url),
            let dtos = try? JSONDecoder().decode([HotWheelDTO].self, from: data)
        else { return }

        let descriptor = FetchDescriptor<HotWheelSeries>()
        let existingSeries = (try? context.fetch(descriptor)) ?? []
        var seriesDict = Dictionary(
            uniqueKeysWithValues: existingSeries.map { ($0.name, $0) }
        )

        for dto in dtos {
            var series: HotWheelSeries? = nil
            if let sName = dto.seriesName {
                if let existing = seriesDict[sName] {
                    series = existing
                } else {
                    let newSeries = HotWheelSeries(name: sName)
                    context.insert(newSeries)
                    seriesDict[sName] = newSeries
                    series = newSeries
                }
            }

            let newCar = HotWheel(
                name: dto.name,
                series: series,
                color: dto.color,
                serialNumberCase: dto.serialNumberCase,
                serialNumberCar: dto.serialNumberCar,
                seriesNumber: dto.seriesNumber,
                yearDesigned: dto.yearDesigned,
                yearReleased: dto.yearReleased,
                yearReceived: dto.yearReceived,
                cost: dto.cost,
                hasCase: dto.hasCase,
                isTreasureHunt: dto.isTreasureHunt,
                notes: dto.notes,
                imageData: dto.imageData
            )
            context.insert(newCar)
        }
    }
}

// MARK: - Reusable UI Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .bold()

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
