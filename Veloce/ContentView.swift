//
//  ContentView.swift
//  Veloce
//
//  Created by Jorge Muñoz Rodríguez on 2/3/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \HotWheel.name) private var cars: [HotWheel]
    @Environment(\.modelContext) private var context
    
    @State private var isShowingAddView = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(cars) { car in
                    VStack(alignment: .leading) {
                        Text(car.name)
                            .font(.headline)
                        Text("\(car.series) • \(String(car.year))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deleteCars)
            }
            .navigationTitle("Mi Colección")
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
                    ContentUnavailableView("Colección vacía",
                                           systemImage: "car",
                                           description: Text("Toca el + para añadir tu primer modelo."))
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
