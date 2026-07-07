import XCTest
@testable import tripweather

@MainActor
final class WeatherEntryStoreTests: XCTestCase {
    var store: Store!

    override func setUp() async throws {
        store = Store()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        XCTAssertLessThan(store.items.count, Store.freeLimit)
    }

    func testCanAddMoreWhenUnderLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testAddIncreasesCount() {
        let before = store.items.count
        store.add(WeatherEntry(tripName: "Sample Tripname 10", date: Date().addingTimeInterval(-2592000), condition: "Sample Condition 10", highTemp: 12, lowTemp: 12, notes: "Sample Notes 10"))
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testAddBeyondFreeLimitIsBlocked() {
        while store.canAddMore {
            store.add(WeatherEntry(tripName: "Sample Tripname 2", date: Date().addingTimeInterval(-518400), condition: "Sample Condition 2", highTemp: 4, lowTemp: 4, notes: "Sample Notes 2"))
        }
        let countAtLimit = store.items.count
        store.add(WeatherEntry(tripName: "Sample Tripname 3", date: Date().addingTimeInterval(-777600), condition: "Sample Condition 3", highTemp: 5, lowTemp: 5, notes: "Sample Notes 3"))
        XCTAssertEqual(store.items.count, countAtLimit)
    }

    func testProUnlockBypassesLimit() {
        while store.canAddMore {
            store.add(WeatherEntry(tripName: "Sample Tripname 2", date: Date().addingTimeInterval(-518400), condition: "Sample Condition 2", highTemp: 4, lowTemp: 4, notes: "Sample Notes 2"))
        }
        store.isProUnlocked = true
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteRemovesItem() {
        let item = store.items[0]
        store.delete(item)
        XCTAssertFalse(store.items.contains(item))
    }

    func testUpdateModifiesItem() {
        var item = store.items[0]
        item.tripName = "Sample Tripname 6"
        store.update(item)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.tripName, item.tripName)
    }

    func testDeleteAtOffsetsRemovesCorrectItem() {
        let target = store.items[0]
        store.delete(at: IndexSet(integer: 0))
        XCTAssertFalse(store.items.contains(target))
    }
}
