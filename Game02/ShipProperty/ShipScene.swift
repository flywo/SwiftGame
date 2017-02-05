//
//  ShipScene.swift
//  ShipProperty
//
//  Created by baiwei－mac on 17/2/5.
//  Copyright © 2017年 YuHua. All rights reserved.
//

import UIKit
import SpriteKit

class ShipScene: SKScene {
    
    var contentCreated = false
    let shipTexture = SKTexture(imageNamed: "Spaceship")
    
    override func didMove(to view: SKView) {
        if !contentCreated {
            createSceneContents()
            contentCreated = true
        }
    }
    
    func createSceneContents() {
        backgroundColor = SKColor.blue//背景
        scaleMode = .aspectFit//缩放模式
        addChild(shipNode())
    }
    
    func shipNode() -> SKSpriteNode {
        let ship = SKSpriteNode(imageNamed: "Spaceship")
        ship.position = view!.center
        
        //使用锚点，移动ship，锚点范围0--1，默认为(0.5, 0.5)
        ship.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        //旋转90度
        ship.zRotation = CGFloat(M_PI_2)

        //使用Scale属性对精灵进行缩放
        ship.xScale = 0.3
        ship.yScale = 0.3
        
        //使用color和colorBlendFactor属性对精灵进行着色，默认混合因子colorBlendFactor为0
        ship.color = SKColor.red
        ship.colorBlendFactor = 0.5

        //颜色动画
        let pulseRed = SKAction.sequence([SKAction.colorize(with: SKColor.red, colorBlendFactor: 0.5, duration: 0.2),
                                          SKAction.wait(forDuration: 0.1),
                                          SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)])
        ship.run(SKAction.repeatForever(pulseRed))

        //使用BlendMode属性控制精灵混合行为
        ship.blendMode = .add
        
        return ship
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        addTextureShip(touch!)
    }
    
    func addTextureShip(_ touch: UITouch) {
        //使用小部分纹理
        let texture = SKTexture(rect: CGRect(x: 0, y: 0.5, width: 1.0, height: 0.5), in: shipTexture)
        
        let ship = SKSpriteNode(texture: texture, size: CGSize(width: 40, height: 40))
        ship.position = touch.location(in: self)
        ship.name = "Ship"
        ship.zRotation = CGFloat(M_PI)
        
        enumerateChildNodes(withName: "Ship") { (node, _) in
            let current = node as! SKSpriteNode
            if current.physicsBody == nil {
                current.physicsBody = SKPhysicsBody(rectangleOf: current.size)
            }
        }
        
        addChild(ship)
    }
    
    override func didSimulatePhysics() {
        enumerateChildNodes(withName: "Ship") { (node, _) in
            if node.position.y < 0 {
                node.removeFromParent()
            }
        }
    }

}
