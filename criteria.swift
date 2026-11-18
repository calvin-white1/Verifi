import SwiftUI

// MARK: - Criteria View

struct CriteriaView: View {
    @Binding var videoURL: String
    @Binding var biasDetection: Bool
    @Binding var aiDetection: Bool
    @Binding var factChecking: Bool

    var onAnalyze: () -> Void

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {

                // URL input field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Insert Video Link Here:")
                        .font(.system(size: 20, weight: .semibold))
                        .tracking(-0.4)
                        .foregroundColor(.black)

                    TextField("", text: $videoURL)
                        .font(.system(size: 14))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .padding(.horizontal, 12)
                        .frame(height: 43)
                        .background(Color(hex: "#c7c7c7"))
                        .cornerRadius(5)
                }
                .padding(.horizontal, 35)
                .padding(.top, 24)
                .padding(.bottom, 32)

                // Analysis Criteria section
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Analysis Criteria:")
                            .font(.system(size: 20, weight: .medium))
                            .tracking(-0.4)
                        Spacer()
                    }
                    .padding(.horizontal, 35)

                    Divider()
                        .padding(.horizontal, 35)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 0) {
                        CriteriaToggleRow(label: "Bias Detection", isOn: $biasDetection)
                        CriteriaToggleRow(label: "AI Detection", isOn: $aiDetection)
                        CriteriaToggleRow(label: "Fact Checking", isOn: $factChecking)
                    }
                    .padding(.horizontal, 35)
                    .padding(.top, 16)
                }

                Spacer()

                // Analyze button
                Button(action: onAnalyze) {
                    Text("Analyze")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 35)
                .padding(.bottom, 32)
                .disabled(videoURL.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .navigationTitle("App name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HamburgerMenuButton()
                }
            }
        }
    }
}

// MARK: - Criteria Toggle Row

struct CriteriaToggleRow: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            Button(action: { isOn.toggle() }) {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: 21, height: 21)
                    .overlay(
                        isOn
                            ? Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.black)
                            : nil
                    )
            }
            .buttonStyle(.plain)

            Text(label)
                .font(.system(size: 16))
                .tracking(-0.32)
                .foregroundColor(.black)

            Spacer()
        }
        .padding(.vertical, 14)
    }
}
