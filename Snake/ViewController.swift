//
//  ViewController.swift
//  Snake
//
//  Created by Hanyuan Ye on 2019-07-03.
//  Copyright © 2019 HY. All rights reserved.
//

import UIKit
import Metal

class ViewController: UIViewController {
    
    static let radius: CGFloat = 20
    static let heightOffset: CGFloat = 300
    
    var isMoving = false
    var currentHandPosition: CGFloat = 0
    
    var renderer: GraphicsRenderer = GraphicsRenderer()
    var physicsEngine: PhysicsEngine? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(renderer)
        
        //constraining to window
        renderer.topAnchor.constraint(equalTo: view.topAnchor).isActive           = true
        renderer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive   = true
        renderer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        renderer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive     = true
        
        physicsEngine = PhysicsEngine(renderer: renderer, width: view.frame.width)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: view).x
        currentHandPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let newHandPosition = touch.location(in: view).x
        let offset = (newHandPosition - currentHandPosition) * 1.5
        currentHandPosition = newHandPosition
//        print(offset)
//        print(currentHandPosition)
        physicsEngine?.handleInput(offset)
    }
}

