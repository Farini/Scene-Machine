//
//  SceneMachineController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/27/21.
//

import Foundation
import SceneKit

class SceneMachineController:ObservableObject {
    
    @Published var scene:SCNScene
    @Published var materials:[SCNMaterial] = []
    @Published var nodes:[SCNNode] = []
    @Published var geometries:[SCNGeometry] = []
    
    init() {
        self.scene = SCNScene(named: "Scenes.scnassets/SMScene.scn")!
        
        // Recursively get Materials
        let root = scene.rootNode
        var stack:[SCNNode] = [root]
        while !stack.isEmpty {
            if let node = stack.first {
                nodes.append(node)
                if let geometry = node.geometry {
                    self.geometries.append(geometry)
                    for material in geometry.materials {
                        self.materials.append(material)
                    }
                }
                stack.append(contentsOf: node.childNodes)
            }
            stack.removeFirst()
        }
    }
    
    // uv
    
    func getUVPoints(from source:SCNGeometrySource) -> [CGPoint] {
        let uv:[CGPoint] = source.uv
        return uv
    }
    
    // MARK: - Loadind
    
    func loadPanel() {
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose a file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.isAccessoryViewDisclosed = true
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let url = dialog.url, url.isFileURL {
                print("Loaded: \(url.absoluteString)")
                self.loadScene(url: url)
            }
        }
        
    }
    
    func loadScene(url:URL) {
        if let scene = try? SCNScene(url: url, options: [SCNSceneSource.LoadingOption.convertToYUp:NSNumber(booleanLiteral: true)]) {
            print("Scene in")
            // Recursively get Materials
            let root = scene.rootNode
            var stack:[SCNNode] = [root]
            while !stack.isEmpty {
                if let node = stack.first {
                    nodes.append(node)
                    if let geometry = node.geometry {
                        self.geometries.append(geometry)
                        for material in geometry.materials {
                            self.materials.append(material)
                        }
                        self.scene.rootNode.addChildNode(node)
                    }
                    stack.append(contentsOf: node.childNodes)
                }
                stack.removeFirst()
            }
        }
    }
    
//    static func makeDefaultScene() -> SCNScene {
//        let scene = SCNScene()
//        let floor = SCNFloor()
//        let material = SCNMaterial()
//        material.name = "FloorMaterial"
//        material.lightingModel = .physicallyBased
//        material.diffuse.contents = NSColor.blue
//        material.isDoubleSided = true
//        material.roughness.contents = 0.1
//        floor.insertMaterial(material, at: 0)
//        let floorNode = SCNNode(geometry: floor)
//        scene.rootNode.addChildNode(floorNode)
//        return scene
//    }
}

//extension SceneMachineController:SCNSceneRendererDelegate {
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        // Updates
//    }
//    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
//        // Animated
//    }
//    func renderer(_ renderer: SCNSceneRenderer, didApplyConstraintsAtTime time: TimeInterval) {
//        // Constraints
//    }
//    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
//        // physics
//    }
//    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
//        // Did render
//    }
//
//}
extension SCNGeometry: Identifiable {
    static func ==(lhs:SCNGeometry, rhs:SCNGeometry) -> Bool {
        return lhs.isEqual(rhs)
    }
}
extension SCNMaterial: Identifiable {
    static func ==(lhs:SCNMaterial, rhs:SCNMaterial) -> Bool {
        return lhs.isEqual(rhs)
    }
}
