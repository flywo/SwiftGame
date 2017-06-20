/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit


enum CardType: Int {
    case wolf,bear,dragon
}


class Card : SKSpriteNode {
    let cardType: CardType
    let frontTexture: SKTexture
    let backTexture: SKTexture
    
    var damage = 0
    let damageLabel: SKLabelNode
    
    var enlarged = false
    var savedPosition = CGPoint.zero
    
    //记录card朝向
    var faceUp = true
    
    let largeTextureFilename: String
    var largeTexture: SKTexture?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("不支持！")
    }
    
    init(cardType: CardType) {
        /*
         swift init方法内，编写的顺序：
         1.先初始化所有不是可选类型的属性
         2.调用super.init方法
         3.最后才能够调用实例方法
         */
        self.cardType = cardType
        backTexture = SKTexture(imageNamed: "card_back")
        
        switch cardType {
        case .wolf:
            frontTexture = SKTexture(imageNamed: "card_creature_wolf")
            largeTextureFilename = "card_creature_wolf_large"
        case .bear:
            frontTexture = SKTexture(imageNamed: "card_creature_bear")
            largeTextureFilename = "card_creature_bear_large"
        case .dragon:
            frontTexture = SKTexture(imageNamed: "card_creature_dragon")
            largeTextureFilename = "card_creature_dragon_large"
        }
        
        //damageLabel属性不是可选的，需要在super.init前初始化
        //添加伤害label
        damageLabel = SKLabelNode(fontNamed: "OpenSans-Bold")
        damageLabel.name = "damageLabel"
        damageLabel.fontSize = 12
        damageLabel.fontColor = SKColor(red: 0.47, green: 0.0, blue: 0.0, alpha: 1.0)
        damageLabel.text = "0"
        //damageLabel的position是相对于self的anchor point，这是damageLabel的中心点
        damageLabel.position = CGPoint(x: 25, y: 40)
        
        super.init(texture: frontTexture, color: .clear, size: frontTexture.size())
        
        //实例方法不能够在super.init方法前调用
        addChild(damageLabel)
    }
    
    //点击
    func flip() {
        
        //使图片的x轴长度发生变化
        let firstHalfFlip = SKAction.scaleX(to: 0, duration: 0.4)
        let secondHalfFlip = SKAction.scaleX(to: 1, duration: 0.4)
        
        //确保变化前是正常状态
        setScale(1)
        
        if faceUp {
            run(firstHalfFlip) {
                self.texture = self.backTexture
                self.damageLabel.isHidden = true
                
                self.run(secondHalfFlip)
            }
        }else {
            run(firstHalfFlip) {
                self.texture = self.frontTexture
                self.damageLabel.isHidden = false
                
                self.run(secondHalfFlip)
            }
        }
        faceUp = !faceUp
    }
    
    //放大
    func enlarge() {
        if enlarged {
            let slide = SKAction.move(to: savedPosition, duration: 0.3)
            let scaleDown = SKAction.scale(to: 1, duration: 0.3)
            run(.group([slide, scaleDown])) {
                self.enlarged = false
                self.zPosition = CardLevel.board.rawValue
            }
        }
        else {
            enlarged = true
            savedPosition = position
            
            if largeTexture != nil {
                texture = largeTexture
            }
            else {
                largeTexture = SKTexture(imageNamed: largeTextureFilename)
                texture = largeTexture
            }
            zPosition = CardLevel.enlarged.rawValue
            
            if let parent = parent {
                removeAllActions()
                zRotation = 0
                let newPosition = CGPoint(x: parent.frame.midX, y: parent.frame.midY)
                let slide = SKAction.move(to: newPosition, duration: 0.3)
                let scaleUp = SKAction.scale(to: 5, duration: 0.3)
                run(.group([slide, scaleUp]))
            }
        }
    }
  
}
