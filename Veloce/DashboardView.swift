//
//  DashboardView.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query private var cars: [HotWheel]

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
