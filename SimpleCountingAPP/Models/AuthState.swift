//
//  AuthState.swift
//  SimpleCountingAPP
//
//  Created on 2026-01-04.
//

import Foundation

class AuthState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var token: String?
    
    private let tokenKey = "authToken"
    private let userKey = "currentUser"
    
    init() {
        loadAuthState()
    }
    
    func login(token: String, user: User) {
        self.token = token
        self.currentUser = user
        self.isAuthenticated = true
        saveAuthState()
    }
    
    func logout() {
        self.token = nil
        self.currentUser = nil
        self.isAuthenticated = false
        clearAuthState()
    }
    
    private func saveAuthState() {
        UserDefaults.standard.set(token, forKey: tokenKey)
        if let user = currentUser, let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    private func loadAuthState() {
        if let savedToken = UserDefaults.standard.string(forKey: tokenKey),
           let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.token = savedToken
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    private func clearAuthState() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
    }
}

struct User: Codable {
    let id: String
    let username: String
    let email: String
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case avatarUrl = "avatar_url"
    }
}
