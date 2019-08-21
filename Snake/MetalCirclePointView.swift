//
//  MetalCirclePointView.swift
//  Snake
//
//  Created by Hanyuan Ye on 2019-07-03.
//  Copyright © 2019 HY. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import simd

final class MetalCirclePointView: BaseRenderedObjectView {
    
    var points: Int = 0
    
    convenience init(metalDevice: MTLDevice, metalRenderPipelineState: MTLRenderPipelineState, metalCommandQueue: MTLCommandQueue, vertexBuffer: MTLBuffer!, points: Int) {
        self.init(metalDevice: metalDevice,
                  metalRenderPipelineState: metalRenderPipelineState,
                  metalCommandQueue: metalCommandQueue,
                  vertexBuffer: vertexBuffer)
        self.points = points
        metalView.delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(metalDevice: MTLDevice, metalRenderPipelineState: MTLRenderPipelineState, metalCommandQueue: MTLCommandQueue, vertexBuffer: MTLBuffer!) {
        super.init(metalDevice: metalDevice,
                   metalRenderPipelineState: metalRenderPipelineState,
                   metalCommandQueue: metalCommandQueue,
                   vertexBuffer: vertexBuffer)
    }
    
    func animateDestroy() {
        self.moveX(to: -500)
        self.setNeedsDisplay()
    }
}

extension MetalCirclePointView: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(size)
    }
    
    func draw(in view: MTKView) {
        //Creating the commandBuffer for the queue
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else { return }
        //Creating the interface for the pipeline
        guard let renderDescriptor = view.currentRenderPassDescriptor else { return }
        //Setting a "background color"
        renderDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
        renderDescriptor.colorAttachments[0].loadAction = .clear
        
        //Creating the command encoder, or the "inside" of the pipeline
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor) else {return}
        
        // We tell it what render pipeline to use
        renderEncoder.setRenderPipelineState(metalRenderPipelineState)
        
        /*********** Encoding the commands **************/
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 1080)
        
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
