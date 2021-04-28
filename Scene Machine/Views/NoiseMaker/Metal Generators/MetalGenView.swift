//
//  MetalGenView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/23/21.
//

import SwiftUI

enum MetalGenType {
    
    case CIGenerators
    case Patterns
    
    case Noise
    case Tiles
    
    // Overlays
    case Overlay
    
    // Others
    case Other
}

struct MetalGenView: View {
    
    @ObservedObject var controller:MetalGenController = MetalGenController()
    
    @State var textureSize:TextureSize = .medium
    @State var image:NSImage = NSImage(size: NSSize(width: 1024, height: 1024))
    @State var selection:MetalGenType = .CIGenerators
    
    @State private var zoomLevel:Double = 1.0
    
    var topBar: some View {
        HStack {
            Picker("Size", selection: $controller.textureSize) {
                ForEach(TextureSize.allCases, id:\.self) { tSize in
                    Text(tSize.fullLabel)
                }
                .onChange(of: controller.textureSize, perform: { value in
                    //                            self.image = NSImage(size: value.size)
                    let imSize:CGSize = value.size
                    let image = MetalGenController.noiseImage(size: imSize)
                    controller.image = image
                })
            }
            .frame(width: 150)
            
            Group {
                Button("CI Gen") {
                    print("CI Gen")
                    controller.selection = .CIGenerators
                }
                Button("Noise") {
                    controller.selection = .Noise
                }
                Button("Tiles") {
                    controller.selection = .Tiles
                }
                Button(action: {
                    controller.saveImage()
                }, label: {
                    Image(systemName: "opticaldisc")
                    Text("Save")
                })
            }
            
            Group {
                // Zoom -
                Button(action: {
                    if controller.zoomLevel > 0.25 {
                        controller.zoomLevel -= 0.2
                    }
                }, label: {
                    Image(systemName:"minus.magnifyingglass")
                }).font(.title2)
                
                // Zoom Label
                let zoomString = String(format: "Zoom: %.2f", zoomLevel)
                Text(zoomString)
                
                // Zoom +
                Button(action: {
                    if controller.zoomLevel <= 8 {
                        controller.zoomLevel += 0.2
                    }
                }, label: {
                    Image(systemName:"plus.magnifyingglass")
                }).font(.title2)
            }
            
        }
        .padding(6)
        .background(Color.black.opacity(0.2))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    switch controller.selection {
                        case .CIGenerators:
                            CIGenView(applied: { (newImage) in
                                controller.image = newImage
                            }, generatorType: .Checkerboard, image: image)
                        case .Noise:
                            MetalNoiseView(controller: controller, applied: { newImage in
                                controller.image = newImage
                            })
                        case .Tiles:
                            MetalTilesView(controller: controller, applied: { newImage in
                                controller.image = newImage
                            }, image: self.image)
                        case .Overlay:
                            MetalOverlaysView(controller: controller, applied: { newImage in
                                controller.image = newImage
                            })
                        case .Other:
                            MetalOthersView(controller: controller, applied: { newImage in
                                controller.image = newImage
                            })
                        default: Text("Not Implemented").foregroundColor(.gray)
                    }
                }
            }
            .frame(width: 250)
            
            VStack {
                
                // Toolbar
                topBar

                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    HStack(alignment:.top) {
                        Spacer()
                        Image(nsImage: image)
                            .resizable()
                            .frame(width: textureSize.size.width * CGFloat(zoomLevel), height: textureSize.size.height * CGFloat(zoomLevel), alignment: .center)
                            .padding(20)
                        Spacer()
                    }
                    
                }
                .frame(minWidth: 400, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            
        }
//        .onAppear() {
//            self.loadBaseImage()
//        }
    }
    
//    func loadBaseImage() {
//        let noise = CIFilter.randomGenerator()
//        let noiseImage = noise.outputImage!
//        let context = CIContext()
//
//        if let cgimg = context.createCGImage(noiseImage, from: CGRect(origin: .zero, size: self.textureSize.size)) {
//            // convert that to a UIImage
//            let nsImage = NSImage(cgImage: cgimg, size:image.size)
//            self.image = nsImage
//        }
//    }
    
//    func truchet() {
//        let context = CIContext()
//
//        let caustic = TruchetFilter() //CausticNoise()
//
//        let noise = CIFilter.randomGenerator()
//        let noiseImage = noise.outputImage!
//
//        caustic.inputImage = noiseImage
//        caustic.tileSize = Float(image.size.width)
//
//        // get a CIImage from our filter or exit if that fails
//        guard let outputImage = caustic.outputImage() else { return }
//
//        // attempt to get a CGImage from our CIImage
//        if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))) {
//            // convert that to a UIImage
//            let nsImage = NSImage(cgImage: cgimg, size:image.size)
//            self.image = nsImage
//        }
//    }
//
//    func hexagon() {
//        let context = CIContext()
//
//        let hexagon = HexagonFilter() //CausticNoise()
//
//        let noise = CIFilter.randomGenerator()
//        let noiseImage = noise.outputImage!
//
//        hexagon.inputImage = noiseImage
//        hexagon.tileSize = Float(image.size.width)
//
//        // get a CIImage from our filter or exit if that fails
//        guard let outputImage = hexagon.outputImage() else { return }
//
//        // attempt to get a CGImage from our CIImage
//        if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))) {
//            // convert that to a UIImage
//            let nsImage = NSImage(cgImage: cgimg, size:image.size)
//            self.image = nsImage
//        }
//    }
//
//    func caustic() {
//
//        let context = CIContext()
//        let caustic = CausticNoiseMetal() //CausticNoise()
//
//        let noise = CIFilter.randomGenerator()
//        let noiseImage = noise.outputImage!
//
//        caustic.inputImage = noiseImage //inputCIImage
//        caustic.tileSize = Float(image.size.width)
//
//        // get a CIImage from our filter or exit if that fails
//        guard let outputImage = caustic.outputImage() else { return }
//
//        // attempt to get a CGImage from our CIImage
//        if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))) { // outputImage.extent
//            // convert that to a UIImage
//            let nsImage = NSImage(cgImage: cgimg, size:image.size)
//            self.image = nsImage
//        }
//    }
//
//    func checkerboard() {
//
//        print("Checkerboard")
//        let context = CIContext()
//        // Center, Amount
//        let currentFilter = CIFilter.checkerboardGenerator()
//        currentFilter.width = 128
//        currentFilter.color0 = CIColor(red: 1, green: 0.5, blue: 0.5)
//        currentFilter.color1 = CIColor(red: 0.5, green: 0.5, blue: 1.0)
//        currentFilter.center = CGPoint(x: 512, y: 512)
//
//        print("Checkerboard")
//        // get a CIImage from our filter or exit if that fails
//        guard let outputImage = currentFilter.outputImage else { return }
//        print("Output")
//
//
//
//        // attempt to get a CGImage from our CIImage
//        if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: CGPoint.zero, size: CGSize(width: 1024, height: 1024))) {
//
//            print("CGImage")
//            // convert that to a UIImage
//            let nsImage = NSImage(cgImage: cgimg, size:CGSize(width: 1024, height: 1024))
//            self.image = nsImage
//        }
//        print("Check end")
//    }
    
//    func saveImage() {
//        let data = image.tiffRepresentation
//
//        let dialog = NSSavePanel() //NSOpenPanel();
//
//        dialog.title                   = "Choose a directory";
//        dialog.showsResizeIndicator    = true;
//        dialog.showsHiddenFiles        = false;
//
//        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
//            let result = dialog.url // Pathname of the file
//
//            if let result = result {
//
//                var finalURL = result
//
//                // Make sure there is an extension...
//
//                let path: String = result.path
//                print("Picked Path: \(path)")
//
//                var filename = result.lastPathComponent
//                print("Filename: \(filename)")
//                if filename.isEmpty {
//                    filename = "Untitled"
//                }
//
//                let xtend = result.pathExtension.lowercased()
//                print("Extension: \(xtend)")
//
//                let knownImageExtensions = ["jpg", "jpeg", "png", "bmp", "tiff"]
//
//                if !knownImageExtensions.contains(xtend) {
//                    filename = "\(filename).png"
//
//                    let prev = finalURL.deletingLastPathComponent()
//                    let next = prev.appendingPathComponent(filename, isDirectory: false)
//                    finalURL = next
//                }
//
//                do {
//                    try data?.write(to: finalURL)
//                    print("File saved")
//                } catch {
//                    print("ERROR: \(error.localizedDescription)")
//                }
//
//            }
//        } else {
//            // User clicked on "Cancel"
//            return
//        }
//    }
}

struct MetalGenView_Previews: PreviewProvider {
    static var previews: some View {
        MetalGenView()
            .frame(minWidth: 800, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity, alignment: .center)
    }
}
