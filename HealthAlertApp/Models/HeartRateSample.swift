import Foundation

struct HeartRateSample: Identifiable {
    let id = UUID()
    let bpm: Double
    let date: Date
}
