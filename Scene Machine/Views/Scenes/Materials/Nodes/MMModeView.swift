//
//  MMModeView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/27/21.
//

import SwiftUI

/// The main Node View (Center) that displays image + info of a Material
struct MMModeView:View {
    
    @ObservedObject var controller:MaterialMachineController
    
    @State private var url:URL? = nil
    @State private var string:String = ""
    @State private var color:Color = .white
    @State private var image:NSImage? = nil
    @State private var scalar:CGFloat? = nil
    @State private var intensity:CGFloat = 1
    
    @State private var isCreating:Bool = false
    /// Controls the drop Image
    @State var activeLink:Bool = false
    
    var body: some View {
        VStack {
            
            // Mode & Color
            HStack {
                Text(controller.materialMode.rawValue)
                Spacer()
                if displayColorPicker() {
                    ColorPicker("", selection: $color)
                }
                Button(action: {
                    print("Create new canvas")
                    //                    controller.createNewCanvas(mode: controller.materialMode)
                    self.isCreating.toggle()
                }, label: {
                    Image(systemName: "doc.badge.plus")
                })
                .popover(isPresented:$isCreating) {
                    CreateCanvasView(controller:controller)
                }
            }
            
            // Intensity
            HStack {
                Text("Intensity")
                Spacer()
                TextField("", value: $intensity, formatter: NumberFormatter.scnFormat)
                    .frame(width:36)
                    .onChange(of: intensity, perform: { value in
                        if value > 1 { self.intensity = 1.0 }
                        if value < 0 { self.intensity = 0.0 }
                    })
                Text("\(controller.material.diffuse.wrapS.toString())")
                Text("\(controller.material.diffuse.wrapT.toString())")
            }
            
            /// Image + Drop Area
            ZStack(alignment:.top) {
                if let image = self.image {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: 200, height: 200, alignment: .center)
                }
                if let url = self.url {
                    Text(url.absoluteURL.path)
                } else if let uStr = self.string {
                    Text(uStr)
                }
            }
            .frame(width: 200, height: 200, alignment: .center)
            .border(Color.gray, width: 0.5)
            .onDrop(of: ["public.file-url"], isTargeted: $activeLink) { providers -> Bool in
                providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                    if let data = data {
                        self.droppedImage(data, type: controller.materialMode)
                    }
                })
                return true
            }
        }
        .frame(width:200)
        .onChange(of: controller.materialMode) { newMode in
            self.updateUI()
        }
        .onChange(of:controller.material) { newMaterial in
            self.updateUI()
        }
        .onAppear() {
            updateUI()
        }
        
    }
    
    func updateUI() {
        self.url = nil
        self.string = ""
        self.scalar = nil
        self.image = nil
        
        switch controller.materialMode {
            case .Diffuse:
                
                if let image = controller.material.diffuse.contents as? NSImage {
                    self.image = image
                } else
                if let url = controller.material.diffuse.contents as? URL {
                    self.url = url
                    if let image = NSImage(contentsOf: url) {
                        self.image = image
                    }
                } else if let string = controller.material.diffuse.contents as? String {
                    self.string = string
                    if let image = NSImage(named:string) {
                        self.image = image
                    }
                } else if let color = controller.material.diffuse.contents as? NSColor {
                    self.color = Color(color)
                }
            case .Roughness:
                if let url = controller.material.roughness.contents as? URL {
                    self.url = url
                    if let image = NSImage(contentsOf: url) {
                        self.image = image
                    }
                } else if let string = controller.material.roughness.contents as? String {
                    self.string = string
                    if let image = NSImage(contentsOfFile: string) {
                        self.image = image
                    }
                } else if let number = controller.material.roughness.contents as? CGFloat {
                    self.scalar = number
                }
            case .AO:
                if let url = controller.material.ambientOcclusion.contents as? URL {
                    self.url = url
                    if let image = NSImage(contentsOf: url) {
                        self.image = image
                    }
                } else if let string = controller.material.ambientOcclusion.contents as? String {
                    self.string = string
                    if let image = NSImage(contentsOfFile: string) {
                        self.image = image
                    }
                } else if let number = controller.material.ambientOcclusion.contents as? CGFloat {
                    self.scalar = number
                }
            case .Emission:
                if let url = controller.material.emission.contents as? URL {
                    self.url = url
                    if let image = NSImage(contentsOf: url) {
                        self.image = image
                    }
                } else if let string = controller.material.emission.contents as? String {
                    self.string = string
                    if let image = NSImage(contentsOfFile: string) {
                        self.image = image
                    }
                }
            //                else if let color = material.emission.contents as? NSColor {
            //                    self.color = color
            //                } else if let number = material.emission.contents as? CGFloat {
            //                    self.scalar = number
            //                }
            case .Normal:
                if let url = controller.material.normal.contents as? URL {
                    self.url = url
                    if let image = NSImage(contentsOf: url) {
                        self.image = image
                    }
                } else if let string = controller.material.normal.contents as? String {
                    self.string = string
                    if let image = NSImage(contentsOfFile: string) {
                        self.image = image
                    }
                }
            //            default: print("other")
        }
    }
    
    /// Material modes that display a Color Picker.
    func displayColorPicker() -> Bool {
        let allowedModes:[MaterialMode] = [.Diffuse, .Emission]
        return allowedModes.contains(controller.materialMode)
    }
    
    /// Gets data from a drop image, and updates the controller's `Material`
    func droppedImage(_ data:Data, type:MaterialMode) {
        guard let url = URL(dataRepresentation: data, relativeTo: nil) else {
            print("Could not get url")
            return
        }
        if let img = NSImage(contentsOf: url) {
            
            DispatchQueue.main.async {
                // Update the main image in Controller
                controller.uvImage = img
                switch type {
                    case .Diffuse:
                        controller.material.diffuse.contents = img
                    case .AO:
                        controller.material.ambientOcclusion.contents = img
                    case .Roughness:
                        controller.material.roughness.contents = img
                    case .Emission:
                        controller.material.emission.contents = img
                    case .Normal:
                        controller.material.normal.contents = img
                }
                self.updateUI()
            }
            
        }
    }
}

struct MMMode_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            MMNodeView(matType: .constant(.Diffuse), matName: .constant("Material")).padding()
            Divider().frame(height:200)
            MMModeView(controller: MaterialMachineController()).padding()
            Divider().frame(height:200)
            MMNodeFXView(controller: MaterialMachineController(), original: nil, effectImage: nil)
                .padding()
        }
        
    }
}

// MARK: - Create Canvas

/// When ccreating a new canvas, select size, color, edges, etc. to setup the image for a `MaterialMode`
struct CreateCanvasView:View {
    
    @ObservedObject var controller:MaterialMachineController
    
    @State private var textureSize:TextureSize = .medium // 1024
    @State private var color:Color = .white
    
    @State private var wantsEdges:Bool = true
    @State private var wantsColor:Bool = false
    
    var body: some View {
        VStack {
            Text("Create canvas").font(.title2).foregroundColor(.orange)
            Divider()
            // size - choose size
            Picker(selection: $textureSize, label: Text("Size")) {
                ForEach(TextureSize.allCases, id:\.self) { texSize in
                    Text("\(texSize.fullLabel)")
                }
            }
            .frame(maxWidth:150)
            Divider()
            
            Group {
                Text("Background").font(.title3).foregroundColor(.blue)
                // Color
                Toggle(isOn:$wantsColor, label:{ Text("Back color") })
                ColorPicker("Color", selection: $color)
                Text("Without back color, the background will be transparent").foregroundColor(.gray).font(.footnote)
                Divider()
            }
            
            Group {
                Text("Foreground").font(.title3).foregroundColor(.blue)
                // Draw UVMap edges?
                Toggle(isOn: $wantsEdges, label: { Text("Draw UV Edges") })
                
                Divider()
            }
            
            Group {
                Button("Create") {
                    print("Creating Canvas")
                    self.makeImage()
                }
            }
            
        }
        .frame(maxWidth:160)
        .padding(8)
        .onAppear() {
            self.updateUI()
        }
    }
    
    // For square
    var squareColored:some View {
        Rectangle()
            .frame(width: textureSize.size.width, height: textureSize.size.height, alignment: .center)
            .background(self.color)
    }
    
    func updateUI() {
        switch controller.materialMode {
            case .Diffuse:
                if let dc = controller.material.diffuse.contents as? NSColor {
                    self.color = Color(dc)
                    self.wantsColor = true
                } else {
                    self.wantsColor = false
                }
            case .AO:
                self.color = .white
                self.wantsColor = true
                self.wantsEdges = false
            case .Emission:
                self.color = .black
                self.wantsColor = true
                self.wantsEdges = false
                if let value = controller.material.emission.contents as? CGFloat {
                    self.color = Color.init(white: Double(value))
                } else if let eColor = controller.material.emission.contents as? NSColor {
                    self.color = Color(eColor)
                }
            case .Normal:
                self.wantsColor = true
                self.wantsEdges = true
            case .Roughness:
                self.wantsColor = true
                self.wantsEdges = false
                if let value = controller.material.roughness.contents as? CGFloat {
                    self.color = Color.init(white: Double(value))
                }
                
        }
    }
    
    
    func makeImage() {
        
        
        var image:NSImage?
        if wantsColor {
            image = squareColored.snapShot(uvSize: textureSize.size)
        } else {
            image = NSImage(size: textureSize.size)
        }
        
        if wantsEdges {
            if let semantic = controller.geometry.sources.first(where: { $0.semantic == .texcoord }) {
                let uv:[CGPoint] = semantic.uv
                if let snapImage:NSImage = UVMapView(size: textureSize.size, image: image, uvPoints: uv).snapShot(uvSize: textureSize.size) {
                    image = snapImage
                }
            }
        }
        
        print("\(image!.size.debugDescription)")
        controller.createNewCanvas(image: image!)
        
        
//        let context = CIContext()
//        let cic = CIColor(cgColor: self.color.cgColor!)
//        let parameters = [kCIInputColorKey: cic]
//
////        let filter = CIFilter.checkerboardGenerator()
//        let f2 = CIFilter(name: "CIConstantColorGenerator", parameters: parameters)!
//        if let ciim = f2.outputImage,
//           let cgimg = context.createCGImage(ciim, from: CGRect(origin: CGPoint.zero, size: self.textureSize.size)) {
//            let nsImg = NSImage(cgImage: cgimg, size: NSSize(width: textureSize.size.width, height: textureSize.size.height))
//
//           }
    }
}

struct CreateCanvas_Previews:PreviewProvider {
    static var previews: some View {
        CreateCanvasView(controller: MaterialMachineController())
    }
}
