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
import CoreHaptics

class ExplorerController:ObservableObject {
    
    @Published var scene:SCNScene
    @Published var hero:SCNNode
    
    @Published var turnData:String = "♦︎"
    @Published var renderData:String = "0"
    @Published var posData:String = ""
    
    // MARK: - UI Indicators + Updates
    
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
    
    // MARK: - Init
    
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
        
        // Post init deco
        self.postInitDecoration()
    }
    
    /// Builds the Scene (Basics) to display
    class func makeScene() -> SCNScene {
        
        // Initialize the Scene
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
        
        // Constraints
        
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
    
    /// Main Character Node
    class func makeMainCharacter() -> SCNNode {
        
        let proScene:SCNNode = SCNScene(named: "Scenes.scnassets/Ship.scn")!.rootNode.childNode(withName: "protagonist", recursively: false)!
        
        return proScene
    }
    
    /// Loads Scene decoration on a background thread AFTER the view has loaded.
    func postInitDecoration() {
        
        DispatchQueue(label: "Scene loader").async {
            
            var rangeX:ClosedRange<Int> = 2...30
            var rangeZ:ClosedRange<Int> = -30...(-2)
            
            // var geometry:SCNGeometry = SCNSphere(radius: 0.2)
            
            // Material
            var materialColor:NSColor = .orange
            var materialRough:Double = 0.15
            
            var nodes:[SCNNode] = []
            
            for px in rangeX {
                for pz in rangeZ {
                    
                    let position = SCNVector3(5 * px, 2, 5 * pz)
//                    let materialColor = NSColor.orange
                    
                    let material = SCNMaterial()
                    material.lightingModel = .physicallyBased
                    material.diffuse.contents = materialColor
                    material.roughness.contents = materialRough
                    
                    let sphere = SCNSphere(radius: 0.2)
                    sphere.firstMaterial = material
                    
                    let sNode = SCNNode(geometry: sphere)
                    
                    sNode.position = position
                    
                    // input.rootNode.addChildNode(sNode)
                    nodes.append(sNode)
                    
                }
            }
            
            // Part2
            materialColor = .systemTeal
            materialRough = 0.5
            
            rangeZ = 2...30
            
            for px in rangeX {
                for pz in rangeZ {
                    let position = SCNVector3(5 * px, 2, 5 * pz)
                    //                    let materialColor = NSColor.orange
                    
                    let material = SCNMaterial()
                    material.lightingModel = .physicallyBased
                    material.diffuse.contents = materialColor
                    material.roughness.contents = materialRough
                    
                    let sphere = SCNSphere(radius: 0.2)
                    sphere.firstMaterial = material
                    
                    let sNode = SCNNode(geometry: sphere)
                    
                    sNode.position = position
                    
                    // input.rootNode.addChildNode(sNode)
                    nodes.append(sNode)
                }
            }
            
            // Part 3
            
            materialColor = .systemRed
            materialRough = 0.8
            
            rangeZ = -30...(-1)
            rangeX = -30...(-1)
            
            for px in rangeX {
                for pz in rangeZ {
                    let position = SCNVector3(5 * px, 2, 5 * pz)
                    //                    let materialColor = NSColor.orange
                    
                    let material = SCNMaterial()
                    material.lightingModel = .physicallyBased
                    material.diffuse.contents = materialColor
                    material.roughness.contents = materialRough
                    
                    let sphere = SCNSphere(radius: 0.2)
                    sphere.firstMaterial = material
                    
                    let sNode = SCNNode(geometry: sphere)
                    
                    sNode.position = position
                    
                    // input.rootNode.addChildNode(sNode)
                    nodes.append(sNode)
                }
            }
            
            // Part 4
            
            materialColor = .systemBlue
            materialRough = 0.1
            
            rangeZ = 1...30
            rangeX = -30...(-1)
            
            for px in rangeX {
                for pz in rangeZ {
                    let position = SCNVector3(5 * px, 2, 5 * pz)
                    //                    let materialColor = NSColor.orange
                    
                    let material = SCNMaterial()
                    material.lightingModel = .physicallyBased
                    material.diffuse.contents = materialColor
                    material.roughness.contents = materialRough
                    
                    let sphere = SCNSphere(radius: 0.2)
                    sphere.firstMaterial = material
                    
                    let sNode = SCNNode(geometry: sphere)
                    
                    sNode.position = position
                    
                    // input.rootNode.addChildNode(sNode)
                    nodes.append(sNode)
                }
            }
            
            // Posts
            
            rangeZ = (-10)...30
            
            for pz in rangeZ {
                let position = SCNVector3(0, 0, 10 * pz)
                
                let post = AppGeometries.PostWithLamp.getGeometry()!
                
                post.position = position
                
                // input.rootNode.addChildNode(sNode)
                nodes.append(post)
            }
            
            DispatchQueue.main.async {
                for node in nodes {
                    self.scene.rootNode.addChildNode(node)
                }
            }
            
        }
        
    }
    
    // MARK: - Controller
    
    @objc
    func handleControllerDidConnect(_ notification: Notification) {
        guard let gameController = notification.object as? GCController else {
            return
        }
        
        print("Connecting controller...")
        self.turnData = "Controller connected"
        registerGameController(gameController)
        
        // Larn Haptics to implement
        // HapticUtility.initHapticsFor(controller: gameController)
        
    }
    
    @objc
    func handleControllerDidDisconnect(_ notification: Notification) {
        print("Disconnecting controller...")
    }
    
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
            guard let strongController = weakController else {
                return
            }
            strongController.hitBreaks()
        }
        
        rightTrigger?.pressedChangedHandler = buttonB?.valueChangedHandler
    }
    
}
