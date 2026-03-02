//
//  HotWheel.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import Foundation
import SwiftData

@Model
final class HotWheel {
    // Required
    var name: String
    var series: HotWheelSeries?
    var color: String

    // Identifiers
    var serialNumberCase: String?
    var serialNumberCar: String?
    var seriesNumber: String?

    // Dates
    var yearDesigned: Int?
    var yearReleased: Int?
    var yearReceived: Int?

    // Others
    var cost: Double?
    var hasCase: Bool
    var isTreasureHunt: Bool
    var notes: String?

    @Attribute(.externalStorage) var imageData: Data?

    init(
        name: String,
        series: HotWheelSeries? = nil,
        color: String,
        serialNumberCase: String? = nil,
        serialNumberCar: String? = nil,
        seriesNumber: String? = nil,
        yearDesigned: Int? = nil,
        yearReleased: Int? = nil,
        yearReceived: Int? = nil,
        cost: Double? = nil,
        hasCase: Bool = false,
        isTreasureHunt: Bool = false,
        notes: String? = nil,
        imageData: Data? = nil
    ) {
        self.name = name
        self.series = series
        self.color = color
        self.serialNumberCase = serialNumberCase
        self.serialNumberCar = serialNumberCar
        self.seriesNumber = seriesNumber
        self.yearDesigned = yearDesigned
        self.yearReleased = yearReleased
        self.yearReceived = yearReceived
        self.cost = cost
        self.hasCase = hasCase
        self.isTreasureHunt = isTreasureHunt
        self.notes = notes
        self.imageData = imageData
    }
}
