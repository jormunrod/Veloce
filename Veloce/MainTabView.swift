//
//  MainTabView.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import SwiftData
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Collection", systemImage: "car.fill")
                }

            SeriesListView()
                .tabItem {
                    Label("Series", systemImage: "square.stack.3d.up.fill")
                }

            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
        }
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

            let experimotors = HotWheelSeries(
                name: "EXPERIMOTORS",
                year: 2022,
                totalCars: 5
            )
            let jImports = HotWheelSeries(
                name: "HW J-IMPORTS",
                year: 2021,
                totalCars: 10
            )

            context.insert(experimotors)
            context.insert(jImports)

            let car1 = HotWheel(
                name: "DRAGGIN' WAGON",
                series: experimotors,
                color: "BLUE"
            )

            context.insert(car1)

            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()

    return MainTabView()
        .modelContainer(previewContainer)
}
