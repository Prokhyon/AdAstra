//
//  SendMessageView.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 20.02.2025.
//

import SwiftUI

struct SendMessageView: View {
    @ObservedObject var session: MultipeerSession
//    @State var session = MultipeerSession()
    @State var savedMessages = SavedMessages()
//    @State var text: String = ""
    @State var writeMessage = false
    @State var confirmMessage = false
    @State var confirmDeletion = false
    @State var editing = false
    @State var selectedMessage: Message?
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Text("Communications").font(.custom("silom", size: 30))
                    Spacer()
                    Button(action: {
                        editing.toggle()
                    }) {
                        Image(systemName: editing ? "minus.circle.fill" : "minus.circle").font(.largeTitle)
                    }
                }
                HStack {
                    Spacer()
                    Button(action: {
                        writeMessage = true
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Text("Rédiger un message").font(.custom("silom", size: 20))
                            }
                    }
                    .frame(width: 300, height: 70)
                    Button(action: {
                        LightControl(mode: .normal)
                        session.sendCommand("removeMessage")
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Text("Retirer le message de l'affichage").font(.custom("silom", size: 20))
                            }
                    }
                    .frame(width: 300, height: 70)
                    Spacer()
                }
                ScrollView {
                    ForEach(savedMessages.savedMessages, id: \.self) { message in
                        HStack {
                            if editing {
                                Button(action: {
                                    selectedMessage = message
                                    confirmDeletion = true
                                }) {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 100)
                                        .overlay {
                                            Image(systemName: "xmark")
                                                .foregroundStyle(.red)
                                        }
                                }
                            }
                            Button(action: {
                                selectedMessage = message
                                confirmMessage = true
                            }) {
                                PreparedMessageView(message: message)
                            }
                            .foregroundStyle(.primary)
                        }
                        .padding(10)
                    }
                }
            }
            .sheet(isPresented: $writeMessage, content: {
                WriteMessageView(session: session, savedMessages: $savedMessages, writeMessage: $writeMessage)
            })
//                if writeMessage {
//                    WriteMessageView(session: session, savedMessages: $savedMessages, writeMessage: $writeMessage)
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 30)
//                }
            if confirmMessage {
                VStack(spacing: 30) {
                    Text("Confirmer l'envoi du message").font(.custom("silom", size: 30))
                    HStack(spacing: 30) {
                        Button(action: {
                            confirmMessage = false
                        }) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThickMaterial)
                                .frame(maxWidth: 400, maxHeight: 80)
                                .overlay {
                                    Text("Annuler").font(.custom("silom", size: 20)).foregroundColor(.primary)
                                }
                        }
                        Button(action: {
                            if let message = selectedMessage {
                                if message.type == .Alert {
                                    LightControl(mode: .alarm)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                        session.sendMessage(message)
                                    }
                                } else {
                                    session.sendMessage(message)
                                }
                            }
                            confirmMessage = false
                        }) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThickMaterial)
                                .frame(maxWidth: 400, maxHeight: 80)
                                .overlay {
                                    Text("Envoyer").font(.custom("silom", size: 20)).foregroundStyle(.blue)
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
            if confirmDeletion{
                VStack(spacing: 30) {
                    Text("Confirmer la suppression").font(.custom("silom", size: 30))
                    HStack(spacing: 30) {
                        Button(action: {
                            confirmDeletion = false
                        }) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThickMaterial)
                                .frame(maxWidth: 400, maxHeight: 80)
                                .overlay {
                                    Text("Annuler").font(.custom("silom", size: 20)).foregroundColor(.primary)
                                }
                        }
                        Button(action: {
                            if let message = selectedMessage{
                                savedMessages.remove(message: message)
                            }
                            selectedMessage = nil
                            confirmDeletion = false
                        }) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThickMaterial)
                                .frame(maxWidth: 400, maxHeight: 80)
                                .overlay {
                                    Text("Supprimer").font(.custom("silom", size: 20)).foregroundStyle(.red)
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
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        }
        .padding()
    }
}

struct WriteMessageView: View {
    @ObservedObject var session: MultipeerSession
    @Binding var savedMessages: SavedMessages
    @Binding var writeMessage: Bool
    @State var message: Message = Message(id: UUID(), text: "", type: .Information)
    @State var text: String = ""
    @State var type: MessageType = .Information
//    @State var messageSaved: Bool = false
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Button(action: {
                    writeMessage = false
                }) {
                    Image(systemName: "xmark").font(.largeTitle)
                }
                .frame(width: 200)
                Spacer()
                Text("Nouveau message").font(.custom("silom", size: 20))
                Spacer()
                if savedMessages.savedMessages.contains(where: { $0.id == message.id }){
                    Image(systemName: "checkmark").font(.largeTitle)
                } else {
                    Button(action: {
                        savedMessages.add(message: message)
//                        messageSaved = true
                    }) {
                        Text("Enregistrer le message").font(.custom("silom", size: 20))
                    }
                    .frame(width: 200)
                }
            }
            HStack {
                Button(action: {
                    message.type = .Alert
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(message.type == .Alert ? .ultraThickMaterial : .ultraThinMaterial)
                        .frame(maxWidth: 300, maxHeight: 50)
                        .overlay(Text("Alerte")).font(.custom("silom", size: 20))
                        .background(RoundedRectangle(cornerRadius: 20).stroke(message.type == .Alert ? .blue : .clear, lineWidth: 2))
                }
                .foregroundStyle(.primary)
                Button(action: {
                    message.type = .Information
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(message.type == .Information ? .ultraThickMaterial : .ultraThinMaterial)
                        .frame(maxWidth: 300, maxHeight: 50)
                        .overlay(Text("Information")).font(.custom("silom", size: 20))
                        .background(RoundedRectangle(cornerRadius: 20).stroke(message.type == .Information ? .blue : .clear, lineWidth: 2))
                }
                .foregroundStyle(.primary)
                Button(action: {
                    message.type = .Transmission
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(message.type == .Transmission ? .ultraThickMaterial : .ultraThinMaterial)
                        .frame(maxWidth: 300, maxHeight: 50)
                        .overlay(Text("Transmission")).font(.custom("silom", size: 20))
                        .background(RoundedRectangle(cornerRadius: 20).stroke(message.type == .Transmission ? .blue : .clear, lineWidth: 2))
                }
                .foregroundStyle(.primary)
            }
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black)
                .overlay {
                    TextEditor(text: $message.text).font(.custom("silom", size: 20))
                        .padding(10)
                }
                .frame(minHeight: 100, maxHeight: 300)
            Button(action: {
                if message.type == .Alert {
                    LightControl(mode: .alarm)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        session.sendMessage(message)
                    }
                } else {
                    session.sendMessage(message)
                }
            }) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThickMaterial)
                    .frame(width: 400, height: 50)
                    .overlay {
                        Text("Envoyer ce message").font(.custom("silom", size: 30))
                    }
            }
            .disabled(message.text.isEmpty)
        }
        .padding()
//        .background {
//            RoundedRectangle(cornerRadius: 20)
//                .fill(.ultraThinMaterial)
//        }
    }
}

struct PreparedMessageView: View {
    var message: Message
    var body: some View {
        
                HStack {
                    VStack(alignment: .leading) {
                        Text("Type de message: \(message.type)").font(.custom("silom", size: 30))
                        Text(message.text).font(.custom("silom", size: 20))
                    }
                    Spacer()
                }
                .padding(30)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                }
    }
}

class SavedMessages: ObservableObject {
    @Published public var savedMessages: [Message] {
        didSet {
            saveMessages()
        }
    }
    
    private let userDefaultsKey = "savedMessages"
    
    init() {
        self.savedMessages = []
        loadMessages()
    }
    
    func add(message: Message) {
        savedMessages.insert(message, at: 0)
    }
    
    func remove(message: Message) {
        DispatchQueue.main.async {
            self.savedMessages = self.savedMessages.filter { $0.id != message.id }
        }
    }
    
    private func saveMessages() {
        do {
            let data = try JSONEncoder().encode(savedMessages)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error encoding recent searches: \(error)")
        }
    }
    
    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let items = try JSONDecoder().decode([Message].self, from: data)
                self.savedMessages = items
                print("Saved messages loaded")
            } catch {
                print("Error decoding saved messages: \(error)")
            }
        }
    }
}

//struct MessageViewPreview: PreviewProvider {
////    @State var session = MultipeerSession()
//    static var previews: some View {
//        VStack {
//            SendMessageView()
//                .background(Color.blue)
//        }
//    }
//}

