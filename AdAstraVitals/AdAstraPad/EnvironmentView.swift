//
//  EnvironmentView.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 27.02.2025.
//

import SwiftUI
import Intents

struct EnvironmentView: View {
    @ObservedObject var session: MultipeerSession
    
    var body: some View {
        VStack {
            Text("Connecté à: \(session.connectedPeers.map { $0.displayName }.joined(separator: ", "))")
            //alarm view
            Spacer()
            Text("Contrôle de l'heure").font(.custom("silom", size: 20))
            TimeChangeView(session: session)
            Spacer()
            //Light settings
            Text("Contrôle de la lumière").font(.custom("silom", size: 20))
            LightControlView()
                .frame(width: 700, height: 70)
            Spacer()
            Text("Contrôle de l'alarme").font(.custom("silom", size: 20))
            HStack {
                Button(action: {
                    session.sendCommand("playAlarm")
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Text("Activer").font(.custom("silom", size: 20))
                        }
                }
                Button(action: {
                    session.sendCommand("stopAlarm")
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Text("Désactiver").font(.custom("silom", size: 20))
                        }
                }
            }
            .frame(width: 700, height: 70)
            Spacer()
        }
    }
}

struct LightControlView: View {
    var body: some View {
        HStack {
            Button(action: {
                LightControl(mode: .normal)
            }) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Text("Normal").font(.custom("silom", size: 20))
                    }
            }
            Button(action: {
                LightControl(mode: .alarm)
            }) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Text("Alarme").font(.custom("silom", size: 20))
                    }
            }
            Button(action: {
                LightControl(mode: .flash)
            }) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Text("Flash").font(.custom("silom", size: 20))
                    }
            }
        }
    }
}
