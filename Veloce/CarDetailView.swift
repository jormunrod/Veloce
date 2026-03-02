//
//  CarDetailView.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import SwiftData
import SwiftUI

struct CarDetailView: View {

    let car: HotWheel

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingEditView = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let imageData = car.imageData,
                    let uiImage = UIImage(data: imageData)
                {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                        .padding(.horizontal)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "car.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                        )
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(car.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        if car.isTreasureHunt {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.title)
                        }
                    }
                    Text(car.series?.name ?? "No Series")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                VStack(spacing: 20) {
                    DetailSection(title: "Basic Info") {
                        DetailRow(label: "Color", value: car.color)
                        DetailRow(
                            label: "Series Number",
                            value: car.seriesNumber
                        )
                    }

                    DetailSection(title: "Identifiers") {
                        DetailRow(
                            label: "S.N. (Case)",
                            value: car.serialNumberCase
                        )
                        DetailRow(
                            label: "S.N. (Car)",
                            value: car.serialNumberCar
                        )
                    }

                    DetailSection(title: "Dates") {
                        DetailRow(
                            label: "Designed",
                            value: car.yearDesigned?.description
                        )
                        DetailRow(
                            label: "Released",
                            value: car.yearReleased?.description
                        )
                        DetailRow(
                            label: "Received",
                            value: car.yearReceived?.description
                        )
                    }

                    DetailSection(title: "Acquisition & Status") {
                        if let cost = car.cost {
                            DetailRow(
                                label: "Cost",
                                value: String(format: "€%.2f", cost)
                            )
                        } else {
                            DetailRow(label: "Cost", value: nil)
                        }
                        DetailRow(
                            label: "Has Case",
                            value: car.hasCase ? "Yes" : "No"
                        )
                    }

                    if let notes = car.notes {
                        DetailSection(title: "Comments") {
                            Text(notes)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    Button(role: .destructive) {
                        isShowingDeleteConfirmation = true
                    } label: {
                        Label("Delete Car", systemImage: "trash")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 16)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isShowingEditView = true
                }
            }
        }
        .sheet(isPresented: $isShowingEditView) {
            AddCarView(carToEdit: car)
        }
        .alert("Delete Car", isPresented: $isShowingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                context.delete(car)
                dismiss()
            }
        } message: {
            Text(
                "Are you sure you want to delete this car? This action cannot be undone."
            )
        }
    }
}

// MARK: - Reusable UI Components

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                content
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String?

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            Text(value ?? "N/A")
                .foregroundColor(.secondary)
        }
    }
}
