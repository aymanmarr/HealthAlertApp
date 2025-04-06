import UserNotifications

enum NotificationService {
    static func sendHeartRateAlert(bpm: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Alerte Santé 💓"
        content.body = "Rythme cardiaque élevé : \(Int(bpm)) BPM"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
