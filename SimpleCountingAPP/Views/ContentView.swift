//
//  ContentView.swift
//  SimpleCountingAPP
//
//  Created on 2026-01-04.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = CountItemStore()
    @StateObject private var skinStore = SkinStore()
    @State private var showingAddSheet = false
    @State private var newItemName = ""
    @State private var editMode = EditMode.inactive
    @State private var selectedItems = Set<UUID>()
    @State private var showingSkinShop = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List(selection: $selectedItems) {
                    ForEach(store.items) { item in
                        NavigationLink(destination: CountingView(item: item, store: store, skinStore: skinStore)) {
                            HStack {
                                Text(item.name)
                                    .font(.headline)
                                Spacer()
                                Text("\(item.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .environment(\.editMode, $editMode)
                .navigationTitle("计数项目")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if editMode == .active && !selectedItems.isEmpty {
                            Button("删除选中") {
                                deleteSelectedItems()
                            }
                            .foregroundColor(.red)
                        } else if editMode == .active {
                            Button("取消") {
                                editMode = .inactive
                                selectedItems.removeAll()
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            // Skin shop button
                            Button(action: {
                                showingSkinShop = true
                            }) {
                                Image(systemName: "paintbrush.fill")
                            }
                            .disabled(editMode == .active)
                            
                            if !store.items.isEmpty {
                                Button(editMode == .active ? "完成" : "选择") {
                                    withAnimation {
                                        if editMode == .active {
                                            editMode = .inactive
                                            selectedItems.removeAll()
                                        } else {
                                            editMode = .active
                                        }
                                    }
                                }
                            }
                            
                            Button(action: {
                                showingAddSheet = true
                            }) {
                                Image(systemName: "plus")
                            }
                            .disabled(editMode == .active)
                        }
                    }
                }
                
                if store.items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "list.number")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                        Text("暂无计数项目")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("点击右上角 + 创建新项目")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddItemSheet(isPresented: $showingAddSheet, store: store)
            }
            .sheet(isPresented: $showingSkinShop) {
                SkinShopView(skinStore: skinStore)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func deleteItems(at offsets: IndexSet) {
        store.deleteItems(at: offsets)
    }
    
    private func deleteSelectedItems() {
        let itemsToDelete = store.items.filter { selectedItems.contains($0.id) }
        store.deleteItems(itemsToDelete: itemsToDelete)
        selectedItems.removeAll()
        editMode = .inactive
    }
}

struct AddItemSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var store: CountItemStore
    @State private var itemName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("项目名称")) {
                    TextField("输入项目名称", text: $itemName)
                }
            }
            .navigationTitle("创建计数项目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("创建") {
                        if !itemName.trimmingCharacters(in: .whitespaces).isEmpty {
                            store.addItem(name: itemName)
                            isPresented = false
                        }
                    }
                    .disabled(itemName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
