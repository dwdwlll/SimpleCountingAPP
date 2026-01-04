//
//  RegisterView.swift
//  SimpleCountingAPP
//
//  Created on 2026-01-04.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authState: AuthState
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("创建账号")
                            .font(.system(size: 28, weight: .bold))
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Registration Form
                    VStack(spacing: 16) {
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("用户名")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("输入用户名", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.username)
                                .autocapitalization(.none)
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("邮箱")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("输入邮箱地址", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("密码")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            SecureField("输入密码（至少8个字符）", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.newPassword)
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("确认密码")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            SecureField("再次输入密码", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.newPassword)
                            
                            if !confirmPassword.isEmpty && password != confirmPassword {
                                Text("两次输入的密码不一致")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Register Button
                        Button(action: handleRegister) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            } else {
                                Text("注册")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                        }
                        .background(isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(12)
                        .disabled(!isFormValid || isLoading)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword
    }
    
    private func handleRegister() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                let (token, user) = try await NetworkService.shared.register(
                    username: username,
                    email: email,
                    password: password
                )
                
                await MainActor.run {
                    authState.login(token: token, user: user)
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(authState: AuthState())
    }
}
