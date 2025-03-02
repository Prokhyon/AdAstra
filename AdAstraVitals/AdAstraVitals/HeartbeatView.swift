//
//  HeartbeatView.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 10.02.2025.
//

import SwiftUI
import Combine


struct ECGWaveformView: View {
    @State private var phase: CGFloat = -1
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
//    let beatModeRefreshTimer: Publishers.Autoconnect<Timer.TimerPublisher>
    @State var style = Int.random(in: 1...4)
//    var noise = CGFloat.random(in: 0.8...1.2)
    @State var bpmAdjustmentTimer: Timer?

    @State private var phaseSpeed: CGFloat = 0.12
    @State private var bpm: CGFloat = 60
    var heartbeatMode: HeartbeatMode
    let twoPi = CGFloat.pi * 2 //- 1.6

    var body: some View {
        GeometryReader { geometry in
            let rect = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
            let lastPoint = ECGShape(phase: phase, style: style/*, noise: noise*/).lastPoint(in: rect)

            ZStack {
                ECGShape(phase: phase, style: style/*, noise: noise*/)
                    .stroke(Color.cyan, lineWidth: 3)
                    .frame(height: 100)
                    .padding()
                    .onReceive(timer) { _ in
                        phase = (phase + phaseSpeed).truncatingRemainder(dividingBy: twoPi)
                    }
//                    .onReceive(beatModeRefreshTimer) { _ in
//                        setHeartbeatMode(heartbeatMode)
//                    }

                Circle()
                    .fill(Color.cyan)
                    .frame(width: 6, height: 6)
                    .position(x: geometry.size.width - 17, y: lastPoint.y + 16)
                    .blur(radius: 2)
            }
            .drawingGroup()
        }
        .frame(height: 100)
        .padding(.horizontal, 10)
        .onAppear {
            setHeartbeatMode(heartbeatMode)
        }
        .onChange(of: heartbeatMode) {
            setHeartbeatMode(heartbeatMode)
        }
    }
    
    // Change heartbeat settings based on mode
    private func setHeartbeatMode(_ mode: HeartbeatMode) {
        // Stop any existing BPM adjustment to prevent overlap
        bpmAdjustmentTimer?.invalidate()
        bpmAdjustmentTimer = nil

        let targetBPM: CGFloat

        switch mode {
        case .calm:
            targetBPM = CGFloat.random(in: 50...70)
        case .active:
            targetBPM = CGFloat.random(in: 115...150)
        case .dead:
            targetBPM = 0
        }

//        print("Setting new target BPM: \(targetBPM)")
        
        // Smoothly adjust BPM and ensure no duplicate transitions occur
        smoothlyAdjustBPM(to: targetBPM)
    }
    
    private func smoothlyAdjustBPM(to target: CGFloat, duration: TimeInterval = 5.0) {
        bpmAdjustmentTimer?.invalidate() // Stop any existing timer
        bpmAdjustmentTimer = nil

        let stepCount = 50
        let stepDuration = duration / Double(stepCount)
        
        let initialBPM = bpm
        let bpmStep = (target - initialBPM) / CGFloat(stepCount)
        
        bpmAdjustmentTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            if abs(self.bpm - target) < abs(bpmStep) {
                self.bpm = target
                self.phaseSpeed = target / 450 // 850
                timer.invalidate()
                self.bpmAdjustmentTimer = nil // Clear reference
                if heartbeatMode == .dead {
                    style = 5
                }

            } else {
                self.bpm += bpmStep
                self.phaseSpeed = self.bpm / 450 //850
//                print("BPM Adjusting: \(self.bpm)")
            }
        }
    }
}

struct ECGShape: Shape {
    var phase: CGFloat
    var style: Int
    /*var noise: CGFloat*/

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = height / 2

        path.move(to: CGPoint(x: 0, y: midY))
//        var lastPoint = CGPoint(x: 0, y: midY)

        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = (x / width) * .pi * 2 + phase
            let y = midY - ecg(relativeX, style: style/*, noise: noise*/) * (height / 10)/* / noise*/
            let point = CGPoint(x: x, y: y)
            path.addLine(to: point)
//            lastPoint = point
        }

        return path
    }
    
    private func ecg(_ x: CGFloat, style: Int/*, noise: CGFloat*/) -> CGFloat {
        let stretchFactor: CGFloat = 1 //1.2 // Adjust to stretch the waveform
        let t = (x / stretchFactor).truncatingRemainder(dividingBy: .pi)

        switch style {
        case 1:
            if t < 0.15 { return 0.12 }
            if t < 0.25 { return -0.5 }
            if t < 0.30 { return 6 }
            if t < 0.38 { return -2 }
            if t < 0.45 { return -1 }
            if t < 0.75 { return 0.6 * sin((t - 0.45) * 4) }
            return 0.05 * sin(t * 8)
            
        case 2:
            if t < 0.1 { return 0.1 }
            if t < 0.18 { return -0.6 }
            if t < 0.22 { return 6 }
            if t < 0.28 { return -3 }
            if t < 0.35 { return -1.5 }
            if t < 0.6 { return 0.4 * sin((t - 0.35) * 5) } // Faster oscillation for a rapid T-wave
            return 0.08 * sin(t * 10)
            
        case 3:
            if t < 0.12 { return 0.2 * sin(t * 10) }
            if t < 0.2 { return -0.4 }
            if t < 0.24 { return 5.5 }
            if t < 0.29 { return -2.2 }
            if t < 0.35 { return -1.2 }
            if t < 0.55 { return 0.6 * sin((t - 0.35) * 4) } // More pronounced T-wave with irregularity
            return 0.05 * sin(t * 14) * (Bool.random() ? 1.2 : 0.8) // Random variations to create an irregular effect

        case 4:
            if t < 0.2 { return 0.12 }
            if t < 0.25 { return -0.4 }
            if t < 0.30 { return 5 }
            if t < 0.38 { return -2 }
            if t < 0.45 { return -1 }
            if t < 0.75 { return 0.6 * sin((t - 0.45) * 4) }
            return 0.05 * sin(t * 8)

            
            //        case 1: // Normal (baseline)
//            if t < 0.12 /* * noise*/ { return 0.15 /* * sin(t * 10)*/ }
//            if t < 0.18 /* * noise*/ { return -0.5 }
//            if t < 0.21 /* * noise*/ { return 6 }
//            if t < 0.25 /* * noise*/ { return -2 }
//            if t < 0.3 /* * noise*/ { return -1 }
//            if t < 0.5 /* * noise*/ { return 0.6/* * sin((t - 0.3) * 6)*/ }
//            return 0.05 * sin(t * 12) /* * noise*/

//        case 2:
//            if t < 0.1 /* * noise*/ { return 0.12/* * sin(t * 12)*/ }
//            if t < 0.16 /* * noise*/ { return -0.7 }
//            if t < 0.2 /* * noise*/ { return 5 }
//            if t < 0.23 /* * noise*/ { return -3 }
//            if t < 0.28 /* * noise*/ { return -1.2 }
//            if t < 0.45 /* * noise*/ { return 0.3/* * sin((t - 0.3) * 8) */} // Weaker T-wave
//            return 0.04 * sin(t * 15) /* * noise*/
//
//        case 3: // Irregular beats
//            if t < 0.14 /* * noise*/ { return 0.18 * sin(t * 8) }
//            if t < 0.2 /* * noise*/ { return -0.4 }
//            if t < 0.23 /* * noise*/ { return 6.2 }
//            if t < 0.27 /* * noise*/ { return -2.5 }
//            if t < 0.32 /* * noise*/ { return -1.5 }
//            if t < 0.55 /* * noise*/ { return 0.7 * sin((t - 0.3) * 5) } // More pronounced T-wave
//            return 0.06 * sin(t * 10) /* * noise*/
//            
//        case 4:
//            if t < 0.1 /* * noise*/ { return 0.12 * sin(t * 12) }
//            if t < 0.16/* * noise*/ { return -0.7 }
//            if t < 0.19 /* * noise*/ { return 4 }
//            if t < 0.23 /* * noise*/ { return -3 }
//            if t < 0.28 /* * noise*/ { return -1.2 }
//            if t < 0.4 /* * noise*/ { return 0.3 * sin((t - 0.3) * 8) } // Weaker T-wave
//            return 0.04 * sin(t * 15) /* * noise*/
            
        case 5:
            return 0

        default: // Fallback to normal
            return ecg(x, style: 1/*, noise: 1*/)
        }
    }

    func lastPoint(in rect: CGRect) -> CGPoint {
        let width = rect.width
        let height = rect.height
        let midY = height / 2
        let x = width
        let relativeX = (x / width) * .pi * 2 + phase
        let y = midY - ecg(relativeX, style: style/*, noise: noise*/) * (height / 10) /*/ noise*/
        return CGPoint(x: x, y: y)
    }
}

//struct ECGWaveformView_Previews: PreviewProvider {
//    static var previews: some View {
//        let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
////        let beatModeRefreshTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
//        var heartMode = HeartbeatMode.calm
//        ECGWaveformView(timer: timer, /*beatModeRefreshTimer: beatModeRefreshTimer,*/ heartbeatMode: heartMode)
////            .frame(width: 1000)
//    }
//}


#Preview {
    ECGShape(phase: -1, style: 4)
        .stroke(Color.cyan, lineWidth: 3)
        .frame(height: 100)
        .padding()
}
