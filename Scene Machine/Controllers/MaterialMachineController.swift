//
//  MaterialMachineController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/20/21.
//

import SwiftUI
import Cocoa
import SceneKit

enum MMGeometryOption:String, CaseIterable {
    case Sphere
    case Box
    case Cylinder
    
    var geometry:SCNGeometry {
        switch self {
            case .Sphere: return SCNSphere(radius: 1)
            case .Box: return SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
            case .Cylinder: return SCNCylinder(radius: 1, height: 1)
        }
    }
}

class MaterialMachineController:ObservableObject {
    
    @Published var scene:SCNScene
    @Published var sceneBackground:AppBackgrounds = AppBackgrounds.Lava2
    
    @Published var geometry:SCNGeometry = SCNSphere(radius: 1)
    @Published var geoOption:MMGeometryOption = .Sphere
    
    @Published var node:SCNNode
    @Published var material:SCNMaterial = SCNMaterial()
    @Published var baseColor:Color = Color.blue
    
    init() {
        let scene = SCNScene()
        self.scene = scene
        
        self.node = SCNNode(geometry: SCNSphere(radius: 1))
        
        scene.background.contents = "Scenes.scnassets/HDRI/\(sceneBackground.content)"
        scene.lightingEnvironment.contents = "Scenes.scnassets/HDRI/\(sceneBackground.content)"
        
        self.material = makeMaterial()
        
        let node = SCNNode(geometry: geometry)
        geometry.insertMaterial(material, at: 0)
        
        scene.rootNode.addChildNode(node)
    }
    
    func updateNode() {
        
        scene.rootNode.childNodes.first?.removeFromParentNode()
        
        self.geometry = geoOption.geometry
        
//        if let prevColor = material.diffuse.contents as? Color {
//            print("Previous: \(prevColor.description)")
//        self.material.diffuse.contents = baseColor
//        }
        
        self.geometry.insertMaterial(material, at: 0)
        
        let newNode = SCNNode(geometry: geometry)
        
        self.node = newNode
        
        scene.rootNode.addChildNode(newNode)
    }
    
    func changedColor() {
//        node.geometry?.firstMaterial?.diffuse.contents = baseColor
        material.diffuse.contents = NSColor(baseColor)
    }
    
    func changeBackground() {
        scene.background.contents = "Scenes.scnassets/HDRI/\(sceneBackground.content)"
        scene.lightingEnvironment.contents = "Scenes.scnassets/HDRI/\(sceneBackground.content)"
    }
    
    func makeMaterial() -> SCNMaterial {
        
        let material = SCNMaterial()
        
        material.name = "BaseMaterial"
        material.lightingModel = .physicallyBased
        material.diffuse.contents = baseColor
        material.roughness.contents = 0.4
        
        return material
    }
}
