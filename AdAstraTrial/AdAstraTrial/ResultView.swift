//
//  ResultView.swift
//  AdAstraTrial
//
//  Created by Loris Thomas on 18.02.2025.
//

import SwiftUI

struct ResultView: View {
    @Binding var step: Step
    @Binding var code: String
    @Binding var firstTryDone: Bool
    var mainTerminal: Bool
//    var m = ["Syracuse", "Agincourt", "Orleans", "Vienne", "Leipzig", "Waterloo", "Stalingrad", "Marathon", "Zama", "Poitiers", "Somme", "Austerlitz", "Verdun", "Marignan"]
    var codes: [String : String] = ["WP67": "Zama", "QBO6": "Austerlitz", "THWM": "Orleans", "7765": "Waterloo", "FL25": "Somme", "YT4Y": "Hastings", "KWKV": "Alésia", "EI47": "Leipzig", "O72X": "Marathon", "TGJT": "Poitiers", "WP77": "Verdun", "ZTGM": "Agincourt", "KVFP": "Dunes", "N32W": "Marignan", "CF4Z": "Stalingrad", "BDZ7": "Vienne"]
    var result: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if result {
                Text("Analyse terminée avec succès").font(.custom("silom", size: 30))
                Text("Le texte déchiffré est :").font(.custom("silom", size: 20))
                Text(codes[code] ?? "Erreur, allez voir le mj").font(.custom("silom", size: 20))
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    }
            } else if !firstTryDone {
                Spacer()
                Text("Echec de l'analyse").font(.custom("silom", size: 30))
                Text("Le symbole n'a pas été transmis correctement").font(.custom("silom", size: 20))
                Text("Vous avez échoué l'épreuve.").font(.custom("silom", size: 20))
                Spacer()
                Text("Vous avez le droit à un second essai").font(.custom("silom", size: 30))
                Spacer()
            } else {
                Text("Echec de l'analyse").font(.custom("silom", size: 30))
                Text("Le symbole n'a pas été transmis correctement").font(.custom("silom", size: 20))
                Text("Vous avez échoué l'épreuve.").font(.custom("silom", size: 20))
            }
            if mainTerminal {
                if !firstTryDone && !result {
                    Button(action: {
                        firstTryDone = true
                        withAnimation {
                            step = .Trial
                        }
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.regularMaterial)
                            .frame(minWidth: 50, maxWidth: 200, maxHeight: 50)
                            .overlay {
                                Text("Redémarrer").font(.custom("silom", size: 20))
                            }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                } else {
                    Button(action: {
                        withAnimation {
                            step = .Welcome
                        }
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.regularMaterial)
                            .frame(minWidth: 50, maxWidth: 200, maxHeight: 50)
                            .overlay {
                                Text("Terminer").font(.custom("silom", size: 20))
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

func codeHash(codes: [String]) /*-> [String : String]*/ {
    var dict: [String : String] = [:]
    for code in codes {
        dict[generateBase32ID(from: code)] = code
    }
    
//    return dict
    print(dict)
}

import CryptoKit
func generateBase32ID(from name: String, length: Int = 4) -> String {
    let data = SHA256.hash(data: Data(name.utf8))
    let base32Alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")

    var base32 = ""
    var index = 0
    var accumulator: UInt32 = 0
    var bits = 0

    for byte in data {
        accumulator = (accumulator << length) | UInt32(byte)
        bits += 8

        while bits >= 5 {
            let charIndex = (accumulator >> (bits - 5)) & 31
            base32.append(base32Alphabet[Int(charIndex)])
            bits -= 5
        }
        
        index += 1
        if base32.count >= length { break } // Limit to 8 characters
    }

    // Edge case: Ensure we always return exactly 8 characters
    while base32.count < length {
        base32.append(base32Alphabet[Int(accumulator & 31)])
        accumulator >>= 5
    }

    return base32
}

//#Preview {
//    var m = ["Syracuse", "Agincourt", "Orleans", "Vienne", "Leipzig", "Waterloo", "Stalingrad", "Marathon", "Zama", "Poitiers", "Somme", "Austerlitz", "Verdun", "Marignan", "Hastings", "Dunes", "Alésia", "Marignan"]
//    testView()
//        .body.onAppear {
//            codeHash(codes: m)
//        }
//}
//
//struct testView {
//    var body: some View {
//        Text("Hello, World!")
//    }
//}
