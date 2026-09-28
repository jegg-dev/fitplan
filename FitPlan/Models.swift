import Foundation

struct TrainingSplit: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var days: [TrainingDay]
    let createdAt: Date

    init(id: UUID = UUID(), name: String, days: [TrainingDay] = [], createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.days = days
        self.createdAt = createdAt
    }
}

struct TrainingDay: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var exercises: [Exercise]

    init(id: UUID = UUID(), name: String, exercises: [Exercise] = []) {
        self.id = id
        self.name = name
        self.exercises = exercises
    }
}

struct Exercise: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var kind: ExerciseKind
    var sets: Int?
    var reps: Int?
    var durationMinutes: Int?
    var intensity: CardioIntensity?
    var notes: String

    init(
        id: UUID = UUID(),
        name: String,
        kind: ExerciseKind,
        sets: Int? = nil,
        reps: Int? = nil,
        durationMinutes: Int? = nil,
        intensity: CardioIntensity? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.sets = sets
        self.reps = reps
        self.durationMinutes = durationMinutes
        self.intensity = intensity
        self.notes = notes
    }
}

enum ExerciseKind: String, Codable, CaseIterable, Identifiable {
    case strength
    case cardio

    var id: Self { self }
    var title: String { rawValue.capitalized }
    var symbol: String { self == .strength ? "dumbbell.fill" : "figure.run" }
}

enum CardioIntensity: String, Codable, CaseIterable, Identifiable {
    case easy
    case moderate
    case hard

    var id: Self { self }
    var title: String { rawValue.capitalized }
}

