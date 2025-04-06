//
// HealthAlertApp.swift
//
// Un projet complet SwiftUI avec HealthKit et notifications locales
//

import SwiftUI
import HealthKit
import UserNotifications

@main
struct HealthAlertApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("Notifications autorisées")
            }
        }
        return true
    }
}

// MARK: - HealthKit Manager

class HealthManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

    @Published var latestBPM: Double = 0.0

    init() {
        requestAuthorization()
        startHeartRateMonitoring()
    }

    func requestAuthorization() {
        let readTypes: Set = [heartRateType]
        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if !success {
                print("Erreur autorisation: \(error?.localizedDescription ?? "inconnue")")
            }
        }
    }

    func startHeartRateMonitoring() {
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, _, _ in
            self?.fetchLatestHeartRate()
        }
        healthStore.execute(query)
    }

    func fetchLatestHeartRate() {
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }
            let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async {
                self.latestBPM = bpm
                if bpm > 120 {
                    NotificationManager.sendAlertNotification(bpm: bpm)
                }
            }
        }
        healthStore.execute(query)
    }
}

// MARK: - Notification Manager

class NotificationManager {
    static func sendAlertNotification(bpm: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Alerte Santé 💓"
        content.body = "Votre rythme cardiaque est élevé : \(Int(bpm)) BPM."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - UI

struct ContentView: View {
    @StateObject var healthManager = HealthManager()

    var body: some View {
        VStack(spacing: 24) {
            Text("Rythme cardiaque actuel")
                .font(.title)

            Text("\(Int(healthManager.latestBPM)) BPM")
                .font(.system(size: 64, weight: .bold))
                .foregroundColor(healthManager.latestBPM > 120 ? .red : .green)

            if healthManager.latestBPM > 120 {
                Text("⚠️ Alerte: Rythme cardiaque élevé")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}
