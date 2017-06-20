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
    let textureAtlas = SKTextureAtlas(named: "sprites.atlas")
    let backgroundNode = SKSpriteNode(imageNamed: "Background")
    let backgroundStarsNode = SKSpriteNode(imageNamed: "Stars")
    let backgroundPlanetNode = SKSpriteNode(imageNamed: "PlanetStart")
    var playerNode: SpaceMan!
    //该节点是一个图层，容纳了所有的会影响游戏的精灵
    let foregroundNode = SKSpriteNode()
    //水平监视  CMMotionManager提供iOS运动服务对象，包括加速计，磁力计，转速和其它运动传感器
    let coreMotionManager = CMMotionManager()
    var score = 0
    let scoreTextNode = SKLabelNode(fontNamed: "Copperplate")
    let impulseTextNode = SKLabelNode(fontNamed: "Copperplate")
    //音效
    let orbPopAction = SKAction.playSoundFileNamed("orb_pop.wav", waitForCompletion: false)
    
    //按钮
    let startGameTextNode = SKLabelNode(fontNamed: "Copperplate")
    
    //粒子效果
    var engineExhaust: SKEmitterNode?
    
    var impulseCount = 4
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        /*SKLabelNode需要注意的属性：
         SKLabelNode的horizontalAlignmentMode用于设置文本相对于节点位置的水平位置。 有三个水平对齐选项，所有这些选项都由枚举SKLabelHorizontalAlignmentMode定义。 三个选项是SKLabelHorizontalAlignmentMode.left，SKLabelHorizontalAlignmentMode.center和SKLabelHorizontalAlignmentMode.right。
         用于更改垂直对齐的SKLabelNode属性是verticalAlignmentMode。有四个值可以设置此属性，它们由SKLabelVerticalAlignmentMode枚举定义。分别是：center中心 top顶部 bottom底部 baseline基本线
         */
//        let simpleLabel = SKLabelNode(fontNamed: "Copperplate")
//        simpleLabel.text = "你好，飞船！"
//        simpleLabel.fontSize = 40
//        simpleLabel.position = CGPoint(x: size.width/2, y: frame.height-simpleLabel.frame.height)
//        simpleLabel.horizontalAlignmentMode = .center
//        addChild(simpleLabel)
        
        scoreTextNode.text = "分数:\(score)"
        scoreTextNode.fontSize = 20
        scoreTextNode.fontColor = SKColor.white
        scoreTextNode.position = CGPoint(x: size.width-10, y: size.height-20)
        scoreTextNode.horizontalAlignmentMode = .right
        
        impulseTextNode.text = "能量:\(impulseCount)"
        impulseTextNode.fontSize = 20
        impulseTextNode.fontColor = SKColor.white
        impulseTextNode.position = CGPoint(x: 10, y: size.height-20)
        impulseTextNode.horizontalAlignmentMode = .left
        
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
        
        playerNode = SpaceMan(textureAtlas: textureAtlas)
        playerNode.position = CGPoint(x: size.width/2, y: 180)
        //加入物理形状，可以添加很多标准的形状 circle圆 rectangles矩形 polygon多边形
//        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width/2)
//        playerNode.physicsBody?.isDynamic = false
        //阻尼，模拟空气摩擦
//        playerNode.physicsBody?.linearDamping = 1.0
//        addChild(playerNode)
        /*创建节点树关系，会用到的三个方法：
         1.addChild() 添加子节点
         2.insertChild(_: at:) 插入子节点
         3.removeFromParent() 移除子节点
         */
        
        //如果两个node相互碰撞，动态的会被弹开，并且开始旋转，如果不需要旋转，则可以设置
//        playerNode.physicsBody?.allowsRotation = false
        
        /*
         碰撞性能三维掩码属性：
         collisionBitMask:碰撞类别
         categoryBitMask:主题碰撞类别
         contactTestBitMask:确定物理机构与那些类别接触
         */
//        playerNode.physicsBody?.categoryBitMask = CollisionCategoryPlayer//设置类别掩码
//        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryPowerUpOrbs | CollisionCategoryBlackHoles//设置当碰撞发生时，需要通知
//        playerNode.physicsBody?.collisionBitMask = 0//spritekit不处理冲突，代码自行处理
        
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
        
        /*粒子加速器，可以模拟出很多特效。系统提供的粒子模板有：
         bokeh:六边形粒子集合
         fire:火焰效果
         fireflies:萤火虫模板
         magic:魔术模板创建了一个绿色（默认）粒子的集合，它们在生长和模糊的同时随机移动很短的距离，然后在生命周期结束时退出。
         rain:雨模板只是你会想到的：它创建一个粒子的集合，从发射器的顶部开始，并移动到屏幕底部，目的是模拟雨暴。
         smoke:烟雾模板创建几个大的黑色粒子，从发射器的底部开始并向屏幕顶部移动。 随着每个粒子向屏幕顶部移动，它逐渐淡出。
         snow:雪模板创建从发射器顶部开始的白色，漫射，圆形颗粒，像雨粒子一样向屏幕底部移动。
         spark:火花模板创建短暂的金色颗粒，全部360度从发射器中爆发出来，然后才消失。
         
         使用new->添加新的粒子效果sks后，在代码中，如下使用sks文件：
         let pathToEmitter = Bundle.main.path(forResource: "MySparkParticle", ofType: "sks")
         let emitter = NSKeyedUnarchiver.unarchiveObject(withFile: pathToEmitter!) as? SKEmitterNode
         addChild(emitter!)
         
         颗粒声明周期决定创建多少个粒子，可以创建的最大粒子数以及每个创建的粒子的生命周期。控制粒子的寿命周期有四个属性：
         emitter:前两个生命周期属性是Emitter Birthrate和Maximum属性。 Birthrate属性定义了每秒发射新粒子的速率。值越高，生成的新颗粒越快。最大颗粒寿命特性决定了发射体发射的颗粒总数。值为0会导致粒子无限期地发射。任何其他值将导致发射器在达到该值时停止发射。Birthrate属性更改为20，将Maximum属性更改为0.观察发生的情况 - 发射器每秒产生20个粒子。现在将Birthrate属性设置为20，将Maximum属性更改为20，然后检查了解发射器的变化。这次发射器将在1秒钟内发射20颗粒子，然后停止1秒，然后再发射20颗粒子
         lifetime:接下来的两个粒子生命周期属性是Start和Range属性。 这些特性控制发射粒子的寿命。 Start属性控制粒子可见的平均时间长度（以秒为单位）。 当时间过去时，粒子消失。Range属性提供了一种改变粒子在屏幕上的时间的方法。 当您将此属性设置为0以外的任何数字时，将生成0和输入的数字之间的随机数。 然后将该数字的一半随机添加或减去“起始”值以产生粒子的最终生命周期。 如果输入0，则所有颗粒在相同的时间内保持可见。
         
         有五组影响发射的颗粒的运动的性质：
         position range:定义了在其中创建发射的粒子的区域。粒子在由Position Range属性的X和Y值定义的矩形内创建。将Position Range属性的X值更改为300，将Y值更改为300，并观察其如何影响粒子的发射。 您现在将看到在300×300盒子中发射的颗粒。
         Z位置属性控制粒子沿z轴的平均起始深度。 您可以将此属性视为控制粒子从视口中放置的距离近或远。
         下一个粒子移动属性是Angle属性。 Angle属性定义了以逆时针方向离开创建点的粒子的角度。有两个角度值：起始和范围。起始值定义了粒子发射的方向（以度为单位），范围值定义了粒子的初始角度变化的度数，加或减数值的一半。如果您查看火花发射器的Angle属性的初始值，您将看到它大约为90度，并且Range属性设置为大约360度。最简单的方法看看这些值如何影响粒子发射是设置“开始”和“范围”值。目前，Range设置为360度，这表明粒子发射范围是一个完整的圆。将范围值减小到90度，将起始值设置为0度，看看会发生什么。您现在将看到粒子开始被放射到屏幕的右侧，并分散到其初始发射点之上和之下的大约45度。现在将起始值增加到90度。请注意颗粒物如何开始生命直接排出。将起始值增加90度，使其达到180度。这一次，颗粒被发射到屏幕的左侧。使用这些值播放后，您将看到起始值从发射点中心的逆时针方向从0到360度，并从起始值扩展到范围值的值的一半。
         速度属性非常简单。 它定义了粒子在创建时移动的初始速度。 您可以使用起始值指定初始速度，然后可以使用范围值来调整粒子的初始速度，加或减半范围值的一半。 将范围值设置为0表示所有粒子以相同的速度行进。
         最终的粒子移动属性是Acceleration属性。 加速度特性根据X和Y方向控制粒子在发射后加速或减速的程度。 您可以使用X值沿x轴施加加速度，并使用Y值沿y轴施加加速度。
         */
        //添加粒子效果
        let engineExhaustPath = Bundle.main.path(forResource: "EngineExhaust", ofType: "sks")
        engineExhaust = NSKeyedUnarchiver.unarchiveObject(withFile: engineExhaustPath!) as? SKEmitterNode
        engineExhaust?.position = CGPoint(x: 0, y: -(playerNode.size.height/2))
        playerNode.addChild(engineExhaust!)
        engineExhaust?.isHidden = true
        
        /*SKLabelNode文本标签：
         let simpleLabel = SKLabelNode(fontNamed: "Copperplate")
         simpleLabel.text = "Hello, SpriteKit!";
         simpleLabel.fontSize = 40;
         simpleLabel.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
         addChild(simpleLabel)
         */
        addChild(scoreTextNode)
        addChild(impulseTextNode)
        
        //添加按钮
        startGameTextNode.text = "点击任意点开始游戏！"
        startGameTextNode.horizontalAlignmentMode = .center
        startGameTextNode.verticalAlignmentMode = .center
        startGameTextNode.fontSize = 20
        startGameTextNode.fontColor = .white
        startGameTextNode.position = CGPoint(x: scene!.size.width/2, y: scene!.size.height/2)
        addChild(startGameTextNode)
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
        
        let moveLeft = SKAction.moveTo(x: 0, duration: 2)
        let moveRight = SKAction.moveTo(x: size.width, duration: 2)
        let sequence = SKAction.sequence([moveLeft, moveRight])
        let moveAction = SKAction.repeatForever(sequence)
        
        for i in 1...10 {
            let blackHoleNode = BlackHole()
            
            blackHoleNode.position = CGPoint(x: size.width-80, y: 600 * CGFloat(i))
            blackHoleNode.run(moveAction)
            
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
            let orbNode = Orb()
            if orbNodePosition.x - orbNode.size.width * 2 <= 0 {
                orbXShift = 1.0
            }
            
            if orbNodePosition.x + orbNode.size.width >= size.width {
                orbXShift = -1.0
            }
            
            orbNodePosition.x += 40.0 * orbXShift
            orbNodePosition.y += 120
            orbNode.position = orbNodePosition
            
            foregroundNode.addChild(orbNode)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //添加动力，CGVector向量
//        playerNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
        
        startGameTextNode.removeFromParent()
        
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
            engineExhaust?.isHidden = false
            impulseTextNode.text = "能量:\(impulseCount)"
            Timer.scheduledTimer(timeInterval: 0.5,
                                 target: self,
                                 selector: #selector(hideEngineExaust(_:)),
                                 userInfo: nil,
                                 repeats: false)
        }
    }
    
    func hideEngineExaust(_ timer: Timer!) {
        if !engineExhaust!.isHidden {
            engineExhaust?.isHidden = true
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
        //判断是否赢得游戏
        else if playerNode.position.y > 7000 {
            gameOverWithResult(true)
        }
        else if playerNode.position.y < 0 {
            gameOverWithResult(false)
        }
        
        removeOutOfSceneNodesWithName("BLACK_HOLE")
        removeOutOfSceneNodesWithName("POWER_UP_ORB")
    }
    
    func gameOverWithResult(_ gameResult: Bool) {
        playerNode.removeFromParent()
        let transition = SKTransition.crossFade(withDuration: 2)
        let menuScene = MenuScene(size: size,
                                  gameResult: gameResult,
                                  score: score)
        view?.presentScene(menuScene, transition: transition)
    }
    
    func removeOutOfSceneNodesWithName(_ name: String) {
        foregroundNode.enumerateChildNodes(withName: name) { (node, stop) in
            if self.playerNode.position.y - node.position.y > self.size.height {
                node.removeFromParent()
            }
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
    
    /*
     SKTransition用于场景过渡，步骤如下：
     1.创建出要进入的场景
     2.创建出SKTransition
     3.使用SKView的presentScene()方法推出新场景
     
     可以创建出自定义的SKTransition，下方13个方法用于创建出SKTransition自定义内容
     class func crossFade(withDuration: TimeInterval)
     class func doorsCloseHorizontal(withDuration: TimeInterval)
     class func doorsCloseVertical(withDuration: TimeInterval)
     class func doorsOpenHorizontal(withDuration: TimeInterval)
     class func doorsOpenVertical(withDuration: TimeInterval)
     class func doorway(withDuration: TimeInterval)
     class func fade(with: UIColor, duration: TimeInterval)
     class func fade(withDuration: TimeInterval)
     class func flipHorizontal(withDuration: TimeInterval)
     class func flipVertical(withDuration: TimeInterval)
     class func moveIn(with: SKTransitionDirection, duration: TimeInterval)
     class func push(with: SKTransitionDirection, duration: TimeInterval)
     class func reveal(with: SKTransitionDirection, duration: TimeInterval)
     
     例子：
     let transition = SKTransition.fade(withDuration: 2.0)
     let sceneTwo = SceneTwo(size: size)
     view?.presentScene(sceneTwo, transition: transition)
     
     需要注意的两个属性：pausesIncomingScene和pausesOutgoingScene。 这些属性分别用于暂停传入和传出场景的动画的Bool属性。如果您想在场景转换期间继续进行场景的动画，则在呈现场景之前，您只需将相应的属性设置为false。 两个属性的默认值为true。
     
     SpriteKit在SKScene类中提供了两种可以覆盖的方法来检测何时一个场景正在被转移或转换。 第一种方法是SKScene willMove（）方法。 当SKScene即将从视图中删除时，将调用此方法。第二种方法是SKScene didMove（）方法。 当场景刚刚通过视图呈现时，调用此方法。
     
     
     */
    
    //不使用速度计后，需要关闭
    deinit {
        coreMotionManager.stopAccelerometerUpdates()
    }
    
}


/*播放声音： MP3, M4A, CAF, WAV
 let playSoundAction = SKAction.playSoundFileNamed("sound.wav", waitForCompletion: false)
 runAction(playSoundAction)
 */


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
        let nodeB = contact.bodyB.node
        print("name:\(nodeB?.name)")
        if nodeB?.name == "POWER_UP_ORB" {
            
            run(orbPopAction)
            
            impulseCount += 1
            impulseTextNode.text = "能量:\(impulseCount)"
            score += 1
            scoreTextNode.text = "分数:\(score)"
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




