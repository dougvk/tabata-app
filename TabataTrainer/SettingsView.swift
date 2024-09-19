import SwiftUI

struct SettingsView: View {
    @ObservedObject var timerManager: TimerManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var cycles: Int
    @State private var rounds: Int
    @State private var prepareTime: Int
    @State private var workTime: Int
    @State private var restTime: Int
    
    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        _cycles = State(initialValue: timerManager.cycles)
        _rounds = State(initialValue: timerManager.rounds)
        _prepareTime = State(initialValue: timerManager.prepareTime)
        _workTime = State(initialValue: timerManager.workTime)
        _restTime = State(initialValue: timerManager.restTime)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Structure")) {
                    Stepper("Cycles: \(cycles)", value: $cycles, in: 1...10)
                    Stepper("Rounds per cycle: \(rounds)", value: $rounds, in: 1...20)
                }
                
                Section(header: Text("Timers")) {
                    Stepper("Prepare time: \(prepareTime) sec", value: $prepareTime, in: 3...30)
                    Stepper("Work time: \(workTime) sec", value: $workTime, in: 1...60)
                    Stepper("Rest time: \(restTime) sec", value: $restTime, in: 1...30)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Save") {
                saveSettings()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveSettings() {
        timerManager.cycles = cycles
        timerManager.rounds = rounds
        timerManager.prepareTime = prepareTime
        timerManager.workTime = workTime
        timerManager.restTime = restTime
        timerManager.reset()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(timerManager: TimerManager())
    }
}