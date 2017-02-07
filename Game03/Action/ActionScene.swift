//
//  ActionScene.swift
//  Action
//
//  Created by baiwei－mac on 17/2/7.
//  Copyright © 2017年 YuHua. All rights reserved.
//

import UIKit
import SpriteKit

class ActionScene: SKScene {

    let shipTexture = SKTexture(imageNamed: "Spaceship")
    var contentCreated = false
    var ship: SKSpriteNode!
    var scaleShip: SKSpriteNode!
    var moveShip: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        if !contentCreated {
            createSceneContent()
            createScaleShip()
            createMoveShip()
            contentCreated = true
        }
    }
    
    func createMoveShip() {
        moveShip = createShip()
        addChild(moveShip)
    }
    
    func createScaleShip() {
        scaleShip = createShip()
        let scale = SKAction.scale(to: 2, duration: 1)
        scaleShip.run(scale)
    }
    
    func createSceneContent() {
        backgroundColor = SKColor.orange
        scaleMode = .aspectFit
        ship = createShip()
        addChild(ship)
    }
    
    //添加一个序列动作的飞船
    func addListAction() {
        let listShip = createShip()
        listShip.position = CGPoint(x: 0, y: 0)
        addChild(listShip)
        
        let move = SKAction.move(to: CGPoint(x: view!.frame.width/2, y: view!.frame.height/2), duration: 1)
        let zoom = SKAction.scale(to: 4, duration: 1)
        let wait = SKAction.wait(forDuration: 1)
        let fade = SKAction.fadeOut(withDuration: 1)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move,zoom,wait,fade,remove])
        listShip.run(sequence)
    }
    
    //添加组动作的飞船
    func addGroupAction() {
        let groupShip = createShip()
        groupShip.position = CGPoint(x: 0, y: 0)
        addChild(groupShip)
        
        let move = SKAction.move(to: CGPoint(x: view!.frame.width, y: view!.frame.height), duration: 1)
        let rotate = SKAction.rotate(toAngle: CGFloat(M_PI*2), duration: 1)
        let group = SKAction.group([move,rotate])
        groupShip.run(group)
    }
    
    //添加重复动作
    func repeatAction() {
        let repeatShip = createShip()
        repeatShip.position = CGPoint(x: view!.frame.width/2, y: view!.frame.height/2+100)
        addChild(repeatShip)
        
        let fadIn = SKAction.fadeIn(withDuration: 0.5)
        let fadOut = SKAction.fadeOut(withDuration: 0.5)
        let list = SKAction.sequence([fadIn, fadOut])
        let repeatA = SKAction.repeatForever(list)
        repeatShip.run(repeatA)
    }
    
    //创建飞船
    func createShip() -> SKSpriteNode {
        let ship = SKSpriteNode(texture: shipTexture)
        ship.position = view!.center
        ship.zRotation = CGFloat(M_PI)
        ship.size = CGSize(width: 50, height: 50)
        return ship
    }
    
    //飞船添加一个往下飞行的动作
    func addAction(ship: SKSpriteNode) {
        let move = SKAction.moveTo(y: 0, duration: 1)
        ship.run(move)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let move = SKAction.move(to: touch!.location(in: self), duration: 1)
        moveShip.run(move, withKey: "Move")
        
        guard ship.position.y != 0 && !ship.hasActions() else {
            return
        }
        addAction(ship: ship)
        addChild(scaleShip)
        addListAction()
        addGroupAction()
        repeatAction()
    }
    
}
