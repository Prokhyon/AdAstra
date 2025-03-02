//
//  GridView.swift
//  AdAstraTrial
//
//  Created by Loris Thomas on 18.02.2025.
//
import SwiftUI

struct GridView: View {
    @State var symbolList: [String]
    @Binding var selectedSymbol: String
    @Binding var selectedFont: String
    @Binding var guessSymbol: String
    @Binding var step: Step
    @Binding var result: Bool?
    var size: CGFloat = 50
    @State private var showMenu = false

    // Define grid columns
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)

    var body: some View {
        ZStack {
            VStack {
//                HStack {
////                    Button(action: {
////                        withAnimation {
////                            step = .Welcome
////                        }
////                    }) {
////                        Image(systemName: "arrowtriangle.left.fill")
////                            .padding(20)
////                            .font(.largeTitle)
////                            .foregroundStyle(.white)
////                    }
////                    .buttonStyle(.plain)
//                    Text("Mars Express")
//                    Spacer()
//                    Image(systemName: showMenu ? "wake.circle.fill" : "wake.circle")
//                        .padding(20)
//                        .font(.largeTitle)
//                        .foregroundStyle(.white)
//                        .onTapGesture {
//                            withAnimation {
//                                showMenu.toggle()
//                            }
//                        }
//                }

                Spacer()
                // Replacing Grid with LazyVGrid
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(symbolList, id: \.self) { symbol in
                        SelectableSymbolView(
                            symbol: symbol, size: size,
                            isSelected: selectedSymbol == symbol,
                            onSelected: {
                                if selectedSymbol == symbol {
                                    withAnimation(.spring()) {
                                        selectedSymbol = ""
                                    }
                                } else {
                                    withAnimation(.spring()) {
                                        selectedSymbol = symbol
                                    }
                                }
                            },
                            selectedFont: $selectedFont
                        )
                        
                    }
                }
                .padding(.horizontal)
                Spacer()
                Button(action: {
                    withAnimation {
//                        result = true
                        result = selectedSymbol == guessSymbol
                        step = .Result
                    }
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                        .frame(minWidth: 50, maxWidth: 200, maxHeight: 50)
                        .overlay {
                            Text("Confirmer").font(.custom("silom", size: 20))
                        }
                }
                .buttonStyle(.plain)
                .disabled(selectedSymbol.isEmpty)
                Spacer()
            }
            .padding()
            HStack(alignment: .bottom) {
                Spacer()
//                if showMenu {
//                    VStack {
//                        VStack(alignment: .leading) {
//                            Button("Shuffle") {
//                                symbolList = symbolList.shuffled()
//                                guessSymbol = symbolList.randomElement()!
//                            }
//                            .padding()
//                            Text("Symbols")
//                                .font(.title)
//                                .padding(.top, 10)
//                            Picker(selection: $selectedFont, label: Text("")) {
//                                Text("Covenant").tag("Covenant")
//                                Text("Anastomosis").tag("Anastomosis")
//                                Text("Cafed").tag("Cafeina Dig_v2")
//                                Text("Cycles").tag("Cycles")
//                                Text("Hexacode").tag("Hexacode")
//                                Text("Sprykski").tag("Sprykski")
//                                Text("WordsOfPeuna").tag("wordsofpeuna")
//                                Text("Zuptype").tag("zuptype_pica")
//                            }
//                            .pickerStyle(.radioGroup)
//                        }
//                        .frame(width: 150, height: 300)
//                        .background {
//                            RoundedRectangle(cornerRadius: 30)
//                                .fill(.regularMaterial)
//                        }
//                        Spacer()
//                    }
//                    .padding(.vertical, 70)
//                    .padding(.trailing, 20)
//                }
            }
        }
        .onAppear {
            symbolList = symbolList.shuffled()
        }
    }
}

struct SelectableSymbolView: View {
    var symbol: String
    var size: CGFloat
    var isSelected: Bool
    var onSelected: () -> Void
    @Binding var selectedFont: String
    @State private var offset: CGSize = .zero
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(isSelected ? .ultraThickMaterial : .ultraThinMaterial)
            .frame(maxWidth: .infinity, minHeight: 200)
//            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Text(symbol)
                    .font(.custom(selectedFont, size: 130))
                    .minimumScaleFactor(0.5) // Scale down to half the size if necessary
                    /*.frame(maxWidth: .infinity, maxHeight: .infinity)*/ // Let it expand as needed
            )
            .scaleEffect(isSelected ? 1.1 : 1.0) // Slightly larger when selected
            .offset(x: offset.width, y: offset.height)
            .gesture(TapGesture().onEnded(onSelected))
            .onHover { hovering in
                if hovering {
                    withAnimation(.spring(duration: 0.3)) {
                        offset = CGSize(width: CGFloat.random(in: -5...5), height: CGFloat.random(in: -5...5))
                    }
                } else {
                    withAnimation(.spring(duration: 0.3)) {
                        offset = .zero
                    }
                }
            }
    }
}

//#Preview {
//    @Previewable @State var step: Step = .Trial
//    @Previewable @State var guessSymbol = "a"
//    @Previewable @State var failure = false
//    @Previewable @State var result: Bool?
//    
//    ZStack {
//        Background(failure: $failure)
//        ContentView(step: $step, guessSymbol: $guessSymbol, failure: $failure, result: $result)
//    }
//}
