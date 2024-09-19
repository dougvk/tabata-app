//
//  ContentView.swift
//  TabataTrainer
//
//  Created by Anonymous on 9/19/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    @State private var showSettings = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                        .font(.title)
                }
                Spacer()
                Text(timerManager.totalTimeString)
                    .font(.title)
                Spacer()
                Button(action: timerManager.reset) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                }
            }
            .padding()
            
            Spacer()
            
            CircularProgressView(progress: timerManager.progress)
                .frame(width: 250, height: 250)
            
            Text(timerManager.currentState.rawValue)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(timerManager.currentTimeString)
                .font(.system(size: 60, weight: .bold, design: .monospaced))
            
            if timerManager.currentState != .prepare {
                RoundedRectangleProgressView(progress: timerManager.secondaryProgress)
                    .frame(height: 20)
                    .padding()
            }
            
            Spacer()
            
            HStack {
                VStack {
                    Text("ROUNDS LEFT")
                        .font(.caption)
                    Text("\(timerManager.roundsLeft)")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                Spacer()
                VStack {
                    Text("CYCLES LEFT")
                        .font(.caption)
                    Text("\(timerManager.cyclesLeft)")
                        .font(.title)
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            
            Button(action: {
                if timerManager.currentState == .finished {
                    timerManager.reset()
                } else {
                    timerManager.toggleTimer()
                }
            }) {
                Text(buttonText)
                    .font(.title)
                    .padding()
                    .background(buttonColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(timerManager: timerManager)
        }
    }
    
    private var buttonText: String {
        if timerManager.currentState == .finished {
            return "Reset"
        } else if timerManager.isRunning {
            return "Pause"
        } else {
            return "Start"
        }
    }
    
    private var buttonColor: Color {
        if timerManager.currentState == .finished {
            return .blue
        } else if timerManager.isRunning {
            return .red
        } else {
            return .green
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}

struct RoundedRectangleProgressView: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                
                Rectangle()
                    .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width))
                    .foregroundColor(.green)
            }
            .cornerRadius(10)
        }
    }
}

// Add this preview provider at the end of the file
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
