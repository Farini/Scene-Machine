//
//  MaterialMachineController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/20/21.
//

import SwiftUI
import Cocoa
import SceneKit

/// Geometries available for the View
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

/// Diffuse, Roughness, Emission, etc.
enum MaterialMode:String, CaseIterable {
    case Diffuse, Roughness, Emission, Normal, AO
}

class MaterialMachineController:ObservableObject {
    
    @Published var scene:SCNScene
    @Published var sceneBackground:AppBackgrounds = AppBackgrounds.Lava2
    
    @Published var node:SCNNode
    @Published var geometry:SCNGeometry = SCNSphere(radius: 1)
    @Published var geoOption:MMGeometryOption = .Sphere
    
    /// The mode map selected
    @Published var materialMode:MaterialMode = .Diffuse
    @Published var material:SCNMaterial = SCNMaterial.example
    
    @Published var materials:[SCNMaterial] = [SCNMaterial.example]
    @Published var dbMaterials:[SceneMaterial] = []
    
    @Published var baseColor:Color = Color.blue
    @Published var uvImage:NSImage?
    
    init() {
        
        let scene = SCNScene()
        self.scene = scene
        
        self.node = SCNNode(geometry: SCNSphere(radius: 1))
        
        scene.background.contents = "Scenes.scnassets/HDRI/\(sceneBackground.content)"
        scene.lightingEnvironment.contents = "Scenes.scnassets/HDRI/\(sceneBackground.content)"
        
        let node = SCNNode(geometry: geometry)
        geometry.insertMaterial(material, at: 0)
        
        scene.rootNode.addChildNode(node)
        
        let dbmat = LocalDatabase.shared.materials
        self.dbMaterials = dbmat
    }
    
    // MARK: - Loading
    
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
        
        guard let scene = try? SCNScene(url: url, options: [:]),
              let node = scene.rootNode.childNodes.first(where: { $0.geometry != nil })?.clone(),
              let geometry = node.geometry,
              let geoSource = geometry.sources.first(where: { $0.semantic == .texcoord }) else {
            print("Missing data to create a UV Texture")
            return
        }
        
        let uvPoints:[CGPoint] = geoSource.uv
        
        let ctrl = SceneMachineController()
        
        if let snapImage:NSImage = UVMapStack(controller: ctrl, geometry: geometry, points: uvPoints).uvTexture.snapShot(uvSize: CGSize(width: 2048, height: 2048)) {
            // UVShape(uv: uvPoints).snapShot(uvSize: CGSize(width: 1024, height: 1024)) {
            // UVMapStack(controller: ctrl, geometry: geometry, points: uvPoints).uvTexture.snapShot(uvSize: CGSize(width: 2048, height: 2104)) {
            
            print("Got Snapshot Image of UV. Size: \(snapImage.size)")
            self.uvImage = snapImage
            
            if let bmat = geometry.materials.first {
                print("Updating Materials")
                if bmat.lightingModel != .physicallyBased {
                    bmat.lightingModel = .physicallyBased
                }
                bmat.diffuse.contents = snapImage
                self.material = bmat
            }
        }
        
        self.geometry = geometry
        self.materials = geometry.materials
        
        
        
        print("Updating Geometry in View")
        self.scene.rootNode.childNodes.first(where: { $0.geometry != nil })?.removeFromParentNode()
        self.scene.rootNode.addChildNode(node)
    }
    
    /// Changes the geometry displayed to one of the default ones
    func updateNode() {
        
        scene.rootNode.childNodes.first?.removeFromParentNode()
        
        self.geometry = geoOption.geometry
        
        self.geometry.insertMaterial(material, at: 0)
        
        let newNode = SCNNode(geometry: geometry)
        
        self.node = newNode
        
        scene.rootNode.addChildNode(newNode)
    }
    
    /// Updates the Geometry's material (and the drawing, if any)
    func updateGeometryMaterial(material:SCNMaterial) {
        print("updating geometry material \(material.name ?? "noname")")
        self.geometry.firstMaterial = material
    }
    
    func updateUVImage(image:NSImage) {
        print("Updating uv image")
        
        // Draw the image on geometry
        self.geometry.firstMaterial?.diffuse.contents = image
        
        
        
        // Update material with image
        self.material.diffuse.contents = image
        self.material.diffuse.wrapS = .clampToBorder
        self.material.diffuse.wrapT = .clampToBorder
//        self.material.diffuse.borderColor
        
//        let matCopy = self.material.copy() as! SCNMaterial
//        matCopy.diffuse.contents = image
//        self.material = matCopy
        
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
