//
//  GameScene.swift
//  testgame
//
//  Created by peacock on 14-7-12.
//  Copyright (c) 2014年 peacock. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate, ProtocolMainScene {
    var scoreLabel = SKLabelNode(fontNamed:"Chalkduster")
    var wormLabel = SKLabelNode(fontNamed:"Chalkduster")
    var wormNum = 0
    var platform = Platform()
    var hero = Hero()
    
    var startJumpY = 0.0
    var endJumpY = 0.0
    
    var downAct = SKAction.moveByX(0, y:-50, duration:0.05)
    var upAct = SKAction.moveByX(0, y:50, duration:0.1)
    var downUpAct = SKAction()
    
    // pipes
    let verticalPipeGap = 200.0
    var pipeTextureUp:SKTexture!
    var pipeTextureDown:SKTexture!
    var movePipesAndRemove:SKAction!
    var pipes:SKNode!
    var moving:SKNode!
    
    var isLose = false
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!";
//        myLabel.fontSize = 65;
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
//        
//        self.addChild(myLabel)
        let skyColor = SKColor(red:113.0/255.0, green:197.0/255.0, blue:207.0/255.0, alpha:1.0)
        self.backgroundColor = skyColor
        self.physicsWorld.gravity = CGVectorMake(0.0, -5)
        self.physicsWorld.contactDelegate = self
        
        var textPlatform = SKTexture(imageNamed: "platform")
        println(self.frame.size.width)
        
        platform = Platform(sceneWidth: CGFloat(self.frame.size.width), textPlatform: textPlatform)
        platform.delegate = self
        
        hero.run()
        
        self.addChild(platform)
        self.addChild(hero)
        
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.position = CGPointMake(20, self.frame.size.height-150)
        scoreLabel.text = "run: 0 km"
        self.addChild(scoreLabel)
        
        wormLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        wormLabel.position = CGPointMake(400, self.frame.size.height-150)
        wormLabel.text = "worm: \(wormNum) "
        self.addChild(wormLabel)
        
        moving = SKNode()
        self.addChild(moving)
        pipes = SKNode()
        moving.addChild(pipes)
        moving.speed = 3
        // create the pipes textures
        pipeTextureUp = SKTexture(imageNamed: "pipe_up")
        pipeTextureUp.filteringMode = .Nearest
        pipeTextureDown = SKTexture(imageNamed: "pipe_down")
        pipeTextureDown.filteringMode = .Nearest
        
        // create the pipes movement actions
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * pipeTextureUp.size().width)
        let movePipes = SKAction.moveByX(-distanceToMove, y:0.0, duration:NSTimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
        
        // spawn the pipes
        let spawn = SKAction.runBlock({() in self.spawnPipes()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
    }
    
    // 点击屏幕
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        if !isLose {
            if hero.status != 2 {
                //self.runAction(SKAction.playSoundFileNamed("jump_from_platform.mp3", waitForCompletion: false))
            }
            hero.jump()
        } else {
            onReset()
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if !isLose {
            if hero.node.position.y < -self.frame.size.height/2 {
                //self.runAction(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
                isLose = true
                //bgMusicPlayer.stop()
            } else {
                platform.onUpdate()
            }
            
        }
    }
    
    // contact begin delegate
    func didBeginContact(contact: SKPhysicsContact) {
        println("didBeginContact")
        // 落到台子上
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == (ColliderType.hero | ColliderType.platform) {
            hero.node.physicsBody.velocity = CGVectorMake(0, 0)
            hero.run()
        } else if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == (ColliderType.hero | ColliderType.worm){
            if contact.bodyA.categoryBitMask == ColliderType.worm {
                contact.bodyA.node.removeFromParent()
            }else{
                contact.bodyB.node.removeFromParent()
            }
            hero.eat()
            wormNum++
            wormLabel.text = "worm: \(wormNum) "
            //self.runAction(SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false))
        }
    }
    
    // contact end delegate
    func didEndContact(contact: SKPhysicsContact) {
        // 跳起
        println("didEndContact")
        hero.jumpEffect();
    }

    // main scene delegate
    func onSetScore(score: CGFloat) {
        scoreLabel.text = "run: \(score) km"
    }
    
    func onReset(){
        //bgMusicPlayer.play()
        hero.onReset()
        platform.onReset()
        isLose = false
        wormNum = 0
        wormLabel.text = "worm: \(wormNum) "
        // Remove all existing pipes
        pipes.removeAllChildren()
        moving.speed = 1
    }
    
    func spawnPipes() {
        let pipePair = SKNode()
        pipePair.position = CGPointMake( self.frame.size.width + pipeTextureUp.size().width * 2, 0 )
        pipePair.zPosition = -10
        
        let height = UInt32( self.frame.size.height / 4 )
        let y = arc4random() % height + height
        
        let pipeDown = SKSpriteNode(texture: pipeTextureDown)
        pipeDown.setScale(2.0)
        pipeDown.position = CGPointMake(0.0, CGFloat(y) + pipeDown.size.height + CGFloat(verticalPipeGap))
        
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOfSize: pipeDown.size)
        pipeDown.physicsBody.dynamic = false
        pipeDown.physicsBody.categoryBitMask = ColliderType.pipe
        pipeDown.physicsBody.contactTestBitMask = ColliderType.hero
        pipePair.addChild(pipeDown)
        
        let pipeUp = SKSpriteNode(texture: pipeTextureUp)
        pipeUp.setScale(2.0)
        pipeUp.position = CGPointMake(0.0, CGFloat(y))
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOfSize: pipeUp.size)
        pipeUp.physicsBody.dynamic = false
        pipeUp.physicsBody.categoryBitMask = ColliderType.pipe
        pipeUp.physicsBody.contactTestBitMask = ColliderType.hero
        pipePair.addChild(pipeUp)
        
        
        pipePair.runAction(movePipesAndRemove)
        pipes.addChild(pipePair)
    }
}
