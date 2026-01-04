//
//  CountingView.swift
//  SimpleCountingAPP
//
//  Created on 2026-01-04.
//

import SwiftUI

struct CountingView: View {
    let item: CountItem
    @ObservedObject var store: CountItemStore
    @ObservedObject var skinStore: SkinStore
    @State private var currentCount: Int
    
    private let minCount = 0
    private let maxCount = 9999
    
    init(item: CountItem, store: CountItemStore, skinStore: SkinStore) {
        self.item = item
        self.store = store
        self.skinStore = skinStore
        _currentCount = State(initialValue: item.count)
    }
    
    var body: some View {
        let skin = skinStore.selectedSkin
        
        VStack(spacing: 40) {
            Spacer()
            
            // Count Display
            Text(formattedCount)
                .font(fontForStyle(skin.fontStyle, size: 80))
                .foregroundColor(skin.color(from: skin.textColor))
                .frame(minWidth: 200)
                .padding()
            
            // Buttons
            HStack(spacing: 30) {
                // Decrement Button
                Button(action: {
                    decrementCount()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(skin.color(from: skin.decrementColor))
                }
                .buttonStyle(PlainButtonStyle())
                
                // Increment Button
                Button(action: {
                    incrementCount()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(skin.color(from: skin.incrementColor))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            
            Spacer()
            
            // Reset Button
            Button(action: {
                resetCount()
            }) {
                Text("重置")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(skin.color(from: skin.resetColor))
                    .cornerRadius(10)
            }
            .padding(.bottom, 40)
        }
        .background(skin.color(from: skin.backgroundColor).edgesIgnoringSafeArea(.all))
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func fontForStyle(_ style: FontStyle, size: CGFloat) -> Font {
        switch style {
        case .rounded:
            return .system(size: size, weight: .bold, design: .rounded)
        case .serif:
            return .system(size: size, weight: .bold, design: .serif)
        case .monospaced:
            return .system(size: size, weight: .bold, design: .monospaced)
        case .standard:
            return .system(size: size, weight: .bold, design: .default)
        }
    }
    
    private var formattedCount: String {
        return String(format: "%04d", currentCount)
    }
    
    private func incrementCount() {
        if currentCount < maxCount {
            currentCount += 1
            updateItem()
        }
    }
    
    private func decrementCount() {
        if currentCount > minCount {
            currentCount -= 1
            updateItem()
        }
    }
    
    private func resetCount() {
        currentCount = minCount
        updateItem()
    }
    
    private func updateItem() {
        var updatedItem = item
        updatedItem.count = currentCount
        store.updateItem(updatedItem)
    }
}

struct CountingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CountingView(item: CountItem(name: "测试项目", count: 42), store: CountItemStore(), skinStore: SkinStore())
        }
    }
}
