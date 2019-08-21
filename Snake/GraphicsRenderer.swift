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
import simd

class GraphicsRenderer: UIView {
    
    private var metalDevice: MTLDevice!
    private var metalCommandQueue: MTLCommandQueue!
    
    private var metalCircleRenderPipelineState : MTLRenderPipelineState!
    
    private var circleVertexBuffer: MTLBuffer!
    private var squareVertexBuffer: MTLBuffer!
    
    private var circleRadius: CGFloat = 0
    
    private var pointsLabel: UILabel? = nil
    
    var circles: [MetalCircleView] = [] {
        didSet {
            circles.forEach { $0.render() }
            pointsLabel?.text = String(circles.count)
        }
    }
    var obstacles: [MetalObstacleView] = [] {
        didSet {
            obstacles.forEach { $0.render() }
        }
    }
    
    public required init() {
        super.init(frame: .zero)
        setupMetal()
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func render() {
        obstacles.forEach { $0.render() }
        circles.forEach { $0.render() }
    }
    
    // MARK: Initialization
    
    fileprivate func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
        pointsLabel = UILabel(frame: CGRect(x: 200, y: 200, width: 50, height: 50))
        pointsLabel?.textColor = .white
        addSubview(pointsLabel!)
    }
    
    fileprivate func setupMetal() {
        metalDevice              = MTLCreateSystemDefaultDevice()!
        metalCommandQueue        = metalDevice.makeCommandQueue()!
        metalCircleRenderPipelineState = createPipelineStateCircle()
        
        let circleVertices = createVertexPoints()
        circleVertexBuffer = metalDevice.makeBuffer(bytes: circleVertices,
                                                    length: circleVertices.count * MemoryLayout<simd_float2>.stride,
                                                    options: [])!
        
        let squareVertices = squareVertexPoints
        squareVertexBuffer = metalDevice.makeBuffer(bytes: squareVertices,
                                                    length: squareVertexPoints.count * MemoryLayout<simd_float2>.stride,
                                                    options: [])!
    }
}

// MARK: - Obstacle Rendering
extension GraphicsRenderer {
    func createObstacle(frame: CGRect, points: Int) {
        let obstacleView = MetalObstacleView(metalDevice: metalDevice,
                                             metalRenderPipelineState: metalCircleRenderPipelineState,
                                             metalCommandQueue: metalCommandQueue,
                                             vertexBuffer: squareVertexBuffer,
                                             points: points)
        addSubview(obstacleView)
        
        obstacleView.frame = frame
        obstacleView.render()
        
        obstacles.append(obstacleView)
    }
}

// MARK: - Circle Rendering
extension GraphicsRenderer {
    
    func createCircle(position: CGPoint, radius: CGFloat) {
        let circleView = MetalCircleView(metalDevice: metalDevice,
                                         metalRenderPipelineState: metalCircleRenderPipelineState,
                                         metalCommandQueue: metalCommandQueue,
                                         vertexBuffer: circleVertexBuffer)
        addSubview(circleView)
        
        let frame = CGRect(x: position.x, y: position.y, width: radius, height: radius)
        circleView.frame = frame
        
        circleView.render()
        circles.append(circleView)
    }
    
    func moveCirclesHorizontal(position: CGFloat) {
        circles.forEach { $0.moveX(to: position) }
    }
    
    func moveCirclesVertical(offset: CGFloat) {
        circles.forEach { $0.moveY(offset: offset) }
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

// MARK: - Geometrical functions
extension GraphicsRenderer {
    
    fileprivate var squareVertexPoints: [simd_float2] {
        
        return [ simd_float2(-1, 1), simd_float2(1, 1), simd_float2(1, -1),
                 simd_float2(-1, -1), simd_float2(-1, 1), simd_float2(1, -1)]
    }
    
    fileprivate func createVertexPoints() -> [simd_float2] {
        func rads(forDegree d: Float)->Float32{
            return (Float.pi*d)/180
        }
        
        let origin = simd_float2(0, 0)
        
        var circleVertices: [simd_float2] = []
        
        for i in 0..<720 {
            let position : simd_float2 = [cos(rads(forDegree: Float(i))),sin(rads(forDegree: Float(i)))]
            circleVertices.append(position)
            if (i+1)%2 == 0 {
                circleVertices.append(origin)
            }
        }
        
        return circleVertices
    }
}
