//
//  BlackHole.swift
//  SuperSpaceMan
//
//  Created by baiwei－mac on 17/6/20.
//  Copyright © 2017年 YuHua. All rights reserved.
//

import Foundation
import SpriteKit

class BlackHole: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("无法被创建")
    }
    
    init() {
        let frame0 = SKTexture(imageNamed: "BlackHole0")
        let frame1 = SKTexture(imageNamed: "BlackHole1")
        let frame2 = SKTexture(imageNamed: "BlackHole2")
        let frame3 = SKTexture(imageNamed: "BlackHole3")
        let frame4 = SKTexture(imageNamed: "BlackHole4")
        let blackHoleTextures = [frame0, frame1, frame2, frame3, frame4]
        let animateAction =
            SKAction.animate(with: blackHoleTextures, timePerFrame: 0.2)
        let rotateAction = SKAction.repeatForever(animateAction)
        super.init(texture: frame0,
                   color: UIColor.clear,
                   size: frame0.size())
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionCategoryBlackHoles
        physicsBody?.collisionBitMask = 0
        name = "BLACK_HOLE"
        run(rotateAction)
    }
}
