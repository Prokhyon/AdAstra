//
//  ContentView.swift
//  AdAstraTrial
//
//  Created by Loris Thomas on 27.11.2024.
//

import SwiftUI

enum Font {
    case Covenant
    case Anastomosis
    case Cafed
    case Cycles
    case Hexacode
    case Sprykski
    case WordsOfPeuna
    case Zuptype
}

enum Step {
    case Welcome
    case Trial
    case Result
}

struct ContentView: View {
    @Binding var step: Step
    @State var symbolList = ["a", "c", "d", "F", "f", "g", "h", "j", "k", "Y", "m", "n", "o", "p", "q", "r", "s", "Ì", "u", "v", "w", "x", "y", "z"]
    @Binding var guessSymbol: String
    @Binding var currentCode: String
    @Binding var failure: Bool
    @Binding var result: Bool?
    @State var selectedSymbol = ""
    @Binding var selectedFont: String
    @Binding var firstTryDone: Bool
    @State var inputCodes: [String : Bool] = ["WP67": false, "QBO6": false, "THWM": false, "7765": false, "FL25": false, "YT4Y": false, "KWKV": false, "EI47": false, "O72X": false, "TGJT": false, "WP77": false, "ZTGM": false, "KVFP": false, "N32W": false, "CF4Z": false, "BDZ7": false]
    
    var body: some View {
        switch step {
        case .Welcome:
            WelcomeGridView(step: $step, currentCode: $currentCode, inputCodes: $inputCodes)
                .onAppear {
                    guessSymbol = ""
                    selectedSymbol = ""
                    failure = false
                    result = nil
                    firstTryDone = false
                }
        case .Trial:
            GridView(symbolList: symbolList, selectedSymbol: $selectedSymbol, selectedFont: $selectedFont, guessSymbol: $guessSymbol, step: $step, result: $result)
                .onAppear {
                    guessSymbol = symbolList.randomElement()!
                    selectedSymbol = ""
                    failure = false
                    result = nil
                }
        case .Result:
            ResultView(step: $step, code: $currentCode, firstTryDone: $firstTryDone, mainTerminal: true, result: result ?? false)
                .onAppear {
                    failure = !(result ?? true)
                }
        }

    }
}

struct ContentSymbolView: View {
    @Binding var step: Step
    @Binding var guessSymbol: String
    @Binding var result: Bool?
    @Binding var currentCode: String
    @Binding var selectedFont: String
    @Binding var firstTryDone: Bool
    
    var body: some View {
        switch step {
        case .Welcome:
            WelcomeSymbolView(step: $step)
        case .Trial:
            SymbolView(symbol: guessSymbol, size: 300, selectedFont: $selectedFont)
                .transition(.scale)
        case .Result:
            ResultView(step: $step, code: $currentCode, firstTryDone: $firstTryDone, mainTerminal: false, result: result ?? false)
        }
    }
}

struct SymbolView: View {
    var symbol: String
    var size: CGFloat
    @Binding var selectedFont: String
    
    var body: some View {
        Text(symbol)
            .font(.custom(selectedFont, size: size))
            .padding(100)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.4))
            }
    }
}

func checkAnswer(selectedSymbol: String, guessSymbol: String) -> Bool {
    return selectedSymbol == guessSymbol
}

//#Preview {
//    @Previewable @State var step: Step = .Welcome
//    @Previewable @State var guessSymbol = "a"
//    @Previewable @State var failure = false
//    @Previewable @State var result: Bool?
//    
//    ZStack {
//        Background(failure: $failure)
//        ContentView(step: $step, guessSymbol: $guessSymbol, failure: $failure, result: $result)
//    }
//}

//struct preview_Previews: PreviewProvider {
//    @State var step: Step = .Welcome
//    @State var guessSymbol = ""
//    @State var failure = false
//    @State var result: Bool?
//    
//    static var previews: some View {
//        ZStack {
//            Background(failure: $failure)
//            ContentView(guessSymbol: $guessSymbol, failure: $failure)
//        }
//    }
//}
