//
//  ShortcutLaunch.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 27.02.2025.
//

import Intents
import SwiftUI
//import UIKit

func runSiriShortcutA() {
    let activity = NSUserActivity(activityType: "LED%20Alarme") // Replace with exact shortcut name
    activity.isEligibleForPrediction = true
    UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil, errorHandler: nil)
}

func runSiriShortcut() {
    let shortcutName = "LED%20Alarme"
    let shortcut = INShortcut(userActivity: NSUserActivity(activityType: shortcutName))
    
    let interaction = INInteraction(intent: shortcut.intent!, response: nil)
    interaction.donate { error in
        if let error = error {
            print("Failed to donate shortcut: \(error)")
        }
    }
}
func getShortcuts() {
    INVoiceShortcutCenter.shared.getAllVoiceShortcuts { shortcuts, error in
        if let shortcuts = shortcuts {
            for shortcut in shortcuts {
                print("Shortcut Name: \(shortcut.invocationPhrase)")
            }
        } else if let error = error {
            print("Error fetching shortcuts: \(error)")
        }
    }
}

enum LightMode {
    case normal
    case alarm
    case flash
}
func LightControl(mode: LightMode) {
    if mode == .alarm {
        if let url = URL(string: "shortcuts://x-callback-url/run-shortcut?name=LED%20Alarme&x-success=adastra://success") {
            UIApplication.shared.open(url)
        }
    } else if mode == .flash {
        if let url = URL(string: "shortcuts://x-callback-url/run-shortcut?name=LED%20Flash&x-success=adastra://success") {
            UIApplication.shared.open(url)
        }
    } else {
        if let url = URL(string: "shortcuts://x-callback-url/run-shortcut?name=LED%20Spaceship&x-success=adastra://success") {
            UIApplication.shared.open(url)
        }
    }
}
