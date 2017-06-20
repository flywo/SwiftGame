//
//  SpaceMan.swift
//  SuperSpaceMan
//
//  Created by baiwei－mac on 17/6/20.
//  Copyright © 2017年 YuHua. All rights reserved.
//

import Foundation
import SpriteKit

/*通过plist文件保存游戏需要的数据，便于团队开发。使用方式：
 let orbPlistPath = Bundle.main.path(forResource: "orbs", ofType: "plist")
 let orbDataDictionary = NSDictionary(contentsOfFile: orbPlistPath!)
 if let positionDictionary = orbDataDictionary {
    let positions = positionDictionary.object(forKey: "positions") as! NSArray
    for position in positions {
        let orbNode = Orb(textureAtlas: SKTextureAtlas(named: "sprites.atlas"))
        let x = (position as AnyObject).object(forKey: "x") as! CGFloat
        let y = (position as AnyObject).object(forKey: "y") as! CGFloat
        orbNode.position = CGPoint(x: x, y: y)
        foregroundNode.addChild(orbNode)
    }
 }
 */

class SpaceMan: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)不能被使用！")
    }
    
    //通过纹理集合添加
    init(textureAtlas: SKTextureAtlas) {
        let texture = textureAtlas.textureNamed("Player")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        physicsBody?.isDynamic = false
        physicsBody?.linearDamping = 1.0
        physicsBody?.allowsRotation = false
        
        physicsBody?.categoryBitMask = CollisionCategoryPlayer
        physicsBody?.contactTestBitMask = CollisionCategoryPowerUpOrbs | CollisionCategoryBlackHoles
        physicsBody?.collisionBitMask = 0
    }
}
