//
//  HelloScene.swift
//  Game
//
//  Created by baiwei－mac on 17/1/24.
//  Copyright © 2017年 YuHua. All rights reserved.
//

import UIKit
import SpriteKit

class HelloScene: SKScene {

    var contentCreated = false
    
    override func didMove(to view: SKView) {
        if !contentCreated {
            createSceneContents()
            contentCreated = true
        }
    }
    
    func createSceneContents() {
        backgroundColor = SKColor.blue//背景
        scaleMode = .aspectFit//缩放模式
        addChild(newHelloNode())
    }
    
    func newHelloNode() -> SKLabelNode {
        let helloNode = SKLabelNode(fontNamed: "Chalkduster")
        helloNode.text = "你好！"
        helloNode.name = "LabelNode"
        helloNode.fontSize = 42
        helloNode.position = CGPoint(x: frame.width/2, y: frame.height/2)
        return helloNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let helloNode = childNode(withName: "LabelNode")
        if let node = helloNode {
            node.name = ""//防止按压事件重复触发，HelloNode被重复动作
            let moveUp = SKAction.moveBy(x: 0, y: 100, duration: 0.5)//上移
            let zoom = SKAction.scale(to: 2.0, duration: 0.25)//放大
            let pause = SKAction.wait(forDuration: 0.5)//暂停
            let fade = SKAction.fadeIn(withDuration: 0.25)//消失
            let remove = SKAction.removeFromParent()//移除
            let colorChange = SKAction.colorize(with: .orange, colorBlendFactor: 1, duration: 0.5)//改变背景色
            let moveSequence = SKAction.sequence([moveUp, zoom, pause, fade, remove])
            //动作执行
            node.run(moveSequence) {
                let ship = ShipScene(size: self.size)
                let transition = SKTransition.doorsOpenVertical(withDuration: 2)//动画类型
                self.view?.presentScene(ship, transition: transition)//呈现ship场景后，hello场景会被丢弃
            }
            self.run(colorChange)
        }
    }
    
    deinit {
        print("\(String(describing: self))被销毁了)")
    }
}
