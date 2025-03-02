//
//  AdAstraTrialApp.swift
//  AdAstraTrial
//
//  Created by Loris Thomas on 27.11.2024.
//

import SwiftUI
import CoreText
import AppKit

func registerFont(withName fontName: String, type: String) {
    guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: type) else {
        print("Failed to find font file")
        return
    }

    guard let fontData = try? Data(contentsOf: fontURL) as CFData else {
        print("Failed to load font data")
        return
    }

    guard let provider = CGDataProvider(data: fontData),
          let font = CGFont(provider) else {
        print("Failed to create CGFont")
        return
    }

    var error: Unmanaged<CFError>?
    if !CTFontManagerRegisterGraphicsFont(font, &error) {
        print("Error registering \(fontName) font: \(error!.takeUnretainedValue())")
    } else {
        print("Successfully registered font: \(font.fullName!)")
    }
}

func loadAllFonts() {
    registerFont(withName: "Covenant", type: "ttf")
    registerFont(withName: "Anastomosis", type: "otf")
    registerFont(withName: "Cafed", type: "ttf")
    registerFont(withName: "Cycles", type: "ttf")
    registerFont(withName: "Hexacode", type: "ttf")
    registerFont(withName: "Sprykski", type: "otf")
    registerFont(withName: "wordsofpeuna", type: "ttf")
    registerFont(withName: "zuptype", type: "ttf")
}

@main
struct AdAstraTrialApp: App {
    @State var step: Step = .Welcome
    @State var guessSymbol = ""
    @State var currentCode: String = ""
    @State var failure = false
    @State var result: Bool?
    @State var selectedFont: String = "Cycles"
    @State var firstTryDone = false
    
    
    init() {
        loadAllFonts()
        
    }
    
    var body: some Scene {        
        WindowGroup("GridWindow") {
            ZStack {
                Background(failure: $failure)
                ContentView(step: $step, guessSymbol: $guessSymbol, currentCode: $currentCode, failure: $failure, result: $result, selectedFont: $selectedFont, firstTryDone: $firstTryDone)
            }
            .background(Background(failure: $failure))
            .preferredColorScheme(.dark)
        }

        WindowGroup("SymbolWindow") {
            ZStack {
                Background(failure: $failure)
                ContentSymbolView(step: $step, guessSymbol: $guessSymbol, result: $result, currentCode: $currentCode, selectedFont: $selectedFont, firstTryDone: $firstTryDone)
            }
            .background(Background(failure: $failure))
            .preferredColorScheme(.dark)
        }
        .handlesExternalEvents(matching: ["SymbolWindow"])
        
    }
}

//func getSymbol() -> String {
//    return ["a", "b", "c", "d", "F", "f", "g", "h", "j", "k", "Y", "m", "n", "o", "p", "q", "r", "s", "Ì", "u", "v", "w", "x", "y", "z"].randomElement()!
//}

struct Background: View {
    @Binding var failure: Bool
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("galaxyMap")
                    
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .blur(radius: 20)
//                    .ignoresSafeArea()
                
                Rectangle()
                    .fill(.red)
                    .opacity(failure ? 0.3 : 0)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
//                Rectangle()
//                    .fill(.ultraThinMaterial)
//                    .frame(width: geometry.size.width, height: geometry.size.height)
////                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    @State var failure: Bool = false
    Background(failure: $failure)
}
