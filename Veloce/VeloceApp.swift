//
//  VeloceApp.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import SwiftUI
import SwiftData

@main
struct VeloceApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: HotWheel.self)
    }
}
