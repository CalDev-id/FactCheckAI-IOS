import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var error: String?
    @State private var isLoading = false

    @State private var isPasswordVisible = false
    @State private var isConfirmVisible = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.plus")
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
                            Text("Buat akun untuk melanjutkan.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.top, 10)
                }
                .padding(.bottom, 50)

                // MARK: Form Card
                VStack(alignment: .leading, spacing: 14) {
                    Text("Data akun")
                        .font(.headline)
                        .fontWeight(.semibold)

                    IconField(systemImage: "person.fill", placeholder: "Name", text: $name)
                        .textInputAutocapitalization(.words)

                    IconField(systemImage: "envelope.fill", placeholder: "Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)

                    IconSecureField(
                        systemImage: "lock.fill",
                        placeholder: "Password",
                        text: $password,
                        isVisible: $isPasswordVisible
                    )

                    IconSecureField(
                        systemImage: "lock.fill",
                        placeholder: "Confirm Password",
                        text: $confirmPassword,
                        isVisible: $isConfirmVisible
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

                    // MARK: Primary button
                    Button {
                        Task { await register() }
                    } label: {
                        HStack(spacing: 10) {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(isLoading ? "Memproses..." : "Sign Up")
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
                    .disabled(isLoading || !canSubmit)

                    // MARK: Back to login
                    HStack(spacing: 6) {
                        Text("Sudah punya akun?")
                            .foregroundColor(.secondary)
                        Button {
                            dismiss()
                        } label: {
                            Text("Login")
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
        .navigationBarBackButtonHidden(true)
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty
    }

    // MARK: - REGISTER LOGIC (async)
    private func register() async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else { error = "Name is required"; return }
        guard !trimmedEmail.isEmpty else { error = "Email is required"; return }
        guard password.count >= 6 else { error = "Password minimal 6 karakter"; return }
        guard password == confirmPassword else { error = "Passwords do not match"; return }

        error = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await auth.signup(email: trimmedEmail, password: password, name: trimmedName)
            dismiss()
        } catch {
            self.error = "Registration failed"
        }
    }
}


// MARK: - Shared Components (same style as Login)

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
