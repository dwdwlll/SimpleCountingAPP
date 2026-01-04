//
//  NetworkService.swift
//  SimpleCountingAPP
//
//  Created on 2026-01-04.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    // 配置后端服务器地址
    private let baseURL = "http://localhost:5000"
    
    private init() {}
    
    // MARK: - Auth Endpoints
    
    func register(username: String, email: String, password: String) async throws -> (token: String, user: User) {
        let url = URL(string: "\(baseURL)/api/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode != 201 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.error)
            }
            throw NetworkError.serverError("注册失败")
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        return (authResponse.token, authResponse.user)
    }
    
    func login(email: String, password: String) async throws -> (token: String, user: User) {
        let url = URL(string: "\(baseURL)/api/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.error)
            }
            throw NetworkError.serverError("登录失败")
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        return (authResponse.token, authResponse.user)
    }
    
    // MARK: - Payment Endpoints
    
    func createPaymentIntent(token: String, itemId: String, amount: Int, currency: String = "usd") async throws -> PaymentIntentResponse {
        let url = URL(string: "\(baseURL)/api/payments/create-intent")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "item_id": itemId,
            "amount": amount,
            "currency": currency
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.error)
            }
            throw NetworkError.serverError("创建支付失败")
        }
        
        return try JSONDecoder().decode(PaymentIntentResponse.self, from: data)
    }
    
    func confirmPayment(token: String, paymentIntentId: String) async throws -> PaymentConfirmResponse {
        let url = URL(string: "\(baseURL)/api/payments/confirm")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "payment_intent_id": paymentIntentId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.error)
            }
            throw NetworkError.serverError("确认支付失败")
        }
        
        return try JSONDecoder().decode(PaymentConfirmResponse.self, from: data)
    }
}

// MARK: - Response Models

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct ErrorResponse: Codable {
    let error: String
}

struct PaymentIntentResponse: Codable {
    let clientSecret: String
    let paymentIntentId: String
    
    enum CodingKeys: String, CodingKey {
        case clientSecret = "client_secret"
        case paymentIntentId = "payment_intent_id"
    }
}

struct PaymentConfirmResponse: Codable {
    let status: String
    let paymentIntentId: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case paymentIntentId = "payment_intent_id"
    }
}

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "无效的服务器响应"
        case .serverError(let message):
            return message
        }
    }
}
