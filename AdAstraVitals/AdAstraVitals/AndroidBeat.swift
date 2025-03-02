//
//  AndroidBeat.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 14.02.2025.
//

import SwiftUI
import Combine

struct AndroidHeartbeatView: View {
    @State private var phase1: CGFloat = 0.0
    @State private var phase2: CGFloat = .pi / 2
    @State private var phase3: CGFloat = .pi
    @State private var baseSpeed: CGFloat = 0
    @State private var speedVariation: CGFloat = 0
    @State private var amplitude: CGFloat = 0
    @State private var frequency: CGFloat = 1.0 // New: adjustable frequency for stressed mode
    @State private var deathOffset: CGFloat = 15
    let twoPi = CGFloat.pi * 2

    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    var heartbeatMode: HeartbeatMode
    @State var waveAdjustmentTimer: Timer?

    var body: some View {
                GeometryReader { geometry in
                    ZStack {
                        let rect = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)
                        
                        let point1 = SinusShape(phase: phase1, amplitude: amplitude, frequency: frequency, deathOffset: deathOffset).lastPoint(in: rect)
                        let point2 = SinusShape(phase: phase2, amplitude: amplitude * 0.9, frequency: frequency * 1.1, deathOffset: deathOffset).lastPoint(in: rect)
                        let point3 = SinusShape(phase: phase3, amplitude: amplitude * 0.8, frequency: frequency * 1.05, deathOffset: deathOffset).lastPoint(in: rect)
                        
                        SinusShape(phase: phase1, amplitude: amplitude, frequency: frequency, deathOffset: deathOffset)
                            .stroke(Color.cyan, lineWidth: 2)
                            .padding(.horizontal, 5)
                        SinusShape(phase: phase2, amplitude: amplitude * 0.9, frequency: frequency * 1.1, deathOffset: deathOffset)
                            .stroke(Color.blue, lineWidth: 1.5)
                            .padding(.horizontal, 5)
                        SinusShape(phase: phase3, amplitude: amplitude * 0.8, frequency: frequency * 1.05, deathOffset: deathOffset)
                            .stroke(Color.purple, lineWidth: 1.2)
                            .padding(.horizontal, 5)
                        
                        // Move the lights to the right by shifting their x position
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 6, height: 6)
                            .position(x: geometry.size.width-25, y: point1.y)
                            .blur(radius: 2)
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 5, height: 5)
                            .position(x: geometry.size.width-25, y: point2.y)
                            .blur(radius: 2)
                        
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 4, height: 4)
                            .position(x: geometry.size.width-25, y: point3.y)
                            .blur(radius: 2)
                    }
                    .drawingGroup()
                    .padding(.horizontal, 10)
            }
            .frame(height: 100)
            .padding(.horizontal, 10)
        .onAppear {
            setHeartbeatMode(heartbeatMode)
        }
        .onChange(of: heartbeatMode) { _, newMode in
            withAnimation(.easeInOut(duration: 1.0)) { // Smooth transition
                setHeartbeatMode(newMode)
            }
        }
        .onReceive(timer) { _ in
            phase1 += baseSpeed + CGFloat.random(in: -speedVariation...speedVariation).truncatingRemainder(dividingBy: twoPi)
            phase2 += (baseSpeed * 1.05) + CGFloat.random(in: -speedVariation...speedVariation).truncatingRemainder(dividingBy: twoPi)
            phase3 += (baseSpeed * 1.1) + CGFloat.random(in: -speedVariation...speedVariation).truncatingRemainder(dividingBy: twoPi)
        }
    }

    private func setHeartbeatMode(_ mode: HeartbeatMode) {
        let amplitudeTarget: CGFloat
        let baseSpeedTarget: CGFloat
        let speedVariationTarget: CGFloat
        let frequencyTarget: CGFloat
        let deathOffsetTarget: CGFloat
        
        switch mode {
        case .calm:
            amplitudeTarget = 15
            baseSpeedTarget = 0.16
            speedVariationTarget = 0.01
            frequencyTarget = 1.2 // Normal frequency
            deathOffsetTarget = 0
            
        case .active:
            amplitudeTarget = 30
            baseSpeedTarget = 0.4
            speedVariationTarget = 0.02
            frequencyTarget = 1.5
            deathOffsetTarget = 0

//        case .active:
//            amplitudeTarget = 25
//            baseSpeedTarget = 0.15
//            speedVariationTarget = 0.02
//            frequencyTarget = 1.3

//        case .stressed:
//            amplitudeTarget = 35
//            baseSpeedTarget = 0.25
//            speedVariationTarget = 0.03
//            frequencyTarget = 1.8

        case .dead:
            amplitudeTarget = 0
            baseSpeedTarget = 0
            speedVariationTarget = 0
            frequencyTarget = 1.0
            deathOffsetTarget = 20
        }
        
        smoothlyAdjustWaves(amplitudeTarget: amplitudeTarget, baseSpeedTarget: baseSpeedTarget, variationTarget: speedVariationTarget, frequencyTraget: frequencyTarget, deathOffsetTarget: deathOffsetTarget)
    }
    
    private func smoothlyAdjustWaves(amplitudeTarget: CGFloat, baseSpeedTarget: CGFloat, variationTarget: CGFloat, frequencyTraget: CGFloat, deathOffsetTarget: CGFloat, duration: TimeInterval = 5.0) {
        waveAdjustmentTimer?.invalidate() // Stop any existing timer
        waveAdjustmentTimer = nil

        let stepCount = 50
        let stepDuration = duration / Double(stepCount)
        
        let initialAmplitude = amplitude
        let intitialBaseSpeed = baseSpeed
        let initialVariation = speedVariation
        let initialFrequency = frequency
        let initialDeathOffset = deathOffset
        
        let amplitudeStep = (amplitudeTarget - initialAmplitude) / CGFloat(stepCount)
        let baseSpeedStep = (baseSpeedTarget - intitialBaseSpeed) / CGFloat(stepCount)
        let variationStep = (variationTarget - initialVariation) / CGFloat(stepCount)
        let frequencyStep = (frequencyTraget - initialFrequency) / CGFloat(stepCount)
        let deathOffsetStep = (deathOffsetTarget - initialDeathOffset) / CGFloat(stepCount)
        
        var currentStep = 0
        
        waveAdjustmentTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
                if currentStep >= stepCount {
                    self.amplitude = amplitudeTarget
                    self.baseSpeed = baseSpeedTarget
                    self.speedVariation = variationTarget
                    self.frequency = frequencyTraget
                    self.deathOffset = deathOffsetTarget
                    timer.invalidate()
                    self.waveAdjustmentTimer = nil // Clear reference
                    return
                }

                self.amplitude += amplitudeStep
                self.baseSpeed += baseSpeedStep
                self.speedVariation += variationStep
                self.frequency += frequencyStep
                self.deathOffset += deathOffsetStep

                currentStep += 1
            }
    }
}

struct SinusShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var frequency: CGFloat
    var deathOffset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = (height / 2) + deathOffset

        path.move(to: CGPoint(x: 0, y: midY))
        
        var lastPoint = CGPoint(x: 0, y: midY) // Store last point

        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = (x / width) * frequency * .pi * 2 + phase
            let y = midY - sin(relativeX) * amplitude
            let point = CGPoint(x: x, y: y)
            path.addLine(to: point)
            lastPoint = point
        }

        return path
    }

    func lastPoint(in rect: CGRect) -> CGPoint {
        let width = rect.width
        let height = rect.height
        let midY = height / 2 + deathOffset
        let x = width
        let relativeX = (x / width) * frequency * .pi * 2 + phase
        let y = midY - sin(relativeX) * amplitude
        return CGPoint(x: x, y: y)
    }
}

struct AndroidHeartbeatView_Previews: PreviewProvider {
    static var previews: some View {
        let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
            AndroidHeartbeatView(timer: timer, heartbeatMode: .calm)
    }
}
