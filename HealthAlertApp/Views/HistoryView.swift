import SwiftUI

struct HistoryView: View {
    let history: [HeartRateSample]

    var body: some View {
        List(history.sorted { $0.date > $1.date }) { sample in
            VStack(alignment: .leading) {
                Text("\(Int(sample.bpm)) BPM")
                    .font(.headline)
                Text(sample.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Historique")
    }
}
