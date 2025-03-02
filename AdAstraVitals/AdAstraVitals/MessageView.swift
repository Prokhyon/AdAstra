//
//  MessageView.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 20.02.2025.
//
import SwiftUI
//struct Message {
//    var text: String
//    var type: MessageType
//}
//enum MessageType {
//    case Alert, Transmission, Information
//}

func MessageTypeText(_ type: MessageType) -> String {
    switch type {
    case .Alert:
        return "Alerte"
    case .Transmission:
        return "Transmission reçue"
    case .Information:
        return "Information"
    }
}

func MessageTypeImage(_ type: MessageType) -> Image {
    switch type {
    case .Alert:
        return Image(systemName: "exclamationmark.triangle")
    case .Transmission:
//        return Image(systemName: "arrow.clockwise.circle.fill")
        return  Image(systemName: "waveform")
    case .Information:
        return Image(systemName: "info.circle")
    }
}

struct MessageView: View {
    var message: Message
    var body: some View {
        VStack {
            HStack {
                MessageTypeImage(message.type).foregroundColor(message.type == .Alert ? .red : .blue).font(.system(size: 50))
                Text(MessageTypeText(message.type)).font(.custom("silom", size: 50))
                MessageTypeImage(message.type).foregroundColor(message.type == .Alert ? .red : .blue).font(.system(size: 50))
            }
            
            Text(message.text).font(.custom("silom", size: 30)).minimumScaleFactor(0.5)
        }
        .padding(100)
    }
}
