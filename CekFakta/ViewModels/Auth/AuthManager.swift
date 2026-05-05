//
//  AuthManager.swift
//  CekFakta
//
//  Created by Heical Chandra on 18/12/25.
//
import Foundation
import SwiftUI

@MainActor
final class AuthManager: ObservableObject {

    // MARK: - State
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var userEmail: String?
    @Published var userName: String?
    @Published var avatarURL: String?
    @Published var userRole: String?

    var isAdmin: Bool {
        userRole == "admin"
    }

    private let baseURL = "https://api.caldev.my.id"
//    private let baseURL = "http://192.168.1.6:8000"

    // MARK: - Init
    init() {
        loadSession()
    }

    // MARK: - Session
    func loadSession() {
        Task {
            defer { isLoading = false }

            guard AuthTokenProvider.accessToken() != nil else {
                isAuthenticated = false
                return
            }

            await fetchCurrentUser()
        }
    }

    // MARK: - Login
    func login(email: String, password: String) async throws {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONEncoder().encode([
            "email": email,
            "password": password
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(AuthResponse.self, from: data)
        Keychain.save("access_token", result.access_token)
        Keychain.save("refresh_token", result.refresh_token)

        await fetchCurrentUser()
    }

    // MARK: - Signup ✅ (INI YANG KEMARIN KEHAPUS)
    func signup(email: String, password: String, name: String) async throws {
        let url = URL(string: "\(baseURL)/auth/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONEncoder().encode([
            "email": email,
            "password": password,
            "name": name
        ])

        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Logout
    func logout() {
        Keychain.delete("access_token")
        Keychain.delete("refresh_token")

        isAuthenticated = false
        userEmail = nil
        userName = nil
        avatarURL = nil
        userRole = nil
    }

    // MARK: - Fetch User
    func fetchCurrentUser() async {
        guard let token = AuthTokenProvider.accessToken() else {
            logout()
            return
        }

        if !(await fetchUser(with: token)),
           await refreshAccessToken(),
           let newToken = AuthTokenProvider.accessToken() {
            _ = await fetchUser(with: newToken)
        }
    }

    private func fetchUser(with token: String) async -> Bool {
        let url = URL(string: "\(baseURL)/auth/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return false }

            let user = try JSONDecoder().decode(User.self, from: data)
            userEmail = user.email
            userName = user.name
            avatarURL = user.avatar_url
            userRole = user.role
            isAuthenticated = true
            return true
        } catch {
            return false
        }
    }

    // MARK: - Refresh Token
    private func refreshAccessToken() async -> Bool {
        guard let refreshToken = Keychain.load("refresh_token") else { return false }

        let url = URL(string: "\(baseURL)/auth/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONEncoder().encode([
            "refresh_token": refreshToken
        ])

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                logout()
                return false
            }

            let result = try JSONDecoder().decode(RefreshResponse.self, from: data)
            Keychain.save("access_token", result.access_token)
            return true
        } catch {
            logout()
            return false
        }
    }
    
    func uploadAvatar(_ image: UIImage) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8),
              let token = Keychain.load("access_token") else {
            throw URLError(.userAuthenticationRequired)
        }

        let fileName = UUID().uuidString + ".jpg"
        let url = URL(string: "\(baseURL)/profile/avatar")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = MultipartFormData.build(
            boundary: boundary,
            data: data,
            fileName: fileName
        )

        let (responseData, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let error = String(data: responseData, encoding: .utf8) ?? ""
            print("UPLOAD ERROR:", error)
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(UploadResponse.self, from: responseData)
        return result.avatar_url
    }

}
