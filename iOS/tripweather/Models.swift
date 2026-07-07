import Foundation

struct WeatherEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var tripName: String
    var date: Date
    var condition: String
    var highTemp: Int
    var lowTemp: Int
    var notes: String

    init(id: UUID = UUID(), tripName: String, date: Date, condition: String, highTemp: Int, lowTemp: Int, notes: String) {
        self.id = id
        self.tripName = tripName
        self.date = date
        self.condition = condition
        self.highTemp = highTemp
        self.lowTemp = lowTemp
        self.notes = notes
    }
}
