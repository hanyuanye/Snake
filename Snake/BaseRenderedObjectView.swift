//
//  BaseRenderedObjectView.swift
//  Snake
//
//  Created by Hanyuan Ye on 2019-07-03.
//  Copyright © 2019 HY. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import simd

class BaseRenderedObjectView: UIView {
    
    //MARK: METAL VARS
    var metalView : MTKView!
    var metalDevice : MTLDevice!
    var metalCommandQueue : MTLCommandQueue!
    var metalRenderPipelineState : MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    
    //MARK: INIT
    public required init(metalDevice: MTLDevice,
                         metalRenderPipelineState: MTLRenderPipelineState,
                         metalCommandQueue: MTLCommandQueue,
                         vertexBuffer: MTLBuffer!) {
        super.init(frame: .zero)
        
        self.metalDevice = metalDevice
        self.metalRenderPipelineState = metalRenderPipelineState
        self.metalCommandQueue = metalCommandQueue
        self.vertexBuffer = vertexBuffer
        
        setupView()
        setupMetal()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func render() {
        metalView.setNeedsDisplay()
    }
    
    // MARK: SETUP
    fileprivate func setupView() {
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
        
        metalView.device = metalDevice
        metalView.layer.isOpaque = false
        metalView.isOpaque = false
        metalView.backgroundColor = .clear
        
        //updates
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
    }
    
    // MARK: Movement
    
    func moveX(to position: CGFloat) {
        let newFrame = CGRect(origin: CGPoint(x: position, y: frame.origin.y), size: frame.size)
        frame = newFrame
        
        self.render()
    }
    
    func moveX(offset: CGFloat) {
        let position = frame.origin.y + offset
        moveX(to: position)
    }
    
    func moveY(to position: CGFloat) {
        let newFrame = CGRect(origin: CGPoint(x: frame.origin.x, y: position), size: frame.size)
        frame = newFrame
        
        self.render()
    }
    
    func moveY(offset: CGFloat) {
        let position = frame.origin.y + offset
        moveY(to: position)
    }
}
