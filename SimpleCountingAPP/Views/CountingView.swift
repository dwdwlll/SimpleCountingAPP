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
    @State private var currentCount: Int
    
    init(item: CountItem, store: CountItemStore) {
        self.item = item
        self.store = store
        _currentCount = State(initialValue: item.count)
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Count Display
            Text(formattedCount)
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
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
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Increment Button
                Button(action: {
                    incrementCount()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.green)
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
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding(.bottom, 40)
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var formattedCount: String {
        let clampedCount = min(max(currentCount, 0), 9999)
        return String(format: "%04d", clampedCount)
    }
    
    private func incrementCount() {
        if currentCount < 9999 {
            currentCount += 1
            updateItem()
        }
    }
    
    private func decrementCount() {
        if currentCount > 0 {
            currentCount -= 1
            updateItem()
        }
    }
    
    private func resetCount() {
        currentCount = 0
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
            CountingView(item: CountItem(name: "测试项目", count: 42), store: CountItemStore())
        }
    }
}
