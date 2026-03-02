//
//  BackupModels.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct HotWheelDTO: Codable {
    var name: String
    var seriesName: String?
    var color: String
    var serialNumberCase: String?
    var serialNumberCar: String?
    var seriesNumber: String?
    var yearDesigned: Int?
    var yearReleased: Int?
    var yearReceived: Int?
    var cost: Double?
    var hasCase: Bool
    var isTreasureHunt: Bool
    var notes: String?
    var imageData: Data?
}

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var dtos: [HotWheelDTO]

    init(dtos: [HotWheelDTO] = []) { self.dtos = dtos }

    init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents ?? Data()
        self.dtos = try JSONDecoder().decode([HotWheelDTO].self, from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(dtos)
        return FileWrapper(regularFileWithContents: data)
    }
}
