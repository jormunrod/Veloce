//
//  HotWheelSeries.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import Foundation
import SwiftData

@Model
final class HotWheelSeries {
    @Attribute(.unique) var name: String
    
    var year: Int?
    var totalCars: Int?
    var notes: String?
    
    @Attribute(.externalStorage) var imageData: Data?

    @Relationship(deleteRule: .nullify, inverse: \HotWheel.series)
    var cars: [HotWheel]? = []

    init(
        name: String,
        year: Int? = nil,
        totalCars: Int? = nil,
        notes: String? = nil,
        imageData: Data? = nil
    ) {
        self.name = name
        self.year = year
        self.totalCars = totalCars
        self.notes = notes
        self.imageData = imageData
    }
}
