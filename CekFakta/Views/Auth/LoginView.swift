import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var showRegister = false

    @State private var isLoading = false
    @State private var isPasswordVisible = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: Header (simple branding)
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                LinearGradient(
                                    colors: [Color.redPrimary, Color.redPrimary.opacity(0.75)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("CekFakta")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Masuk untuk melanjutkan.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.top, 10)

                }
                .padding(.bottom, 50)

                // MARK: Form Card (keep this style)
                VStack(alignment: .leading, spacing: 14) {
                    Text("Selamat datang kembali")
                        .font(.headline)
                        .fontWeight(.semibold)

                    IconField(
                        systemImage: "envelope.fill",
                        placeholder: "Email",
                        text: $email
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                    IconSecureField(
                        systemImage: "lock.fill",
                        placeholder: "Password",
                        text: $password,
                        isVisible: $isPasswordVisible
                    )

                    if let error {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                        .padding(.top, 2)
                    }

                    // MARK: Primary Button
                    Button {
                        Task { await login() }
                    } label: {
                        HStack(spacing: 10) {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                            }

                            Text(isLoading ? "Memproses..." : "Login")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                colors: [Color.redPrimary, Color.redPrimary.opacity(0.80)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoading || email.isEmpty || password.isEmpty)

                    // MARK: Secondary actions
                    HStack {
                        Button {
                            showRegister = true
                        } label: {
                            Text("Buat akun baru")
                                .fontWeight(.semibold)
                                .foregroundColor(.redPrimary)
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                    .font(.footnote)
                    .padding(.top, 2)
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                )

                Spacer(minLength: 18)

                Text("By continuing, you agree to our Terms & Privacy Policy.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 6)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationDestination(isPresented: $showRegister) {
            RegisterView()
        }
    }

    private func login() async {
        error = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await auth.login(email: email, password: password)
        } catch {
            self.error = "Email atau password salah"
        }
    }
}

// MARK: - Components (same as before)
private struct IconField: View {
    let systemImage: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(.secondary)
                .frame(width: 18)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct IconSecureField: View {
    let systemImage: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(.secondary)
                .frame(width: 18)

            Group {
                if isVisible {
                    TextField(placeholder, text: $text).textFieldStyle(.plain)
                } else {
                    SecureField(placeholder, text: $text).textFieldStyle(.plain)
                }
            }

            Button { isVisible.toggle() } label: {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthManager())
    }
}
