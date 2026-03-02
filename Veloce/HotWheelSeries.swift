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

    @Relationship(deleteRule: .nullify, inverse: \HotWheel.series)
    var cars: [HotWheel]? = []

    init(name: String) {
        self.name = name
    }
}
