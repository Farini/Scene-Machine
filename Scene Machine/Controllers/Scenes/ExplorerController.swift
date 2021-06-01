//
//  ExplorerController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 6/1/21.
//

import SceneKit
import Cocoa
import SwiftUI

class ExplorerController:ObservableObject {
    
    @Published var scene:SCNScene
    @Published var hero:SCNNode
    
    @Published var turnData:String = "♦︎"
    @Published var renderData:String = "0"
    
    func reportStatus(string:String) {
        self.turnData = string
    }
    
    func reportRenderer(string:String) {
        self.renderData = string
    }
    
    // methods
    func turnRight() {
        var turnDescriptor:String = "→ "
        
        hero.transform = hero.presentation.transform
        
        let degrees = hero.eulerAngles.y.toDegrees()
        turnDescriptor += String(format: "Deg.: %.2f", arguments: [Double(degrees)])
        
        let rotate = SCNAction.rotateBy(x: 0, y: -0.1, z: 0, duration: 0.1)
        hero.runAction(rotate)
        
//        degrees -= 5
        hero.eulerAngles.y = degrees.toRadians()
        turnDescriptor += String(format: "Deg.: %.2f R.: %.2f", arguments: [Double(degrees), Double(degrees.toRadians())])
        turnData = turnDescriptor
    }
    
    func turnLeft() {
        var turnDescriptor:String = "← "
        
        hero.transform = hero.presentation.transform
        var degrees = hero.eulerAngles.y.toDegrees()
        turnDescriptor += String(format: "Deg.: %.2f", arguments: [Double(degrees)])
        
        var rd:CGFloat = 0
        if (85...90).contains(hero.presentation.eulerAngles.y.toDegrees()) {
            rd = hero.eulerAngles.y - CGFloat(5).toRadians()
        } else {
            rd = hero.eulerAngles.y + CGFloat(5).toRadians()
        }
         
        
        degrees += 5
        
    
        hero.eulerAngles.y = rd //degrees.toRadians()
        turnDescriptor += String(format: "Deg.: %.2f R.: %.2f", arguments: [Double(degrees), Double(degrees.toRadians())])
        turnData = turnDescriptor
    }
    
    // Init
    
    init() {
        let mainScene = ExplorerController.makeScene()
        self.scene = mainScene
        self.hero = mainScene.rootNode.childNode(withName: "protagonist", recursively: false)!
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
        camNode.position = SCNVector3(0, 0.2, 2)
        
        // --- Constraints
        
        let distanceConstraint = SCNDistanceConstraint(target: mainCharacter)
        distanceConstraint.maximumDistance = 4
        distanceConstraint.minimumDistance = 2
        
        let replicatorConstraint = SCNReplicatorConstraint(target: mainCharacter)
        // Replicates the position, scale and rotation
        replicatorConstraint.positionOffset = SCNVector3(0, 0.25, 3)
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
        
        return boxNode
    }
    
    // Scene deco
    class func createSceneDeco(input:SCNScene) {
        
        for idx in 0...30 {
            let materialColor = idx % 2 == 0 ? NSColor.orange:NSColor.red
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = materialColor
            
            let sphere = SCNSphere(radius: 0.2)
            sphere.firstMaterial = material
            let sNode = SCNNode(geometry: sphere)
            // sNode.position = SCNVector3(0, 1, -5)
            
            
            let spherePos = SCNVector3(idx % 2 == 0 ? 0.5:-0.5, 1.5, Float(idx * -4))
            sNode.position = spherePos
            
            input.rootNode.addChildNode(sNode)
        }
        
        for idx in 0...30 {
            let materialColor = idx % 2 == 0 ? NSColor.blue:NSColor.systemBlue
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = materialColor
            
            let sphere = SCNSphere(radius: 0.2)
            sphere.firstMaterial = material
            let sNode = SCNNode(geometry: sphere)
            // sNode.position = SCNVector3(0, 1, -5)
            
            
            let spherePos = SCNVector3(idx % 2 == 0 ? 1:3, 1.5, Float(idx * -5))
            sNode.position = spherePos
            
            input.rootNode.addChildNode(sNode)
        }
        
        for idx in -15...15 {
            let materialColor = idx % 2 == 0 ? NSColor.green:NSColor.yellow
            
            let material = SCNMaterial()
            material.lightingModel = .physicallyBased
            material.diffuse.contents = materialColor
            
            let sphere = SCNSphere(radius: 0.2)
            sphere.firstMaterial = material
            let sNode = SCNNode(geometry: sphere)
            // sNode.position = SCNVector3(0, 1, -5)
            
            
            let spherePos = SCNVector3(Float(idx * 5),  1.5, idx % 2 == 0 ? 1:3)
            sNode.position = spherePos
            
            input.rootNode.addChildNode(sNode)
        }
        
    }
    
    // Floor
    // Lights, cameras, etc.
    
}
