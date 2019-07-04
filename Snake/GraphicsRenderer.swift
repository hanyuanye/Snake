//
//  GraphicsRenderer.swift
//  Snake
//
//  Created by Hanyuan Ye on 2019-07-03.
//  Copyright © 2019 HY. All rights reserved.
//

import UIKit
import MetalKit
import Metal

class GraphicsRenderer: UIView {
    
    private var metalDevice: MTLDevice!
    private var metalRenderPipelineState : MTLRenderPipelineState!
    var circles: [MetalCircleView] = []
    
    public required init() {
        super.init(frame: .zero)
        setupMetal()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func createCircle(position: CGPoint, radius: CGFloat) {
        let circleView = MetalCircleView(metalDevice: metalDevice, metalRenderPipelineState: metalRenderPipelineState)
        addSubview(circleView)
        
        let frame = CGRect(x: position.x, y: position.y, width: radius, height: radius)
        circleView.frame = frame
        
        circleView.render()
        circles.append(circleView)
    }
    
    // MARK: Initialization
    
    fileprivate func setupMetal() {
        metalDevice              = MTLCreateSystemDefaultDevice()!
        metalRenderPipelineState = createPipelineStateCircle()
    }
    
    fileprivate func createPipelineStateCircle() -> MTLRenderPipelineState? {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        //finds the metal file from the main bundle
        let library = metalDevice.makeDefaultLibrary()!
        
        //give the names of the function to the pipelineDescriptor
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        //set the pixel format to match the MetalView's pixel format
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        //make the pipelinestate using the gpu interface and the pipelineDescriptor
        return try? metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}


