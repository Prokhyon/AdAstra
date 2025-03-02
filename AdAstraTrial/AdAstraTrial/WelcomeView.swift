//
//  WelcomeView.swift
//  AdAstraTrial
//
//  Created by Loris Thomas on 18.02.2025.
//

import SwiftUI

enum codeState {
    case empty
    case accepted
    case notAccepted
    case alreadyUsed
}

struct WelcomeGridView: View {
    @Binding var step: Step
    @Binding var currentCode: String
    @Binding var inputCodes: [String : Bool]
    @State var codeState: codeState = .empty
    @State private var codeText: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Bienvenue à l'avant-poste").font(.custom("silom", size: 30))
            Text("Vous pourrez ici analyser les objets que vous trouvez").font(.custom("silom", size: 20))
            Text("Pour ce faire, placez vous chacun devant un moniteur").font(.custom("silom", size: 20))
            Text("Votre but à ce poste est de retrouver le symbole de votre partenaire face à vous grâce à ses descriptions").font(.custom("silom", size: 20))
            Text("Une fois chacun prêt, entrez votre code ci-dessous afin de débuter l'analyse").font(.custom("silom", size: 20))
            Spacer()
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .frame(width: 300, height: 50)
                .overlay {
                    TextField(
                        "Entrez le code ici",
                        text: $codeText
                    )
                    .font(.custom("silom", size: 20))
                    .onChange(of: codeText) { newValue in
                        // Filter only uppercase letters and numbers
                        codeText = newValue.uppercased().filter { $0.isLetter || $0.isNumber }
                    }
                    .onSubmit {
                        if codeState != .accepted {
                            validateCode(code: codeText)
                            if codeState != .accepted {
                                codeText = ""
                            }
                        }
                    }
                    
                    .disableAutocorrection(true)
                    .textFieldStyle(.plain)
                    .padding(.horizontal)
                }
            Spacer()
            VStack {
                switch codeState {
                case .empty:
                    Spacer()
                case .accepted:
                    Text("Votre code est valide").font(.custom("silom", size: 20))
                    Spacer()
                    Button(action: {
                        withAnimation {
                            step = .Trial
                        }
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.regularMaterial)
                            .frame(minWidth: 50, maxWidth: 200, maxHeight: 50)
                            .overlay {
                                Text("Démarrer").font(.custom("silom", size: 30))
                            }
                    }
                    .buttonStyle(.plain)
                case .notAccepted:
                    Text("Ce code n'est pas valide").font(.custom("silom", size: 20))
                case .alreadyUsed:
                    Text("Votre code a déjà été utilisé").font(.custom("silom", size: 20))
                }
            }
                .frame(height: 100)
            Spacer()
        }
        .shadow(radius: 2)
        .padding()
    }
    private func validateCode(code: String) {
        if inputCodes.contains(where: { $0.key == code }) {
//            print(inputCodes[code])
            if inputCodes[code] ?? true {
                codeState = .alreadyUsed
            } else {
                codeState = .accepted
                currentCode = codeText
                inputCodes[code] = true
            }
        } else {
            codeState = .notAccepted
        }
        
    }
}

struct WelcomeSymbolView : View {
    @Binding var step: Step
     var body: some View {
         VStack(spacing: 20) {
             Text("Bienvenue à l'avant-poste").font(.custom("silom", size: 30))
             Text("Vous pourrez ici analyser les objets que vous trouvez").font(.custom("silom", size: 20))
             Text("Placez vous chacun devant un moniteur afin de débuter l'analyse").font(.custom("silom", size: 20))
             Text("Votre but à ce poste est de décrire à votre partenaire face à vous, le symbole qui vous sera dévoilé").font(.custom("silom", size: 20))
             Text("Il devra alors le retrouver").font(.custom("silom", size: 20))
         }
         .shadow(radius: 2)
    }
}

#Preview {
    @State var step: Step = .Welcome
    @State var code: String = ""
    @State var failure: Bool = false
    WelcomeSymbolView(step: $step/*, currentCode: $code*/)
        .background(Background(failure: $failure))
}
