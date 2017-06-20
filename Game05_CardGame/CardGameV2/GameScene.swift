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


//精灵z轴的层次，确保拖动的时候的card是最大的等级
enum CardLevel: CGFloat {
    case board = 10
    case moving = 100
    case enlarged = 200
}


class GameScene: SKScene {

  override func didMove(to view: SKView) {
    let bg = SKSpriteNode(imageNamed: "bg_blank")
    bg.anchorPoint = CGPoint.zero
    bg.position = CGPoint.zero
    addChild(bg)
    
    let wolf = Card(cardType: .wolf)
    wolf.position = CGPoint(x: 100, y: 200)
    addChild(wolf)
    
    let bear = Card(cardType: .bear)
    bear.position = CGPoint(x: 300, y: 200)
    addChild(bear)
    }
    
    //在点击card的时候，让card的z轴层次为当前所有精灵中最高的层级
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if let card = atPoint(location) as? Card {
                if touch.tapCount > 1 {
                    //                    card.flip()
                    card.enlarge()
                    return
                }
                
                if card.enlarged {
                    return
                }
                
                card.zPosition = CardLevel.moving.rawValue
                
                //添加一个放大效果
                card.removeAction(forKey: "drop")
                card.run(.scale(to: 1.3, duration: 0.25), withKey: "pickup")
                //添加一个抖动效果
                let wiggleIn = SKAction.scaleX(to: 1, duration: 0.2)
                let wiggleOut = SKAction.scaleX(to: 1.2, duration: 0.2)
                let wiggle = SKAction.sequence([wiggleIn, wiggleOut])
                card.run(.repeatForever(wiggle), withKey: "wiggle")
                
                //旋转效果
//                let rotR = SKAction.rotate(byAngle: 0.15, duration: 0.2)
//                let rotL = SKAction.rotate(byAngle: -0.15, duration: 0.2)
//                let cycle = SKAction.sequence([rotR, rotL, rotL, rotR])
//                card.run(.repeatForever(cycle), withKey: "wiggle")
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if let card = atPoint(location) as? Card {
                if card.enlarged {
                    return
                }
                
                card.zPosition = CardLevel.board.rawValue
                
                card.removeAction(forKey: "pickup")
                card.run(.scale(to: 1, duration: 0.25), withKey: "drop")
                card.removeAction(forKey: "wiggle")
                //停止旋转
//                card.run(.rotate(byAngle: 0, duration: 0.2), withKey: "rotate")
                //这一步是解决界面显示是按照添加顺序显示的问题
                card.removeFromParent()
                addChild(card)
            }
        }
    }
    
    //拖拽
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            //判断拖动的点击点，是否是在图片上面，是的话，就让图片跟着移动
            let location = touch.location(in: self)
            //atPoint(location) 方法会一直返回一个值
            if let card = atPoint(location) as? Card {
                
                if card.enlarged {
                    return
                }
                
                /*
                 注意点：
                 1.在z轴上面，精灵的排序是以添加顺序排序的，所以说，如果把wolf和bear放到一起，bear会一直处于上面
                 2.由于atPoint(location)会返回处于顶部的精灵，所以，会导致如果拖动wolf到bear上时，会变成在拖动bear
                 
                 要解决上面的问题，需要修改精灵的zPosition的值在使用的时候
                 */
                card.position = location
            }
        }
    }

}
