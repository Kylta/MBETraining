//
//  MBEMetalView.swift
//  CleanScreen
//
//  Created by Christophe Bugnon on 3/28/20.
//  Copyright © 2020 Christophe Bugnon. All rights reserved.
//

import MetalKit

class MBEMetalView: MTKView, MTKViewDelegate {
    var commendQueue: MTLCommandQueue!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.device = MTLCreateSystemDefaultDevice()
        self.colorPixelFormat = .bgra8Unorm
        self.commendQueue = self.device?.makeCommandQueue()
        self.delegate = self
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        self.draw(in: self)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // If screen rotate
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let renderPassDescriptor = self.currentRenderPassDescriptor else { return }
        
        let texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1)
        
        let commandBuffer = self.commendQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }
}
