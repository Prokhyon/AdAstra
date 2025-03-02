//
//  TimeChange.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 27.02.2025.
//
import SwiftUI

struct TimeChangeView: View {
    @ObservedObject var session: MultipeerSession
    @State var setTime: Bool = false
    @State private var selectedHour = 14
     @State private var selectedMinute = 0
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        session.sendCommand("startClock")
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Text("Démarer").font(.custom("silom", size: 20))
                            }
                    }
                    .frame(width: 300, height: 70)
                    
                    Button(action: {
                        session.sendCommand("pauseClock")
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Text("Pause").font(.custom("silom", size: 20))
                            }
                    }
                    .frame(width: 300, height: 70)
                }
                Button(action: {
                    setTime = true
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Text("Régler manuellement").font(.custom("silom", size: 20))
                        }
                }
                .frame(width: 300, height: 70)
            }
            .sheet(isPresented: $setTime, content: {
                VStack {
                        Text("Régler l'heure").font(.custom("silom", size: 30))
                            .padding()
                    
                    HStack {
                        Picker("Hour", selection: $selectedHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text("\(hour)").tag(hour).font(.custom("silom", size: 25))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80)
                        
                        Text(":").font(.custom("silom", size: 25))
                        
                        Picker("Minute", selection: $selectedMinute) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text(String(format: "%02d", minute)).tag(minute).font(.custom("silom", size: 25))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80)
                    }
                    
                    Button(action: {
                        session.sendTimeUpdate(hour: selectedHour, minute: selectedMinute)
                        setTime = false
                    }) {
                        Text("Mettre à jour l'heure").font(.custom("silom", size: 30))
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                            }
                    }
                }
//                .background {
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(.ultraThinMaterial)
//                }
            })
        }
    }
}

#Preview {
    @State var session = MultipeerSession()
    TimeChangeView(session: session)
}
