import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HeartRateViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Rythme cardiaque")
                    .font(.title)

                Text("\(Int(viewModel.currentBPM)) BPM")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(viewModel.currentBPM > 120 ? .red : .green)

                NavigationLink("Voir l'historique", destination: HistoryView(history: viewModel.history))
            }
            .padding()
        }
    }
}
