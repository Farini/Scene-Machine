//
//  MaterialEditView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/13/21.
//

import SwiftUI
import SceneKit
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
                SceneView(scene: self.scene, pointOfView: nil, options: .allowsCameraControl, preferredFramesPerSecond: 60, antialiasingMode: .multisampling4X, delegate: nil, technique: nil)
                Text("Materials: \(materials.count)")
                    .padding()
                
            }
            
            if let geo = geometry {
                VStack {
                    HStack {
                        Text("UV MAP").font(.title).foregroundColor(.accentColor)
                        Button("SSave") {
                            let image = uvView.snapShot()
                            self.openSavePanel(for: image!)
                        }
                        Spacer()
                        Text("Sources:\(geo.sources.count), Vertices:\(geo.sources.last!.vectorCount)")
                    }
                    .padding(.horizontal)
                    
                    let uv = self.describeUV(source:geo.sources.last!, geo: geo)
                    UVShape(uv:uv)
                        .stroke(lineWidth: 0.5)
                        .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                        .background(Color.gray.opacity(0.1))
                }
                
            }
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
        
        VStack {
            let uv = self.describeUV(source:geometry!.sources.last, geo: geometry!)
            UVShape(uv: uv)
                .stroke(lineWidth: 0.5)
                .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                .background(Color.gray.opacity(0.1))
                .frame(width:1000, height:1000, alignment: .center)
        }
        
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
    
    var body: some View {
        VStack {
            Text("Material")
            Text(material.name ?? "untitled")
            if let diff = material.diffuse.contents {
                HStack {
                    Text("Diffuse")
                    Spacer()
                    if let color = diff as? NSColor {
                        ColorPicker("", selection:.constant(Color(color)))
                    } else if let number = diff as? Float {
                        Text("\(number)")
                    }
                }
            }
            
            if let metalness = material.metalness.contents {
                HStack {
                    Text("Metalness:")
                    Spacer()
                    if let number = metalness as? CGFloat {
                        Text("\(number)")
                    } else
                    if let color = metalness as? NSColor {
                        ColorPicker("", selection:.constant(Color(color)))
                    }
                }
            }
            
            // Roughness
            if let rough = material.roughness.contents {
                HStack {
                    Text("Roughness:")
                    Spacer()
                    if let number = rough as? CGFloat {
                        Text("\(number)")
                    } else
                    if let color = rough as? NSColor {
                        ColorPicker("", selection:.constant(Color(color)))
                    }
                }
            }
            
            if let emission = material.emission.contents {
                HStack {
                    Text("Emission:")
                    Spacer()
                    if let number = emission as? CGFloat {
                        Text("\(number)")
                    } else
                    if let color = emission as? NSColor {
                        ColorPicker("", selection:.constant(Color(color)))
                    }
                }
            }
        }
        .frame(width:200)
        .padding(.horizontal, 6)
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
        newMat.diffuse.contents = NSColor.red
        newMat.roughness.contents = 0.2
        self.material = newMat
    }
}



/**
 A `Shape` showing a UVMap.
 See: https://stackoverflow.com/questions/17250501/extracting-vertices-from-scenekit */
struct UVShape: Shape {
    
    var uv:[CGPoint]
//    let multi:CGFloat = 10
    
    // MARK:- functions
    func path(in rect: CGRect) -> Path {
        
        // Path
        var path = Path()
        
        // Start in first
        path.move(to: uv.first!)
        
        var substack:[CGPoint] = []
        
        for uvPoint in uv {
            
            if uvPoint == .zero { break }
            
            if substack.count >= 3 {
                
                path.closeSubpath()
                substack = []
                
                substack.append(uvPoint)
                path.move(to: CGPoint(x:uvPoint.x * 1024, y:uvPoint.y * 1024))
                
            } else if substack.isEmpty {
                
                path.move(to: CGPoint(x:uvPoint.x * 1024, y:uvPoint.y * 1024))
                substack.append(uvPoint)
                
            } else {
                
                path.addLine(to: CGPoint(x:uvPoint.x * 1024, y:uvPoint.y * 1024))
                substack.append(uvPoint)
            }
        }
        
        path.closeSubpath()
        
        return path
    }
}

extension View {
    func snapShot() -> NSImage? {
        let controller = NSHostingController(rootView: self)
        
        let rView = controller.rootView
        
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        print("Target Size: \(targetSize)")
        
        view.bounds = CGRect(origin: .zero, size: targetSize)
        
        
//        let renderer = GraphicsImageRenderer(size: targetSize)
//        return renderer.image { _ in
//            layer.render
//        }
        
        let image = view.asImage(size: CGSize(width: 1000, height: 1000))
            // image.draw(in: NSMakeRect(0, 0, targetSize.width, targetSize.height))
        
        
//        let image:NSImage = NSImage(size: targetSize)
//
//        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(targetSize.width), pixelsHigh: Int(targetSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
//
//        image.addRepresentation(rep)
//        image.lockFocus()
//
////        image.draw(at: NSPoint.zero, from: CGRect(origin: .zero, size: targetSize), operation: .overlay, fraction: 1.0) // = view.draw(NSRect(origin: .zero, size: targetSize))
//
//        let rect = NSMakeRect(0, 0, targetSize.width, targetSize.height)
//        let ctx = NSGraphicsContext.current!.cgContext
//        ctx.clear(rect)
//        ctx.setFillColor(NSColor.black.cgColor)
//        ctx.fill(rect)
//
//        image.unlockFocus()
        
        
        
        return image
    }
}

extension NSView {
    func asImage(size: CGSize) -> NSImage {
        let format = GraphicsImageRendererFormat()
//        format.scale = 1.0
        return GraphicsImageRenderer(size: size, format: format).image { context in
            
            self.layer!.render(in: context.cgContext)
        }
    }
}

#if os(OSX)
public class MacGraphicsImageRendererFormat: NSObject {
    public var opaque: Bool = false
    public var prefersExtendedRange: Bool = false
    public var scale: CGFloat = 2.0
    public var bounds: CGRect = .zero
}

public typealias GraphicsImageRendererFormat = MacGraphicsImageRendererFormat
#else
public typealias GraphicsImageRendererFormat = UIGraphicsImageRendererFormat
#endif

#if os(OSX)
public class MacGraphicsImageRendererContext: NSObject {
    
    public var format: GraphicsImageRendererFormat
    
    public var cgContext: CGContext {
        guard let context = NSGraphicsContext.current?.cgContext
        else { fatalError("Unavailable cgContext while drawing") }
        return context
    }
    
    public func clip(to rect: CGRect) {
        cgContext.clip(to: rect)
    }
    
    public func fill(_ rect: CGRect) {
        cgContext.fill(rect)
    }
    
    public func fill(_ rect: CGRect, blendMode: CGBlendMode) {
        NSGraphicsContext.saveGraphicsState()
        cgContext.setBlendMode(blendMode)
        cgContext.fill(rect)
        NSGraphicsContext.restoreGraphicsState()
    }
    
    public func stroke(_ rect: CGRect) {
        cgContext.stroke(rect)
    }
    
    public func stroke(_ rect: CGRect, blendMode: CGBlendMode) {
        NSGraphicsContext.saveGraphicsState()
        cgContext.setBlendMode(blendMode)
        cgContext.stroke(rect)
        NSGraphicsContext.restoreGraphicsState()
    }
    
    public override init() {
        self.format = GraphicsImageRendererFormat()
        super.init()
    }
    
    public var currentImage: NSImage {
        guard let cgImage = cgContext.makeImage()
        else { fatalError("Cannot retrieve cgImage from current context") }
        return NSImage(cgImage: cgImage, size: format.bounds.size)
    }
}

public typealias GraphicsImageRendererContext = MacGraphicsImageRendererContext
#else
public typealias GraphicsImageRendererContext = UIGraphicsImageRendererContext
#endif

#if os(OSX)
public class MacGraphicsImageRenderer: NSObject {
    
    public class func context(with format: GraphicsImageRendererFormat) -> CGContext? {
        fatalError("Not implemented")
    }
    
    public class func prepare(_ context: CGContext, with: GraphicsImageRendererContext) {
        fatalError("Not implemented")
    }
    
    public class func rendererContextClass() {
        fatalError("Not implemented")
    }
    
    public var allowsImageOutput: Bool = true
    
    public let format: GraphicsImageRendererFormat
    
    public let bounds: CGRect
    
    public init(bounds: CGRect, format: GraphicsImageRendererFormat) {
        (self.bounds, self.format) = (bounds, format)
        self.format.bounds = self.bounds
        super.init()
    }
    
    public convenience init(size: CGSize, format: GraphicsImageRendererFormat) {
        self.init(bounds: CGRect(origin: .zero, size: size), format: format)
    }
    
    public convenience init(size: CGSize) {
        self.init(bounds: CGRect(origin: .zero, size: size), format: GraphicsImageRendererFormat())
    }
    
    public func image(actions: @escaping (GraphicsImageRendererContext) -> Void) -> NSImage {
        let image = NSImage(size: format.bounds.size, flipped: false) {
            (drawRect: NSRect) -> Bool in
            
            let imageContext = GraphicsImageRendererContext()
            imageContext.format = self.format
            actions(imageContext)
            
            return true
        }
        return image
    }
    
    public func pngData(actions: @escaping (GraphicsImageRendererContext) -> Void) -> Data {
        let image = self.image(actions: actions)
        var imageRect = CGRect(origin: .zero, size: image.size)
        guard let cgImage = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        else { fatalError("Could not construct PNG data from drawing request") }
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        bitmapRep.size = image.size
        guard let data = bitmapRep.representation(using: .png, properties: [:])
        else { fatalError("Could not retrieve data from drawing request") }
        return data
    }
    
    public func jpegData(withCompressionQuality compressionQuality: CGFloat, actions: @escaping (GraphicsImageRendererContext) -> Void) -> Data {
        let image = self.image(actions: actions)
        var imageRect = CGRect(origin: .zero, size: image.size)
        guard let cgImage = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        else { fatalError("Could not construct PNG data from drawing request") }
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        bitmapRep.size = image.size
        guard let data = bitmapRep.representation(using: .jpeg, properties: [NSBitmapImageRep.PropertyKey.compressionFactor: compressionQuality])
        else { fatalError("Could not retrieve data from drawing request") }
        return data
    }
    
    public func runDrawingActions(_ drawingActions: (GraphicsImageRendererContext) -> Void, completionActions: ((GraphicsImageRendererContext) -> Void)? = nil) throws {
        fatalError("Not implemented")
    }
}
#endif

#if os(OSX)
public typealias GraphicsImageRenderer = MacGraphicsImageRenderer
#else
public typealias GraphicsImageRenderer = UIGraphicsImageRenderer
#endif
