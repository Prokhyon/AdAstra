//
//  Holo1.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 14.02.2025.
//

import SwiftUI
import Combine

struct HologramView: View {
    let imageName: String
//    let startDate = Date()
    let playerName: String
    @Binding var elapsedTime: Double // Manually tracked time
    
    var body: some View {
        TimelineView(.animation) { context in
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.5)) // Dark holographic background
                       
                    
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.width) // Square shape
                    
                        .colorEffect(ShaderLibrary.infrablue())
//                        .colorEffect(ShaderLibrary.flicker(.float(startDate.timeIntervalSinceNow)))
                    
//                        .distortionEffect(ShaderLibrary.hologramDrift(.float(startDate.timeIntervalSinceNow)), maxSampleOffset: .zero)
                    
//                        .layerEffect(ShaderLibrary.chromaticAberration(), maxSampleOffset: .zero)
                    
//                        .layerEffect(ShaderLibrary.edgeGlow(), maxSampleOffset: .zero)
                    
                        .layerEffect(ShaderLibrary.colorPlanes(.float2(geometry.size.width, geometry.size.height), .float(elapsedTime.truncatingRemainder(dividingBy: 3.0))), maxSampleOffset: .zero)
                    
                        .colorEffect(ShaderLibrary.pixelMesh(.float2(geometry.size.width, geometry.size.height)))
                    
                        .colorEffect(ShaderLibrary.scanlines(.float(elapsedTime.truncatingRemainder(dividingBy: 3.0))))
                    
//                        .mask {
//                            Rectangle()
//                                .overlay(alignment: .trailing) {
//                                    LinearGradient(colors: [.white, .clear], startPoint: UnitPoint(x: 0, y: 1), endPoint: UnitPoint(x: 0, y: 0))
//                                        .blendMode(.destinationOut)
//                                }
//                                .padding(.trailing, 20)
//                        }
                    Rectangle()
                        .fill(LinearGradient(colors: [.black, .clear], startPoint: UnitPoint(x: 0, y: 1), endPoint: UnitPoint(x: 0, y: 0.7)))
                        .overlay {
                            VStack {
                                Spacer()
                                Text(generateBase32ID(from: playerName)).font(.custom("silom", size: 50))
//                                    .shadow(color: .blue, radius: 3)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                            }
                            .foregroundStyle(.white)//.opacity(0.5)
                            .padding(.horizontal, 10)
                        }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .aspectRatio(1, contentMode: .fit) // Ensure square shape
//        .padding(4)
        
    }
}

//
//
//struct HologramPreview: PreviewProvider {
//    
//    static var previews: some View {
//        @State var timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
//        VStack {
////            HologramEffectView()
//            HologramView(imageName: "tom", playerName: "Tom Holland", timer: timer)
////            Image("Person")
////                .frame(width: 300, height: 300)
//        }
//    }
//}
