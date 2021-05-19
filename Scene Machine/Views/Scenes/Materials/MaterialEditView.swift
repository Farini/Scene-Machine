//
//  MaterialEditView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/13/21.
//

import SwiftUI
import SceneKit
import Cocoa

//import Simd

struct MaterialEditView: View {
    
    @State var scene = SCNScene(named: "Scenes.scnassets/Monkey4.scn")!
    @State var materials:[SCNMaterial] = []
    @State var currentMat:String = ""
    @State var selectedMaterial:SCNMaterial?
    @State var geometry:SCNGeometry?
    
    var body: some View {
        
        NavigationView {
            VStack(alignment:.leading) {
                // Materials list
                Group {
                    Text("Materials").font(.title).foregroundColor(.accentColor).padding(.bottom, 6)
                    ForEach(materials, id:\.self) { material in
                        HStack {
                            Text(material.name ?? "untitled")
                            Spacer()
                            Text(self.materialLetters(material)).foregroundColor(.gray)
                        }
                        .onTapGesture {
                            self.selectedMaterial = material
                            self.getDetails(material)
                        }
                    }
                    Divider()
                }
                
                // Selection
                Text("Selection").font(.title).foregroundColor(.accentColor)
                if selectedMaterial != nil {
                    MaterialView(material: selectedMaterial!)
                } else {
                    Text("No selection").foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(6)
            
            ZStack(alignment:.topLeading) {
//                SceneView(scene: self.scene, pointOfView: nil, options: .allowsCameraControl, preferredFramesPerSecond: 60, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
                GeoSceneView(scene: scene, options: [])
                
                Text("Materials: \(materials.count)")
                    .padding()
                
            }
            
//            if let geo = geometry {
//                VStack {
//                    HStack {
//                        Text("UV MAP").font(.title).foregroundColor(.accentColor)
//                        Button("Save") {
//                            let image = uvView.snapShot(uvSize: CGSize(width: 1024, height: 1024))
//                            self.openSavePanel(for: image!)
//
//                        }
//                        Spacer()
//                        Text("Sources:\(geo.sources.count), Vertices:\(geo.sources.last!.vectorCount)")
//                    }
//                    .padding(.horizontal)
//
//                    let uv = self.describeUV(source:geo.sources.last!, geo: geo)
//                    UVShape(uv:uv)
//                        .stroke(lineWidth: 0.5)
//                        .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
//                        .background(Color.gray.opacity(0.1))
//                }
//            }
        }
        .onAppear {
            self.getSceneMaterials()
        }
    }
    
    // This opens the Finder, but not to save...
    func openSavePanel(for image:NSImage) {
        
        let data = image.tiffRepresentation
        
        let dialog = NSSavePanel() //NSOpenPanel();
        
        dialog.title                   = "Choose a directory";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if let result = result {
                if result.isFileURL {
                    print("Picked a file")
                } else {
                    // this doesn't happen
                    print("Picked what?")
                }
                let path: String = result.path
                print("Picked Path: \(path)")
                
                
                do {
                    try data?.write(to: URL(fileURLWithPath: path))
                    print("File saved")
                } catch {
                    print("ERROR: \(error.localizedDescription)")
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    var uvView: some View {
        
            let uv = self.describeUV(source:geometry!.sources.last, geo: geometry!)
            return UVShape(uv: uv)
                .stroke(lineWidth: 0.5)
                .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                .background(Color.clear)
                .frame(width:1024, height:1024, alignment: .center)
        
    }
    
    /// Funstion runs on appear
    func getSceneMaterials() {
        
        var mats:[SCNMaterial] = []
        
        // Recursively get Materials
        let root = scene.rootNode
        var stack:[SCNNode] = [root] // .childNode(withName:"Body_M_GeoRndr", recursively:false)!]
        while !stack.isEmpty {
            
            for mat in stack.first?.geometry?.materials ?? [] {
                self.geometry = stack.first?.geometry
                mats.append(mat)
            }
            stack.append(contentsOf: stack.first?.childNodes ?? [])
            stack.removeFirst()
        }
        
        self.materials = mats
    }
    
    func getDetails(_ material:SCNMaterial) {
        var string:String = ""
        if let diff = material.diffuse.contents {
            string.append(material.name ?? "untitled")
            if let color = diff as? NSColor {
                string.append("\n Color: R:\(color.redComponent), G:\(color.greenComponent),  B:\(color.blueComponent)")
            } else {
                string.append("[O] \(diff)")
            }
            
        } else {
            string = "no diffuse"
        }
        
        self.currentMat = string
    }
    
    func materialLetters(_ m:SCNMaterial) -> String {
        var string:String = ""
        if let _ = m.diffuse.contents {
            string.append("D")
        }
        if let _ = m.roughness.contents {
            string.append("R")
        }
        if let _ = m.emission.contents {
            string.append("E")
        }
        
        return string.isEmpty ? "-":string
    }
    
    func describeUV(source:SCNGeometrySource?, geo:SCNGeometry?) -> [CGPoint] {
        
        let gs = source!
        
        // https://stackoverflow.com/questions/55319763/weird-scngeometrysource-data
        // let vec = gs.data
        // print(MemoryLayout<float2>.stride)
        // vec.withUnsafeBytes { (pointer: UnsafePointer<float2>) in
        //      for i in 0..<gs.vectorCount {
        //          print((pointer + i).pointee)
        //      }
        // }
        
        // https://stackoverflow.com/questions/17250501/extracting-vertices-from-scenekit
        
        let uv:[CGPoint] = gs.uv
        
        return uv
    }
}


struct MaterialView: View {
    
    var material:SCNMaterial
    @State var active:Bool = false
    
    @State var diffuseURL:URL?
    @State var diffuseColor:Color = .white
    @State var diffuseImage:NSImage = NSImage()
    
    @State var metalnessURL:URL?
    @State var metalnessColor:Color = .white
    @State var metalnessImage:NSImage = NSImage()
    
    @State var roughnessURL:URL?
    @State var roughnessColor:Color = .white
    @State var roughnessImage:NSImage = NSImage()
    
    @State var occlusionURL:URL?
    @State var occlusionColor:Color = .white
    @State var occlusionImage:NSImage = NSImage()
    
    @State var emissionURL:URL?
    @State var emissionColor:Color = .white
    @State var emissionImage:NSImage = NSImage()
    
    @State var normalURL:URL?
    @State var normalColor:Color = .white
    @State var normalImage:NSImage = NSImage()
    
    var body: some View {
        VStack {
            
            Group {
                Text("Material")
                Text(material.name ?? "untitled")
            }
            
            
            // Diffuse
            if let diff = material.diffuse.contents {
                HStack {
                    Group {
                        Text("Diffuse")
                        Spacer()
                        Image(systemName: "rectangle.dashed.and.paperclip").font(.title2).foregroundColor(.gray)
                            .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                                providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                    if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                        if let dropImage = NSImage(contentsOf: uu) {
                                            self.material.diffuse.contents = dropImage
                                            self.diffuseURL = uu
                                        }
                                    }
                                })
                                return true
                            }
                    }
                    if let image = diff as? NSImage {
                        Image(nsImage: image)
                            .resizable()
                            .frame(width:200, height:200)
                    } else if let number = diff as? Float {
                        Text("\(number)")
                    }
                    ColorPicker("", selection: $diffuseColor)
                        .onChange(of: diffuseColor, perform: { value in
                            self.material.diffuse.contents = NSColor(diffuseColor)
                        })
                }
            }
            
            // Metalness
            if let metalness = material.metalness.contents {
                HStack {
                    Text("Metalness:")
                    Spacer()
                    if let number = metalness as? CGFloat {
                        Text("\(number)")
                    } else {
                        Image(systemName: "rectangle.dashed.and.paperclip").font(.title2).foregroundColor(.gray)
                            .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                                providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                    if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                        if let dropImage = NSImage(contentsOf: uu) {
                                            self.material.metalness.contents = dropImage
                                            self.metalnessURL = uu
                                        }
                                    }
                                })
                                return true
                            }
                        ColorPicker("", selection:$metalnessColor)
                            .onChange(of: metalnessColor, perform: { value in
                                self.material.metalness.contents = NSColor(metalnessColor)
                            })
                    }
                }
            }
            
            // Roughness
            if let rough = material.roughness.contents {
                HStack {
                    Text("Roughness:")
                    Spacer()
                    if let number = rough as? CGFloat {
                        Text("\(NumberFormatter.scnFormat.string(from: NSNumber(value: Float(number))) ?? "--")")
                    } else {
                        
                        ColorPicker("", selection:$roughnessColor)
                            .onChange(of: roughnessColor, perform: { value in
                                self.material.roughness.contents = NSColor(roughnessColor)
                            })
                    }
                    Image(systemName: "rectangle.dashed.and.paperclip").font(.title2).foregroundColor(.gray)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.roughness.contents = dropImage
                                        self.roughnessURL = uu
                                    }
                                }
                            })
                            return true
                        }
                }
            }
            
            // Occlusion
            if let occlusion = material.ambientOcclusion.contents {
                HStack {
                    Text("Occlusion:")
                    Spacer()
                    if let number = occlusion as? CGFloat {
                        Text("\(number)")
                    } else {
                        
                        ColorPicker("", selection:$occlusionColor)
                            .onChange(of: occlusionColor, perform: { value in
                                self.material.ambientOcclusion.contents = NSColor(occlusionColor)
                            })
                    }
                    Image(systemName: "rectangle.dashed.and.paperclip").font(.title2).foregroundColor(.gray)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.ambientOcclusion.contents = dropImage
                                        self.occlusionURL = uu
                                    }
                                }
                            })
                            return true
                        }
                }
            }
            
            // Emission
            if let _ = material.emission.contents {
                HStack {
                    Text("Emission:")
                    Spacer()
                    Image(systemName: "rectangle.dashed.and.paperclip").font(.title2).foregroundColor(.gray)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.emission.contents = dropImage
                                        self.emissionURL = uu
                                    }
                                }
                            })
                            return true
                        }
                    
                    ColorPicker("", selection:$emissionColor)
                        .onChange(of: emissionColor, perform: { value in
                            self.material.emission.contents = NSColor(emissionColor)
                        })
                }
            }
            
            // Normal
            if let _ = material.normal.contents {
                HStack {
                    Text("Normal:")
                    Spacer()
                    Image(systemName: "rectangle.dashed.and.paperclip").font(.title2).foregroundColor(.gray)
                        .onDrop(of: ["public.file-url"], isTargeted: $active) { providers -> Bool in
                            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                                    if let dropImage = NSImage(contentsOf: uu) {
                                        self.material.normal.contents = dropImage
                                        self.normalURL = uu
                                    }
                                }
                            })
                            return true
                        }
                    
                    ColorPicker("", selection:$normalColor)
                        .onChange(of: normalColor, perform: { value in
                            self.material.normal.contents = NSColor(normalColor)
                        })
                }
            }
            
            // Buttons
//            Group {
//                Divider()
//                HStack {
//                    Button("Save") {
//                        print("Save Material")
//                    }
//                }
//            }
        }
        .frame(width:200)
        .padding(.horizontal, 6)
        .onAppear() {
            self.prepareUI()
        }
    }
    
    func prepareUI() {
        // Diffuse
        if let difImage = material.diffuse.contents as? NSImage {
            self.diffuseImage = difImage
        } else if let difColor = material.diffuse.contents as? NSColor {
            self.diffuseColor = Color(difColor)
        }
        // Metalness
        if let metalImage = material.metalness.contents as? NSImage {
            self.metalnessImage = metalImage
        } else if let color = material.metalness.contents as? NSColor {
            self.metalnessColor = Color(color)
        }
        // Roughness
        if let image = material.roughness.contents as? NSImage {
            self.roughnessImage = image
        } else if let color = material.roughness.contents as? NSColor {
            self.roughnessColor = Color(color)
        }
        // Emission
        if let image = material.emission.contents as? NSImage {
            self.emissionImage = image
        } else if let color = material.emission.contents as? NSColor {
            self.emissionColor = Color(color)
        }
        // Normal
        if let image = material.normal.contents as? NSImage {
            self.normalImage = image
        } else if let color = material.displacement.contents as? NSColor {
            self.normalColor = Color(color)
        }
    }
}

struct MaterialEditView_Previews: PreviewProvider {
    static var previews: some View {
        MaterialEditView()
    }
}

struct MaterialDetail_Previews: PreviewProvider {
    static var previews: some View {
        MaterialView(material:MaterialExample().material)
    }
}

struct MaterialExample {
    var material:SCNMaterial
    init() {
        let newMat = SCNMaterial()
        newMat.name = "Example 1"
        newMat.lightingModel = .physicallyBased
        newMat.diffuse.contents = NSImage(named:"Checkerboard")
        newMat.roughness.contents = 0.2
        self.material = newMat
    }
}

struct GeoSceneView: NSViewRepresentable {
    
    var scene: SCNScene
    var options: [Any]
    
    var view = SCNView()
    
    func makeNSView(context: Context) -> SCNView {
        
        // Instantiate the SCNView and setup the scene
        view.scene = scene
        view.pointOfView = scene.rootNode.childNode(withName: "camera", recursively: true)
        view.allowsCameraControl = true
        
        // Add gesture recognizer
        let tapGesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        
        view.addGestureRecognizer(tapGesture)
        
        let other = NSClickGestureRecognizer()
        other.buttonMask = 2
        
        return view
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {
        // updates
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(view)
    }
    
    class Coordinator: NSObject {
        private let view: SCNView
        init(_ view: SCNView) {
            self.view = view
            super.init()
        }
        
        @objc func handleTap(_ gestureRecognize: NSGestureRecognizer) {
            // check what nodes are tapped
            let p:NSPoint = gestureRecognize.location(in: view)
            print("Touch point: \(p)")
            
            let hitResults = view.hitTest(p, options: [:])
            
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                
                // retrieved the first clicked object
                let result = hitResults[0]
                
                // Face
                let face:Int = result.faceIndex
                print("Touch face index: \(face)")
                
                let c = result.localCoordinates
                print("Local coordinates: \(c)")
                
                let d = result.localNormal
                print("Local normal: \(d)")
                
//                let e = result.
//                print("Local normal: \(d)")
                
                let g = result.geometryIndex
                print("Geometry Index: \(g)")
                
                if let elements = result.node.geometry?.elements {
                    print("Elements: \(elements.count)")
                    var elindx:Int = 0
                    for el in elements {
                        print("*** Element #\(elindx)")
//                        print("*** range \(el.primitiveRange) | count \(el.primitiveCount)")
                        print("count \(el.primitiveCount)")
                        print("Data: \(el.data)")
                        let aa = el.getVertices()
                        print("Vector 3's: \(aa.count)")
                        print("--- --- ---")
                        elindx += 1
                    }
                    
                }
                
//                let gi = result.node.geometry!.sources.first(where: { $0.semantic == .vertex })?.uv
                
                // get material for selected geometry element
                let material = result.node.geometry!.materials[(result.geometryIndex)]
                
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                // on completion - unhighlight
                SCNTransaction.completionBlock = {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5
                    
                    material.emission.contents = NSColor.black
                    
                    SCNTransaction.commit()
                }
                material.emission.contents = NSColor.green
                SCNTransaction.commit()
            }
        }
        
        
    }
}

class GeoViewBack:SCNView {
    
    // Main mouse events
    
    override func mouseDown(with event: NSEvent) {
        
    }
    
    override func mouseUp(with event: NSEvent) {
        
    }
    
    override func rightMouseDown(with event: NSEvent) {
        
    }
    
    override func rightMouseUp(with event: NSEvent) {
        
    }
    
    // Touches
    
    override func touchesBegan(with event: NSEvent) {
        
    }
    
    override func touchesMoved(with event: NSEvent) {
        
    }
    
    override func touchesEnded(with event: NSEvent) {
        
    }
    
    // Keyboard
    
    override func keyUp(with event: NSEvent) {
        
    }
}
