import Foundation

final class StorageService {
    static let shared = StorageService()
    private let key = "HeartRateHistory"

    func save(_ samples: [HeartRateSample]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(samples.map { ["bpm": $0.bpm, "date": $0.date.timeIntervalSince1970] }) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() -> [HeartRateSample] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let rawArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return rawArray.compactMap {
            guard let bpm = $0["bpm"] as? Double,
                  let timestamp = $0["date"] as? TimeInterval else { return nil }
            return HeartRateSample(bpm: bpm, date: Date(timeIntervalSince1970: timestamp))
        }
    }
}
