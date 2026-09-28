import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: TrainingStore
    @State private var isCreatingSplit = false

    var body: some View {
        NavigationStack {
            Group {
                if store.splits.isEmpty {
                    emptyState
                } else {
                    splitList
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Training splits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isCreatingSplit = true
                    } label: {
                        Label("New split", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isCreatingSplit) {
                NameEntrySheet(
                    title: "New training split",
                    prompt: "Give your routine a memorable name.",
                    placeholder: "Push, Pull, Legs",
                    actionTitle: "Create"
                ) { name in
                    store.addSplit(named: name)
                }
            }
        }
    }

    private var splitList: some View {
        List {
            Section {
                ForEach(store.splits) { split in
                    NavigationLink {
                        SplitEditorView(splitID: split.id)
                    } label: {
                        SplitRow(split: split)
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 12))
                }
                .onDelete(perform: store.deleteSplits)
            } header: {
                Text("Your routines")
            } footer: {
                Text("Splits advance in the order you create them—there are no fixed calendar dates.")
                    .padding(.top, 6)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Build your first split", systemImage: "figure.strengthtraining.traditional")
        } description: {
            Text("Combine lifting and cardio into a routine that moves at your pace.")
        } actions: {
            Button("Create training split") {
                isCreatingSplit = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

private struct SplitRow: View {
    let split: TrainingSplit

    var body: some View {
        HStack(spacing: 14) {
            RoundIcon(systemName: "repeat", color: AppTheme.accent)

            VStack(alignment: .leading, spacing: 4) {
                Text(split.name)
                    .font(.headline)
                Text(daySummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 2)
    }

    private var daySummary: String {
        switch split.days.count {
        case 0: "No days yet"
        case 1: "1 training day"
        default: "\(split.days.count) training days"
        }
    }
}

