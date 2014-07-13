//
//  Platform.swift
//  testgame
//
//  Created by peacock on 14-7-12.
//  Copyright (c) 2014年 peacock. All rights reserved.
//

import SpriteKit

protocol ProtocolMainScene {
    func onSetScore(score:CGFloat)
}

class Platform: SKNode {
    var textPlatform = SKTexture()
    var sceneWidth: CGFloat = 0.0
    var textWorm = SKTexture()
    
    var platformSpeed: CGFloat = 5
    var distance: CGFloat = 0.0
    var lastDistance: CGFloat = 0.0
    var moveAct = SKAction()
    var isFirst: Bool = true
    
    var theX: Float = 0.0
    var theY: Float = 0.0
    var theScale: Float = 1.0
    var gap: Float = 0.0
    
    let platforms = SKNode()
    let worms = SKNode()
    let background = SKSpriteNode()
    var delegate:ProtocolMainScene?
    
    
    init()  {
        super.init()
    }
    
    init(sceneWidth:CGFloat, textPlatform:SKTexture) {
        super.init()
        self.sceneWidth = sceneWidth
        self.textPlatform = textPlatform
        
        let bg0 = SKSpriteNode(imageNamed: "background_f0")
        bg0.anchorPoint = CGPointMake(0, 0)
        bg0.position = CGPointMake(0, 50)
        
        let bg1 = SKSpriteNode(imageNamed: "background_f0")
        bg1.anchorPoint = CGPointMake(0, 0)
        bg1.position = CGPointMake(1185, 50)
        
        background.addChild(bg0)
        background.addChild(bg1)
        self.addChild(background)
        
        var bgMoveAct = SKAction.moveToX(-1185, duration:10)
        var bgMoveBackAct = SKAction.moveToX(0, duration:0)
        var bgMoveSequence = SKAction.sequence([bgMoveAct, bgMoveBackAct])
        var bgMoveRepeat = SKAction.repeatActionForever(bgMoveSequence)
        background.runAction(bgMoveRepeat)
        
        self.addChild(platforms)
        
        moveAct = SKAction.moveByX(CGFloat(-platformSpeed), y:0.0, duration:0.0)
        
        generatePlatform()
        
        // worms
        textWorm = SKTexture(imageNamed:"worm_02")
        
        self.addChild(worms)
        
    }
    
    func generatePlatform() {
        println("great textplatform")
        if self.textPlatform == nil {
            println("textplatform is nil")
        }
        var platformSprite = SKSpriteNode(texture:textPlatform)
        
        if isFirst {
            theScale = 2.3
            platformSprite.xScale = theScale
            theY = 250.0
            theX = platformSprite.size.width / 2
            platformSprite.position = CGPoint(x:theX, y:theY)
            lastDistance = CGFloat(platformSprite.size.width) - sceneWidth
            isFirst = false
        } else {
            theScale = CGFloat(Float(arc4random() % 6) / 10) + 1
            platformSprite.xScale = theScale
            self.gap = 100 + CGFloat(arc4random() % 5 * 80)
            
            theY = CGFloat(arc4random() % 200 + 200)
            theX = CGFloat(self.sceneWidth) + platformSprite.size.width / 2 + self.gap
            platformSprite.position = CGPoint(x:theX, y:theY)
            
            lastDistance = CGFloat(platformSprite.size.width + self.gap)
        }
        
        platformSprite.physicsBody = SKPhysicsBody(rectangleOfSize:CGSizeMake(platformSprite.size.width, platformSprite.size.height))
        platformSprite.physicsBody.dynamic = false
        platformSprite.physicsBody.restitution = 0
        platformSprite.physicsBody.categoryBitMask = ColliderType.platform
        platforms.addChild(platformSprite)
    }
    
    func generateWorm() {
        var random: Int = Int(arc4random() % 100)
        var randomSpeed: Int = Int(platformSpeed / 50)
        if randomSpeed > 10 {
            randomSpeed = 10
        }
        if random < 88 {
            random = Int(randomSpeed + randomSpeed)
        }
        if random > 98 {
            let worm = SKSpriteNode(texture:textWorm)
            worm.setScale(0.5)
            worm.physicsBody = SKPhysicsBody(rectangleOfSize:worm.size)
            worm.physicsBody.restitution = 0
            worm.physicsBody.categoryBitMask = ColliderType.worm
            worm.physicsBody.dynamic = false
            worm.position = CGPointMake(sceneWidth + worm.size.width / 2, CGFloat(self.theY) + CGFloat(random) + 100)
            worms.addChild(worm)
        }
        for object: AnyObject in worms.children {
            var worm = object as SKNode
            worm.runAction(moveAct)
            if worm.position.x < -worm.frame.size.width / 2 {
                worm.removeFromParent()
            }
        }
    }
    
    func onUpdate() {
        // worms
        generateWorm()
        
        for object: AnyObject in platforms.children {
            var platform = object as SKNode
            platform.runAction(moveAct)
            if platform.position.x < -platform.frame.size.width / 2 {
                platform.removeFromParent()
            }
        }
        
        lastDistance -= platformSpeed
        
        if lastDistance <= platformSpeed {
            generatePlatform()
        }
        distance += platformSpeed
        delegate?.onSetScore(CGFloat(Int(distance / 1000 * 10)) / 10)
        let tempSpeed = CGFloat(5 + Int(distance / 2000))
        if platformSpeed != tempSpeed {
            platformSpeed = tempSpeed
            moveAct = SKAction.moveByX(CGFloat(-platformSpeed), y:0.0, duration:0.0)
        }
    }
    
    func onReset() {
        isFirst = true
        worms.removeAllChildren()
        platforms.removeAllChildren()
        generatePlatform()
        distance = 0.0
        platformSpeed = 5
        moveAct = SKAction.moveByX(CGFloat(-platformSpeed), y:0.0, duration:0.0)
        
    }
    

}