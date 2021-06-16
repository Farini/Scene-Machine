//
//  TerrainView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/14/21.
//

import SwiftUI
import SceneKit
import ModelIO
import SceneKit.ModelIO

struct TerrainView: View {
    
    @ObservedObject var exporter:SceneExporter
    @State var scene:SCNScene //= TerrainView.createTerrain() //SCNScene(named: "Scenes.scnassets/Terrain.scn")!
    
    @State private var dragOver = false
    
    @State var diffuseImagePath:String = ""
    @State var displaceImagePath:String = ""
    @State var displacementIntensity:Double = 0.2
    
    // Controllable parts
    // ------------------
    // Material roughness
    // Light Position
    // Light Color
    // Sky Arrangement
    // Mesh 'creaseThreshold' property
    // plane.widthSegmentCount = 200
    // plane.heightSegmentCount = 200
    // subdivisions
    // Scene background
    // Environment Lighting
    
    init() {
        // Initialize this just once
        let terrain = TerrainView.createTerrain()
        self.scene = terrain
        
        let theScene = terrain //SCNScene(named: "Scenes.scnassets/Terrain.scn")!
        self.exporter = SceneExporter(scene: theScene)
    }
    
    var body: some View {
        HSplitView {
            List() {
                Section(header: Text("Terrain")) {
                    VStack {
                        Text("Terrain").font(.title2).foregroundColor(.orange)
                            .padding(8)
                        Text("Drop image from finder to update the UV")
                            .foregroundColor(.gray)
                            .frame(maxWidth:180)
                            .padding(.bottom, 6)
                    }
                    
                }
                Section(header: Text("Images")) {
                    VStack {
                        Text("Diffuse")
                        SubMatImageArea(url: nil, active: true, image: nil) { droppedImage, droppedURL in
                            print("Image dropped. Size: \(droppedImage.size)")
                            self.diffuseImagePath = droppedURL.path
                            self.textDropped()
                        }
                        .help("Color Map of the terrain")
                        
                        Text("Displacement")
                        SubMatImageArea(url: nil, active: true, image: nil) { droppedImage, droppedURL in
                            print("Image dropped. Size: \(droppedImage.size)")
                            self.displaceImagePath = droppedURL.path
                            self.textDropped()
                        }
                        .help("Height Map of the terrain")
                    }
                }
                Section(header: Text("Setup")) {
                    VStack {
                        SliderInputView(value: 0.2, vRange: 0...1, title: "Intensity") { intensity in
                            self.displacementIntensity = intensity
                            self.textDropped()
                        }
                        
                        Button("Export") {
                            exportScene()
                        }
                    }
                }
                Group {
                    SliderInputView(value: 0.2, vRange: 0...1, title: "Intensity") { intensity in
                        self.displacementIntensity = intensity
                        self.textDropped()
                    }
                    
                    Button("Export") {
                        exportScene()
                    }
                }
            }
            .frame(minWidth: 180, maxWidth: 200, maxHeight: .infinity, alignment: .center)
            /*
            ScrollView {
                VStack {
                    Text("Terrain").font(.title2).foregroundColor(.orange)
                        .padding(8)
                    Text("Drop image from finder to update the UV")
                        .foregroundColor(.gray)
                        .frame(maxWidth:180)
                        .padding(.bottom, 6)
                    
                    Text("Diffuse")
                    SubMatImageArea(url: nil, active: true, image: nil) { droppedImage, droppedURL in
                        print("Image dropped. Size: \(droppedImage.size)")
                        self.diffuseImagePath = droppedURL.path
                        self.textDropped()
                    }
                    .help("Color Map of the terrain")
                    
                    Text("Displacement")
                    SubMatImageArea(url: nil, active: true, image: nil) { droppedImage, droppedURL in
                        print("Image dropped. Size: \(droppedImage.size)")
                        self.displaceImagePath = droppedURL.path
                        self.textDropped()
                    }
                    .help("Height Map of the terrain")
                    
                    SliderInputView(value: 0.2, vRange: 0...1, title: "Intensity") { intensity in
                        self.displacementIntensity = intensity
                        self.textDropped()
                    }
                    
                    Button("Export") {
                        exportScene()
                    }
                }
            }
            .frame(minWidth: 160, maxWidth: 200, alignment: .center)
            */
            
            SceneView(scene: scene, pointOfView: nil, options: .allowsCameraControl, preferredFramesPerSecond: 60, antialiasingMode: .multisampling4X, delegate: TerrainDelegate(), technique: nil)
            
        }
    }
    
    static func createTerrain() -> SCNScene {
        
        // Plane Geometry
        let plane = SCNPlane(width: 4, height: 4)
        plane.widthSegmentCount = 200
        plane.heightSegmentCount = 200
        // plane.cornerSegmentCount = 10
        // plane.cornerRadius = 2
        plane.name = "Terrain"
        
        // Material
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.name = "TerrainMaterial"
        material.diffuse.contents = NSColor(calibratedRed: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        material.roughness.contents = 0.75
        material.displacement.contents = "Scenes.scnassets/UVMaps/CausticNoise.png" //NSImage(byReferencingFile:
        material.displacement.intensity = 0.2
        
        //(named: "Scenes.scnassets/UVMaps/CausticNoise.png")
        material.isDoubleSided = true
        
        plane.insertMaterial(material, at: 0)
        
        // Plane Mesh
        // let planeMesh = MDLMesh(planeWithExtent: vector_float3(4, 4, 0), segments: vector_uint2(100, 100), geometryType: .quads, allocator: nil)
        let planeMesh = MDLMesh(scnGeometry: plane)
        planeMesh.addNormals(withAttributeNamed: "normal", creaseThreshold: 0.2)
        let vertexCount = planeMesh.vertexCount
        let vertexDescr = planeMesh.vertexDescriptor
        print("Vertex Count: \(vertexCount)")
        print("Vertex Descr Attrib: \(vertexDescr.attributes)")
        print("Vertex Descr Layout: \(vertexDescr.layouts)")
        
        
        // MDL Node
        let planeNode = SCNNode(mdlObject: planeMesh)
        planeNode.name = "plane"
        planeNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0)
        
        // Camera
        let camera = SCNCamera()
        let camNode = SCNNode()
        camNode.camera = camera
        camNode.position = SCNVector3(x: -5, y: 1, z: 5)
        camNode.look(at: SCNVector3(0, 0, 0))
        
        
        // Light
        let light = SCNLight()
        light.type = .directional
        light.color = NSColor(calibratedRed: 0.9, green: 0.8, blue: 0.9, alpha: 1.0)
        light.castsShadow = true
        light.automaticallyAdjustsShadowProjection = true
        light.shadowCascadeCount = 2
        light.shadowCascadeSplittingFactor = 0.15
        light.shadowSampleCount = 2
        
        // Light Node
        let lNode = SCNNode()
        lNode.light = light
        lNode.position = SCNVector3(3.0, 1.0, 1.0)
        lNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        
        // Scene
        let baseScene = SCNScene()
        baseScene.rootNode.addChildNode(planeNode)
        baseScene.rootNode.addChildNode(lNode)
        baseScene.rootNode.addChildNode(camNode)
        
        // Environment
        let sky = MDLSkyCubeTexture(name: "sky",
                                    channelEncoding: .float16,
                                    textureDimensions: vector_int2(128, 128),
                                    turbidity: 0,
                                    sunElevation: 1.5,
                                    upperAtmosphereScattering: 0.5,
                                    groundAlbedo: 0.5)
        
        baseScene.background.contents = sky
        baseScene.lightingEnvironment.contents = sky
        
        return baseScene
    }
    
    func exportScene() {
        
        let dialog = NSSavePanel()
        
        dialog.title                   = "Save Scene";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.message = "By default, it will export .scn file. Use *.dae to export collada file."
        dialog.allowedFileTypes = ["scn", "dae"]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            if let result = result {
                self.exporter.exportScene(to: result)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    func textDropped() {
        if let plane = scene.rootNode.childNode(withName: "plane", recursively: false) {
            print("plane")
            if let material = plane.geometry?.materials.first {
                
                if let diffuseImage = NSImage(contentsOf:URL(fileURLWithPath: self.diffuseImagePath)) {
                    material.diffuse.contents = diffuseImage
                    material.diffuse.intensity = 1
                }
                
                if let displacementImage = NSImage(contentsOf:URL(fileURLWithPath: self.displaceImagePath)) {
                    material.displacement.contents = displacementImage
                    material.displacement.intensity = CGFloat(self.displacementIntensity)
                }
            }
        }
    }
}

struct TerrainView_Previews: PreviewProvider {
    static var previews: some View {
        TerrainView()
    }
}

class TerrainDelegate: NSObject, SCNSceneRendererDelegate {
    
    override init() {
        super.init()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
}

struct DroppableArea: View {
    
    @State private var imageUrls: [Int: URL] = [:]
    @State private var active = 0
    
    struct GridCell: View {
        let active: Bool
        let url: URL?
        
        var body: some View {
            let img = Image(nsImage: url != nil ? NSImage(byReferencing: url!) : NSImage())
                .resizable()
                .frame(width: 50, height: 50)
            
            return Rectangle()
                .fill(self.active ? Color.green : Color.clear)
                .frame(width: 50, height: 50)
                .overlay(img)
        }
    }
    
    var body: some View {
        let dropDelegate = MyDropDelegate(imageUrls: $imageUrls, active: $active)
        
        return VStack {
            HStack {
                GridCell(active: self.active == 1, url: imageUrls[1])
                GridCell(active: self.active == 2, url: imageUrls[2])
            }
        }
        .background(Rectangle().fill(Color.gray))
        .frame(width: 120, height: 120)
        .onDrop(of: ["public.file-url"], delegate: dropDelegate)
        
    }
}

struct SubMatImageArea: View {
    
    @State var url:URL?
    @State var active:Bool = false
    @State var image:NSImage?
    
    /// Callback function. Returns an image
    var dropped: (_ image:NSImage, _ url:URL) -> Void = {_,_  in }
    
    var body: some View {
        
        VStack {
            Group {
                if let dropped = image {
                    Image(nsImage: dropped)
                        .resizable()
//                        .frame(width:150, height:150)
                } else {
                    Text(" [ Drop Image ] ").foregroundColor(.gray)// .padding(.vertical, 30)
                }
            }
            .frame(width: 150, height: 150, alignment: .center)
            .background(Color.black.opacity(0.5))
            .cornerRadius(12)
            .padding(8)
            .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                    if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                        if let dropImage = NSImage(contentsOf: uu) {
                            self.image = dropImage
                            dropped(dropImage, uu)
                        }
                    }
                })
                return true
            }
            Spacer()
        }
    }
}

struct MyDropDelegate: DropDelegate {
    
    @Binding var imageUrls: [Int: URL]
    @Binding var active: Int
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: ["public.file-url"])
    }
    
    func dropEntered(info: DropInfo) {
        NSSound(named: "Morse")?.play()
    }
    
    func performDrop(info: DropInfo) -> Bool {
        NSSound(named: "Submarine")?.play()
        
        let gridPosition = getGridPosition(location: info.location)
        self.active = gridPosition
        
        if let item = info.itemProviders(for: ["public.file-url"]).first {
            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                DispatchQueue.main.async {
                    if let urlData = urlData as? Data {
                        self.imageUrls[gridPosition] = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                    }
                }
            }
            
            return true
            
        } else {
            return false
        }
        
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        self.active = getGridPosition(location: info.location)
        return nil
    }
    
    func dropExited(info: DropInfo) {
        self.active = 0
    }
    
    func getGridPosition(location: CGPoint) -> Int {
        if location.x > 50  {
            return 2
        } else if location.x < 150  {
            return 1
        } else {
            return 0
        }
    }
}

class SceneExporter:NSObject, SCNSceneExportDelegate, ObservableObject {
  
    var scene:SCNScene
    @Published var progress:Float = 0
    @Published var error:Error?
    
    init(scene:SCNScene) {
        self.scene = scene
    }
    
    func exportScene(to url:URL) {
        scene.write(to: url, options: ["checkConsistency":NSNumber.init(booleanLiteral: true)], delegate: self) { (progress, error, boolean) in
            print("Write progress: \(progress)")
            print("Error: \(error?.localizedDescription ?? "nodesc")")
        }
    }
    
    func write(_ image: NSImage, withSceneDocumentURL documentURL: URL, originalImageURL: URL?) -> URL? {
        print("Writing images: \(image.size) \(originalImageURL?.absoluteString ?? "n/a")")
        if let original = originalImageURL {
            return original
        } else {
            // Make URL
            // To do that, there should be a convention to name it.
            // One option: [MaterialName]+<Diffuse>.png
            // Option 2: UUID().string.png
            let folder = documentURL.deletingLastPathComponent()
            let file = folder.appendingPathComponent("\(UUID().uuidString).png", isDirectory: false)
            return file
        }
    }
    
}
