import SwiftUI

struct SplitEditorView: View {
    @EnvironmentObject private var store: TrainingStore
    let splitID: UUID

    @State private var isAddingDay = false
    @State private var isRenamingSplit = false

    private var split: TrainingSplit? { store.split(withID: splitID) }

    var body: some View {
        Group {
            if let split {
                List {
                    overview(for: split)

                    Section("Training days") {
                        if split.days.isEmpty {
                            emptyDaysRow
                        } else {
                            ForEach(Array(split.days.enumerated()), id: \.element.id) { index, day in
                                NavigationLink {
                                    DayEditorView(splitID: splitID, dayID: day.id)
                                } label: {
                                    DayRow(day: day, index: index)
                                }
                            }
                            .onDelete { store.deleteDays(at: $0, from: splitID) }
                            .onMove { store.moveDays(from: $0, to: $1, in: splitID) }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle(split.name)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        EditButton()
                        Button {
                            isAddingDay = true
                        } label: {
                            Label("Add day", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isAddingDay) {
                    NameEntrySheet(
                        title: "Add training day",
                        prompt: "Name this step in your rotation.",
                        placeholder: "Day 1 · Upper body",
                        actionTitle: "Add"
                    ) { name in
                        store.addDay(to: splitID, named: name)
                    }
                }
                .sheet(isPresented: $isRenamingSplit) {
                    NameEntrySheet(
                        title: "Rename split",
                        prompt: "Choose a new name for this routine.",
                        placeholder: "Training split",
                        actionTitle: "Save",
                        initialValue: split.name
                    ) { name in
                        store.renameSplit(splitID, to: name)
                    }
                }
            } else {
                ContentUnavailableView("Split not found", systemImage: "exclamationmark.triangle")
            }
        }
    }

    private func overview(for split: TrainingSplit) -> some View {
        Section {
            Button {
                isRenamingSplit = true
            } label: {
                HStack(spacing: 14) {
                    RoundIcon(systemName: "repeat", color: AppTheme.accent)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Flexible rotation")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("\(split.days.count) days · tap to rename")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "pencil")
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyDaysRow: some View {
        Button {
            isAddingDay = true
        } label: {
            HStack(spacing: 14) {
                RoundIcon(systemName: "plus", color: AppTheme.accent)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Add your first day")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("For example: Upper body or Long run")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

private struct DayRow: View {
    let day: TrainingDay
    let index: Int

    var body: some View {
        HStack(spacing: 14) {
            Text("\(index + 1)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 34, height: 34)
                .background(AppTheme.accent.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(day.name)
                    .font(.headline)
                Text(exerciseSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
    }

    private var exerciseSummary: String {
        switch day.exercises.count {
        case 0: "No exercises yet"
        case 1: "1 exercise"
        default: "\(day.exercises.count) exercises"
        }
    }
}

