//
//  Orb.swift
//  SuperSpaceMan
//
//  Created by baiwei－mac on 17/6/20.
//  Copyright © 2017年 YuHua. All rights reserved.
//

import Foundation
import SpriteKit

class Orb: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(code)无法调用！")
    }
    
    init() {
        let texture = SKTexture(imageNamed: "PowerUp")
        super.init(texture: texture,
                   color: .clear,
                   size: texture.size())
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionCategoryPowerUpOrbs
        physicsBody?.collisionBitMask = 0
        name = "POWER_UP_ORB"
    }
}
