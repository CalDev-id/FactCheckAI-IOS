//import Foundation
//
//@MainActor
//final class PredictionStore: ObservableObject {
//    @Published var latestPrediction: News?
//}
//
//@MainActor
//final class PredictionViewModel: ObservableObject {
//    // Inputs
//    @Published var urlInput: String = ""
//    @Published var claimInput: String = ""
//    @Published var titleInput: String = ""
//    @Published var contentInput: String = ""
//
//    // UI state
//    @Published var isLoading: Bool = false
//    @Published var result: News?
//    @Published var errorMessage: String = ""
//
//    private let baseURL = "https://api.caldev.my.id"
//
//    // MARK: - Public APIs
//
//    /// 1) Predict with link
//    func predictWithLink() {
//        Task { await predictWithLinkAsync() }
//    }
//
//    /// 2) Predict with claim
//    func predictWithClaim() {
//        Task { await predictWithClaimAsync() }
//    }
//
//    /// 3) Predict news (title + content)
//    func predictNews() {
//        Task { await predictNewsAsync() }
//    }
//
//    // MARK: - Requests (DTO)
//
//    private struct URLRequestBody: Codable {
//        let url: String
//    }
//
//    private struct ClaimRequestBody: Codable {
//        let claim: String
//    }
//
//    private struct PredictRequestBody: Codable {
//        let title: String
//        let content: String
//    }
//
//    // MARK: - Async implementations
//
//    private func predictWithLinkAsync() async {
//        let endpoint = "\(baseURL)/predict_from_/"
//        let trimmed = urlInput.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        guard !trimmed.isEmpty else {
//            errorMessage = "URL tidak boleh kosong"
//            return
//        }
//
//        await performPredict(
//            endpoint: endpoint,
//            body: URLRequestBody(url: trimmed)
//        )
//    }
//
//    private func predictWithClaimAsync() async {
//        let endpoint = "\(baseURL)/predict_from_claim/"
//        let trimmed = claimInput.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        guard !trimmed.isEmpty else {
//            errorMessage = "Claim tidak boleh kosong"
//            return
//        }
//
//        await performPredict(
//            endpoint: endpoint,
//            body: ClaimRequestBody(claim: trimmed)
//        )
//    }
//
//    private func predictNewsAsync() async {
//        let endpoint = "\(baseURL)/predict/"
//        let title = titleInput.trimmingCharacters(in: .whitespacesAndNewlines)
//        let content = contentInput.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        guard !title.isEmpty else {
//            errorMessage = "Title tidak boleh kosong"
//            return
//        }
//        guard !content.isEmpty else {
//            errorMessage = "Content tidak boleh kosong"
//            return
//        }
//
//        await performPredict(
//            endpoint: endpoint,
//            body: PredictRequestBody(title: title, content: content)
//        )
//    }
//
//    // MARK: - Core network helper
//
//    private func performPredict<T: Codable>(endpoint: String, body: T) async {
//        guard let url = URL(string: endpoint) else {
//            errorMessage = "Invalid API URL"
//            return
//        }
//
//        isLoading = true
//        errorMessage = ""
//        result = nil
//        defer { isLoading = false }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            request.httpBody = try JSONEncoder().encode(body)
//
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            guard let http = response as? HTTPURLResponse else {
//                errorMessage = "Invalid server response"
//                return
//            }
//
//            guard (200...299).contains(http.statusCode) else {
//                // kalau server kamu ngirim detail error dalam JSON/string,
//                // kamu bisa print String(data: data, encoding: .utf8) untuk debug.
//                errorMessage = "Server error (\(http.statusCode))"
//                return
//            }
//
//            result = try JSONDecoder().decode(News.self, from: data)
//
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//    }
//}

import Foundation

@MainActor
final class PredictionStore: ObservableObject {
    @Published var latestPrediction: News?
}

@MainActor
final class PredictionViewModel: ObservableObject {
    @Published var urlInput: String = ""
    @Published var claimInput: String = ""
    @Published var titleInput: String = ""
    @Published var contentInput: String = ""

    @Published var isLoading: Bool = false
    @Published var result: News?
    @Published var errorMessage: String = ""

    private let baseURL = "https://api.caldev.my.id"
//    private let baseURL = "http://192.168.1.6:8000"


    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300
        config.timeoutIntervalForResource = 300
        return URLSession(configuration: config)
    }()

    func predictWithLink() {
        Task { await predictWithLinkAsync() }
    }

    func predictWithClaim() {
        Task { await predictWithClaimAsync() }
    }

    func predictNews() {
        Task { await predictNewsAsync() }
    }

    private struct URLRequestBody: Codable {
        let url: String
    }

    private struct ClaimRequestBody: Codable {
        let claim: String
    }

    private struct PredictRequestBody: Codable {
        let title: String
        let content: String
    }

    private func predictWithLinkAsync() async {
        let endpoint = "\(baseURL)/predict_from_/"
        let trimmed = urlInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            errorMessage = "URL tidak boleh kosong"
            return
        }

        await performPredict(endpoint: endpoint, body: URLRequestBody(url: trimmed))
    }

    private func predictWithClaimAsync() async {
        let endpoint = "\(baseURL)/predict_from_claim/"
        let trimmed = claimInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            errorMessage = "Claim tidak boleh kosong"
            return
        }

        await performPredict(endpoint: endpoint, body: ClaimRequestBody(claim: trimmed))
    }

    private func predictNewsAsync() async {
        let endpoint = "\(baseURL)/predict/"
        let title = titleInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let content = contentInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty else {
            errorMessage = "Title tidak boleh kosong"
            return
        }

        guard !content.isEmpty else {
            errorMessage = "Content tidak boleh kosong"
            return
        }

        await performPredict(endpoint: endpoint, body: PredictRequestBody(title: title, content: content))
    }

    private func performPredict<T: Codable>(endpoint: String, body: T) async {
        guard let url = URL(string: endpoint) else {
            errorMessage = "Invalid API URL"
            return
        }

        isLoading = true
        errorMessage = ""
        result = nil
        defer { isLoading = false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 300
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)

            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                errorMessage = "Invalid server response"
                return
            }

            guard (200...299).contains(http.statusCode) else {
                let serverMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
                errorMessage = "Server error (\(http.statusCode)): \(serverMessage)"
                return
            }

            result = try JSONDecoder().decode(News.self, from: data)

        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                errorMessage = "Request timeout. Server terlalu lama merespons."
            case .notConnectedToInternet:
                errorMessage = "Tidak ada koneksi internet."
            case .cannotFindHost, .cannotConnectToHost:
                errorMessage = "Tidak bisa terhubung ke server."
            default:
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
