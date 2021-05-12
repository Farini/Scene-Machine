//
//  SceneMachineController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/27/21.
//

import Foundation
import SceneKit
import MetalKit
import QuartzCore

/// The View on the Right side of the SplitView Scene Machine View
enum MachineRightView {
    case Empty
    case UVMap
    case ShapeEditor
}

class SceneMachineController:ObservableObject {
    
    @Published var scene:SCNScene
    @Published var materials:[SCNMaterial] = []
    @Published var nodes:[SCNNode] = []
    @Published var geometries:[SCNGeometry] = []
    
    @Published var selectedNode:SCNNode?
    @Published var isNodeOptionSelected:Bool = false
    
    @Published var rightView:MachineRightView = .Empty
    
    // Alert
    @Published var presentingTempAlert:Bool = false
    @Published var tempAlertMessage:String = ""
    
    var device: MTLDevice!
//    var outputTexture: MTLTexture?
    
    /// The default way to initialize `SceneMachine`
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
        
        device = MTLCreateSystemDefaultDevice()
    }
    
    /// Alternatively initialize `SceneMachine` with a given `SCNScene`
    init(scene:SCNScene) {
        self.scene = scene
        
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
        
        device = MTLCreateSystemDefaultDevice()
    }
    
    /// Called mostly when removing a Geometry, to update the scene, and remove the node of the geometry selected.
    func nodeTreeUpdate() {
        
        print("Removing a node....")
        
        self.nodes = []
        self.materials = []
        
        // Recursively get Materials
        let root = scene.rootNode
        var stack:[SCNNode] = [root]
        while !stack.isEmpty {
            
            if let node = stack.first {
//                print("First from stack")
                // nodes.append(node)
                var shouldAdd:Bool = false
                
                if let geometry = node.geometry {
//                    print("geometry")

                    if geometries.contains(geometry) {
//                        print("no remove")
                        nodes.append(node)
                        for material in geometry.materials {
                            //self.materials.append(material)
                            materials.append(material)
                            shouldAdd = true
                        }
                    } else {

                        print("Should remove: \(node.name ?? "na")")
                        let removable:[SCNNode] = scene.rootNode.childNodes { pNode, pBol in
                            return pNode.geometry == geometry
                        }
                        removable.first?.removeFromParentNode()
                    }
                } else {
                    print("no geometry")
                    stack.append(contentsOf: node.childNodes)
                }
                if shouldAdd {
                    stack.append(contentsOf: node.childNodes)
                }
            }
            stack.removeFirst()
        }
    }
    
    // MARK: - UV Map
    
    /// Get the points that compose the `UVMap`
    func inspectUVMap(geometry:SCNGeometry) -> [CGPoint]? {
        let sources = geometry.sources
        for src in sources {
            if src.semantic == .texcoord {
                let uvMap = src.uv
                if !uvMap.isEmpty {
                    return uvMap
                }
            } else if src.semantic == .boneIndices {
                let vv = src.componentsPerVector
                print("Bone indices Components per vector: \(vv)")
            } else if src.semantic == .boneWeights {
                let vv = src.componentsPerVector
                print("Bone indices Components per vector: \(vv)")
            } else if src.semantic == .vertex {
                let vertices = src.vertices
                print("All Vertices! Count: \(vertices.count)")
            } else if src.semantic == .normal {
                // Can be used for baking, or display info
                let vertices = src.vertices // will get for normal, as for vertices
                print("Normal Vertices: \(vertices.count)")
            } else {
                print("Other source")
            }
            
            // OTHER SEMANTICS
            // + Edge Create
            // + vertex crease
            // + color (vertex color)
            // + tangent
        }
        tempAlertMessage = "Could not find UV map."
        presentingTempAlert.toggle()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.presentingTempAlert.toggle()
            self.tempAlertMessage = ""
        }
        print("Could not find a UV Map")
        return nil
    }
    
    /// Saves the UVMap `contour` as an Image
    func saveUVMap(image:NSImage) {
        // use NSSavePanel
        let dialog = NSSavePanel() //NSOpenPanel();
        
        dialog.title                   = "UVMap layout";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowedFileTypes = ["png", "jpg", "jpeg"]
        dialog.message = "Save UVMap"
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            // Pathname of the file
            if let result = dialog.url,
               let imageData = image.tiffRepresentation {
                do {
                    try imageData.write(to: result)
                } catch {
                    print("Error. Could not save image")
                }
                
            } else {
                print("Could not save image to the specified URL")
                tempAlertMessage = "Could not save image to the specified URL."
                presentingTempAlert.toggle()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    self.presentingTempAlert.toggle()
                    self.tempAlertMessage = ""
                }
            }
        }
    }
    
    // MARK: - SCNProgram
    
    
    
    // Program
    func addProgram() {
     
        let boxGeo = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.2)
        
        let program = SCNProgram()
        program.vertexFunctionName = "myVertex" //"phong_vertex"
        program.fragmentFunctionName = "myFragment" //"phong_fragment"
        
        let box = SCNNode(geometry: boxGeo)
        
        box.geometry!.firstMaterial!.program = program
        
        box.position = SCNVector3(0, 1, 1.5)
        scene.rootNode.addChildNode(box)
        
        self.scene.isPaused = false
    }
    
    // Shape
    func makeShape(path:NSBezierPath) {
        
        print("Making shape path: \(path.debugDescription)")
        
        // Create material
        let redMat = SCNMaterial()
        redMat.lightingModel = .physicallyBased
        redMat.emission.contents = NSColor.red
        redMat.diffuse.contents = NSColor.white
//        redMat.isDoubleSided = true
        
        // Create Shape
        
        let shape = SCNShape(path: path, extrusionDepth: 1)
//        shape.extrusionDepth = 3 // Thickness in Z Axis
//        shape.chamferMode = .front
//        shape.chamferRadius = 0.1
//        shape.
        
        // shape.chamferProfile - Needs another bezier path (like in blender)
        
        shape.insertMaterial(redMat, at: 0)
        
        let shapeNode = SCNNode(geometry: shape)
        shapeNode.name = "Shape"
        
        
        shapeNode.scale = SCNVector3(0.05, 0.05, 0.05)
        
        let bb = abs(shape.boundingBox.min.y) * 0.05
        shapeNode.position = SCNVector3(0, bb, 0)
        print("Bounding box: Min:\(shape.boundingBox.min.y), Max:\(shape.boundingBox.max.y)")
        
        shapeNode.look(at: scene.rootNode.childNode(withName: "camera", recursively: false)?.position ?? SCNVector3())
        
        let bc = abs(shape.boundingBox.min.y) * 0.025
        shapeNode.position = SCNVector3(0, bc, 0)
        print("Bounding box2: Min:\(shape.boundingBox.min.y), Max:\(shape.boundingBox.max.y)")
        
        
        // let rot = SCNAction.rotateBy(x: 1.2, y: 0.2, z: 0, duration: 5)
        // shapeNode.runAction(rot)
        
        self.nodes.append(shapeNode)
        self.materials.append(redMat)
        self.scene.rootNode.addChildNode(shapeNode)
    }
    
    // MARK: - Extra Assets
    
    /// Adds an in-app geometry
    func addAppGeometry(geo:AppGeometries) {
        
        if let node = geo.getGeometry() {
            self.scene.rootNode.addChildNode(node)
            var stack:[SCNNode] = [node]
            while !stack.isEmpty {
                if let child = stack.first {
                    nodes.append(child)
                    if let geometry = child.geometry {
                        self.geometries.append(geometry)
                        for material in geometry.materials {
                            self.materials.append(material)
                        }
                    }
                    stack.append(contentsOf: child.childNodes)
                }
                
                stack.removeFirst()
            }
        }
    }
    
    /// Remove Geometry from list (and scene)
    func removeGeometry(geo:SCNGeometry) {
        self.geometries.removeAll(where: { $0 == geo })
        self.nodeTreeUpdate()
    }
    
    /// Changes the HDRI background of the Scene
    func changeBackground(back:AppBackgrounds) {
        scene.background.contents = "Scenes.scnassets/HDRI/\(back.content)"
        scene.lightingEnvironment.contents = "Scenes.scnassets/HDRI/\(back.content)"
    }
    
    // MARK: - Saving
    
    func saveScene() {
        
        let dialog = NSSavePanel() //NSOpenPanel();
        
        dialog.title                   = "Saving Scene";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowedFileTypes        = ["scn", "dae"]
        dialog.message = "Note: By default, it will export .scn file. Use '.dae' extension to export collada file."
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            // Pathname of the file
            if let result = dialog.url {
                if result.pathExtension == "dae" {
                    print("Mode:.dae")
                    scene.write(to: result, options: nil, delegate: nil) { (progress, error, boolean) in
                        print("Write progress: \(progress)")
                        print("Error: \(error?.localizedDescription ?? "no_error")")
                        if let error = error {
                            self.tempAlertMessage = "\(error.localizedDescription)"
                            self.presentingTempAlert.toggle()
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                                self.presentingTempAlert.toggle()
                                self.tempAlertMessage = ""
                            }
                        }
                    }
                } else {
                    scene.write(to: result, options: ["checkConsistency":NSNumber.init(booleanLiteral: true)], delegate: nil) { (progress, error, boolean) in
                        print("Write progress: \(progress)")
                        print("Error: \(error?.localizedDescription ?? "no_error")")
                        if let error = error {
                            self.tempAlertMessage = "\(error.localizedDescription)"
                            self.presentingTempAlert.toggle()
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                                self.presentingTempAlert.toggle()
                                self.tempAlertMessage = ""
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    // MARK: - Loading
    
    func loadPanel() {
        
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Choose a scene file.";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.isAccessoryViewDisclosed = true
        dialog.allowedFileTypes = ["scn", "dae", "usz", "obj"]
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let url = dialog.url, url.isFileURL {
                print("Loaded: \(url.absoluteString)")
                self.loadScene(url: url)
            }
        }
        
    }
    
    /// Loads a Scene chosen in the load Panel
    func loadScene(url:URL) {
        if let scene = try? SCNScene(url: url, options: [SCNSceneSource.LoadingOption.convertToYUp:NSNumber(value:1)]) {
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
        } else {
            tempAlertMessage = "Could not load the scene at \(url.absoluteString)."
            presentingTempAlert.toggle()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                self.presentingTempAlert.toggle()
                self.tempAlertMessage = ""
            }
        }
    }
    
    /// Create a Scene from Code (unsused for now)
    static func makeDefaultScene() -> SCNScene {
        
        let scene = SCNScene()
        let floor = SCNFloor()
        let material = SCNMaterial()
        material.name = "FloorMaterial"
        material.lightingModel = .physicallyBased
        material.diffuse.contents = NSColor.blue
        material.isDoubleSided = true
        material.roughness.contents = 0.1
        floor.insertMaterial(material, at: 0)
        let floorNode = SCNNode(geometry: floor)
        scene.rootNode.addChildNode(floorNode)
        return scene
    }
    
    // Call a compute kernel function to create an instance of MTLTexture
    //    func createTexture(device: MTLDevice) -> MTLTexture {
    //        // Instantiate a texture descriptor with the appropriate properties.
    //        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
    //                                                                  width: 256,
    //                                                                  height: 256,
    //                                                                  mipmapped: false)
    //        descriptor.textureType = MTLTextureType.type2D
    //        descriptor.usage = [MTLTextureUsage.shaderRead, MTLTextureUsage.shaderWrite]
    //        let outputTexture = device.makeTexture(descriptor: descriptor)
    //
    //        let commandQueue = device.makeCommandQueue()
    //        let defaultLibrary = device.makeDefaultLibrary()!
    //
    //        let kernelFunction = defaultLibrary.makeFunction(name: "kernel_function")!
    //        var computePipelineState: MTLComputePipelineState!
    //        do {
    //            computePipelineState = try! device.makeComputePipelineState(function: kernelFunction)
    //        }
    //
    //        let commandBuffer = commandQueue?.makeCommandBuffer()
    //        commandBuffer?.addCompletedHandler {
    //            (commandBuffer) in
    //            //print("texture is ready")
    //        }
    //        let computeEncoder = commandBuffer!.makeComputeCommandEncoder()
    //        computeEncoder!.setComputePipelineState(computePipelineState)
    //        computeEncoder!.setTexture(outputTexture,
    //                                   index: 0)
    //        let threadgroupSize = MTLSizeMake(16, 16, 1)        // # of threads per group
    //        var threadgroupCount = MTLSizeMake(1, 1, 1)         // # of thread groups per gird
    //        threadgroupCount.width  = (outputTexture!.width + threadgroupSize.width - 1) / threadgroupSize.width
    //        threadgroupCount.height = (outputTexture!.height + threadgroupSize.height - 1) / threadgroupSize.height
    //        computeEncoder!.dispatchThreadgroups(threadgroupCount,
    //                                            threadsPerThreadgroup: threadgroupSize)
    //        computeEncoder!.endEncoding()
    //        commandBuffer!.commit()
    //        commandBuffer!.waitUntilCompleted()
    //
    //        return outputTexture!
    //    }
}


//class ProgramDelegate:NSObject, SCNProgramDelegate {
//
//    var pVal:SCNProgram
//
//    init(program:SCNProgram) {
//        self.pVal = program
//    }
//
//    func program(_ program: SCNProgram, handleError error: Error) {
//        print("Error in program: \(error.localizedDescription)")
//    }
//}

//class MachineRenderer: NSObject, SCNSceneRendererDelegate {
//
//    var scene:SCNScene
//
//    init(scene:SCNScene) {
//        self.scene = scene
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//
//    }
//}

