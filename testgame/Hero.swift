//
//  Hero.swift
//  testgame
//
//  Created by peacock on 14-7-12.
//  Copyright (c) 2014年 peacock. All rights reserved.
//

import SpriteKit

class Hero: SKNode {
    var jumpAct = SKAction()
    var jumpEffectAct = SKAction()
    var runAct = SKAction()
    var eatAct = SKAction()

    var node = SKSpriteNode()
    
    var eat_1 = SKTexture(imageNamed: "hit_item_01")
    var eat_2 = SKTexture(imageNamed: "hit_item_02")
    var eat_3 = SKTexture(imageNamed: "hit_item_03")
    
    var run_1 = SKTexture(imageNamed:"bird-01")
    var run_2 = SKTexture(imageNamed:"bird-02")
    var run_3 = SKTexture(imageNamed:"bird-03")
    var run_4 = SKTexture(imageNamed:"bird-04")
    
    var hero_jump_1 = SKTexture(imageNamed:"bird-01")
    var hero_jump_2 = SKTexture(imageNamed:"bird-02")
    var hero_jump_3 = SKTexture(imageNamed:"bird-03")
    var hero_jump_4 = SKTexture(imageNamed:"bird-04")
    
    var jump_1 = SKTexture(imageNamed: "jump_from_ground_effect_01")
    var jump_2 = SKTexture(imageNamed: "jump_from_ground_effect_02")
    var jump_3 = SKTexture(imageNamed: "jump_from_ground_effect_03")
    var jump_4 = SKTexture(imageNamed: "jump_from_ground_effect_04")
    var panda_run_1 = SKTexture(imageNamed: "panda_run_01")
    var panda_run_2 = SKTexture(imageNamed: "panda_run_02")
    var panda_run_3 = SKTexture(imageNamed: "panda_run_03")
    var panda_run_4 = SKTexture(imageNamed: "panda_run_04")
    var panda_run_5 = SKTexture(imageNamed: "panda_run_05")
    var panda_run_6 = SKTexture(imageNamed: "panda_run_06")
    var panda_run_7 = SKTexture(imageNamed: "panda_run_07")
    var panda_run_8 = SKTexture(imageNamed: "panda_run_08")
    var status = 0
    
    init() {
        super.init()
        var animRun = SKAction.animateWithTextures([run_1,run_2,run_3,run_4],timePerFrame: 0.05)
        //var animRun = SKAction.animateWithTextures([panda_run_1,panda_run_2,panda_run_3,panda_run_4,panda_run_5,panda_run_6,panda_run_7,panda_run_8], timePerFrame: 0.05)
        runAct = SKAction.repeatActionForever(animRun)
        
        var animJump = SKAction.animateWithTextures([hero_jump_1, hero_jump_2, hero_jump_4, hero_jump_4],timePerFrame: 0.05)
        jumpAct =  SKAction.repeatAction(animJump, count: 1)
        
        node = SKSpriteNode(texture: run_1)
        node.setScale(2.0)
        node.physicsBody = SKPhysicsBody(rectangleOfSize:CGSizeMake(node.frame.size.width, node.frame.size.height))
        node.physicsBody.categoryBitMask = ColliderType.hero
        // contactTestBitMask表示与什么类型对象碰撞时，应该通知contact代理
        node.physicsBody.contactTestBitMask = ColliderType.platform | ColliderType.worm
        node.physicsBody.collisionBitMask = ColliderType.platform
        //hero.physicsBody.dynamic = YES; // 设为yes时不由物理引擎控制运动
        // collisionBitMask表示物理引擎需要处理的碰撞事件,比如相互弹开
        //node.physicsBody.collisionBitMask = 0;
        // usesPreciseCollisionDetection用于检测快速物体的碰撞
        //node.physicsBody.usesPreciseCollisionDetection = YES;
        node.physicsBody.restitution = 0
        node.physicsBody.allowsRotation = false
        node.position = CGPoint(x:200, y:400)
        self.addChild(node)
    }
    
    func run() {
        node.runAction(runAct)
        self.status = 0
    }
    
    func jump() {
        println("now status is \(status)")
        if status != 2 {
            node.removeAllActions()
            node.runAction(jumpAct)
            node.physicsBody.velocity = CGVectorMake(0, 350)
            node.physicsBody.applyImpulse(CGVectorMake(0, 20))
            if status == 1 {
                status = 2
                println("now the hero status is 2")
            } else {
                status = 1
            }
        }
    }
    
    func onReset() {
        node.position = CGPoint(x:200, y:400)
    }
    
    // 吃虫子
    func eat() {
        var eatEffectNode = SKSpriteNode(texture:eat_1)
        var animEat = SKAction.animateWithTextures([eat_1, eat_2, eat_3], timePerFrame:0.01)
        var eatRemove = SKAction.runBlock({() in self.removeEffect(eatEffectNode)})
        eatAct = SKAction.sequence([animEat, eatRemove])
        node.addChild(eatEffectNode)
        eatEffectNode.runAction(eatAct)
    }
    
    func jumpEffect() {
        println("[hero jumpEffectAct] start")
        var jumpEffectNode = SKSpriteNode(texture:jump_1)
        jumpEffectNode.position = CGPointMake(-80, -30)
        var animJump = SKAction.animateWithTextures([jump_1, jump_2, jump_3, jump_4], timePerFrame:0.05)
        var jumpRemove = SKAction.runBlock({() in self.removeEffect(jumpEffectNode)})
        jumpEffectAct = SKAction.sequence([animJump,jumpRemove])
        node.addChild(jumpEffectNode)
        jumpEffectNode.runAction(jumpEffectAct)
    }

    func removeEffect(effect:SKSpriteNode) {
        effect.removeFromParent()
    }
}
