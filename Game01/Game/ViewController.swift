//
//  ViewController.swift
//  Game
//
//  Created by baiwei－mac on 17/1/24.
//  Copyright © 2017年 YuHua. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    var spriteView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spriteView = view as! SKView
        
        spriteView.showsDrawCount = true//使用多少绘画，越少越好
        spriteView.showsNodeCount = true//节点个数
        spriteView.showsFPS = true//FPS开启
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let hello = HelloScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        spriteView.presentScene(hello)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

