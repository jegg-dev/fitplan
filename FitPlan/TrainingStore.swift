import SwiftUI

@MainActor
final class TrainingStore: ObservableObject {
    @Published private(set) var splits: [TrainingSplit] = []

    private let defaults: UserDefaults
    private let storageKey = "fitplan.training-splits.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    @discardableResult
    func addSplit(named name: String) -> UUID {
        let split = TrainingSplit(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        splits.append(split)
        save()
        return split.id
    }

    func deleteSplits(at offsets: IndexSet) {
        splits.remove(atOffsets: offsets)
        save()
    }

    func split(withID id: UUID) -> TrainingSplit? {
        splits.first { $0.id == id }
    }

    func renameSplit(_ splitID: UUID, to name: String) {
        guard let index = splits.firstIndex(where: { $0.id == splitID }) else { return }
        splits[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        save()
    }

    @discardableResult
    func addDay(to splitID: UUID, named name: String) -> UUID? {
        guard let splitIndex = splits.firstIndex(where: { $0.id == splitID }) else { return nil }
        let day = TrainingDay(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        splits[splitIndex].days.append(day)
        save()
        return day.id
    }

    func renameDay(_ dayID: UUID, in splitID: UUID, to name: String) {
        guard let indices = indices(for: dayID, in: splitID) else { return }
        splits[indices.split].days[indices.day].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        save()
    }

    func deleteDays(at offsets: IndexSet, from splitID: UUID) {
        guard let splitIndex = splits.firstIndex(where: { $0.id == splitID }) else { return }
        splits[splitIndex].days.remove(atOffsets: offsets)
        save()
    }

    func moveDays(from offsets: IndexSet, to destination: Int, in splitID: UUID) {
        guard let splitIndex = splits.firstIndex(where: { $0.id == splitID }) else { return }
        splits[splitIndex].days.move(fromOffsets: offsets, toOffset: destination)
        save()
    }

    func day(withID dayID: UUID, in splitID: UUID) -> TrainingDay? {
        split(withID: splitID)?.days.first { $0.id == dayID }
    }

    func addExercise(_ exercise: Exercise, to dayID: UUID, in splitID: UUID) {
        guard let indices = indices(for: dayID, in: splitID) else { return }
        splits[indices.split].days[indices.day].exercises.append(exercise)
        save()
    }

    func deleteExercises(at offsets: IndexSet, from dayID: UUID, in splitID: UUID) {
        guard let indices = indices(for: dayID, in: splitID) else { return }
        splits[indices.split].days[indices.day].exercises.remove(atOffsets: offsets)
        save()
    }

    func moveExercises(from offsets: IndexSet, to destination: Int, in dayID: UUID, splitID: UUID) {
        guard let indices = indices(for: dayID, in: splitID) else { return }
        splits[indices.split].days[indices.day].exercises.move(fromOffsets: offsets, toOffset: destination)
        save()
    }

    private func indices(for dayID: UUID, in splitID: UUID) -> (split: Int, day: Int)? {
        guard let splitIndex = splits.firstIndex(where: { $0.id == splitID }),
              let dayIndex = splits[splitIndex].days.firstIndex(where: { $0.id == dayID }) else {
            return nil
        }
        return (splitIndex, dayIndex)
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([TrainingSplit].self, from: data) else {
            return
        }
        splits = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(splits) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
