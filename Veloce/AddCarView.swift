//
//  AddCarView.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import SwiftUI
import SwiftData

struct AddCarView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var series: String = ""
    @State private var year: Int = Calendar.current.component(.year, from: Date())
    @State private var color: String = ""
    @State private var isTreasureHunt: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detalles del modelo") {
                    TextField("Nombre (ej. Twin Mill)", text: $name)
                    TextField("Serie", text: $series)
                    TextField("Color principal", text: $color)
                }
                
                Section("Especificaciones") {
                    Stepper("Año: \(year)", value: $year, in: 1968...2030)
                    Toggle("Es Treasure Hunt", isOn: $isTreasureHunt)
                }
            }
            .navigationTitle("Nuevo Hot Wheel")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { saveCar() }
                        .disabled(name.isEmpty || series.isEmpty)
                }
            }
        }
    }
    
    private func saveCar() {
        let newCar = HotWheel(name: name, series: series, year: year, color: color, isTreasureHunt: isTreasureHunt)
        context.insert(newCar)
        dismiss()
    }
}

#Preview {
    AddCarView()
}
