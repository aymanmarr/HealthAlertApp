import HealthKit

final class HealthKitService {
    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        healthStore.requestAuthorization(toShare: [], read: [heartRateType]) { success, _ in
            completion(success)
        }
    }

    func fetchLatestHeartRate(completion: @escaping (HeartRateSample?) -> Void) {
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(HeartRateSample(bpm: bpm, date: sample.endDate))
        }
        healthStore.execute(query)
    }
}
