//
//  SkinShopView.swift
//  SimpleCountingAPP
//
//  Created on 2026-01-04.
//

import SwiftUI

struct SkinShopView: View {
    @ObservedObject var skinStore: SkinStore
    @ObservedObject var authState: AuthState
    @State private var selectedCategory: SkinCategory?
    @State private var showingPurchaseSheet = false
    @State private var skinToPurchase: CounterSkin?
    @State private var isProcessingPayment = false
    
    var filteredSkins: [CounterSkin] {
        if let category = selectedCategory {
            return skinStore.skins.filter { $0.category == category }
        }
        return skinStore.skins
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryChip(
                                title: "全部",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(SkinCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    // Skins grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredSkins) { skin in
                            SkinCard(
                                skin: skin,
                                isSelected: skinStore.selectedSkinId == skin.id,
                                isPurchased: skinStore.isSkinPurchased(skin.id),
                                onSelect: {
                                    if skinStore.isSkinPurchased(skin.id) {
                                        skinStore.selectSkin(skin)
                                    } else {
                                        skinToPurchase = skin
                                        showingPurchaseSheet = true
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("皮肤商城")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPurchaseSheet) {
                if let skin = skinToPurchase {
                    PurchaseSheet(
                        skin: skin,
                        isProcessing: $isProcessingPayment,
                        onPurchase: {
                            purchaseSkin(skin)
                        },
                        onCancel: {
                            showingPurchaseSheet = false
                        }
                    )
                }
            }
        }
    }
    
    private func purchaseSkin(_ skin: CounterSkin) {
        guard let token = authState.token else {
            isProcessingPayment = false
            showingPurchaseSheet = false
            return
        }
        
        isProcessingPayment = true
        
        Task {
            do {
                // 1. 向服务器发送支付请求，创建支付意图
                let amountInCents = Int(skin.price * 100) // 转换为分
                let paymentIntent = try await NetworkService.shared.createPaymentIntent(
                    token: token,
                    itemId: skin.id,
                    amount: amountInCents,
                    currency: "usd"
                )
                
                // 2. 模拟支付流程（在实际应用中，这里会调用 Stripe SDK）
                // 等待一小段时间模拟支付过程
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                
                // 3. 确认支付
                let confirmResult = try await NetworkService.shared.confirmPayment(
                    token: token,
                    paymentIntentId: paymentIntent.paymentIntentId
                )
                
                await MainActor.run {
                    if confirmResult.status == "succeeded" {
                        // 支付成功，标记皮肤为已购买
                        skinStore.purchaseSkin(skin.id)
                        skinStore.selectSkin(skin)
                    }
                    
                    isProcessingPayment = false
                    showingPurchaseSheet = false
                }
                
            } catch {
                await MainActor.run {
                    // 支付失败，显示错误（在生产环境中应该显示警告对话框）
                    isProcessingPayment = false
                    showingPurchaseSheet = false
                }
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct SkinCard: View {
    let skin: CounterSkin
    let isSelected: Bool
    let isPurchased: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Skin preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(skin.color(from: skin.backgroundColor))
                        .frame(height: 120)
                    
                    VStack(spacing: 8) {
                        Text("8888")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(skin.color(from: skin.textColor))
                        
                        HStack(spacing: 16) {
                            Circle()
                                .fill(skin.color(from: skin.decrementColor))
                                .frame(width: 24, height: 24)
                            Circle()
                                .fill(skin.color(from: skin.incrementColor))
                                .frame(width: 24, height: 24)
                        }
                    }
                    
                    // Selected badge
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .background(Circle().fill(Color.white))
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                }
                
                // Skin info
                VStack(alignment: .leading, spacing: 4) {
                    Text(skin.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(skin.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    if isPurchased {
                        Text("已拥有")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    } else if skin.price > 0 {
                        Text("$\(String(format: "%.2f", skin.price))")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    } else {
                        Text("免费")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PurchaseSheet: View {
    let skin: CounterSkin
    @Binding var isProcessing: Bool
    let onPurchase: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Skin preview
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(skin.color(from: skin.backgroundColor))
                        .frame(height: 200)
                    
                    VStack(spacing: 16) {
                        Text("8888")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(skin.color(from: skin.textColor))
                        
                        HStack(spacing: 24) {
                            Circle()
                                .fill(skin.color(from: skin.decrementColor))
                                .frame(width: 40, height: 40)
                            Circle()
                                .fill(skin.color(from: skin.incrementColor))
                                .frame(width: 40, height: 40)
                        }
                    }
                }
                .padding()
                
                // Skin details
                VStack(spacing: 12) {
                    Text(skin.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(skin.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("$\(String(format: "%.2f", skin.price))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                }
                .padding()
                
                Spacer()
                
                // Purchase button
                Button(action: onPurchase) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    } else {
                        Text("购买皮肤")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                }
                .background(Color.blue)
                .cornerRadius(12)
                .disabled(isProcessing)
                .padding(.horizontal)
                
                Text("支付方式: Stripe (服务器端)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .padding()
            .navigationTitle("购买皮肤")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        onCancel()
                    }
                    .disabled(isProcessing)
                }
            }
        }
    }
}

struct SkinShopView_Previews: PreviewProvider {
    static var previews: some View {
        SkinShopView(skinStore: SkinStore(), authState: AuthState())
    }
}
