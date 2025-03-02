//
//  AdAstraVitalsApp.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 11.10.2024.
//

import SwiftUI

@main
struct AdAstraVitalsApp: App {
    @StateObject var session = MultipeerSession()
    
    var body: some Scene {
        WindowGroup {
            ContentView(session: session)
                .background(Background())
                .preferredColorScheme(.dark)
//                .scaledToFit()
//                .frame(width: 1500, height: 1500)
        }

        WindowGroup("Edit Players") {
            EditView(session: session)
                .background(Background())
                .preferredColorScheme(.dark)
        }
        .handlesExternalEvents(matching: ["editPlayers"])
    }
}
