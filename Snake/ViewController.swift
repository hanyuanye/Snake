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
    
    let radius: CGFloat = 40

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let renderer = GraphicsRenderer()
        view.addSubview(renderer)
        
        //constraining to window
        renderer.topAnchor.constraint(equalTo: view.topAnchor).isActive           = true
        renderer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive   = true
        renderer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        renderer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive     = true
        
        for i in 0..<10 {
            renderer.createCircle(position: CGPoint(x: 100, y: i * 35 + 100), radius: radius)
        }
        
    }
}

