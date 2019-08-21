//
//  PhysicsEngine.swift
//  Snake
//
//  Created by Hanyuan Ye on 2019-07-03.
//  Copyright © 2019 HY. All rights reserved.
//

import UIKit

class PhysicsEngine {
    
    static let acceleration: CGFloat = 4
    private var width: CGFloat
    private var isColliding: Bool = false
    
    let renderer: GraphicsRenderer
    var currentPosition: CGFloat = 200
    
    var circles: [MetalCircleView] {
        return renderer.circles
    }
    
    var obstacles: [MetalObstacleView] {
        return renderer.obstacles
    }
    
    required init(renderer: GraphicsRenderer, width: CGFloat) {
        self.renderer = renderer
        self.width = width
        for _ in 0..<10 {
            appendCircleToSnake()
        }
        
        generateObstacles()
        
        let displaylink = CADisplayLink(target: self,
                                        selector: #selector(loop))
        
        displaylink.add(to: .current,
                        forMode: .default)
    }
    
    @objc func loop() {
        cleanupLoop()
        collisionLoop()
        if !isColliding {
            obstacles.forEach { object in
                object.moveY(offset: PhysicsEngine.acceleration)
            }
        }
        else {
            renderer.moveCirclesVertical(offset: -PhysicsEngine.acceleration)
            isColliding = false
        }
    }
    
    func handleInput(_ offset: CGFloat) {
        let newPosition = min(max(currentPosition + offset, 0), width - ViewController.radius)
        
        //verify new position does not collide with any current objects.
        
        let collisions = circles.map { circle -> Bool in
            let frame = circle.frame
            let newFrame = CGRect(origin: CGPoint(x: newPosition, y: frame.origin.y), size: frame.size)
            return obstacles.map{ !$0.frame.isCollidingWith(newFrame) }.allSatisfy { $0 }
        }
        
        let noCollisions = collisions.allSatisfy { $0 }
        if noCollisions {
            currentPosition = newPosition
            renderer.moveCirclesHorizontal(position: currentPosition)
        }
    }
    
    private func cleanupLoop() {
        var generateNextBlocks = false
        
        obstacles.forEach { object in
            if object.frame.minY > renderer.frame.maxY &&
               object.frame.minX > renderer.frame.minX &&
               object.frame.maxX < renderer.frame.maxX {
                object.animateDestroy()
                generateNextBlocks = true
            }
        }
        
        if generateNextBlocks { generateObstacles() }
    }
    
    private func collisionLoop() {
        guard circles.count > 0 else { return }
        
        let circleHitbox = circles.first!.frame
        
        obstacles.forEach { object in
            if object.points == 0, let index = renderer.obstacles.firstIndex(of: object) {
                renderer.obstacles.remove(at: index).animateDestroy()
            }
            else {
                let objectHitbox = object.frame
                if circleHitbox.isCollidingWith(objectHitbox) {
                    popCircleFromSnake(object: object)
                    isColliding = true
                }
            }
        }
    }
    
    private func popCircleFromSnake(object: MetalObstacleView) {
        object.decrementPoints()
        renderer.circles.remove(at: 0).animateDestroy()
    }
    
    private func appendCircleToSnake() {
        let lastCircle = circles.last?.frame.origin ?? CGPoint(x: currentPosition, y: ViewController.heightOffset)
        var nextCircle = lastCircle
        nextCircle.y += ViewController.radius
        
        renderer.createCircle(position: nextCircle, radius: ViewController.radius)
    }
    
    private func createObstacle(at index: Int, points: Int) {
        guard index >= 0 && index <= 4 else { return }
        let obstacleWidth = width / 5
        let xPos = obstacleWidth * CGFloat(index)
        let frame = CGRect(x: xPos, y: 0, width: obstacleWidth - 5, height: obstacleWidth - 5)
        renderer.createObstacle(frame: frame, points: points)
    }
    
    private func generateObstacles() {
        for i in 0..<5 {
            createObstacle(at: i, points: i + 1)
        }
    }
}
