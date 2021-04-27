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
    
    // Displacement url
    // Diffuse url
    // Ambient Occlusion?
    
    init() {
        let theScene = SCNScene(named: "Scenes.scnassets/Terrain.scn")!
        self.exporter = SceneExporter(scene: theScene)
    }
    
    var body: some View {
        HStack {
            VStack {
                Text("Terrain")
                Text("Drop image from finder to update the UV")
                    .foregroundColor(.gray)
                    .frame(maxWidth:180)
                
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
                
                
                Button("Geometry") {
                    self.describeTerrain()
                }
                
                Button("Export") {
//                    let doc = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
//                    let url = doc.appendingPathComponent("SceneName.scn", isDirectory: false)
//                    self.exporter.exportScene(to: url)
                    exportScene()
                }
            }
            
            SceneView(scene: scene, pointOfView: nil, options: .allowsCameraControl, preferredFramesPerSecond: 60, antialiasingMode: .multisampling4X, delegate: TerrainDelegate(), technique: nil)
            
        }
    }
    
    func exportScene() {
        
        
        let dialog = NSSavePanel() //NSOpenPanel();
        
        dialog.title                   = "Choose a directory";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if let result = result {
                
                var finalURL = result
                
                // Make sure there is an extension...
                
                let path: String = result.path
                print("Picked Path: \(path)")
                
                var filename = result.lastPathComponent
                print("Filename: \(filename)")
                if filename.isEmpty {
                    filename = "Untitled"
                }
                
                let xtend = result.pathExtension.lowercased()
                print("Extension: \(xtend)")
                
                let knownImageExtensions = ["scn"]
                
                if !knownImageExtensions.contains(xtend) {
                    filename = "\(filename).scn"
                    
                    let prev = finalURL.deletingLastPathComponent()
                    let next = prev.appendingPathComponent(filename, isDirectory: false)
                    finalURL = next
                }
                
                self.exporter.exportScene(to: finalURL)
                
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
                    material.diffuse.intensity = 1
                }
            }
        }
    }
    
    func describeTerrain() {
        if let plane = scene.rootNode.childNode(withName: "plane", recursively: false) {
            print("plane")
            if let geometry = plane.geometry {
                print("Geometry: \(geometry.elementCount)")
                if let gsource = geometry.sources.first {
                    print("Source: \(gsource.debugDescription)")
                    print("Semantic: \(gsource.semantic.rawValue)")
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
//            Text("Drop Image")
            Group {
                if let dropped = image {
                    Image(nsImage: dropped)
                        .resizable()
                        .frame(width:100, height:100)
                } else {
                    Text(" [ Drop Image ] ").foregroundColor(.gray).padding(.vertical, 30)
                }
            }
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
