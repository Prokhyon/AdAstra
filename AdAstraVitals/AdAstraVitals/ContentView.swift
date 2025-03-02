//
//  ContentView.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 11.10.2024.
//

import SwiftUI
import Combine

struct PlayerView: View {
    var player: Player
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
//    let beatModeRefreshTimer: Publishers.Autoconnect<Timer.TimerPublisher>
    @Binding var elapsedTime: Double
    
    var body: some View {
        let playerName = "\(player.name) \(player.surname)"
        ZStack {
                VStack {
                    switch player.origin {
                    case .Human:
                        ECGWaveformView(timer: timer, /*beatModeRefreshTimer: beatModeRefreshTimer,*/ heartbeatMode: player.heartMode)
                    case .Augmented:
                        ECGWaveformView(timer: timer, /*beatModeRefreshTimer: beatModeRefreshTimer,*/ heartbeatMode: player.heartMode)
                    case .Android:
                        AndroidHeartbeatView(timer: timer, heartbeatMode: player.heartMode)
                    case .Saved:
                        AndroidHeartbeatView(timer: timer, heartbeatMode: player.heartMode)
                    }
                }
                .mask {
                    Rectangle()
                        .overlay(alignment: .trailing) {
                            LinearGradient(colors: [.black, .clear], startPoint: UnitPoint(x: 0.4, y: 0), endPoint: UnitPoint(x: 0.9, y: 0))
                                .blendMode(.destinationOut)
                        }
                        .padding(.trailing, 20)
                }
            
            HStack {
                    HologramView(imageName: player.imageName, playerName: playerName, elapsedTime: $elapsedTime)
                
                VStack(alignment: .leading) {
                    Text(playerName).font(.custom("silom", size: 30))
                    Text(originDisplay(player.origin)).font(.custom("silom", size: 18))
                    Spacer()
                    HStack {
                        Spacer()
                        Text(stateText(player.state)).font(.custom("silom", size: 20)).foregroundStyle(player.state == .Dead ? .red : .primary)
                        stateIcon(player.state)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.leading)
            }
                
                
                
//                .padding(.leading)
//                .padding(.vertical, 10)
                .foregroundStyle(.white)//.opacity(0.7)
//                .shadow(color: .blue, radius: 2)
        }
//        .frame(width: 400)
        .padding(10)
    }
}



struct ContentView: View {
    private let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
//    private let beatModeRefreshTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    @ObservedObject var session: MultipeerSession
    @State private var currentDate = Date()
//    private let dateTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @StateObject private var audioManager = AudioManager()
    @State private var elapsedTime: Double = 0

    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Mars Express").font(.custom("silom", size: 30))
//                    Spacer()
                    //                Text("Connected Peers: \(session.connectedPeers.map { $0.displayName }.joined(separator: ", "))")
                    Spacer()
//                    Text("02/03/2194 ").font(.custom("silom", size: 30))
                    
                    CustomClockView()
//                    Text(currentDate.formatted(date: .omitted, time: .standard)).font(.custom("silom", size: 30))
//                        .onReceive(dateTimer) { newDate in
//                            currentDate = newDate
//                        }
                }
                Grid {
                    ForEach(0..<session.players.count/3) { row in
                        HStack {
                            ForEach(0..<3) { column in
                                PlayerView(player: session.players[row * 3 + column], timer: timer, elapsedTime: $elapsedTime/*, beatModeRefreshTimer: beatModeRefreshTimer*/)
                                    .background(RoundedRectangle(cornerRadius: 25).fill(.ultraThinMaterial).shadow(radius: 3))
                                    .padding(5)
                            }
                        }
                    }
                    HStack {
                        Rectangle()
                            .fill(.clear)
                        PlayerView(player: session.players[12], timer: timer, elapsedTime: $elapsedTime/*, beatModeRefreshTimer: beatModeRefreshTimer*/)
                            .background(RoundedRectangle(cornerRadius: 25).fill(.ultraThinMaterial).shadow(radius: 3))
                            .padding(5)
                        Rectangle()
                            .fill(.clear)
                    }
                }
            }
            .padding()
            
            //Display a received message if it is not empty. The message stays until the command to empty the message variable is sent from the pad
            if let message = session.receivedMessage {
                if message.type == .Alert {
                    Rectangle()
                        .fill(Color.red.opacity(0.3))
                        .onAppear {
                            print("redAppear")
                            audioManager.play()
                        }
                        .onDisappear {
                            audioManager.stop()
                        }
                }
                MessageView(message: message)
                    .background {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.ultraThinMaterial)
                            .frame(minWidth: 400, minHeight: 100)
                            .shadow(radius: 3)
                    }
            }
        }
        .onAppear {
            audioManager.prepareAudio()
        }
        .onReceive(NotificationCenter.default.publisher(for: .playAlarm)) { _ in
            audioManager.play()
        }
        .onReceive(NotificationCenter.default.publisher(for: .stopAlarm)) { _ in
            audioManager.stop()
        }
        .onReceive(timer) { _ in
                    elapsedTime += 0.04 // Increment time with each timer tick
            if elapsedTime >= 1.24 {
                elapsedTime = 0
            }
                }
    }
}

//struct Background:View {
//    var body: some View {
//        Image("galaxyMap")
//            .resizable()
//            .aspectRatio(contentMode: .fill)
////            .scaledToFill()
//            .ignoresSafeArea()
//            .blur(radius: 5)
//    }
//}

import CryptoKit

func generateBase32ID(from name: String) -> String {
    let data = SHA256.hash(data: Data(name.utf8))
    let base32Alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")

    var base32 = ""
    var index = 0
    var accumulator: UInt32 = 0
    var bits = 0

    for byte in data {
        accumulator = (accumulator << 10) | UInt32(byte)
        bits += 8

        while bits >= 5 {
            let charIndex = (accumulator >> (bits - 5)) & 31
            base32.append(base32Alphabet[Int(charIndex)])
            bits -= 5
        }
        
        index += 1
        if base32.count >= 10 { break } // Limit to 8 characters
    }

    // Edge case: Ensure we always return exactly 8 characters
    while base32.count < 10 {
        base32.append(base32Alphabet[Int(accumulator & 31)])
        accumulator >>= 5
    }

    return base32
}



struct CustomClockView: View {
    @State private var isRunning = false
    @State private var startTime = Date()
    @State private var elapsedTime: TimeInterval = 0
    @State private var manualTime: Date = Date()
    private let gameStartHour: Double = 14 // 14:00
    private let realToGameTimeRatio: Double = 60.0 / 20.0 // 1 real minute = 3 game minutes

    var displayedDate: Date {
        let gameSecondsElapsed = elapsedTime * realToGameTimeRatio
        let newDate = Calendar.current.date(byAdding: .second, value: Int(gameSecondsElapsed), to: startTime) ?? startTime
                return newDate
    }

    var body: some View {
        HStack {
            Text(clockDateString(from: displayedDate))
                .font(.custom("silom", size: 30))
            
            Text(clockTimeString(from: displayedDate))
                .font(.custom("silom", size: 30))

//            HStack {
//                Button(action: startClock) {
//                    Text("Start")
//                        .padding()
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .clipShape(Capsule())
//                }
//                .disabled(isRunning)
//
//                Button(action: pauseClock) {
//                    Text("Pause")
//                        .padding()
//                        .background(Color.red)
//                        .foregroundColor(.white)
//                        .clipShape(Capsule())
//                }
//                .disabled(!isRunning)
//            }
        }
        .onAppear {
            resetClock()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if isRunning {
                elapsedTime += 1
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .startClock)) { _ in
            startClock()
        }
        .onReceive(NotificationCenter.default.publisher(for: .pauseClock)) { _ in
            pauseClock()
        }
        .onReceive(NotificationCenter.default.publisher(for: .resetClock)) { _ in
            resetClock()
        }
        .onReceive(NotificationCenter.default.publisher(for: .setTime)) { notification in
            if let userInfo = notification.userInfo,
               let hour = userInfo["hour"] as? Int,
               let minute = userInfo["minute"] as? Int {
                setClockTime(hour: hour, minute: minute)
            }
        }
    }
    

    func startClock() {
        isRunning = true
    }

    func pauseClock() {
        isRunning = false
    }

    private func resetClock() {
        var dateComponents = DateComponents()
        dateComponents.year = 2194
        dateComponents.month = 3
        dateComponents.day = 2
        dateComponents.hour = 14
        dateComponents.minute = 0
        dateComponents.second = 0

        if let customStart = Calendar.current.date(from: dateComponents) {
            startTime = customStart
            elapsedTime = 0
        }
    }
    
    private func setClockTime(hour: Int, minute: Int) {
        let now = Date()
        if let newTime = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: now) {
            startTime = newTime
            elapsedTime = 0
        }
    }

    private func clockTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func clockDateString(from date: Date) -> String {
            let formatter = DateFormatter()
        formatter.dateStyle = .short
            return formatter.string(from: date)
        }
}

struct CustomClockView_Previews: PreviewProvider {
    static var previews: some View {
        CustomClockView()
    }
}

//#Preview {
//    ContentView()
//        .padding()
//        .background(Background())
//}

#Preview {
    @State var session = MultipeerSession()
    ContentView(session: session)
        .onAppear {
            sortPlayers(session.players)
        }
//    stateIcon(.Injured)
//        .padding()
//        .frame(width: 100, height: 100)
}


struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
        @State var elapsedTime = 0.0
        PlayerView(player: Player(name: "Test", surname: "Test", playerName: "", origin: .Human, heartMode: .calm, imageName: "tom"), timer: timer, elapsedTime: $elapsedTime)
    }
}
