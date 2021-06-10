//
//  ExplorerController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 6/1/21.
//

import SceneKit
import Cocoa
import SwiftUI
import GameController

class ExplorerController:ObservableObject {
    
    @Published var scene:SCNScene
    @Published var hero:SCNNode
    
    @Published var turnData:String = "♦︎"
    @Published var renderData:String = "0"
    @Published var posData:String = ""
    
    func reportStatus(string:String) {
        self.turnData = string
    }
    
    func reportRenderer(string:String) {
        DispatchQueue.main.async {
            self.renderData = string
        }
        
    }
    
    func reportPosition(string:String) {
        DispatchQueue.main.async {
            self.posData = string
        }
        
    }
    
    // MARK: - Moving
    
    func goForward() {
        let force = simd_make_float4(0, 0, 2, 0)
//        let a = simd_mul
        let rotatedForce = simd_mul(hero.simdTransform, force)
        let vectorForce = SCNVector3(x:CGFloat(rotatedForce.x), y:CGFloat(rotatedForce.y), z:CGFloat(rotatedForce.z))
        
        hero.physicsBody!.applyForce(vectorForce, asImpulse: true)
    }
    
    func hitBreaks() {
        
        let v = hero.simdTransform //.velocity ?? SCNVector3(0, 0, 0)
        print("Breaking at speed: \(v)")
        /*
         simd_float4x4([
         Position
         [-0.23206632, 0.011173804, -0.97247446, 0.0],
         Rotation
         [-0.04701464, 0.9985666, 0.022692937, 0.0],
         Scale
         [0.971394, 0.05098994, -0.23122263, 0.0],
         [-1.1025246, 0.046561405, -87.90251, 1.0]
         ])
         // ----
         [[0.99971706, 0.0054734186, -0.014391317, 0.0],
         [-0.0059202965, 0.9994374, -0.031149484, 0.0],
         [0.014213592, 0.031227773, 0.9992479, 0.0],
         [0.5451004, 0.03991383, 91.398224, 1.0]]
         */
        let force = simd_make_float4(0, 0, -2, 0)
        let rotatedForce = simd_mul(hero.simdTransform, force)
        let vectorForce = SCNVector3(x:CGFloat(rotatedForce.x), y:CGFloat(rotatedForce.y), z:CGFloat(rotatedForce.z))
        
        hero.physicsBody!.applyForce(vectorForce, asImpulse: false)
    }
    
    func turnLeft() {
        var turnDescriptor:String = "← "
        
        let force = simd_make_float4(0, 0, 1, 0)
        
        let rotatedForce = simd_mul(hero.simdTransform, force)
        let vectorForce = SCNVector3(x:CGFloat(rotatedForce.x), y:CGFloat(rotatedForce.y), z:CGFloat(rotatedForce.z))
        
        let degrees = hero.presentation.eulerAngles.y.toDegrees()
        
        turnDescriptor += String(format: "Deg.: %.2f", arguments: [Double(degrees)])
        
        let pt = hero.convertVector(SCNVector3(-1, 0, 0), to: hero.parent!)
        hero.physicsBody!.applyForce(vectorForce, at: pt, asImpulse: true) //applyForce(vectorForce, asImpulse: true)
        
        hero.transform = hero.presentation.transform
        turnData = turnDescriptor
    }
    
    // methods
    func turnRight() {
        var turnDescriptor:String = "→ "
        
        let force = simd_make_float4(0, 0, 1, 0)
        
        let rotatedForce = simd_mul(hero.simdTransform, force)
        let vectorForce = SCNVector3(x:CGFloat(rotatedForce.x), y:CGFloat(rotatedForce.y), z:CGFloat(rotatedForce.z))
        
        // let angle = hero.presentation.eulerAngles
        let degrees = hero.presentation.eulerAngles.y.toDegrees()
        
        turnDescriptor += String(format: "Deg.: %.2f", arguments: [Double(degrees)])
        
        let pt = hero.convertVector(SCNVector3(1, 0, 0), to: hero.parent!)
        hero.physicsBody!.applyForce(vectorForce, at: pt, asImpulse: true) //applyForce(vectorForce, asImpulse: true)
        
        hero.transform = hero.presentation.transform
        
    }
    
    
    
    // Init
    
    init() {
        let mainScene = ExplorerController.makeScene()
        self.scene = mainScene
        self.hero = mainScene.rootNode.childNode(withName: "protagonist", recursively: false)!
        
        GCController.startWirelessControllerDiscovery {
            self.turnData = "Controller ???"
        }
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleControllerDidConnect),
            name: NSNotification.Name.GCControllerDidBecomeCurrent, object: nil)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleControllerDidDisconnect),
            name: NSNotification.Name.GCControllerDidStopBeingCurrent, object: nil)
    }
    
    // MARK: - Controller
    
    @objc
    func handleControllerDidConnect(_ notification: Notification) {
        guard let gameController = notification.object as? GCController else {
            return
        }
//        unregisterGameController()
        self.turnData = "Controller ?connected?"
        registerGameController(gameController)
//        HapticUtility.initHapticsFor(controller: gameController)
        
//        self.overlay?.showHints()
    }
    @objc
    func handleControllerDidDisconnect(_ notification: Notification) {
//        unregisterGameController()
//
//        guard let gameController = notification.object as? GCController else {
//            return
//        }
//        HapticUtility.deinitHapticsFor(controller: gameController)
    }
    // Game controller
    private var gamePadCurrent: GCController?
    private var gamePadLeft: GCControllerDirectionPad?
    private var gamePadRight: GCControllerDirectionPad?
    
    func registerGameController(_ gameController: GCController) {
        
        var buttonA: GCControllerButtonInput?
        var buttonB: GCControllerButtonInput?
        var rightTrigger: GCControllerButtonInput?
        
        weak var weakController = self
        
        if let gamepad = gameController.extendedGamepad {
            self.gamePadLeft = gamepad.leftThumbstick
            self.gamePadRight = gamepad.rightThumbstick
            buttonA = gamepad.buttonA
            buttonB = gamepad.buttonB
            rightTrigger = gamepad.rightTrigger
        } else if let gamepad = gameController.microGamepad {
            self.gamePadLeft = gamepad.dpad
            buttonA = gamepad.buttonA
            buttonB = gamepad.buttonX
        }
        
        buttonA?.valueChangedHandler = {(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            guard let strongController = weakController else {
                return
            }
            strongController.goForward()
        }
        
        gamePadLeft?.valueChangedHandler = { (_ controllerDirection:GCControllerDirectionPad, xValue:Float, yValue:Float) -> Void in
            if xValue > 0 && xValue > yValue {
                self.turnRight()
            } else if xValue < 0 && xValue < yValue {
                self.turnLeft()
            }
        }
        
        buttonB?.valueChangedHandler = {(_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
//            guard let strongController = weakController else {
//                return
//            }
            // breaks
//            strongController.controllerAttack()
        }
        
        rightTrigger?.pressedChangedHandler = buttonB?.valueChangedHandler
        
        
    }
    
    class func makeScene() -> SCNScene {
        
        let scene = SCNScene()
        scene.background.contents = "Scenes.scnassets/HDRI/\(AppBackgrounds.CityDay.content)"
        scene.lightingEnvironment.contents = "Scenes.scnassets/HDRI/\(AppBackgrounds.CityDay.content)"
        
        let mainCharacter = ExplorerController.makeMainCharacter()
        let bullseye = mainCharacter.childNode(withName: "bullseye", recursively: false)!
        
        // Cam
        let camNode = SCNNode()
        camNode.name = "camnode"
        let camera = SCNCamera()
        camera.zNear = 0.1
        camera.zFar = 200
        
        camNode.camera = camera
        camNode.position = SCNVector3(0, 3, -4)
        
        // --- Constraints
        
        let distanceConstraint = SCNDistanceConstraint(target: mainCharacter)
        distanceConstraint.maximumDistance = 4
        distanceConstraint.minimumDistance = 2
        
        let replicatorConstraint = SCNReplicatorConstraint(target: mainCharacter)
        // Replicates the position, scale and rotation
        replicatorConstraint.positionOffset = SCNVector3(0, 2.75, -4)
        replicatorConstraint.replicatesOrientation = false
        replicatorConstraint.influenceFactor = 0.05
        
        let lookAtConstraint = SCNLookAtConstraint(target: bullseye)
        lookAtConstraint.influenceFactor = 0.07
        lookAtConstraint.isGimbalLockEnabled = true
        
        let accelerationConstraint = SCNAccelerationConstraint()
        accelerationConstraint.maximumLinearAcceleration = 300.0
        
        camNode.constraints = [distanceConstraint, replicatorConstraint, lookAtConstraint, accelerationConstraint]
        
        // Scene Deco
        // Spheres
        self.createSceneDeco(input: scene)
        
        // FLOOR
        let floor = SCNFloor()
        let floorphy = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: floor, options: nil))
        let floorNode = SCNNode(geometry: floor)
        floorNode.physicsBody = floorphy
        let bMao = SCNMaterial()
        bMao.lightingModel = .physicallyBased
        bMao.diffuse.contents = NSColor.blue
        floor.insertMaterial(bMao, at: 0)
        
        scene.rootNode.addChildNode(floorNode)
        scene.rootNode.addChildNode(mainCharacter)
        scene.rootNode.addChildNode(camNode)
        
        
        return scene
    }
    
    // Main Character
    class func makeMainCharacter() -> SCNNode {
        
        /*
        // Geometry
        let geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        
        // Material
        let bMaterial = SCNMaterial.example
        bMaterial.lightingModel = .physicallyBased
        bMaterial.diffuse.contents = NSColor(calibratedWhite: 0.1, alpha: 1)
        bMaterial.roughness.contents = 0.1
        bMaterial.metalness.contents = 0.85
        geometry.insertMaterial(bMaterial, at: 0)
        
        // Physics
        let boxBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: geometry, options: nil))
//        boxBody.angularVelocityFactor = SCNVector3(0, 0, 0)
        
        // Node
        let boxNode = SCNNode(geometry: geometry)
        boxNode.name = "protagonist"
        boxNode.physicsBody = boxBody
        boxNode.position = SCNVector3(0, 1, 0)
        
        let boxChild = SCNNode()
        boxChild.name = "bullseye"
        let bcg = SCNSphere(radius: 0.2)
        let geoMaterial = SCNMaterial()
        geoMaterial.lightingModel = .physicallyBased
        geoMaterial.diffuse.contents = NSColor.white.withAlphaComponent(0.2)
        bcg.insertMaterial(geoMaterial, at: 0)
        
        boxChild.geometry = bcg
        boxChild.position = SCNVector3(0, 0.5, -1)
        boxNode.addChildNode(boxChild)
        */
        let proScene:SCNNode = SCNScene(named: "Scenes.scnassets/Ship.scn")!.rootNode.childNode(withName: "protagonist", recursively: false)!
        
        return proScene//boxNode
    }
    
    // Scene deco
    class func createSceneDeco(input:SCNScene) {
        
        for orangeX in 0...30 {
            
            for orangeZ in 0...30 {
                
                let position = SCNVector3(5 * orangeX, 2, 5 * orangeZ)
                let materialColor = NSColor.orange
                
                let material = SCNMaterial()
                material.lightingModel = .physicallyBased
                material.diffuse.contents = materialColor
                
                let sphere = SCNSphere(radius: 0.2)
                sphere.firstMaterial = material
                
                let sNode = SCNNode(geometry: sphere)
                
                sNode.position = position
                
                input.rootNode.addChildNode(sNode)
            }
        }
        
        for redX in -30...0 {
            
            for redZ in 0...30 {
                
                let position = SCNVector3(5 * redX, 2, 5 * redZ)
                let materialColor = NSColor.red
                
                let material = SCNMaterial()
                material.lightingModel = .physicallyBased
                material.diffuse.contents = materialColor
                
                let sphere = SCNSphere(radius: 0.2)
                sphere.firstMaterial = material
                
                let sNode = SCNNode(geometry: sphere)
                
                sNode.position = position
                
                input.rootNode.addChildNode(sNode)
            }
        }
        
        for bluX in -30...0 {
            
            for bluZ in -30...0 {
                
                let position = SCNVector3(5 * bluX, 2, 5 * bluZ)
                let materialColor = NSColor.blue
                
                let material = SCNMaterial()
                material.lightingModel = .physicallyBased
                material.diffuse.contents = materialColor
                
                let sphere = SCNSphere(radius: 0.2)
                sphere.firstMaterial = material
                
                let sNode = SCNNode(geometry: sphere)
                
                sNode.position = position
                
                input.rootNode.addChildNode(sNode)
            }
        }
        
        for greenX in 0...30 {
            
            for greenZ in -30...0 {
                
                let position = SCNVector3(5 * greenX, 2, 5 * greenZ)
                let materialColor = NSColor.green
                
                let material = SCNMaterial()
                material.lightingModel = .physicallyBased
                material.diffuse.contents = materialColor
                
                let sphere = SCNSphere(radius: 0.2)
                sphere.firstMaterial = material
                
                let sNode = SCNNode(geometry: sphere)
                
                sNode.position = position
                
                input.rootNode.addChildNode(sNode)
            }
        }
        
        
        /*
         Additional....
         Basic: Sphere, Box, Cone, Plane
         + EggTree, SQTree, Building
         + Statue, Post, Car
         + Text
         */
        
        // Posts
        for idx in 1...50 {
            if let post = AppGeometries.PostWithLamp.getGeometry() {
                post.position = SCNVector3(idx * 12, 0, idx * 4)
                post.scale = SCNVector3(5, 5, 5)
                input.rootNode.addChildNode(post)
            }
        }
        
        // Statues
        for idx in 1...20 {
            // Spread
            let prep:Double = idx > 10 ? Double(idx) * -1:Double(idx)
            if let statue = AppGeometries.LibertyLady.getGeometry() {
                statue.position = SCNVector3(prep * 18.0, 0.0, Double(idx) * (Bool.random() ? 4.0:-3.5))
                input.rootNode.addChildNode(statue)
                let body = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: statue, options: nil))
                statue.physicsBody = body
            }
        }
        
        
    }
    
    // Floor
    // Lights, cameras, etc.
    
}
