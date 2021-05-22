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
    @Published var material:SCNMaterial = SCNMaterial.example
    @Published var materials:[SCNMaterial] = [SCNMaterial.example]
    
    @Published var baseColor:Color = Color.blue
    
    init() {
        let scene = SCNScene()
        self.scene = scene
        
        self.node = SCNNode(geometry: SCNSphere(radius: 1))
        
        scene.background.contents = "Scenes.scnassets/HDRI/\(sceneBackground.content)"
        scene.lightingEnvironment.contents = "Scenes.scnassets/HDRI/\(sceneBackground.content)"
        
        // self.material = makeMaterial()
        
        let node = SCNNode(geometry: geometry)
        geometry.insertMaterial(material, at: 0)
        
        scene.rootNode.addChildNode(node)
    }
    
    /// Loads a different Geometry
    func loadPanel() {
        
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Choose a scene file.";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.isAccessoryViewDisclosed = true
        dialog.allowedFileTypes = ["scn", "dae", "usz", "obj", "stl"]
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let url = dialog.url, url.isFileURL {
                print("Loaded: \(url.absoluteString)")
                self.loadScene(url: url)
            }
        }
        
    }
    
    /// Loads a Scene chosen in the load Panel
    func loadScene(url:URL) {
        if let scene = try? SCNScene(url: url, options: [:]) {
            print("Scene in")
            // Recursively get Materials
            let root = scene.rootNode
//            var stack:[SCNNode] = [root]
            if let node = root.childNodes.first(where: { $0.geometry != nil })?.clone() {
                //                    nodes.append(node)
                print("Node in")
                
                if let geometry = node.geometry {
                    print("Geom")
                    self.geometry = geometry
                    self.materials = geometry.materials
                    if let bmat = geometry.materials.first {
                        print("material in")
                        if bmat.lightingModel != .physicallyBased {
                            bmat.lightingModel = .physicallyBased
                        }
                        self.material = bmat
                    }
                    
                    self.scene.rootNode.childNodes.first(where: { $0.geometry != nil })?.removeFromParentNode()
                    self.scene.rootNode.addChildNode(node)
                    return
                }
//                stack.append(contentsOf: node.childNodes)
            }
        } else {
            print("Could not load")
        }
    }
    
    /// Changes the geometry displayed
    func updateNode() {
        
        scene.rootNode.childNodes.first?.removeFromParentNode()
        
        if self.geometry == nil { self.geometry = geoOption.geometry }
        
        self.geometry.insertMaterial(material, at: 0)
        
        let newNode = SCNNode(geometry: geometry)
        
        self.node = newNode
        
        scene.rootNode.addChildNode(newNode)
    }
    
    func updateGeometryMaterial(material:SCNMaterial) {
        print("updating geometry material \(material.name ?? "noname")")
        self.geometry.firstMaterial = material
    }
    
    func changedColor() {
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
