//
//  NewsViewModel.swift
//  CekFakta
//
//  Created by Heical Chandra on 09/12/25.
//

import Foundation

@MainActor
class NewsViewModel: ObservableObject {
    @Published var newsList: [News] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "https://api.caldev.my.id"
    private var hasLoadedOnce = false

    func loadIfNeeded(force: Bool = false) async {
        if hasLoadedOnce && !force { return }
        await fetchNews(showLoading: newsList.isEmpty) // loading hanya kalau pertama kali
        hasLoadedOnce = true
    }

    func fetchNews(showLoading: Bool = true) async {
        guard let url = URL(string: "\(baseURL)/news") else {
            errorMessage = "Invalid URL"
            return
        }

        if showLoading { isLoading = true }
        defer { if showLoading { isLoading = false } }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([News].self, from: data)
            newsList = decoded
            errorMessage = nil
        } catch is CancellationError {
            // dibatalkan? abaikan saja
            return
        } catch let urlError as URLError where urlError.code == .cancelled {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


@MainActor
class DetailNewsViewModel: ObservableObject {
    @Published var news: News?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let baseURL = "https://api.caldev.my.id"

    func fetchDetail(newsId: String) async {
        guard let url = URL(string: "\(baseURL)/news/id/\(newsId)") else {
            errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(News.self, from: data)
            self.news = decoded
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

@MainActor
class ShareNewsViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    private let baseURL = "https://api.caldev.my.id"

    // DTO LOKAL (PRIVATE)
    private struct SharePayload: Codable {
        let url: String
        let title: String
        let content: String
        let classification: Classification
        let evidence_links: [String]?
        let evidence_scraped: [EvidenceScraped]?
        let explanation: String?
    }

    func shareNews(_ news: News) async {
        guard let url = URL(string: "\(baseURL)/news") else { return }
        guard let token = Keychain.load("access_token") else {
            errorMessage = "Not authenticated"
            return
        }

        let payload = SharePayload(
            url: news.url ?? "",
            title: news.title ?? "",
            content: news.content ?? "",
            classification: news.classification ?? Classification(final_label: "-", final_confidence: 0),
            evidence_links: news.evidence_links,
            evidence_scraped: news.evidence_scraped,
            explanation: news.explanation
        )

        do {
            isLoading = true

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONEncoder().encode(payload)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }

            isSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
