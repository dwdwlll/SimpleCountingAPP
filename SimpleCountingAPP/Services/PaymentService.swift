//
//  PaymentService.swift
//  SimpleCountingAPP
//
//  Created on 2026-01-04.
//

import Foundation

// Payment result enum
enum PaymentResult {
    case success(transactionId: String)
    case cancelled
    case failed(error: Error)
}

// Payment error types
enum PaymentError: Error {
    case notConfigured
    case invalidAmount
    case userCancelled
    case networkError
    case unknown(String)
}

// Protocol for payment service providers
protocol PaymentService {
    var providerName: String { get }
    var isConfigured: Bool { get }
    
    func configure(with configuration: [String: Any])
    func processPurchase(itemId: String, amount: Double, currency: String, completion: @escaping (PaymentResult) -> Void)
    func restorePurchases(completion: @escaping ([String]) -> Void)
}

// Payment manager to handle multiple payment providers
class PaymentManager: ObservableObject {
    @Published var currentProvider: PaymentService?
    private var providers: [String: PaymentService] = [:]
    
    static let shared = PaymentManager()
    
    private init() {
        // Register available payment providers
        registerProvider(StripePaymentService())
        // Future providers can be added here:
        // registerProvider(ApplePayService())
        // registerProvider(PayPalService())
    }
    
    func registerProvider(_ provider: PaymentService) {
        providers[provider.providerName] = provider
    }
    
    func setCurrentProvider(name: String) {
        currentProvider = providers[name]
    }
    
    func purchase(itemId: String, amount: Double, currency: String = "USD", completion: @escaping (PaymentResult) -> Void) {
        guard let provider = currentProvider, provider.isConfigured else {
            completion(.failed(error: PaymentError.notConfigured))
            return
        }
        
        provider.processPurchase(itemId: itemId, amount: amount, currency: currency, completion: completion)
    }
    
    func restorePurchases(completion: @escaping ([String]) -> Void) {
        guard let provider = currentProvider else {
            completion([])
            return
        }
        
        provider.restorePurchases(completion: completion)
    }
}
