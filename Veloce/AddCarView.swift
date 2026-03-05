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

    @Query(sort: \HotWheelSeries.name) private var allSeries: [HotWheelSeries]

    var carToEdit: HotWheel? = nil

    @State private var name: String = ""
    @State private var selectedSeries: HotWheelSeries?
    @State private var color: String = ""

    @State private var serialNumberCase: String = ""
    @State private var serialNumberCar: String = ""
    @State private var seriesNumber: String = ""
    @State private var yearDesigned: Int? = nil
    @State private var yearReleased: Int? = nil
    @State private var yearReceived: Int? = nil
    @State private var cost: String = ""
    @State private var notes: String = ""

    @State private var hasCase: Bool = false
    @State private var isTreasureHunt: Bool = false

    @State private var imageData: Data? = nil
    @State private var isShowingPhotoPicker = false
    @State private var isShowingPhotoOptions = false
    @State private var photoSource: UIImagePickerController.SourceType =
        .photoLibrary

    private var maxYear: Int {
        Calendar.current.component(.year, from: Date()) + 1
    }

    private let predefinedColors: [(name: String, value: Color)] = [
        ("Black", .black), ("White", .white), ("Silver", .gray),
        ("Red", .red), ("Blue", .blue), ("Green", .green),
        ("Yellow", .yellow), ("Orange", .orange), ("Purple", .purple),
        ("Pink", .pink), ("Brown", .brown), ("Gold", .yellow.opacity(0.8)),
    ]

    private var isCostValid: Bool {
        let trimmed = cost.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return true }
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        return Double(normalized) != nil
    }

    private var isSeriesNumberValid: Bool {
        let trimmed = seriesNumber.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return true }

        let firstNumberStr =
            trimmed.components(separatedBy: "/").first ?? trimmed

        guard let enteredNumber = Int(firstNumberStr) else { return false }
        guard enteredNumber > 0 else { return false }

        if let total = selectedSeries?.totalCars {
            return enteredNumber <= total
        }

        return true
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && isCostValid
            && isSeriesNumberValid
    }

    private var seriesNumberPlaceholder: String {
        if selectedSeries?.totalCars != nil {
            return "Car Number (e.g. 1)"
        }
        return "Series Number (e.g. 1/5)"
    }

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

                    HStack {
                        TextField(seriesNumberPlaceholder, text: $seriesNumber)
                            .onChange(of: seriesNumber) { _, newValue in
                                seriesNumber = newValue.filter {
                                    $0.isNumber || $0 == "/"
                                }
                            }

                        if let total = selectedSeries?.totalCars {
                            Text("Max: \(total)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !isSeriesNumberValid {
                        if let total = selectedSeries?.totalCars {
                            Text(
                                "Must be a valid number between 1 and \(total)."
                            )
                            .font(.caption)
                            .foregroundStyle(.red)
                        } else {
                            Text("Must be a positive number.")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Color (e.g. Red or Zamac)", text: $color)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(predefinedColors, id: \.name) {
                                    preset in
                                    let isSelected =
                                        color.lowercased()
                                        == preset.name.lowercased()

                                    Circle()
                                        .fill(preset.value)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    isSelected
                                                        ? Color.accentColor
                                                        : Color.secondary
                                                            .opacity(0.3),
                                                    lineWidth: isSelected
                                                        ? 3 : 1
                                                )
                                        )
                                        .onTapGesture {
                                            UIImpactFeedbackGenerator(
                                                style: .light
                                            ).impactOccurred()
                                            color = preset.name
                                        }
                                }
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 2)
                        }
                    }
                }

                Section("Identifiers") {
                    TextField("S.N. (case)", text: $serialNumberCase)
                    TextField("S.N. (car)", text: $serialNumberCar)
                }

                Section("Dates") {
                    Picker("Designed Year", selection: $yearDesigned) {
                        Text("Unknown").tag(Int?.none)
                        ForEach((1968...maxYear).reversed(), id: \.self) {
                            year in
                            Text(String(year)).tag(Int?.some(year))
                        }
                    }

                    Picker("Release Year", selection: $yearReleased) {
                        Text("Unknown").tag(Int?.none)
                        ForEach((1968...maxYear).reversed(), id: \.self) {
                            year in
                            Text(String(year)).tag(Int?.some(year))
                        }
                    }

                    Picker("Received Year", selection: $yearReceived) {
                        Text("Unknown").tag(Int?.none)
                        ForEach((1968...maxYear).reversed(), id: \.self) {
                            year in
                            Text(String(year)).tag(Int?.some(year))
                        }
                    }
                }

                Section("Acquisition & Status") {
                    TextField("Cost (€)", text: $cost)
                        .keyboardType(.decimalPad)
                        .onChange(of: cost) { _, newValue in
                            let filtered = newValue.filter {
                                $0.isNumber || $0 == "." || $0 == ","
                            }
                            cost = filtered.replacingOccurrences(
                                of: ",",
                                with: "."
                            )
                        }

                    if !isCostValid {
                        Text("Please enter a valid amount (e.g. 2.50)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Toggle("Has Case (Protector)", isOn: $hasCase)
                    Toggle("Is Treasure Hunt", isOn: $isTreasureHunt)
                    TextField("Comment", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(carToEdit == nil ? "New Hot Wheel" : "Edit Model")
            .onAppear { loadData() }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCar() }
                        .disabled(!isFormValid)
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
        }
    }

    private func loadData() {
        guard let car = carToEdit else { return }
        name = car.name
        selectedSeries = car.series
        color = car.color
        serialNumberCase = car.serialNumberCase ?? ""
        serialNumberCar = car.serialNumberCar ?? ""
        seriesNumber = car.seriesNumber ?? ""
        yearDesigned = car.yearDesigned
        yearReleased = car.yearReleased
        yearReceived = car.yearReceived
        cost = car.cost.map { String(format: "%.2f", $0) } ?? ""
        hasCase = car.hasCase
        isTreasureHunt = car.isTreasureHunt
        notes = car.notes ?? ""
        imageData = car.imageData
    }

    private func getFormattedSeriesNumber() -> String? {
        let trimmed = seriesNumber.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return nil }

        if let total = selectedSeries?.totalCars, !trimmed.contains("/") {
            return "\(trimmed)/\(total)"
        }
        return trimmed
    }

    private func saveCar() {
        let parsedCost = Double(cost.replacingOccurrences(of: ",", with: "."))
        let formattedSeriesNumber = getFormattedSeriesNumber()

        if let car = carToEdit {
            car.name = name
            car.series = selectedSeries
            car.color = color
            car.serialNumberCase =
                serialNumberCase.isEmpty ? nil : serialNumberCase
            car.serialNumberCar =
                serialNumberCar.isEmpty ? nil : serialNumberCar
            car.seriesNumber = formattedSeriesNumber
            car.yearDesigned = yearDesigned
            car.yearReleased = yearReleased
            car.yearReceived = yearReceived
            car.cost = parsedCost
            car.hasCase = hasCase
            car.isTreasureHunt = isTreasureHunt
            car.notes = notes.isEmpty ? nil : notes
            car.imageData = imageData
        } else {
            let newCar = HotWheel(
                name: name,
                series: selectedSeries,
                color: color,
                serialNumberCase: serialNumberCase.isEmpty
                    ? nil : serialNumberCase,
                serialNumberCar: serialNumberCar.isEmpty
                    ? nil : serialNumberCar,
                seriesNumber: formattedSeriesNumber,
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
        }
        dismiss()
    }
}
