import SwiftUI

struct NameEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameIsFocused: Bool

    let title: String
    let prompt: String
    let placeholder: String
    let actionTitle: String
    let initialValue: String
    let onSubmit: (String) -> Void

    @State private var name: String

    init(
        title: String,
        prompt: String,
        placeholder: String,
        actionTitle: String,
        initialValue: String = "",
        onSubmit: @escaping (String) -> Void
    ) {
        self.title = title
        self.prompt = prompt
        self.placeholder = placeholder
        self.actionTitle = actionTitle
        self.initialValue = initialValue
        self.onSubmit = onSubmit
        _name = State(initialValue: initialValue)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text(prompt)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField(placeholder, text: $name)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($nameIsFocused)
                    .onSubmit(submit)
                    .font(.title3.weight(.semibold))
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))

                Spacer()
            }
            .padding()
            .background(AppTheme.background)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(actionTitle, action: submit)
                        .fontWeight(.semibold)
                        .disabled(trimmedName.isEmpty)
                }
            }
            .task { nameIsFocused = true }
        }
        .presentationDetents([.medium])
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submit() {
        guard !trimmedName.isEmpty else { return }
        onSubmit(trimmedName)
        dismiss()
    }
}

