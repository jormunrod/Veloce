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
                    Label("Collection", systemImage: "list.dash")
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

    return MainTabView()
        .modelContainer(previewContainer)
}
