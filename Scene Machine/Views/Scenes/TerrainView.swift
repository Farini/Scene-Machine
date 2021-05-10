//
//  TerrainView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/14/21.
//

import SwiftUI
import SceneKit

struct TerrainView: View {
    
    @ObservedObject var exporter:SceneExporter
    @State var scene:SCNScene = SCNScene(named: "Scenes.scnassets/Terrain.scn")!
    
    @State private var dragOver = false
    
    @State var diffuseImagePath:String = ""
    @State var displaceImagePath:String = ""
    @State var displacementIntensity:Double = 1.0
    
    // Displacement url
    // Diffuse url
    // Ambient Occlusion?
    
    init() {
        let theScene = SCNScene(named: "Scenes.scnassets/Terrain.scn")!
        self.exporter = SceneExporter(scene: theScene)
    }
    
    var body: some View {
        HSplitView {
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
                    
                    Text("Displacement")
                    SubMatImageArea(url: nil, active: true, image: nil) { droppedImage, droppedURL in
                        print("Image dropped. Size: \(droppedImage.size)")
                        self.displaceImagePath = droppedURL.path
                        self.textDropped()
                    }
                    
                    SliderInputView(value: 1.0, vRange: 0...1, title: "Intensity") { intensity in
                        self.displacementIntensity = intensity
                        self.textDropped()
                        self.createRectangle()
                    }
//                    Button("Geometry") {
//                        self.describeTerrain()
//                    }
                    
                    Button("Export") {
                        
                        exportScene()
                    }
                }
            }
            .frame(minWidth: 160, maxWidth: 200, alignment: .center)
            
            SceneView(scene: scene, pointOfView: nil, options: .allowsCameraControl, preferredFramesPerSecond: 60, antialiasingMode: .multisampling4X, delegate: TerrainDelegate(), technique: nil)
            
        }
    }
    
    func exportScene() {
        
        
        let dialog = NSSavePanel() //NSOpenPanel();
        
        dialog.title                   = "Choose a directory";
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
    
    func createRectangle() {
        // Initialize the path.
        let path = NSBezierPath()
        
        // Specify the point that the path should start get drawn.
        path.move(to: CGPoint(x: 2.0, y: 3.0))
        
        // Create a line between the starting point and the bottom-left side of the view.
        path.line(to: NSPoint(x: 0.0, y: 10))//(to: CGPoint(x: 0.0, y: 10))
        
        // Create the bottom line (bottom-left to bottom-right).
        path.line(to: NSPoint(x: 12, y: 10))
        
        // Create the vertical line from the bottom-right to the top-right side.
        path.line(to: NSPoint(x: 12, y: 0.0))
        
        // Close the path. This will create the last line automatically.
        path.close()
        
        // Create material
        let redMat = SCNMaterial()
        redMat.lightingModel = .physicallyBased
        redMat.emission.contents = NSColor.red
        
        // Create Shape
        let shape = SCNShape(path: path, extrusionDepth: 1.2)
        shape.extrusionDepth = 1 // Thickness in Z Axis
        shape.chamferMode = .both
        shape.chamferRadius = 0.2
        
        // shape.chamferProfile - Needs another bezier path (like in blender)
        
        shape.insertMaterial(redMat, at: 0)
        
        let shapeNode = SCNNode(geometry: shape)
        
        shapeNode.position = SCNVector3(0, 2, 0)
        self.scene.rootNode.addChildNode(shapeNode)
    }
    
//    func describeTerrain() {
//        if let plane = scene.rootNode.childNode(withName: "plane", recursively: false) {
//            print("plane")
//            if let geometry = plane.geometry {
//                print("Geometry: \(geometry.elementCount)")
//                if let gsource = geometry.sources.first {
//                    print("Source: \(gsource.debugDescription)")
//                    print("Semantic: \(gsource.semantic.rawValue)")
//                }
//            }
//        }
//    }
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

// 1 Image Only
// SubMatImageArea -> Drop Image
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
// MatImageDelegate -> DropDelegate

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
