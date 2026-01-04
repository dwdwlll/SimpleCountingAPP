//
//  CountItemStore.swift
//  SimpleCountingAPP
//
//  Created on 2026-01-04.
//

import Foundation

class CountItemStore: ObservableObject {
    @Published var items: [CountItem] = []
    
    private let itemsKey = "countItems"
    
    init() {
        loadItems()
    }
    
    func addItem(name: String) {
        let newItem = CountItem(name: name)
        items.append(newItem)
        saveItems()
    }
    
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveItems()
    }
    
    func deleteItems(itemsToDelete: [CountItem]) {
        let idsToDelete = Set(itemsToDelete.map { $0.id })
        self.items.removeAll { idsToDelete.contains($0.id) }
        saveItems()
    }
    
    func updateItem(_ item: CountItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveItems()
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([CountItem].self, from: data) {
            items = decoded
        }
    }
}
