//
//  SkinStore.swift
//  SimpleCountingAPP
//
//  Created on 2026-01-04.
//

import Foundation

class SkinStore: ObservableObject {
    @Published var skins: [CounterSkin] = []
    @Published var selectedSkinId: String = "default"
    @Published var purchasedSkinIds: Set<String> = ["default"]
    
    private let skinsKey = "counterSkins"
    private let selectedSkinKey = "selectedSkinId"
    private let purchasedSkinsKey = "purchasedSkinIds"
    
    init() {
        loadSkins()
        loadSelectedSkin()
        loadPurchasedSkins()
    }
    
    var selectedSkin: CounterSkin {
        skins.first { $0.id == selectedSkinId } ?? CounterSkin.defaultSkin
    }
    
    func selectSkin(_ skin: CounterSkin) {
        guard skin.isPurchased || purchasedSkinIds.contains(skin.id) else {
            return
        }
        selectedSkinId = skin.id
        saveSelectedSkin()
    }
    
    func purchaseSkin(_ skinId: String) {
        purchasedSkinIds.insert(skinId)
        if let index = skins.firstIndex(where: { $0.id == skinId }) {
            skins[index].isPurchased = true
        }
        savePurchasedSkins()
        saveSkins()
    }
    
    func isSkinPurchased(_ skinId: String) -> Bool {
        return purchasedSkinIds.contains(skinId) || skins.first(where: { $0.id == skinId })?.isDefault == true
    }
    
    private func loadSkins() {
        // Initialize with default skins
        skins = CounterSkin.allSkins.map { skin in
            var updatedSkin = skin
            updatedSkin.isPurchased = isSkinPurchased(skin.id) || skin.isDefault
            return updatedSkin
        }
    }
    
    private func saveSkins() {
        if let encoded = try? JSONEncoder().encode(skins) {
            UserDefaults.standard.set(encoded, forKey: skinsKey)
        }
    }
    
    private func loadSelectedSkin() {
        if let savedSkinId = UserDefaults.standard.string(forKey: selectedSkinKey) {
            selectedSkinId = savedSkinId
        }
    }
    
    private func saveSelectedSkin() {
        UserDefaults.standard.set(selectedSkinId, forKey: selectedSkinKey)
    }
    
    private func loadPurchasedSkins() {
        if let data = UserDefaults.standard.data(forKey: purchasedSkinsKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            purchasedSkinIds = decoded
        } else {
            // Default skins are always purchased
            purchasedSkinIds = ["default"]
        }
    }
    
    private func savePurchasedSkins() {
        if let encoded = try? JSONEncoder().encode(purchasedSkinIds) {
            UserDefaults.standard.set(encoded, forKey: purchasedSkinsKey)
        }
    }
}
