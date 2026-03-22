//
//  ProfileViewModel.swift
//  CekFakta
//
//  Created by Heical Chandra on 06/01/26.
//



import Foundation
import SwiftUI

@MainActor
final class ProfileManager: ObservableObject {

    @Published var news: [News] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "https://api.caldev.my.id"
//    private let baseURL = "http://192.168.1.6:8000"

    private var hasLoadedMyNews = false

    private var currentFetchTask: Task<Void, Never>?

    func fetchMyNewsIfNeeded(force: Bool = false) {
        // untuk load sekali / sesuai kebutuhan
        if isLoading { return }
        if hasLoadedMyNews && !force { return }
        refreshMyNews(force: force)
    }

    /// ✅ Gunakan ini untuk pull-to-refresh (tidak ikut cancel dari refreshable)
    func refreshMyNews(force: Bool = true) {
        // cancel task sebelumnya biar "latest wins"
        currentFetchTask?.cancel()

        currentFetchTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            await self._fetchMyNewsDetached(force: force)
        }
    }

    func resetCache() {
        hasLoadedMyNews = false
        news = []
        errorMessage = nil
    }

    // MARK: - Detached worker (jalan di background, update state di MainActor)

    private func _fetchMyNewsDetached(force: Bool) async {
        await MainActor.run {
            self.errorMessage = nil
            self.isLoading = true
        }
        defer {
            Task { @MainActor in self.isLoading = false }
        }

        guard let token = Keychain.load("access_token") else {
            await MainActor.run { self.errorMessage = "Not authenticated" }
            return
        }

        guard var comps = URLComponents(string: "\(baseURL)/news/my") else {
            await MainActor.run { self.errorMessage = "Invalid URL" }
            return
        }

        if force {
            comps.queryItems = (comps.queryItems ?? []) + [
                URLQueryItem(name: "_ts", value: String(Int(Date().timeIntervalSince1970)))
            ]
        }

        guard let url = comps.url else {
            await MainActor.run { self.errorMessage = "Invalid URL components" }
            return
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.cachePolicy = force ? .reloadIgnoringLocalCacheData : .useProtocolCachePolicy
            request.timeoutInterval = 30

            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
            } else {
            }
            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            guard http.statusCode == 200 else {
                let body = String(data: data, encoding: .utf8) ?? ""
                await MainActor.run { self.errorMessage = "HTTP \(http.statusCode): \(body)" }
                return
            }

            let decoded = try JSONDecoder().decode([News].self, from: data)

            await MainActor.run {
                self.news = decoded
                self.errorMessage = nil
                self.hasLoadedMyNews = true
            }

        } catch is CancellationError {
            // Detached task bisa tetap kena cancel kalau kamu cancel currentFetchTask (expected).
            return
        } catch let e as URLError where e.code == .cancelled {
            return
        } catch {
            await MainActor.run { self.errorMessage = "Network error: \(error.localizedDescription)" }
        }
    }
    
    func updateProfile(
        name: String? = nil,
        avatarURL: String? = nil,
        email: String? = nil,
        password: String? = nil
    ) async throws {
        
        guard let token = Keychain.load("access_token") else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let url = URL(string: "\(baseURL)/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH" // 🔥 JANGAN PUT
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = UpdateProfileRequest(
            name: name,
            avatar_url: avatarURL,
            email: email,
            password: password
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
    }
    
    func deleteNews(_ item: News) {
        guard let newsId = item.id else { return }

        // Optimistic UI
        let snapshot = news
        news.removeAll { $0.id == newsId }
        errorMessage = nil

        Task {
            do {
                try await _deleteMyNews(newsId: newsId)
            } catch {
                // rollback kalau gagal
                self.news = snapshot
                self.errorMessage = "Delete failed: \(error.localizedDescription)"
            }
        }
    }


    private func _deleteMyNews(newsId: String) async throws {
        guard let token = Keychain.load("access_token") else {
            throw URLError(.userAuthenticationRequired)
        }

        let url = URL(string: "\(baseURL)/news/my/\(newsId)")!

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // Backend kamu return 200 kalau sukses ({"message":"News deleted"})
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            // Biar kelihatan detail error dari FastAPI
            throw NSError(
                domain: "APIError",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
            )
        }
    }
}
