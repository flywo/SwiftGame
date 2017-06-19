//
//  GameViewController.swift
//  SuperSpaceMan
//
//  Created by baiwei－mac on 17/6/15.
//  Copyright © 2017年 YuHua. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var scene: GameScene!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //配置mian view的内容
        let skView = view as! SKView
        skView.showsFPS = true
        
        //创建game scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        //呈现game scene
        skView.presentScene(scene)
    }
    
}
