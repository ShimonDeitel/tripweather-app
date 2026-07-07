import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [WeatherEntry] = []
    @Published var isProUnlocked: Bool = false

    /// Free tier item cap. Deliberately kept above the seed data count
    /// so a fresh install never opens directly into the paywall.
    static let freeLimit = 8

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("tripweather_items.json")
        load()
    }

    var canAddMore: Bool {
        isProUnlocked || items.count < Store.freeLimit
    }

    func add(_ item: WeatherEntry) {
        guard canAddMore else { return }
        items.append(item)
        save()
    }

    func update(_ item: WeatherEntry) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: WeatherEntry) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([WeatherEntry].self, from: data) {
            items = decoded
        } else {
            items = [
        WeatherEntry(tripName: "Sample Tripname 1", date: Date().addingTimeInterval(-259200), condition: "Sample Condition 1", highTemp: 3, lowTemp: 3, notes: "Sample Notes 1"),
        WeatherEntry(tripName: "Sample Tripname 2", date: Date().addingTimeInterval(-518400), condition: "Sample Condition 2", highTemp: 4, lowTemp: 4, notes: "Sample Notes 2"),
        WeatherEntry(tripName: "Sample Tripname 3", date: Date().addingTimeInterval(-777600), condition: "Sample Condition 3", highTemp: 5, lowTemp: 5, notes: "Sample Notes 3")
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
