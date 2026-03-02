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
    var name: String
    var series: String
    var year: Int
    var color: String
    var isTreasureHunt: Bool
    
    @Attribute(.externalStorage) var imageData: Data?
    
    init(name: String, series: String, year: Int, color: String, isTreasureHunt: Bool = false, imageData: Data? = nil) {
        self.name = name
        self.series = series
        self.year = year
        self.color = color
        self.isTreasureHunt = isTreasureHunt
        self.imageData = imageData
    }
}
