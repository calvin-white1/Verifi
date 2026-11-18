import SwiftUI

// MARK: - Sign In View

struct SignInView: View {
    @Binding var isSignedIn: Bool
    @State private var email = ""

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // App name title
            Text("App name")
                .font(.system(size: 24, weight: .semibold))
                .tracking(-0.24)
                .padding(.bottom, 48)

            VStack(spacing: 24) {

                // Email + Continue
                VStack(alignment: .leading, spacing: 2) {
                    Text("Create an account")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    Text("Enter your email to sign up for this app")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#828282"))
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

                VStack(spacing: 16) {
                    TextField("email@domain.com", text: $email)
                        .font(.system(size: 14))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .padding(.horizontal, 16)
                        .frame(height: 40)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#e0e0e0"), lineWidth: 1)
                        )
                        .cornerRadius(8)

                    Button(action: { isSignedIn = true }) {
                        Text("Continue")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    .disabled(email.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                // Divider
                HStack(spacing: 8) {
                    Rectangle().fill(Color(hex: "#e6e6e6")).frame(height: 1)
                    Text("or")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#828282"))
                    Rectangle().fill(Color(hex: "#e6e6e6")).frame(height: 1)
                }

                // Social buttons
                VStack(spacing: 12) {
                    SocialSignInButton(
                        icon: AnyView(
                            Image("google_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        ),
                        label: "Continue with Google",
                        action: { isSignedIn = true }
                    )

                    SocialSignInButton(
                        icon: AnyView(
                            Image("apple_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        ),
                        label: "Continue with Apple",
                        action: { isSignedIn = true }
                    )
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // Terms
            Group {
                Text("By clicking continue, you agree to our ")
                    .foregroundColor(Color(hex: "#828282"))
                + Text("Terms of Service")
                    .foregroundColor(.black)
                + Text(" and ")
                    .foregroundColor(Color(hex: "#828282"))
                + Text("Privacy Policy")
                    .foregroundColor(.black)
            }
            .font(.system(size: 12))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .ignoresSafeArea()
    }
}

// MARK: - Social Sign In Button

struct SocialSignInButton: View {
    let icon: AnyView
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                icon
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(Color(hex: "#eeeeee"))
            .cornerRadius(8)
        }
        .frame(maxWidth: 327)
    }
}
