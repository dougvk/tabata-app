import Foundation
import AVFoundation

class TimerManager: ObservableObject {
    enum State: String {
        case prepare = "PREPARE"
        case work = "WORK"
        case rest = "REST"
        case finished = "FINISHED"
    }
    
    @Published var currentState: State = .prepare
    @Published var currentTime: Int = 0
    @Published var isRunning: Bool = false
    @Published var roundsLeft: Int = 0
    @Published var cyclesLeft: Int = 0
    
    var prepareTime: Int = 5
    var workTime: Int = 20
    var restTime: Int = 10
    var rounds: Int = 10
    var cycles: Int = 1
    
    private var timer: Timer?
    @Published private(set) var totalTimeLeft: Int = 0
    private var audioPlayer: AVAudioPlayer?
    private var finishAudioPlayer: AVAudioPlayer?
    
    var progress: Double {
        switch currentState {
        case .prepare:
            return Double(prepareTime - currentTime) / Double(prepareTime)
        case .work:
            return Double(workTime - currentTime) / Double(workTime)
        case .rest:
            return Double(restTime - currentTime) / Double(restTime)
        case .finished:
            return 1.0
        }
    }
    
    var secondaryProgress: Double {
        switch currentState {
        case .work:
            return Double(currentTime) / Double(workTime)
        case .rest:
            return Double(currentTime) / Double(restTime)
        default:
            return 0
        }
    }
    
    var totalTimeString: String {
        let minutes = totalTimeLeft / 60
        let seconds = totalTimeLeft % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var currentTimeString: String {
        let minutes = currentTime / 60
        let seconds = currentTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init() {
        reset()
        setupAudioPlayers()
    }
    
    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
    }
    
    func reset() {
        pauseTimer()
        currentState = .prepare
        currentTime = prepareTime
        roundsLeft = rounds
        cyclesLeft = cycles
        calculateTotalTime()
    }
    
    private func updateTimer() {
        if currentTime > 0 {
            currentTime -= 1
            totalTimeLeft -= 1
            
            if currentTime >= 1 && currentTime <= 3 {
                playBeep()
            }
        } else {
            moveToNextState()
        }
        
        if totalTimeLeft <= 0 {
            finishWorkout()
        }
    }
    
    private func moveToNextState() {
        switch currentState {
        case .prepare:
            currentState = .work
            currentTime = workTime
        case .work:
            currentState = .rest
            currentTime = restTime
            roundsLeft -= 1
            if roundsLeft == 0 {
                cyclesLeft -= 1
                if cyclesLeft > 0 {
                    roundsLeft = rounds
                }
            }
        case .rest:
            if roundsLeft > 0 {
                currentState = .work
                currentTime = workTime
            } else if cyclesLeft > 0 {
                currentState = .prepare
                currentTime = prepareTime
                roundsLeft = rounds
            } else {
                finishWorkout()
            }
        case .finished:
            pauseTimer()
        }
    }
    
    private func finishWorkout() {
        currentState = .finished
        currentTime = 0
        totalTimeLeft = 0
        pauseTimer()
        playFinishSound()
    }
    
    private func calculateTotalTime() {
        let cycleTime = prepareTime + (rounds * (workTime + restTime))
        totalTimeLeft = cycles * cycleTime
    }
    
    private func setupAudioPlayers() {
        guard let beepURL = Bundle.main.url(forResource: "beep", withExtension: "wav"),
              let finishURL = Bundle.main.url(forResource: "finish", withExtension: "wav") else {
            print("Error: Could not find sound files.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: beepURL)
            audioPlayer?.prepareToPlay()
            finishAudioPlayer = try AVAudioPlayer(contentsOf: finishURL)
            finishAudioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio players: \(error.localizedDescription)")
        }
    }
    
    private func playBeep() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    private func playFinishSound() {
        finishAudioPlayer?.play()
    }
}