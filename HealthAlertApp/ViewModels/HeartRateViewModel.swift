import Foundation

final class HeartRateViewModel: ObservableObject {
    @Published var currentBPM: Double = 0
    @Published var history: [HeartRateSample] = []

    private let healthKit = HealthKitService()
    private let storage = StorageService.shared

    init() {
        loadHistory()
        requestAccessAndStart()
    }

    func requestAccessAndStart() {
        healthKit.requestAuthorization { [weak self] success in
            if success {
                self?.fetchLatest()
            }
        }
    }

    func fetchLatest() {
        healthKit.fetchLatestHeartRate { [weak self] sample in
            guard let self = self, let sample = sample else { return }
            DispatchQueue.main.async {
                self.currentBPM = sample.bpm
                self.history.append(sample)
                self.storage.save(self.history)
                if sample.bpm > 120 {
                    NotificationService.sendHeartRateAlert(bpm: sample.bpm)
                }
            }
        }
    }

    private func loadHistory() {
        history = storage.load()
    }
}
