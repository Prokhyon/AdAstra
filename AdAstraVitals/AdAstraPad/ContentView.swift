//
//  ContentView.swift
//  AdAstraPad
//
//  Created by Loris Thomas on 16.02.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var session = MultipeerSession()
//    @State var messageView = false

    var body: some View {
        VStack {
            
            TabView {
                EditView(session: session)
                    .tabItem {
                        Label("Détenus", systemImage: "person.2.fill")
                    }
                  .background(Background())
                SendMessageView(session: session)
                    .tabItem {
                        Label("Communications", systemImage: "message.fill")
                    }
                    .background(Background())
                ZStack {
                    Background()
                    EnvironmentView(session: session)
                }
                    .tabItem {
                        Label("Environnement", systemImage: "network")
                    }
            }
        }
//        .background(Background())
//        .background {Image("galaxyMap")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .scaledToFill()
//                .blur(radius: 5)
//        }

    }
}

struct PlayerEditView: View {
    @Binding var player: Player
    let sessionUpdate: ()
    @State var confirmKill = false
    @State var confirmRevive = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(player.name) \(player.surname)").font(.custom("silom", size: 40))
                        Text("Origine: \(originDisplay(player.origin))").font(.custom("silom", size: 25))
                        Spacer()
                    }
                    Spacer()
                    if player.state == .Dead && player.heartMode == .dead {
                        Button(action: {
                            confirmRevive = true
                        }) {
                            RoundedRectangle(cornerRadius: 15)
                                .frame(width: 200, height: 100)
                                .foregroundStyle(.ultraThinMaterial)
                                .overlay {
                                    Text("Revivre").font(.custom("silom", size: 20)).foregroundStyle(.green)
                                }
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: {
                            confirmKill = true
                        }) {
                            RoundedRectangle(cornerRadius: 15)
                                .frame(width: 200, height: 100)
                                .foregroundStyle(.ultraThinMaterial)
                                .overlay {
                                    Text("Tuer").font(.custom("silom", size: 20)).foregroundStyle(.red)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxHeight: 100)
                
                Rectangle()
                    .frame(height: 20)
                    .opacity(0)
                
                Text("Etat:").font(.custom("silom", size: 25))
                VStack {
                    ForEach(0..<PlayerState.allCases.count / 5, id: \.self) { row in
                        HStack {
                            ForEach(0..<5, id: \.self) { column in
                                let index = row * 5 + column
                                if index < PlayerState.allCases.count {
                                    let state = PlayerState.allCases[index]
                                    if state != .Dead {
                                        Button(action: {
                                            player.state = state
//                                            if state == .Poisoned {
//                                                player.heartMode = .active
//                                            }
                                            sessionUpdate
                                        }) {
                                            RoundedRectangle(cornerRadius: 15)
                                                .frame(minWidth: 100, minHeight: 40)
                                                .foregroundStyle(player.state == state ? .ultraThickMaterial : .ultraThinMaterial)
                                                .overlay {
                                                    HStack {
                                                        stateIcon(state)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 20, height: 20)
                                                        Text(stateText(state, displayNormal: true)).font(.custom("silom", size: 15))
                                                            .minimumScaleFactor(0.1)
                                                    }
                                                }
                                                .background {
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(player.state == state ? Color.blue : .clear, lineWidth: 2)
                                                }
                                        }
                                        .disabled(player.state == .Dead)
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
                Rectangle()
                    .frame(height: 20)
                    .opacity(0)
                Text("Rythme interne:").font(.custom("silom", size: 25))
                HStack {
                    Button(action: {
                        player.heartMode = .calm
                        sessionUpdate
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(minWidth: 100, minHeight: 40)
                            .foregroundStyle(player.heartMode == .calm ? .ultraThickMaterial : .ultraThinMaterial)
                            .overlay {
                                Text("Calme").font(.custom("silom", size: 20))
                            }
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(player.heartMode == .calm ? Color.blue : .clear, lineWidth: 2)
                            }
                    }
                    .buttonStyle(.plain)
                    .disabled(player.heartMode == .dead)
                    
                    Button(action: {
                        player.heartMode = .active
                        sessionUpdate
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(minWidth: 100, minHeight: 40)
                            .foregroundStyle(player.heartMode == .active ? .ultraThickMaterial : .ultraThinMaterial)
                            .overlay {
                                Text("Elevé").font(.custom("silom", size: 20))
                            }
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(player.heartMode == .active ? Color.blue : .clear, lineWidth: 2)
                            }
                    }
                    .buttonStyle(.plain)
                    .disabled(player.heartMode == .dead)
                }
                .frame(maxHeight: 100)
            }
            .padding(40)
            .overlay {
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.black)
                    .opacity(confirmKill || confirmRevive ? 0.5 : 0)
//                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        confirmKill = false
                        confirmRevive = false
                    }
            }
            
            if player.state == .Dead && player.heartMode == .dead {
                Text("Décédé·e·x").font(.custom("silom", size: 50)).foregroundStyle(.red)
            }
            
            if confirmKill {
                VStack(spacing: 30) {
                    Text("Confirmer la mort de \(player.name) \(player.surname)").font(.custom("silom", size: 30))
                    HStack(spacing: 30) {
                        Button(action: {
                            confirmKill = false
                        }) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThickMaterial)
                                .frame(maxWidth: 400, maxHeight: 80)
                                .overlay {
                                    Text("Annuler").font(.custom("silom", size: 20)).foregroundColor(.primary)
                                }
                        }
                        Button(action: {
                            player.state = .Dead
                            player.heartMode = .dead
                            sessionUpdate
                            confirmKill = false
                        }) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThickMaterial)
                                .frame(maxWidth: 400, maxHeight: 80)
                                .overlay {
                                    Text("Confirmer et tuer").font(.custom("silom", size: 20)).foregroundStyle(.red)
                                }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 800, maxHeight: 300)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                }

            } else if confirmRevive {
                VStack(spacing: 30) {
                    Text("Confirmer le retour à la vie de \(player.name) \(player.surname)").font(.custom("silom", size: 30))
                    HStack(spacing: 30) {
                        Button(action: {
                            confirmRevive = false
                        }) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThickMaterial)
                                .frame(maxWidth: 400, maxHeight: 80)
                                .overlay {
                                    Text("Annuler").font(.custom("silom", size: 20)).foregroundColor(.primary)
                                }
                        }
                        Button(action: {
                            if player.origin == .Human || player.origin == .Augmented {
                                player.origin = .Saved
                            }
                            player.heartMode = .calm
                            player.state = .Normal
                            sessionUpdate
                            confirmRevive = false
                        }) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThickMaterial)
                                .frame(maxWidth: 400, maxHeight: 80)
                                .overlay {
                                    Text("Confirmer et revivre").font(.custom("silom", size: 20)).foregroundStyle(.green)
                                }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 800, maxHeight: 300)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                }
            }
        }
    }
}

struct EditView: View {
    @ObservedObject var session: MultipeerSession
    @State private var selectedPlayer: Player? = nil
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                ScrollView {
                    VStack {
                        if let columnNumber = reader.size.width > 1000 ? 3 : 2 {
                            ForEach(0..<session.players.count / columnNumber, id: \.self) { row in
                                HStack {
                                    ForEach(0..<columnNumber, id: \.self) { column in
                                        let index = row * columnNumber + column
                                        if index < session.players.count {
                                            let player = session.players[index]
                                            Button(action: {
                                                selectedPlayer = player
                                            }) {
                                                PlayerButton(player: player)
                                            }
                                            .foregroundColor(.primary)
                                        }
                                    }
                                }
                            }
                            HStack {
                                let player = session.players[12]
                                Button(action: {
                                    selectedPlayer = player
                                }) {
                                    PlayerButton(player: player)
                                }
                                .foregroundColor(.primary)
                                Rectangle()
                                    .fill(.clear)
                                Rectangle()
                                    .fill(.clear)
                            }
                        }
                    }
                    .padding()
                }
                
                // Edit View Overlay
                if let player = selectedPlayer, let index = session.players.firstIndex(where: { $0.id == player.id }) {
                    Rectangle()
                        .fill(Color.black)
                        .opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            selectedPlayer = nil
                        }
                    PlayerEditView(player: $session.players[index], sessionUpdate: session.send(players: session.players))
                        .padding(40)
                        .background {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.ultraThinMaterial)
                                .shadow(radius: 5)
                                .padding(40)
                                .onTapGesture {
                                    selectedPlayer = nil
                                }
                        }
                }
            }
        }
    }
}

struct PlayerButton : View {
    var player: Player
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(player.name) \(player.surname)").font(.custom("silom", size: 25))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("Joueur: \(player.playerName)").font(.custom("silom", size: 15)).lineLimit(1).minimumScaleFactor(0.5)
                Spacer(minLength: 20)
                Text("Etat: \( stateText(player.state, displayNormal: true))").font(.custom("silom", size: 17)).lineLimit(1).minimumScaleFactor(0.5)
                Text("Rythme interne: \( heartbeatText(player.heartMode))").font(.custom("silom", size: 17)).lineLimit(1).minimumScaleFactor(0.5)
            }
            Spacer()
        }
        .padding(10)
        .background {
            HStack {
                Spacer()
                    Image(player.imageName)
                        .resizable()
                        .scaledToFit()
                        .colorMultiply(.blue)
            }
            .opacity(0.7)
            .mask {
                Rectangle()
                    .overlay(alignment: .trailing) {
                        LinearGradient(colors: [.black, .clear], startPoint: UnitPoint(x: 0.6, y: 0), endPoint: UnitPoint(x: 1, y: 0))
                            .blendMode(.destinationOut)
                    }
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
        }
    }
}

func heartbeatText(_ heartbeat: HeartbeatMode) -> String {
    switch heartbeat {
    case .calm:
        return "Calme"
    case .active:
        return "Actif·ve·x"
    case .dead:
        return "Décédé·e·x"
    }
}

struct ContentPadPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            ContentView()
        }
    }
}
