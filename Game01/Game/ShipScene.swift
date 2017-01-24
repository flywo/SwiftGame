//
//  ShipScene.swift
//  Game
//
//  Created by baiwei－mac on 17/1/24.
//  Copyright © 2017年 YuHua. All rights reserved.
//

import UIKit
import SpriteKit

class ShipScene: SKScene {
    
    var contentCreated = false
    
    override func didMove(to view: SKView) {
        if !contentCreated {
            createScreated()
            contentCreated = true
        }
    }
    
    func createScreated() {
        backgroundColor = .black
        scaleMode = .aspectFit
        
        let ship = newShip()
        ship.position = CGPoint(x: frame.width/2, y: frame.height/2)
        addChild(ship)
    }
    
    func newShip() -> SKSpriteNode {
        //添加飞船
        let node = SKSpriteNode(color: .green, size: CGSize(width: 100, height: 50))
        let hover = SKAction.sequence([SKAction.wait(forDuration: 1),
                                       SKAction.moveBy(x: 100, y: 50, duration: 1),
                                       SKAction.wait(forDuration: 1),
                                       SKAction.moveBy(x: -100, y: 150, duration: 1)])
        node.run(hover)
        
        //飞船添加亮光，亮光添加到飞船上后，飞船移动后，亮光也会一起移动，旋转等也是。
        let lingt1 = newLight()
        lingt1.position = CGPoint(x: 0, y: 30)
        node.addChild(lingt1)
        
        let lingt2 = newLight()
        lingt2.position = CGPoint(x: 0, y: -30)
        node.addChild(lingt2)
        
        return node
    }
    
    func newLight() -> SKSpriteNode {
        let lingt = SKSpriteNode(color: .white, size: CGSize(width: 50, height: 2))
        let blink = SKAction.sequence([SKAction.fadeOut(withDuration: 0.25),
                                       SKAction.fadeIn(withDuration: 0.25)])
        let blinkForever = SKAction.repeatForever(blink)//让action一直重复下去
        lingt.run(blinkForever)
        return lingt
    }

}
