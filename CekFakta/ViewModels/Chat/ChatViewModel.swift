import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var chatHistory: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let baseURL = "https://api.caldev.my.id/chat"

    private var userKey: String? = nil
    private var cancellables = Set<AnyCancellable>()

    init() {
        // autosave tiap chatHistory berubah (kalau userKey sudah ada)
        $chatHistory
            .dropFirst()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self, let key = self.userKey else { return }
                ChatLocalStore.save(newValue, userKey: key)
            }
            .store(in: &cancellables)
    }

    /// panggil setelah login / saat userEmail tersedia
    func setUserKey(_ newKey: String) {
        let normalized = newKey.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }

        // kalau user berganti, load history milik user tsb
        if userKey != normalized {
            userKey = normalized
            chatHistory = ChatLocalStore.load(userKey: normalized)
        }
    }

    func addUserMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        chatHistory.append(ChatMessage(role: "user", content: trimmed))
    }

    func sendMessage() {
        guard let lastUserMessage = chatHistory.last(where: { $0.role == "user" }) else { return }

        isLoading = true
        errorMessage = nil

        let payload = ChatRequest(message: lastUserMessage.content)

        guard let url = URL(string: baseURL) else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            self.errorMessage = "Failed to encode data"
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No response from server"
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)

                    if let error = decoded.error {
                        self.errorMessage = error
                        return
                    }

                    if let reply = decoded.response {
                        self.chatHistory.append(ChatMessage(role: "assistant", content: reply))
                    }
                } catch {
                    self.errorMessage = "Failed to decode JSON"
                }
            }
        }.resume()
    }

    func clearHistoryForCurrentUser() {
        guard let key = userKey else { return }
        chatHistory = []
        ChatLocalStore.clear(userKey: key)
    }
}


enum ChatLocalStore {
    private static func key(_ userKey: String) -> String {
        "chat_history_\(userKey)"
    }

    static func load(userKey: String) -> [ChatMessage] {
        guard let data = UserDefaults.standard.data(forKey: key(userKey)) else { return [] }
        do {
            return try JSONDecoder().decode([ChatMessage].self, from: data)
        } catch {
            return []
        }
    }

    static func save(_ messages: [ChatMessage], userKey: String) {
        do {
            let data = try JSONEncoder().encode(messages)
            UserDefaults.standard.set(data, forKey: key(userKey))
        } catch { }
    }

    static func clear(userKey: String) {
        UserDefaults.standard.removeObject(forKey: key(userKey))
    }
}
