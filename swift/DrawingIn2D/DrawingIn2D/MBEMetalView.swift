//
//  MBEMetalView.swift
//  DrawingIn2D
//
//  Created by Christophe Bugnon on 3/28/20.
//  Copyright © 2020 Christophe Bugnon. All rights reserved.
//

import MetalKit

typealias float2 = SIMD2<Float>
typealias float3 = SIMD3<Float>
typealias float4 = SIMD4<Float>

protocol Sizeable {
    static func stride(_ count: Int) -> Int
    static func size(_ count: Int) -> Int
}

extension Sizeable {
    static var size: Int {
        return MemoryLayout<Self>.size
    }
    
    static var stride: Int {
        return MemoryLayout<Self>.stride
    }
    
    static func stride(_ count: Int) -> Int {
        return stride * count
    }
    
    static func size(_ count: Int) -> Int {
        return size * count
    }
}

struct MBEVertex: Sizeable {
    let position: float4
    let color: float4
}

class MBEMetalView: MTKView, MTKViewDelegate {
    let vertices: [MBEVertex] = [
        MBEVertex(position: float4(0.0, 0.5, 0, 1), color: float4(1, 0, 0, 1)),
        MBEVertex(position: float4(-0.5, -0.5, 0, 1), color: float4(0, 1, 0, 1)),
        MBEVertex(position: float4(0.5, -0.5, 0, 1), color: float4(0, 0, 1, 1))
    ]
    
    var vertexBuffer: MTLBuffer!
    var pipeline: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!

    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.makeDevice()
        self.makeBuffers()
        self.makePipeline()
        self.delegate = self
        
        self.preferredFramesPerSecond = 60
        self.enableSetNeedsDisplay = false
        self.isPaused = false
    }
    
    private func makeDevice() {
        self.device = MTLCreateSystemDefaultDevice()
        self.colorPixelFormat = .bgra8Unorm
    }
    
    private func makeBuffers() {
        self.vertexBuffer = self.device?.makeBuffer(bytes: self.vertices,
                                                    length: MBEVertex.stride(self.vertices.count),
                                                    options: [])
    }
    
    private func makePipeline() {
        let library = self.device?.makeDefaultLibrary()
        let vertexFunc = library?.makeFunction(name: "vertex_main")
        let fragmentFunc = library?.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        pipelineDescriptor.colorAttachments[0].pixelFormat = self.colorPixelFormat
        self.pipeline = try! self.device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
        self.commandQueue = self.device?.makeCommandQueue()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let passDescriptor = view.currentRenderPassDescriptor else { return }
        
        passDescriptor.colorAttachments[0].texture = drawable.texture
        passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        passDescriptor.colorAttachments[0].storeAction = .store
        passDescriptor.colorAttachments[0].loadAction = .clear
        
        let commandBuffer = self.commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: passDescriptor)
        commandEncoder?.setRenderPipelineState(self.pipeline)
        commandEncoder?.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: self.vertices.count)
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }

}
