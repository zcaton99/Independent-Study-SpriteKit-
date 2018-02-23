//
//  GameScene.swift
//  Independent Study
//
//  Created by Zach Caton on 1/26/18.
//  Copyright © 2018 Zach Caton. All rights reserved.
//

import SpriteKit
import GameplayKit

var person : SKSpriteNode!
var personWalkingFrames : [SKTexture]!

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var label: SKLabelNode {
        let label = SKLabelNode()
        label.horizontalAlignmentMode = .right
        label.position = CGPoint(x: 660, y: 320)
        label.text = "0"
        return label
    }
    
    
    override func sceneDidLoad() {
        physicsWorld.contactDelegate = self
        
    }
    
    // create random num generator
    // if( num%4 ==0) creates random number of objects (25% of the time)
    
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.black
        physicsWorld.contactDelegate = self
        //physicsWorld.gravity = CGVector.zero
        addChild(label)
        
        //creates invisible wall to keep nodes inside the screen
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        
        let personAnimatedAtlas = SKTextureAtlas(named: "BearImages")//PersonImg
        var walkFrames = [SKTexture]()
        
        let numImages = personAnimatedAtlas.textureNames.count
        var i = 1 //0
        while( i < (numImages / 2) ) { // divide by 2
            let personTextureName = "bear\(i)~ipad"
            //print("person-\(i)")
            print("bear\(i)~ipad")
            walkFrames.append(personAnimatedAtlas.textureNamed(personTextureName))
            i += 1

        }
        
        personWalkingFrames = walkFrames
        
        let firstFrame = personWalkingFrames[0]
        person = SKSpriteNode(texture: firstFrame)
        person.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        addChild(person)
        
        walkingPerson()
        addBox()
        
        createGround()
    }
    
    func addBox(){
        
        let box = SKSpriteNode(imageNamed: "box")
        box.position = CGPoint(x: 130, y: 100)
        
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = true
        box.physicsBody?.categoryBitMask = PhysicsCategory.Box
        box.physicsBody?.contactTestBitMask = PhysicsCategory.Person
        box.physicsBody?.collisionBitMask = PhysicsCategory.Person
        box.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(box)
        
    }
    
    
    func personHitsObject(person: SKSpriteNode, box: SKSpriteNode){
        print("hit object!")
        person.removeAllActions()
        //stop bear and it turn around and walk the other way
        
    }
    
    func walkingPerson() {
        //This is our general runAction method to make our bear walk.
        person.run(SKAction.repeatForever(
            SKAction.animate(with: personWalkingFrames,
            timePerFrame: 0.1,
            resize: false,
            restore: true)),
        withKey:"walkingInPlacePerson")
        
        person.physicsBody = SKPhysicsBody(rectangleOf: person.size)
        person.physicsBody?.isDynamic = true
        person.physicsBody?.categoryBitMask = PhysicsCategory.Person
        person.physicsBody?.contactTestBitMask = PhysicsCategory.Box
        person.physicsBody?.collisionBitMask = PhysicsCategory.Person
        person.physicsBody?.allowsRotation = false
        person.physicsBody?.usesPreciseCollisionDetection = true
        person.physicsBody?.affectedByGravity = true
    }
    
    func personMovedEnded(){
        person.removeAllActions()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Person != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Box != 0)) {
            if let person = firstBody.node as? SKSpriteNode, let
                box = secondBody.node as? SKSpriteNode {
                //projectileDidCollideWithMonster(projectile: projectile, monster: monster)
                personHitsObject(person: person, box: box)
            }
        }else if ((firstBody.categoryBitMask & PhysicsCategory.groundCategory != 0) && (secondBody.categoryBitMask & PhysicsCategory.groundCategory != 0)){
            if let person = firstBody.node as? SKSpriteNode, let ground = secondBody.node as? SKSpriteNode{
                
                personHitsObject(person: person, box: ground)
                
            }
        }
    }
    
    
    func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        
        for i in 0 ... 1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -1 //-10
            ground.position = CGPoint(x: (groundTexture.size().width / 2.0 + (groundTexture.size().width * CGFloat(i))), y: groundTexture.size().height / 4)
            
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.isDynamic = true
            ground.physicsBody?.categoryBitMask = PhysicsCategory.groundCategory
            ground.physicsBody?.contactTestBitMask = PhysicsCategory.Person
            ground.physicsBody?.collisionBitMask = PhysicsCategory.Person | (self.physicsBody?.collisionBitMask)!
            ground.physicsBody?.allowsRotation = false
            ground.physicsBody?.usesPreciseCollisionDetection = true
            ground.physicsBody?.affectedByGravity = false
            
            addChild(ground)
            
            //makes it infinitely move
//            let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
//            let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
//            let moveLoop = SKAction.sequence([moveLeft, moveReset])
//            let moveForever = SKAction.repeatForever(moveLoop)
//
//            ground.run(moveForever)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        let touch = touches.first as! UITouch
        let location = touch.location(in: self)
        var multiplierForDirection: CGFloat
        
        let personVelocity = self.frame.size.width / 3.0
        
        let moveDistance = CGPoint(x: location.x - person.position.x, y: location.y - person.position.y)
        let distanceToMove = sqrt(moveDistance.x * moveDistance.x + moveDistance.y * moveDistance.y)
        
        let moveDuration = distanceToMove / personVelocity
        
        
        if (moveDistance.x < 0){
            //walk left
            multiplierForDirection = 1.0 //-1
        }else{
            //walk right
            multiplierForDirection = -1.0 //1
        }
        
        person.xScale = fabs(person.xScale) * multiplierForDirection
        
        
        if (person.action(forKey: "personMoving") != nil){
            //stop just the moving to a new location, but leave the walking legs running
            person.removeAction(forKey: "personMoving")
        }
        if(person.action(forKey: "walkingInPlacePerson") == nil){
            //if legs are not moving go ahead and start them
            walkingPerson()
        }
        
        let moveAction = (SKAction.move(to: location, duration: (Double(moveDuration))))
        
        let doneAction = (SKAction.run({
            print("Animation complete")
            self.personMovedEnded()
        }))
        
        let moveActionWithDone = (SKAction.sequence([moveAction, doneAction]))
        person.run(moveActionWithDone, withKey: "personMoving")
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
    }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let groundCategory: UInt32 = 0x1 << 0
    static let Person    : UInt32 = 0b1       // 1
    static let Box       : UInt32 = 0b10      // 2
}
