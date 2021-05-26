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
    @Published var dbMaterial:SceneMaterial?
    
    @Published var materials:[SCNMaterial] = [SCNMaterial.example]
    @Published var dbMaterials:[SceneMaterial] = []
    
//    @Published var baseColor:Color = Color.blue
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
        
        if let snapImage:NSImage = UVMapView(size: TextureSize.medium.size, image: nil, uvPoints: uvPoints).snapShot(uvSize: CGSize(width: 1024, height: 1024)) {
            
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
    
    func didSelectDBMaterial(dbMaterial:SceneMaterial) {
        let scnMaterial = dbMaterial.make()
        self.material = scnMaterial
        self.dbMaterial = dbMaterial
        self.updateGeometryMaterial(material: scnMaterial)
        
    }
    
    // MARK: - Updating
    
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
    
    /// Called after strokes on canvas
    func updateUVImage(image:NSImage) {
        print("Updating uv image")
        
        switch materialMode {
            case .Diffuse:
                // Draw the image on geometry
                self.geometry.firstMaterial?.diffuse.contents = image
                
                // Update material with image
                self.material.diffuse.contents = image
                self.material.diffuse.wrapS = .clampToBorder
                self.material.diffuse.wrapT = .clampToBorder
            case .Roughness:
                self.geometry.firstMaterial?.roughness.contents = image
                self.material.roughness.contents = image
            case .Normal:
                self.geometry.firstMaterial?.normal.contents = image
                self.material.normal.contents = image
            case .AO:
                self.geometry.firstMaterial?.ambientOcclusion.contents = image
                self.material.ambientOcclusion.contents = image
            case .Emission:
                self.geometry.firstMaterial?.emission.contents = image
                self.material.emission.contents = image
        }
        
        // Decide if save material
        if let dbMaterial = dbMaterial {
            
        }
    }
    
    
    
    // MARK: - Saving
    
    func saveMaterialToDatabase() {
        let savingMaterial:SceneMaterial = SceneMaterial(material: material)
        LocalDatabase.shared.saveMaterial(material: savingMaterial)
    }
    
    func changeBackground() {
        scene.background.contents = "Scenes.scnassets/HDRI/\(sceneBackground.content)"
        scene.lightingEnvironment.contents = "Scenes.scnassets/HDRI/\(sceneBackground.content)"
    }
    
//    func makeMaterial() -> SCNMaterial {
//
//        let material = SCNMaterial()
//
//        material.name = "BaseMaterial"
//        material.lightingModel = .physicallyBased
//        material.diffuse.contents = baseColor
//        material.roughness.contents = 0.4
//
//        return material
//    }
}
