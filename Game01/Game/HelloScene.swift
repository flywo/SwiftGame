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
        helloNode.fontSize = 42
        helloNode.position = CGPoint(x: frame.width/2, y: frame.height/2)
        return helloNode
    }
}
