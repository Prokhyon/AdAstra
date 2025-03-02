//
//  PlayerManager.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 11.02.2025.
//

import Foundation
import SwiftUI



struct PlayerEditView: View {
    @Binding var player: Player
    @State var confirmRevive = false

    var body: some View {
        VStack {
            Text("\(player.name) \(player.surname)").font(.custom("silom", size: 30))
            if player.state == .Dead && player.heartMode == .dead {
                Button(action: {
                    confirmRevive = true
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(minWidth: 100, minHeight: 40)
                        .foregroundStyle(.ultraThinMaterial)
                        .overlay {
                            Text("Revivre").font(.caption).foregroundStyle(.green)
                        }
                }
                .buttonStyle(.plain)
                .confirmationDialog("Confirmer le retour à la vie de \(player.name) \(player.surname)", isPresented: $confirmRevive) {
                    Button("Confirmer et revivre") {
                        if player.origin == .Human || player.origin == .Augmented {
                            player.origin = .Saved
                        }
                        player.heartMode = .calm
                        player.state = .Normal
                    }
                    Button("Annuler", role: .cancel) {}
                }
            }
            HStack {
                ForEach(PlayerState.allCases, id: \.self) { state in
                    Button(action: {
                        player.state = state
                    }) {
                        Text(state.rawValue.capitalized).font(.caption)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 15)
//                                    .frame(minWidth: 100, minHeight: 40)
                                    .foregroundStyle(player.state == state ? .ultraThickMaterial: .ultraThinMaterial)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            HStack {
                
                    Button(action: {
                        player.heartMode = HeartbeatMode.calm
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(minWidth: 100, minHeight: 40)
                            .foregroundStyle(player.heartMode == .calm ? .ultraThickMaterial: .ultraThinMaterial)
                            .overlay {
                                Text("Calme").font(.caption)
                            }
                    }
                    .buttonStyle(.plain)
                Button(action: {
                    player.heartMode = HeartbeatMode.active
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(minWidth: 100, minHeight: 40)
                        .foregroundStyle(player.heartMode == .active ? .ultraThickMaterial: .ultraThinMaterial)
                        .overlay {
                            Text("Actif").font(.caption)
                        }
                }
                .buttonStyle(.plain)
                Button(action: {
                    player.heartMode = HeartbeatMode.dead
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(minWidth: 100, minHeight: 40)
                        .foregroundStyle(player.heartMode == .dead ? .ultraThickMaterial: .ultraThinMaterial)
                        .overlay {
                            Text("Mort").font(.caption)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .padding()
    }
}

struct EditView: View {
    @ObservedObject var session: MultipeerSession

    var body: some View {
        ScrollView {
            Text("Connected Peers: \(session.connectedPeers.map { $0.displayName }.joined(separator: ", "))")
            Grid {
                ForEach(0..<(session.players.count + 1) / 2, id: \.self) { row in
                    HStack {
                        ForEach(0..<2, id: \.self) { column in
                            let index = row * 2 + column
                            if index < session.players.count {
                                PlayerEditView(player: $session.players[index])
                                    .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial).shadow(radius: 5))
                                    .padding(5)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial).shadow(radius: 5))
            .padding()
        }
    }
}

//#Preview {
//    @Previewable @StateObject var playerManager = PlayerManager()
//    EditView()
//        .padding()
//        .background(Background())
//        .environmentObject(playerManager)
//}
