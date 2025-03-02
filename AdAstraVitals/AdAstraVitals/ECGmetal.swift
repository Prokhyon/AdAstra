//
//  ECGmetal.swift
//  AdAstraVitals
//
//  Created by Loris Thomas on 24.02.2025.
//

import SwiftUI
import MetalKit

struct ECGMetalView: NSViewRepresentable {
    var phase: CGFloat
    var style: Int
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> MTKView {
        let metalView = MTKView()
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.clearColor = MTLClearColorMake(0, 0, 0, 0) // Transparent background
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.delegate = context.coordinator
        return metalView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        context.coordinator.phase = phase
        context.coordinator.style = style
    }

    class Coordinator: NSObject, MTKViewDelegate {
        var parent: ECGMetalView
        var phase: CGFloat = 0
        var style: Int = 1
        var device: MTLDevice?
        var commandQueue: MTLCommandQueue?
        var pipelineState: MTLRenderPipelineState?

        init(_ parent: ECGMetalView) {
            self.parent = parent
            self.device = MTLCreateSystemDefaultDevice()
            self.commandQueue = self.device?.makeCommandQueue()

            let library = self.device?.makeDefaultLibrary()
            let vertexFunction = library?.makeFunction(name: "vertex_main")
            let fragmentFunction = library?.makeFunction(name: "fragment_main")

            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

            self.pipelineState = try? self.device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let passDescriptor = view.currentRenderPassDescriptor,
                  let pipelineState = pipelineState,
                  let commandBuffer = commandQueue?.makeCommandBuffer(),
                  let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
                return
            }

            commandEncoder.setRenderPipelineState(pipelineState)

            // Send ECG waveform data to Metal shader
            var phaseData = Float(phase)
            commandEncoder.setVertexBytes(&phaseData, length: MemoryLayout<Float>.stride, index: 0)

            var styleData = Int32(style)
            commandEncoder.setVertexBytes(&styleData, length: MemoryLayout<Int32>.stride, index: 1)

            commandEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: 100)

            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    }
}


struct ECGMView: View {
    @State private var phase: CGFloat = -1
    @State private var style: Int = 1

    var body: some View {
        VStack {
            ECGMetalView(phase: phase, style: style)
                .frame(height: 100)

            Button("Change Style") {
                style = Int.random(in: 1...4)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                phase += 0.07
            }
        }
    }
}

#Preview {
    ECGMView()
}
