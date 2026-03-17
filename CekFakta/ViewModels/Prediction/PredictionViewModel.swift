import Foundation

@MainActor
final class PredictionStore: ObservableObject {
    @Published var latestPrediction: News?
}

@MainActor
final class PredictionViewModel: ObservableObject {
    // Inputs
    @Published var urlInput: String = ""
    @Published var claimInput: String = ""
    @Published var titleInput: String = ""
    @Published var contentInput: String = ""

    // UI state
    @Published var isLoading: Bool = false
    @Published var result: News?
    @Published var errorMessage: String = ""

    private let baseURL = "https://api.caldev.my.id"

    // MARK: - Public APIs

    /// 1) Predict with link
    func predictWithLink() {
        Task { await predictWithLinkAsync() }
    }

    /// 2) Predict with claim
    func predictWithClaim() {
        Task { await predictWithClaimAsync() }
    }

    /// 3) Predict news (title + content)
    func predictNews() {
        Task { await predictNewsAsync() }
    }

    // MARK: - Requests (DTO)

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

    // MARK: - Async implementations

    private func predictWithLinkAsync() async {
        let endpoint = "\(baseURL)/predict_from_/"
        let trimmed = urlInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            errorMessage = "URL tidak boleh kosong"
            return
        }

        await performPredict(
            endpoint: endpoint,
            body: URLRequestBody(url: trimmed)
        )
    }

    private func predictWithClaimAsync() async {
        let endpoint = "\(baseURL)/predict_from_claim/"
        let trimmed = claimInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            errorMessage = "Claim tidak boleh kosong"
            return
        }

        await performPredict(
            endpoint: endpoint,
            body: ClaimRequestBody(claim: trimmed)
        )
    }

    private func predictNewsAsync() async {
        let endpoint = "\(baseURL)/predict_with_evidence/"
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

        await performPredict(
            endpoint: endpoint,
            body: PredictRequestBody(title: title, content: content)
        )
    }

    // MARK: - Core network helper

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
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                errorMessage = "Invalid server response"
                return
            }

            guard (200...299).contains(http.statusCode) else {
                // kalau server kamu ngirim detail error dalam JSON/string,
                // kamu bisa print String(data: data, encoding: .utf8) untuk debug.
                errorMessage = "Server error (\(http.statusCode))"
                return
            }

            result = try JSONDecoder().decode(News.self, from: data)

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
