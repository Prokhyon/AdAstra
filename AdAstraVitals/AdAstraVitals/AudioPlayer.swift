//
//  AudioPlayer.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 27.02.2025.
//

import SwiftUI
import AVFoundation

struct AudioLoopView: View {
    @StateObject private var audioManager = AudioManager()

    var body: some View {
        VStack {
            Button(action: {
                audioManager.togglePlayback()
            }) {
                Text(audioManager.isPlaying ? "Stop Audio" : "Play Audio")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            audioManager.prepareAudio()
        }
    }
}

class AudioManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false

    func prepareAudio() {
        guard let url = Bundle.main.url(forResource: "ImperialAlarm", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Infinite loop
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading audio file: \(error)")
        }
    }
    
    func play() {
        guard let player = audioPlayer else { return }
        player.play()
        isPlaying = true
    }
    
    func stop() {
        guard let player = audioPlayer else { return }
        player.stop()
        isPlaying = false
    }

    func togglePlayback() {
        guard let player = audioPlayer else { return }
        print("togglePlayback")
        if player.isPlaying {
            player.stop()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
}

struct AudioLoopView_Previews: PreviewProvider {
    static var previews: some View {
        AudioLoopView()
    }
}
