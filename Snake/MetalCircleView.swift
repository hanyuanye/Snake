//
//  MetalCircleView.swift
//  Snake
//
//  Created by Hanyuan Ye on 2019-07-03.
//  Copyright © 2019 HY. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import simd

class MetalCircleView: UIView {
    
    //MARK: METAL VARS
    private var metalView : MTKView!
    private var metalDevice : MTLDevice!
    private var metalCommandQueue : MTLCommandQueue!
    private var metalRenderPipelineState : MTLRenderPipelineState!
    
    //MARK: VERTEX VARS
    private var circleVertices = [simd_float2]()
    private var vertexBuffer : MTLBuffer!
    
    //MARK: INIT
    public required init(metalDevice: MTLDevice, metalRenderPipelineState: MTLRenderPipelineState) {
        super.init(frame: .zero)
        
        self.metalDevice = metalDevice
        self.metalRenderPipelineState = metalRenderPipelineState
        
        createVertexPoints()
        setupView()
        setupMetal()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func render() {
        metalView.setNeedsDisplay()
    }
    
    //MARK: SETUP
    fileprivate func setupView() {
//        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }
    
    fileprivate func setupMetal(){
        //view
        metalView = MTKView()
        addSubview(metalView)
        
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        metalView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        metalView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        metalView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        metalView.delegate = self
        metalView.device = metalDevice
        metalView.layer.isOpaque = false
        metalView.isOpaque = false
        metalView.backgroundColor = .clear
        
        //updates
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
        
        //creating the command queue
        metalCommandQueue = metalDevice.makeCommandQueue()!
        
        //turn the vertex points into buffer data
        vertexBuffer = metalDevice.makeBuffer(bytes: circleVertices, length: circleVertices.count * MemoryLayout<simd_float2>.stride, options: [])!
    }
    
    fileprivate func createVertexPoints(){
        func rads(forDegree d: Float)->Float32{
            return (Float.pi*d)/180
        }
        
        let origin = simd_float2(0, 0)
        
        for i in 0..<720 {
            let position : simd_float2 = [cos(rads(forDegree: Float(i))),sin(rads(forDegree: Float(i)))]
            circleVertices.append(position)
            if (i+1)%2 == 0 {
                circleVertices.append(origin)
            }
        }
    }
}

extension MetalCircleView: MTKViewDelegate {
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
