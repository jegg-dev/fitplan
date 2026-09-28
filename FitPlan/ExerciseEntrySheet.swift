import SwiftUI

struct ExerciseEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameIsFocused: Bool

    let onSubmit: (Exercise) -> Void

    @State private var kind: ExerciseKind = .strength
    @State private var name = ""
    @State private var sets = 3
    @State private var reps = 10
    @State private var duration = 20
    @State private var intensity: CardioIntensity = .moderate
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Exercise type", selection: $kind) {
                        ForEach(ExerciseKind.allCases) { type in
                            Label(type.title, systemImage: type.symbol).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Exercise") {
                    TextField(kind == .strength ? "Bench press" : "Easy run", text: $name)
                        .textInputAutocapitalization(.words)
                        .focused($nameIsFocused)
                }

                if kind == .strength {
                    Section("Target") {
                        Stepper("Sets: \(sets)", value: $sets, in: 1...20)
                        Stepper("Reps: \(reps)", value: $reps, in: 1...100)
                    }
                } else {
                    Section("Target") {
                        Stepper("Duration: \(duration) minutes", value: $duration, in: 5...300, step: 5)
                        Picker("Intensity", selection: $intensity) {
                            ForEach(CardioIntensity.allCases) { level in
                                Text(level.title).tag(level)
                            }
                        }
                    }
                }

                Section("Notes (optional)") {
                    TextField("Pace, equipment, or reminders", text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                }
            }
            .navigationTitle("Add exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: submit)
                        .fontWeight(.semibold)
                        .disabled(trimmedName.isEmpty)
                }
            }
            .task { nameIsFocused = true }
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submit() {
        guard !trimmedName.isEmpty else { return }

        let exercise = Exercise(
            name: trimmedName,
            kind: kind,
            sets: kind == .strength ? sets : nil,
            reps: kind == .strength ? reps : nil,
            durationMinutes: kind == .cardio ? duration : nil,
            intensity: kind == .cardio ? intensity : nil,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        onSubmit(exercise)
        dismiss()
    }
}

