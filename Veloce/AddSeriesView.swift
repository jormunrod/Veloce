//
//  AddSeriesView.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 5/3/26.
//

import SwiftData
import SwiftUI

struct AddSeriesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var seriesToEdit: HotWheelSeries? = nil

    @State private var name: String = ""
    @State private var year: Int? = nil
    @State private var totalCars: String = ""
    @State private var notes: String = ""

    private var maxYear: Int {
        Calendar.current.component(.year, from: Date()) + 1
    }

    private var isTotalCarsValid: Bool {
        if totalCars.isEmpty { return true }
        if let value = Int(totalCars), value > 0 { return true }
        return false
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && isTotalCarsValid
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Collection Details") {
                    TextField("Series Name", text: $name)

                    Picker("Year", selection: $year) {
                        Text("Unknown").tag(Int?.none)
                        ForEach((1968...maxYear).reversed(), id: \.self) { y in
                            Text(String(y)).tag(Int?.some(y))
                        }
                    }

                    TextField("Total Cars (e.g., 5 or 10)", text: $totalCars)
                        .keyboardType(.numberPad)

                    if !isTotalCarsValid {
                        Text("Total cars must be a positive number.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("Additional Info") {
                    TextField("Notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(seriesToEdit == nil ? "New Series" : "Edit Series")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadData() }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveSeries() }
                        .disabled(!isFormValid)
                }
            }
        }
    }

    private func loadData() {
        guard let series = seriesToEdit else { return }
        name = series.name
        year = series.year
        totalCars = series.totalCars.map { String($0) } ?? ""
        notes = series.notes ?? ""
    }

    private func saveSeries() {
        let parsedTotalCars = Int(totalCars)

        if let series = seriesToEdit {
            series.name = name
            series.year = year
            series.totalCars = parsedTotalCars
            series.notes = notes.isEmpty ? nil : notes
        } else {
            let newSeries = HotWheelSeries(
                name: name,
                year: year,
                totalCars: parsedTotalCars,
                notes: notes.isEmpty ? nil : notes
            )
            context.insert(newSeries)
        }
        dismiss()
    }
}
