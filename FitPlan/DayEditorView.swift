import SwiftUI

struct DayEditorView: View {
    @EnvironmentObject private var store: TrainingStore
    let splitID: UUID
    let dayID: UUID

    @State private var isAddingExercise = false
    @State private var isRenamingDay = false

    private var day: TrainingDay? { store.day(withID: dayID, in: splitID) }

    var body: some View {
        Group {
            if let day {
                List {
                    Section {
                        Button {
                            isRenamingDay = true
                        } label: {
                            HStack {
                                Label("Rename training day", systemImage: "pencil")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }

                    Section("Exercises") {
                        if day.exercises.isEmpty {
                            addFirstExerciseRow
                        } else {
                            ForEach(day.exercises) { exercise in
                                ExerciseRow(exercise: exercise)
                            }
                            .onDelete {
                                store.deleteExercises(at: $0, from: dayID, in: splitID)
                            }
                            .onMove {
                                store.moveExercises(from: $0, to: $1, in: dayID, splitID: splitID)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle(day.name)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        EditButton()
                        Button {
                            isAddingExercise = true
                        } label: {
                            Label("Add exercise", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isAddingExercise) {
                    ExerciseEntrySheet { exercise in
                        store.addExercise(exercise, to: dayID, in: splitID)
                    }
                }
                .sheet(isPresented: $isRenamingDay) {
                    NameEntrySheet(
                        title: "Rename training day",
                        prompt: "Choose a name that describes this workout.",
                        placeholder: "Day 1 · Upper body",
                        actionTitle: "Save",
                        initialValue: day.name
                    ) { name in
                        store.renameDay(dayID, in: splitID, to: name)
                    }
                }
            } else {
                ContentUnavailableView("Day not found", systemImage: "exclamationmark.triangle")
            }
        }
    }

    private var addFirstExerciseRow: some View {
        Button {
            isAddingExercise = true
        } label: {
            HStack(spacing: 14) {
                RoundIcon(systemName: "plus", color: AppTheme.accent)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Add your first exercise")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Choose strength or cardio")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 14) {
            RoundIcon(systemName: exercise.kind.symbol, color: exercise.kind == .strength ? AppTheme.strength : AppTheme.cardio)
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !exercise.notes.isEmpty {
                    Text(exercise.notes)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var detail: String {
        switch exercise.kind {
        case .strength:
            return "\(exercise.sets ?? 3) sets × \(exercise.reps ?? 10) reps"
        case .cardio:
            return "\(exercise.durationMinutes ?? 20) min · \((exercise.intensity ?? .moderate).title)"
        }
    }
}

