import XCTest

/// iPhone-only mode: counting penalties and free kicks, the list under the counts, and undo.
final class PenaltyCountUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testPenaltiesAreCountedListedAndUndone() throws {
        let app = launchCleanApp()
        kickOffPhoneMatch(app)

        let awayPenalty = app.buttons["penalty.away"]
        let homeFreeKick = app.buttons["freeKick.home"]
        scrollTo(awayPenalty, in: app)
        awayPenalty.tap()
        awayPenalty.tap()
        homeFreeKick.tap()

        XCTAssertEqual(awayPenalty.label, "Penalties against City Lions: 2")
        XCTAssertEqual(homeFreeKick.label, "Free kicks against Rangers RFC: 1")
        let penaltyRows = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS 'penalty against City Lions'"))
        XCTAssertEqual(penaltyRows.count, 2, "Each penalty should be listed")
        attachScreenshot(app, named: "Penalty counts and list")

        // Undo takes back the last one: the free kick.
        tapElement(app.buttons["undoLastEntry"])
        XCTAssertEqual(homeFreeKick.label, "Free kicks against Rangers RFC: 0")
        XCTAssertEqual(awayPenalty.label, "Penalties against City Lions: 2")
    }

    @MainActor
    func testPenaltiesCanOnlyBeCountedDuringPlay() throws {
        let app = launchCleanApp()
        kickOffPhoneMatch(app)
        playToFullTime(app)

        let awayPenalty = app.buttons["penalty.away"]
        scrollTo(awayPenalty, in: app)
        XCTAssertFalse(awayPenalty.isEnabled, "Counts are read-only once play stops")
    }
}
