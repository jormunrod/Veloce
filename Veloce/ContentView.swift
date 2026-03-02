//
//  ContentView.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \HotWheel.name) private var cars: [HotWheel]
    @Environment(\.modelContext) private var context

    @State private var isShowingAddView = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(cars) { car in
                    HStack(spacing: 16) {

                        if let imageData = car.imageData,
                            let uiImage = UIImage(data: imageData)
                        {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Image(systemName: "car.fill")
                                        .foregroundColor(.secondary)
                                }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(car.name)
                                .font(.headline)

                            HStack {
                                Text(car.series?.name ?? "No Series")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                if let year = car.yearReleased {
                                    Text("• \(String(year))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                if car.isTreasureHunt {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteCars)
            }
            .navigationTitle("My Collection")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddView) {
                AddCarView()
            }
            .overlay {
                if cars.isEmpty {
                    ContentUnavailableView(
                        "Empty Collection",
                        systemImage: "car",
                        description: Text("Tap the + to add your first model.")
                    )
                }
            }
        }
    }

    private func deleteCars(offsets: IndexSet) {
        for index in offsets {
            context.delete(cars[index])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: HotWheel.self, inMemory: true)
}
