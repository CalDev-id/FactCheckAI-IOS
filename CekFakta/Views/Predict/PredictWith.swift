import SwiftUI
import UIKit

// MARK: - Predict With Claim
struct PredictWithClaim: View {
    @StateObject private var vm = PredictionViewModel()
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var predictionStore: PredictionStore

    @State private var hasNavigatedToResult = false

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .padding(8)
                        }
                        Spacer()
                    }

                    Text("Claim Prediction")
                        .font(.largeTitle.bold())
                        .padding(.top, 10)

                    Text("Enter a specific claim to analyze its validity.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // CLAIM FIELD
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Claim")
                            .font(.headline)

                        TextEditor(text: $vm.claimInput)
                            .frame(height: 140)
                            .padding(10)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                    }

                    // BUTTON
                    Button {
                        hideKeyboard()
                        hasNavigatedToResult = false
                        vm.predictWithClaim()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Predict")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.redPrimary,
                                    Color.redPrimary.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .disabled(vm.claimInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    if !vm.errorMessage.isEmpty {
                        Text("⚠️ \(vm.errorMessage)")
                            .foregroundColor(.red)
                            .padding(.top, 6)
                    }

                    Spacer(minLength: 30)
                }
                .padding()
            }

            if vm.isLoading {
                LoadingView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onReceive(vm.$result.compactMap { $0 }) { news in
            guard !hasNavigatedToResult else { return }
            hasNavigatedToResult = true

            predictionStore.latestPrediction = news
            router.navigate(to: .predictResult)
        }
    }
}

// MARK: - Predict With Link
struct PredictWithLink: View {
    @StateObject private var vm = PredictionViewModel()
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var predictionStore: PredictionStore

    @State private var hasNavigatedToResult = false

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .padding(8)
                        }
                        Spacer()
                    }

                    Text("Cek Fakta Berita")
                        .font(.largeTitle).bold()

                    Text("Masukkan URL berita untuk dianalisis")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    TextField("https://contoh.com/berita", text: $vm.urlInput)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button {
                        hideKeyboard()
                        hasNavigatedToResult = false
                        vm.predictWithLink()
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Analisis").bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.redPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(vm.urlInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    if !vm.errorMessage.isEmpty {
                        Text("⚠️ \(vm.errorMessage)")
                            .foregroundColor(.red)
                            .padding(.top, 6)
                    }

                    Spacer(minLength: 30)
                }
                .padding()
            }

            if vm.isLoading {
                LoadingView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(vm.$result.compactMap { $0 }) { news in
            guard !hasNavigatedToResult else { return }
            hasNavigatedToResult = true

            predictionStore.latestPrediction = news
            router.navigate(to: .predictResult)
        }
    }
}

// MARK: - Predict With News (title + content)
struct PredictWithNews: View {
    @StateObject private var vm = PredictionViewModel()
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var predictionStore: PredictionStore

    @State private var hasNavigatedToResult = false

    private var isFormValid: Bool {
        !vm.titleInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !vm.contentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    HStack {
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .padding(8)
                        }
                        Spacer()
                    }

                    Text("News Prediction")
                        .font(.largeTitle.bold())
                        .padding(.top, 10)

                    Text("Paste your news article title and content below to analyze.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // TITLE FIELD
                    VStack(alignment: .leading, spacing: 8) {
                        Text("News Title")
                            .font(.headline)

                        TextField("Enter news title...", text: $vm.titleInput)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                    }

                    // CONTENT FIELD
                    VStack(alignment: .leading, spacing: 8) {
                        Text("News Content")
                            .font(.headline)

                        TextEditor(text: $vm.contentInput)
                            .frame(height: 180)
                            .padding(10)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                    }

                    // BUTTON
                    Button {
                        hideKeyboard()
                        hasNavigatedToResult = false
                        vm.predictNews()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Predict")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.redPrimary,
                                    Color.redPrimary.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .disabled(!isFormValid)

                    if !vm.errorMessage.isEmpty {
                        Text("⚠️ \(vm.errorMessage)")
                            .foregroundColor(.red)
                            .padding(.top, 6)
                    }

                    Spacer(minLength: 30)
                }
                .padding()
            }

            if vm.isLoading {
                LoadingView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onReceive(vm.$result.compactMap { $0 }) { news in
            guard !hasNavigatedToResult else { return }
            hasNavigatedToResult = true

            predictionStore.latestPrediction = news
            router.navigate(to: .predictResult)
        }
    }
}

// MARK: - Helpers
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// (Opsional) Kalau masih kepake di file ini:
struct SectionCard<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2, x: 0, y: 1)
    }
}

struct LabelCapsule: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .bold()
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}
