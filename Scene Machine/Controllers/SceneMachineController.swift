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

enum MachineRightView {
    case Empty
    case UVMap
    case Other
}

class SceneMachineController:ObservableObject {
    
    @Published var scene:SCNScene
    @Published var materials:[SCNMaterial] = []
    @Published var nodes:[SCNNode] = []
    @Published var geometries:[SCNGeometry] = []
    
    @Published var rightView:MachineRightView = .UVMap
    
    var device: MTLDevice!
//    var outputTexture: MTLTexture!
    
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
//        outputTexture = createTexture(device: device)
    }
    
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
    
    // uv
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
        print("Could not find a UV Map")
        return nil
    }
    
    // Program
    func addProgram() {
//        let renderDelegate = MachineController(scene: self.scene)
     
        let boxGeo = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.2)
        
        let program = SCNProgram()
        program.vertexFunctionName = "myVertex" //"phong_vertex"
        program.fragmentFunctionName = "myFragment" //"phong_fragment"
//        let pDel = ProgramDelegate(program: program)
//        program.delegate = pDel
        
//        program.delegate = self
//        boxGeo.program = program
        
        let box = SCNNode(geometry: boxGeo)
//        let materialProperty = SCNMaterialProperty(contents: NSColor.yellow)
//        boxGeo.firstMaterial!.diffuse.contents = NSColor.yellow
        
        box.geometry!.firstMaterial!.program = program
        
        
        box.position = SCNVector3(0, 1, 1.5)
        scene.rootNode.addChildNode(box)
        
        self.scene.isPaused = false
    }
    
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
    
    func changeBackground(back:AppBackgrounds) {
        print("Looking for background")
       
        scene.background.contents = "Scenes.scnassets/HDRI/\(back.content)"
        print("Could not find")
//        do {
//            let modelPathDirectoryFiles = try FileManager.default.contentsOfDirectory(atPath: subdir)
//            print(modelPathDirectoryFiles.count) //this works
//            //then do my thing with the array
//            let url = modelPathDirectoryFiles
//        } catch {
//            print("error getting file")
//        }
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
    
    // MARK: - Old
    
    func saveScene() {
        
        let dialog = NSSavePanel() //NSOpenPanel();
        
        dialog.title                   = "Choose destination";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowedFileTypes = ["scn"]
        dialog.message = "save scene"
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            // Pathname of the file
            if let result = dialog.url {
                scene.write(to: result, options: ["checkConsistency":NSNumber.init(booleanLiteral: true)], delegate: nil) { (progress, error, boolean) in
                    print("Write progress: \(progress)")
                    print("Error: \(error?.localizedDescription ?? "no_error")")
                }
            }
        }
    }
    
    // MARK: - Loading
    
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

//class MachineController: NSObject, SCNSceneRendererDelegate {
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
