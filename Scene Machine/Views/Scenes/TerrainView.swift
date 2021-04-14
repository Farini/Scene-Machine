//
//  TerrainView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/14/21.
//

import SwiftUI
import SceneKit

struct TerrainView: View {
    
    @State var scene = SCNScene(named: "Scenes.scnassets/Terrain.scn")!
    @State var imagePath:String = ""
    @State private var dragOver = false
    
    init() {
        
    }
    
    var body: some View {
        HStack {
            VStack {
                Text("Terrain")
                Text("Drop image from finder to update the UV")
                    .foregroundColor(.gray)
                    .frame(maxWidth:180)
                
                TextField("UV", text: $imagePath)
                    .frame(width:150)
                    .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
                        providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                            if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                self.imagePath = uu.path
                                self.textDropped()
                            }
                        })
                        return true
                    }
                DroppableArea()
                    .frame(maxWidth:120, maxHeight:70)
                    .offset(x: 0, y: 0)
                Button("Geometry") {
                    self.describeTerrain()
                }
            }
            
            SceneView(scene: scene, pointOfView: nil, options: .allowsCameraControl, preferredFramesPerSecond: 60, antialiasingMode: .multisampling4X, delegate: TerrainDelegate(), technique: nil)
            
        }
    }
    
    func textDropped() {
        if let plane = scene.rootNode.childNode(withName: "plane", recursively: false) {
            print("plane")
            if let material = plane.geometry?.materials.first {
                if let image = NSImage(contentsOf:URL(fileURLWithPath: self.imagePath)) {
                    material.diffuse.contents = image
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

struct BookmarksList: View {
    @State private var links: [URL] = []
    
    var body: some View {
        List {
            ForEach(links, id: \.self) { url in
                Text(url.absoluteString)
                    .onDrag { NSItemProvider(object: url as NSURL) }
            }
            .onDrop(
                of: ["public.url"],
                delegate: BookmarksDropDelegate(bookmarks: $links)
            )
        }
    }
}
    
struct BookmarksDropDelegate: DropDelegate {
    @Binding var bookmarks: [URL]
    
    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: ["public.url"]) else {
            return false
        }
        
        let items = info.itemProviders(for: ["public.url"])
        for item in items {
            _ = item.loadObject(ofClass: URL.self) { url, _ in
                if let url = url {
                    DispatchQueue.main.async {
                        self.bookmarks.insert(url, at: 0)
                    }
                }
            }
        }
        
        return true
    }
}
