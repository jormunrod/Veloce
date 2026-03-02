//
//  AddCarView.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import SwiftData
import SwiftUI

struct AddCarView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // Database query for existing series
    @Query(sort: \HotWheelSeries.name) private var allSeries: [HotWheelSeries]

    // Required states
    @State private var name: String = ""
    @State private var selectedSeries: HotWheelSeries?
    @State private var color: String = ""

    // Optional states
    @State private var serialNumberCase: String = ""
    @State private var serialNumberCar: String = ""
    @State private var seriesNumber: String = ""
    @State private var yearDesigned: Int? = nil
    @State private var yearReleased: Int? = nil
    @State private var yearReceived: Int? = nil
    @State private var cost: String = ""
    @State private var notes: String = ""

    // Boolean states
    @State private var hasCase: Bool = false
    @State private var isTreasureHunt: Bool = false

    // Image states
    @State private var imageData: Data? = nil
    @State private var isShowingPhotoPicker = false
    @State private var isShowingPhotoOptions = false
    @State private var photoSource: UIImagePickerController.SourceType =
        .photoLibrary

    // New series creation states
    @State private var isShowingNewSeriesAlert = false
    @State private var newSeriesName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    if let imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    Button(action: { isShowingPhotoOptions = true }) {
                        Label(
                            imageData == nil ? "Add Photo" : "Change Photo",
                            systemImage: "photo.badge.plus"
                        )
                    }
                }

                Section("Basic Info") {
                    TextField("Model Name", text: $name)

                    Picker("Select Series", selection: $selectedSeries) {
                        Text("None").tag(HotWheelSeries?.none)
                        ForEach(allSeries) { series in
                            Text(series.name).tag(HotWheelSeries?.some(series))
                        }
                    }

                    Button("Create New Series...") {
                        isShowingNewSeriesAlert = true
                    }

                    TextField("Series Number (e.g. 1/5)", text: $seriesNumber)
                    TextField("Color", text: $color)
                }

                Section("Identifiers") {
                    TextField("S.N. (case)", text: $serialNumberCase)
                    TextField("S.N. (car)", text: $serialNumberCar)
                }

                Section("Dates") {
                    Picker("Designed Year", selection: $yearDesigned) {
                        Text("Unknown").tag(Int?.none)
                        ForEach((1968...2027).reversed(), id: \.self) { year in
                            Text(String(year)).tag(Int?.some(year))
                        }
                    }

                    Picker("Release Year", selection: $yearReleased) {
                        Text("Unknown").tag(Int?.none)
                        ForEach((1968...2027).reversed(), id: \.self) { year in
                            Text(String(year)).tag(Int?.some(year))
                        }
                    }

                    Picker("Received Year", selection: $yearReceived) {
                        Text("Unknown").tag(Int?.none)
                        ForEach((2000...2030).reversed(), id: \.self) { year in
                            Text(String(year)).tag(Int?.some(year))
                        }
                    }
                }

                Section("Acquisition & Status") {
                    TextField("Cost (€)", text: $cost)
                        .keyboardType(.decimalPad)
                    Toggle("Has Case (Protector)", isOn: $hasCase)
                    Toggle("Is Treasure Hunt", isOn: $isTreasureHunt)
                    TextField("Comment", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Hot Wheel")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCar() }
                        .disabled(name.isEmpty || selectedSeries == nil)
                }
            }
            .confirmationDialog(
                "Choose Photo Source",
                isPresented: $isShowingPhotoOptions,
                titleVisibility: .visible
            ) {
                Button("Camera") {
                    photoSource = .camera
                    isShowingPhotoPicker = true
                }
                Button("Photo Library") {
                    photoSource = .photoLibrary
                    isShowingPhotoPicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $isShowingPhotoPicker) {
                ImagePicker(
                    selectedImageData: $imageData,
                    sourceType: photoSource
                )
                .ignoresSafeArea()
            }
            .alert("New Series", isPresented: $isShowingNewSeriesAlert) {
                TextField("Name (e.g. HW J-Imports)", text: $newSeriesName)
                Button("Cancel", role: .cancel) { newSeriesName = "" }
                Button("Create") {
                    let newSeries = HotWheelSeries(name: newSeriesName)
                    context.insert(newSeries)
                    selectedSeries = newSeries
                    newSeriesName = ""
                }
            } message: {
                Text("Enter the name for the new series.")
            }
        }
    }

    private func saveCar() {
        let parsedCost = Double(cost.replacingOccurrences(of: ",", with: "."))

        let newCar = HotWheel(
            name: name,
            series: selectedSeries,
            color: color,
            serialNumberCase: serialNumberCase.isEmpty ? nil : serialNumberCase,
            serialNumberCar: serialNumberCar.isEmpty ? nil : serialNumberCar,
            seriesNumber: seriesNumber.isEmpty ? nil : seriesNumber,
            yearDesigned: yearDesigned,
            yearReleased: yearReleased,
            yearReceived: yearReceived,
            cost: parsedCost,
            hasCase: hasCase,
            isTreasureHunt: isTreasureHunt,
            notes: notes.isEmpty ? nil : notes,
            imageData: imageData
        )

        context.insert(newCar)
        dismiss()
    }
}
