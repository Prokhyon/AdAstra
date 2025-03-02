//
//  MultipeerManager.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 16.02.2025.
//
import SwiftUI
import MultipeerConnectivity

class MultipeerSession: NSObject, ObservableObject {
    private let serviceType = "adastravitals"
#if os(macOS)
    private let myPeerID = MCPeerID(displayName: ProcessInfo.processInfo.hostName)
#else
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
#endif
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    @Published var connectedPeers: [MCPeerID] = []
    @Published var players: [Player] = [
        Player(name: "Björn", surname: "Rasmussen", playerName: "PlayerA", origin: .Human, state: .Normal, heartMode: .calm, imageName: "Human1"),
        Player(name: "Cyran", surname: "", playerName: "PlayerB", origin: .Augmented, state: .Normal, heartMode: .calm, imageName: "Human5"),
        Player(name: "Eileen", surname: "Castor", playerName: "PlayerC", origin: .Human, state: .Normal, heartMode: .calm, imageName: "Human4"),
        Player(name: "Eleri", surname: "", playerName: "PlayerD", origin: .Human, state: .Normal, heartMode: .calm, imageName: "Human2"),
        Player(name: "Jay", surname: "Ghorman", playerName: "PlayerE", origin: .Human, state: .Normal, heartMode: .calm, imageName: "Human3"),
        Player(name: "Kozhedub", surname: "Ivan", playerName: "PlayerF", origin: .Human, state: .Normal, heartMode: .calm, imageName: "Human1"),
        Player(name: "M.I.L.A.N.A", surname: "", playerName: "PlayerG", origin: .Android, state: .Normal, heartMode: .calm, imageName: "Android1"),
        Player(name: "Primo", surname: "Adelante", playerName: "PlayerH", origin: .Augmented, state: .Normal, heartMode: .calm, imageName: "Human2"),
        Player(name: "Rémilion", surname: "Falorin", playerName: "PlayerI", origin: .Saved, state: .Normal, heartMode: .calm, imageName: "Saved1"),
        Player(name: "Tanak", surname: "Bourbaki", playerName: "PlayerJ", origin: .Augmented, state: .Normal, heartMode: .calm, imageName: "Human3"),
        Player(name: "Tchoupi", surname: "", playerName: "PlayerK", origin: .Human, state: .Normal, heartMode: .calm, imageName: "Human1"),
        Player(name: "Tyra", surname: "Solveig", playerName: "PlayerL", origin: .Augmented, state: .Normal, heartMode: .calm, imageName: "Human5"),
        Player(name: "Vex-A430", surname: "", playerName: "PlayerM", origin: .Android, state: .Normal, heartMode: .calm, imageName: "Android2")
    ]

    //Jay Gorst/Ghorman
    //James Eagan
    //James Webb
    //Eagon Marr
    //  Mach
    //  Hull
    //Kier
    @Published var receivedMessage: Message? = nil
//    @Published var displayMessage: Bool = false
    override init() {
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        self.session.delegate = self
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        self.advertiser?.delegate = self
        self.advertiser?.startAdvertisingPeer()
        
        self.browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        self.browser?.delegate = self
        self.browser?.startBrowsingForPeers()
    }
    
    func send(players: [Player]) {
        sendData(players)
    }
    
    func sendMessage(_ message: Message) {
            sendData(message)
        }
//    func removeMessage() {
//        sendData("removeMessage")
//    }
    func sendCommand(_ command: String) {
        sendData(command)
    }
    
    func sendTimeUpdate(hour: Int, minute: Int) {
        let command = "setTime:\(String(format: "%02d", hour)):\(String(format: "%02d", minute))"
        sendData(command)
    }
    
    private func sendData<T: Codable>(_ dataToSend: T) {
            if !session.connectedPeers.isEmpty {
                do {
                    let data = try JSONEncoder().encode(dataToSend)
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                } catch {
                    print("Error sending data: \(error.localizedDescription)")
                }
            }
        }
}

extension Notification.Name {
    static let startClock = Notification.Name("startClock")
    static let pauseClock = Notification.Name("pauseClock")
    static let resetClock = Notification.Name("resetClock")
    static let setTime = Notification.Name("setTime")
    static let stopAlarm = Notification.Name("stopAlarm")
    static let playAlarm = Notification.Name("playAlarm")
}



extension MultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            if let receivedPlayers = try? JSONDecoder().decode([Player].self, from: data) {
                            DispatchQueue.main.async {
                                self.players = receivedPlayers
                            }
            } else if let receivedMessage = try? JSONDecoder().decode(Message.self, from: data) {
                DispatchQueue.main.async {
                    self.receivedMessage = receivedMessage
                }
            } else if let command = try? JSONDecoder().decode(String.self, from: data) {
                DispatchQueue.main.async {
                    if command.starts(with: "setTime:") {
                        let components = command.replacingOccurrences(of: "setTime:", with: "").split(separator: ":")
                        if components.count == 2,
                           let hour = Int(components[0]),
                           let minute = Int(components[1]) {
                            let userInfo: [String: Any] = ["hour": hour, "minute": minute]
                            NotificationCenter.default.post(name: .setTime, object: nil, userInfo: userInfo)
                        }
                    } else {
                        switch command {
                        case "startClock":
                            NotificationCenter.default.post(name: .startClock, object: nil)
                        case "pauseClock":
                            NotificationCenter.default.post(name: .pauseClock, object: nil)
                        case "resetClock":
                            NotificationCenter.default.post(name: .resetClock, object: nil)
                        case "removeMessage":
                            self.receivedMessage = nil
                        case "playAlarm":
                            NotificationCenter.default.post(name: .playAlarm, object: nil)
                        case "stopAlarm":
                            NotificationCenter.default.post(name: .stopAlarm, object: nil)
                        default:
                            print("Unknown command received: \(command)")
                        }
                        //                    if command == "removeMessage" {
                        //                        self.receivedMessage = nil
                        //                    }
                    }
                }
            } else {
                print("Received unknown data format")
            }
        } catch {
            print("Error decoding player data: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
}

extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}


func sortPlayers(_ players: [Player]) {
    var playersSort = players
    playersSort.sort { $0.name < $1.name}
    print(playersSort)
}
