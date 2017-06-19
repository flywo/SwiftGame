//
//  GameScene.swift
//  SuperSpaceMan
//
//  Created by baiwei－mac on 17/6/15.
//  Copyright © 2017年 YuHua. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    /*
     SKNode是基础的节点。
     
     下方的节点都继承于SKNode：
     SKSpriteNode
     SKVideoNode
     SKLabelNode
     SKShapeNode
     SKEmitterNode
     SKCropNode
     SKEffectNode
     */
    let backgroundNode = SKSpriteNode(imageNamed: "Background")
    let backgroundStarsNode = SKSpriteNode(imageNamed: "Stars")
    let backgroundPlanetNode = SKSpriteNode(imageNamed: "PlanetStart")
    let playerNode = SKSpriteNode(imageNamed: "Player")
    //该节点是一个图层，容纳了所有的会影响游戏的精灵
    let foregroundNode = SKSpriteNode()
    //水平监视  CMMotionManager提供iOS运动服务对象，包括加速计，磁力计，转速和其它运动传感器
    let coreMotionManager = CMMotionManager()
    
    let CollisionCategoryPlayer: UInt32 = 0x1 << 1
    let CollisionCategoryPowerUpOrbs: UInt32 = 0x1 << 2
    let CollisionCategoryBlackHoles: UInt32 = 0x1 << 3
    var impulseCount = 4
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //打开相互的作用力
        isUserInteractionEnabled = true
        
        backgroundColor = SKColor(red: 0, green: 0, blue: 0, alpha: 1)
        //宽度
        backgroundNode.size.width = frame.size.width
        //锚点，默认为 0.5 0.5
        backgroundNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        //位置
        backgroundNode.position = CGPoint(x: size.width/2, y: 0)
        addChild(backgroundNode)
        
        backgroundStarsNode.size.width = frame.size.width
        backgroundStarsNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        backgroundStarsNode.position = CGPoint(x: 160, y: 0)
        addChild(backgroundStarsNode)
        
        backgroundPlanetNode.size.width = frame.size.width
        backgroundPlanetNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        backgroundPlanetNode.position = CGPoint(x: size.width/2, y: 0)
        addChild(backgroundPlanetNode)
        
        //添加图层
        addChild(foregroundNode)
        
        playerNode.position = CGPoint(x: size.width/2, y: 180)
        //加入物理形状，可以添加很多标准的形状 circle圆 rectangles矩形 polygon多边形
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width/2)
        playerNode.physicsBody?.isDynamic = false
        //阻尼，模拟空气摩擦
        playerNode.physicsBody?.linearDamping = 1.0
//        addChild(playerNode)
        /*创建节点树关系，会用到的三个方法：
         1.addChild() 添加子节点
         2.insertChild(_: at:) 插入子节点
         3.removeFromParent() 移除子节点
         */
        
        //如果两个node相互碰撞，动态的会被弹开，并且开始旋转，如果不需要旋转，则可以设置
        playerNode.physicsBody?.allowsRotation = false
        
        /*
         碰撞性能三维掩码属性：
         collisionBitMask:碰撞类别
         categoryBitMask:主题碰撞类别
         contactTestBitMask:确定物理机构与那些类别接触
         */
        playerNode.physicsBody?.categoryBitMask = CollisionCategoryPlayer//设置类别掩码
        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryPowerUpOrbs | CollisionCategoryBlackHoles//设置当碰撞发生时，需要通知
        playerNode.physicsBody?.collisionBitMask = 0//spritekit不处理冲突，代码自行处理
        
        //设置重力向量
        physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        //物理世界的代理
        physicsWorld.contactDelegate = self
        
        /*根据节点名字获得节点的方法：
         1.childNode(withName: "player") 获得单个节点，如果有多个，返回第一个添加的
         2.enumerteChildNodes(withName: using:) 遍历节点
         enumerateChileNodes(withName: "orb", using: {
            node, stop in
            //如果需要在中途停止，如下即可
            stop.memory = true
         })
         */
        
        //将精灵添加到图层
        foregroundNode.addChild(playerNode)
        addOrbsToForeground()
        addBlackHolesToForeground()
    }
    
    
    /*SKAction:一个动作，定义了想要改变的一个对象
     1.纹理动画改变节点
     2.改变位置或者隐藏
     3.改变节点大小
     4.播放声音
     5.着色节点
     
     使用SKAction，创建创建要执行的操作，然后告诉要执行该操作的节点来运行操作。
     var moveRightAction = SKAction.moveToX(size.width, duration: 2.0)
     sampleNode.runAction(moveRightAction)
     
     SKAction还可以将动作链接到一起。
     var moveRightAction = SKAction.moveToX(size.width, duration: 2.0)
     var moveLeftAction = SKAction.moveToX(0.0, duration: 2.0)
     var actionSequence = SKAction.sequence([moveRightAction, moveLeftAction])
     sampleNode.runAction(actionSequence)
     
     SKAction还可以重复一个动作。
     let moveLeftAction = SKAction.moveTo(x: 0.0, duration: 2.0)
     let moveRightAction = SKAction.moveTo(x: size.width, duration: 2.0)
     let actionSequence = SKAction.sequence([moveLeftAction, moveRightAction])
     let moveAction = SKAction.repeatForever(actionSequence)
     sampleNode.runAction(moveActionSequence)
     
     着色动作：
     SKAction.colorize(with: UIColor.red(), colorBlendFactor: 0.5, duration: 1)

     SKAction所有方法都是类方法，目前SKAction没有扩展类。
     */
    
    func addBlackHolesToForeground() {
        
        let textureAtlas = SKTextureAtlas(named: "sprites.atlas")
        //检索出图片
        let f0 = textureAtlas.textureNamed("BlackHole0")
        let f1 = textureAtlas.textureNamed("BlackHole1")
        let f2 = textureAtlas.textureNamed("BlackHole2")
        let f3 = textureAtlas.textureNamed("BlackHole3")
        let f4 = textureAtlas.textureNamed("BlackHole4")
        let blackHoleTextures = [f0, f1, f2, f3, f4]
        //动画,0.2秒执行一次更新
        let animateAction = SKAction.animate(with: blackHoleTextures, timePerFrame: 0.2)
        let rotateAction = SKAction.repeatForever(animateAction)
        
        let moveLeft = SKAction.moveTo(x: 0, duration: 2)
        let moveRight = SKAction.moveTo(x: size.width, duration: 2)
        let sequence = SKAction.sequence([moveLeft, moveRight])
        let moveAction = SKAction.repeatForever(sequence)
        
        for i in 1...10 {
            let blackHoleNode = SKSpriteNode(imageNamed: "BlackHole0")
            blackHoleNode.position = CGPoint(x: size.width-80, y: 600 * CGFloat(i))
            blackHoleNode.physicsBody = SKPhysicsBody(circleOfRadius: blackHoleNode.size.width/2)
            blackHoleNode.physicsBody?.isDynamic = false
            blackHoleNode.name = "BLACK_HOLE"
            
            blackHoleNode.physicsBody?.categoryBitMask = CollisionCategoryBlackHoles
            blackHoleNode.physicsBody?.collisionBitMask = 0
            
            blackHoleNode.run(moveAction)
            blackHoleNode.run(rotateAction)
            
            foregroundNode.addChild(blackHoleNode)
        }
    }
    
    /*
     SKTexture是一个保存由SKSpriteNodes，SKShapeNodes或SKEmitterNode创建的粒子使用的图像的对象
     SKTextureAtlas是从存储的纹理图集创建的SKTexture对象的集合
     
     加载图像到TextureAtlas中：
     let textureAtlas = SKTextureAtlas(named: "sprites.atlas")
     */
    
    func addOrbsToForeground() {
        
        var orbNodePosition = CGPoint(x: playerNode.position.x, y: playerNode.position.y+100)
        var orbXShift : CGFloat = -1.0
        
        for _ in 1...50 {
            let orbNode = SKSpriteNode(imageNamed: "PowerUp")
            if orbNodePosition.x - orbNode.size.width * 2 <= 0 {
                orbXShift = 1.0
            }
            
            if orbNodePosition.x + orbNode.size.width >= size.width {
                orbXShift = -1.0
            }
            
            orbNodePosition.x += 40.0 * orbXShift
            orbNodePosition.y += 120
            orbNode.position = orbNodePosition
            orbNode.physicsBody = SKPhysicsBody(circleOfRadius: orbNode.size.width/2)
            orbNode.physicsBody?.isDynamic = false
            
            orbNode.physicsBody?.categoryBitMask = CollisionCategoryPowerUpOrbs
            orbNode.physicsBody?.collisionBitMask = 0
            orbNode.name = "POWER_UP_ORB"
            
            foregroundNode.addChild(orbNode)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //添加动力，CGVector向量
//        playerNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
        
        if !playerNode.physicsBody!.isDynamic {
            playerNode.physicsBody?.isDynamic = true
            
            //使用当前加速度更新应用程序间隔，设置为0.3S
            coreMotionManager.accelerometerUpdateInterval = 0.3
            //启动加速计更新
            coreMotionManager.startAccelerometerUpdates()
        }
        
        if impulseCount > 0 {
            playerNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            impulseCount -= 1
        }
    }
    
    /*每一帧的动作：
     1.update
     2.SKScene evaluates actions
     3.didEvaluateActions
     4.SKScene simulates physics
     5.didSimulatePhysics
     6.SKView renders the scene
     */
    //更新背景
    override func update(_ currentTime: TimeInterval) {
        if playerNode.position.y >= 180 {
            backgroundNode.position = CGPoint(x: backgroundNode.position.x, y: -((playerNode.position.y-180)/8))
            backgroundStarsNode.position = CGPoint(x: backgroundStarsNode.position.x, y: -((playerNode.position.y-180)/6))
            backgroundPlanetNode.position = CGPoint(x: backgroundPlanetNode.position.x, y: -((playerNode.position.y-180)/8))
            foregroundNode.position = CGPoint(x: foregroundNode.position.x, y: -(playerNode.position.y-180))
        }
    }
    
    //物理变化
    override func didSimulatePhysics() {
        if let accelerometerData = coreMotionManager.accelerometerData {
            playerNode.physicsBody?.velocity = CGVector(dx: CGFloat(accelerometerData.acceleration.x * 380),
                                                        dy: playerNode.physicsBody!.velocity.dy)
        }
        
        if playerNode.position.x < -(playerNode.size.width/2) {
            playerNode.position = CGPoint(x: size.width-playerNode.size.width/2,
                                          y: playerNode.position.y)
        }
        else if playerNode.position.x > self.size.width {
            playerNode.position = CGPoint(x: playerNode.size.width/2,
                                          y: playerNode.position.y)
        }
    }
    
    //不使用速度计后，需要关闭
    deinit {
        coreMotionManager.stopAccelerometerUpdates()
    }
    
}


/*
 为了检测何时碰撞，需要实现SKPhysicsContactDelegate协议。
 其中检测何时碰撞的方法有：didBeginContact和didEndContent
 */
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        /*contact包含5个属性：
         bodyA:第一个node
         bodyB:第二个node
         contactPoint:两者接触的点
         collisionImpulse:撞击力度
         collisionNormal:碰撞方向
         */
        print("碰撞开始")
        let nodeB = contact.bodyB.node
        if nodeB?.name == "POWER_UP_ORB" {
            impulseCount += 1
            nodeB?.removeFromParent()
        }
        else if nodeB?.name == "BLACK_HOLE" {
            playerNode.physicsBody?.contactTestBitMask = 0
            impulseCount = 0
            
            let colorizeAction = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 1)
            playerNode.run(colorizeAction)
        }
    }
}




