import XCTest
@testable import FitPlan

@MainActor
final class TrainingStoreTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: #file)
        defaults.removePersistentDomain(forName: #file)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: #file)
        defaults = nil
        super.tearDown()
    }

    func testBuildsSplitDayAndMixedWorkout() throws {
        let store = TrainingStore(defaults: defaults)
        let splitID = store.addSplit(named: "Hybrid")
        let dayID = try XCTUnwrap(store.addDay(to: splitID, named: "Day 1"))

        store.addExercise(Exercise(name: "Squat", kind: .strength, sets: 4, reps: 6), to: dayID, in: splitID)
        store.addExercise(Exercise(name: "Bike", kind: .cardio, durationMinutes: 20, intensity: .moderate), to: dayID, in: splitID)

        let day = try XCTUnwrap(store.day(withID: dayID, in: splitID))
        XCTAssertEqual(day.exercises.map(\.kind), [.strength, .cardio])
        XCTAssertEqual(day.exercises.count, 2)
    }

    func testPersistsChanges() throws {
        let firstStore = TrainingStore(defaults: defaults)
        let splitID = firstStore.addSplit(named: "Three day")
        _ = firstStore.addDay(to: splitID, named: "Push")

        let restoredStore = TrainingStore(defaults: defaults)
        XCTAssertEqual(restoredStore.splits.first?.name, "Three day")
        XCTAssertEqual(restoredStore.splits.first?.days.first?.name, "Push")
    }
}

