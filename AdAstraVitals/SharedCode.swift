//
//  SharedCode.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 24.02.2025.
//
import SwiftUI

struct Player: Identifiable, Codable {
    var id = UUID()
    let name: String
    let surname: String
    let playerName: String
//    let age: Int
//    let height: Double
    var origin: Origin
//    let profession: String
    var state: PlayerState = .Normal
    var heartMode: HeartbeatMode
    var imageName: String
}

enum Origin: String, Codable {
    case Human, Augmented, Android, Saved
}

enum PlayerState: String, CaseIterable, Codable {
    case Normal, Poisoned, Frozen, Burned, Radioactive, Infected, Injured, Unconscious, Unleaded, Pirated, Dead
}

enum HeartbeatMode: String, CaseIterable, Codable {
    case calm, active, dead
}

struct Message: Codable, Identifiable, Hashable {
    var id: UUID
    var text: String
    var type: MessageType
}
enum MessageType: String, Codable {
    case Alert, Transmission, Information
}

func stateIcon(_ state: PlayerState) -> Image {
    switch state {
    case .Normal:
        return Image(systemName: "heart.fill") // Default icon
    case .Poisoned:
        return Image(systemName: "flask") // Poison symbol
    case .Frozen:
        return Image(systemName: "snowflake") // Freezing icon
    case .Burned:
        return Image(systemName: "flame.fill") // Burned icon
    case .Unconscious:
        return Image(systemName: "xmark.circle.fill") // Unconscious icon
    case .Dead:
        return Image("skull").resizable() // Dead icon
    case .Radioactive:
        return Image("radioactive").resizable()
    case .Injured:
        return Image(systemName: "cross.circle.fill")
    case .Infected:
        return Image("biological").resizable()
    case .Unleaded:
        return Image(systemName: "shield.slash.fill")
    case .Pirated:
        return Image(systemName: "lock.open.trianglebadge.exclamationmark.fill")
    }
}

func stateText(_ state: PlayerState, displayNormal: Bool = false) -> String {
    switch state {
    case .Normal:
        if displayNormal {
            return "R·A·S"
        } else {
            return ""
        }
    case .Poisoned:
        return "Empoisonné·e·x"
    case .Frozen:
        return "Glacé·e·x"
    case .Burned:
        return "Brulé·e·x"
    case .Unconscious:
        return "Inconscient·e·x"
    case .Dead:
        return "Décédé·e·x"
    case .Radioactive:
        return "Irradié·e·x"
    case .Injured:
        return "Blessé·e·x"
    case .Infected:
        return "Infécté·e·x"
    case .Unleaded:
        return "Déplombé·e·x"
    case .Pirated:
        return "Piraté·e·x"
    }
}

func originDisplay(_ origin: Origin) -> String {
    switch origin {
    case .Human:
        return "Humain·e·x"
    case .Augmented:
        return "Augmenté·e·x"
    case .Android:
        return "Androïde"
    case .Saved:
        return "Sauvegardé"
    }
}

struct Background:View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .ignoresSafeArea()
            .background {
                Image("galaxyMap")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                //            .scaledToFill()
//                    .blur(radius: 5)
            }
    }
}

#Preview {
    stateIcon(.Unleaded)
}
