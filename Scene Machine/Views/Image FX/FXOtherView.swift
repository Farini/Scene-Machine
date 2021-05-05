//
//  FXOtherView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/5/21.
//

import SwiftUI

struct FXOtherView: View {
    
    @ObservedObject var controller:ImageFXController
    
    /// Completion function. Returns an image
    var applied: (_ image:NSImage) -> Void = {_ in }
    
    @State var otherType:FXOtherType = .GreenRed
    
    // Slider values
    @State private var slider1:Float = 0
    @State private var slider2:Float = 0
    @State private var slider3:Float = 0
    //    @State private var slider4:Float = 0
    
    // CGPoint, or Vector
    @State private var vecPoint:CGPoint = .zero
    @State private var vecPoint2:CGPoint = .zero
    
    // Image used to Preview effect
    @State var image:NSImage? = NSImage(named:"Example")
    @State private var isPreviewing:Bool = true
    var imgPreview: some View {
        VStack {
            Toggle("Preview", isOn: $isPreviewing)
            if isPreviewing {
                if let img = image {
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(minWidth: 200, maxWidth: 250, minHeight: 200, maxHeight: 250, alignment: .center)
                } else {
                    Text("No preview Image").foregroundColor(.gray).padding(12)
                }
            } else {
                Text("Preview is off").foregroundColor(.gray).padding(12)
            }
        }
        .padding(.top, 25)
    }
    
    /** DROPPABLE IMAGE */
    @State private var dragOver:Bool = false
    @State private var droppedImage:NSImage?
    var droppableImage: some View {
        Group {
            if let dropped = droppedImage {
                Image(nsImage: dropped)
                    .resizable()
                    .frame(width:200, height:200)
            } else {
                Text(" [ Drop Image ] ").foregroundColor(.gray).padding(.vertical, 30)
            }
        }
        .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
            providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                    if let dropImage = NSImage(contentsOf: uu) {
                        self.droppedImage = dropImage
                    }
                }
            })
            return true
        }
    }
    
    enum FXOtherType:String, CaseIterable {
        case GreenRed
        case BlackTransp
        case WhiteTransp
        case Laplatian
        case Sketch
    }
    
    var body: some View {
        VStack {
            
            // Header and Picker
            Group {
                HStack {
                    Text("Other Effects")
                    Spacer()
                    Image(systemName:"wand.and.stars")
                }
                .font(.title2)
                .foregroundColor(.accentColor)
                
                Picker("", selection: $otherType) {
                    ForEach(FXOtherType.allCases, id:\.self) { dType in
                        Text(dType.rawValue)
                    }
                }
                Divider()
            }
            .padding(.horizontal, 6)
            
            
            switch otherType {
                case .GreenRed:
                    Text("Swap Green and Red channel pixels")
                case .BlackTransp:
                    // Threshold
                    SliderInputView(value: 0.1, vRange: 0.05...0.5, title: "Threshold") { threshold in
                        self.slider1 = Float(threshold)
                    }
                    Text("Converts black pixels to transparent")
                case .WhiteTransp:
                    SliderInputView(value: 0.1, vRange: 0.05...0.5, title: "Threshold") { threshold in
                        self.slider1 = Float(threshold)
                    }
                    Text("Converts white pixels to transparent")
                case .Laplatian:
                    Text("Testing laplatian")
                case .Sketch:
                    // texel width, texel height, intensity
                    Text("Testing sketch")
                    
                default:
                    Text("Not implemented")

            }
            
            Divider()
            
            // Button & Preview
            Group {
                imgPreview
                
                HStack {
                    // Undo
                    Button(action: {
                        controller.previewUndo()
                    }, label: {
                        Image(systemName:"arrow.uturn.backward.circle")
                        Text("Undo")
                    })
                    .help("Go back a step")
                    
                    // Apply
                    Button(action: {
                        print("Apply effect")
                        self.apply()
                    }, label: {
                        Image(systemName:"checkmark.circle.fill")
                        Text("Apply")
                    })
                    .help("Apply Changes")
                    
                    // Update
                    Button(action: {
                        print("Update Preview")
                        self.updatePreview()
                    }, label: {
                        Image(systemName:"arrow.triangle.2.circlepath.circle")
                        Text("Update")
                    })
                    .help("Update Preview")
                }
            }
        }
        .frame(width:250)
        .padding(8)
        .onAppear() {
            self.image = controller.openingImage
            //                if let img = image {
            ////                    self.undoImages.append(img)
            //
            //                }
        }
    }
    
    // MARK: - Methods
    
    /// Updates the image preview
    func updatePreview() {
        print("Updating Preview")
        let mainImage = controller.openingImage
        guard let imageData = mainImage.tiffRepresentation,
              let imageBitmap = NSBitmapImageRep(data:imageData),
              let coreImage = CIImage(bitmapImageRep: imageBitmap) else {
            return
        }
        
        let context = CIContext()
        
        switch otherType {
            case .GreenRed:
                print("gr")
                
                let filter = MetalFilter()
                filter.inputImage = coreImage

                if let output = filter.outputImage(),
                   let cgImage = context.createCGImage(output, from: output.extent) {
                    print("outputting")
                    
                    let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: controller.openingImage.size.width, height: controller.openingImage.size.height))
                    self.image = filteredImage
                    
                    controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                } else {
                    print("nooutpout")
                }
                
            case .BlackTransp:
                
                let filter = BLKTransparent()
                filter.inputImage = coreImage
                filter.threshold = slider1
                
                if let output = filter.outputImage(),
                   let cgImage = context.createCGImage(output, from: output.extent) {
                    print("outputting")
                    
                    let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: controller.openingImage.size.width, height: controller.openingImage.size.height))
                    self.image = filteredImage
                    
                    controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                } else {
                    print("nooutpout")
                }
                
            case .Laplatian:
                print("not implemented")
                let filter = LaplatianFilter()
                filter.inputImage = coreImage
                filter.tileSize = Float(mainImage.size.width)
                
                if let output = filter.outputImage(),
                   let cgImage = context.createCGImage(output, from: output.extent) {
                    print("outputting")
                    
                    let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: controller.openingImage.size.width, height: controller.openingImage.size.height))
                    self.image = filteredImage
                    
                    controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                } else {
                    print("nooutpout")
                }
                
            case .Sketch:
                print("not implemented")
                let filter = SketchFilter()
                filter.tileSize = Float(mainImage.size.width)
                filter.tWidth = 1
                filter.tHeight = 1
                filter.inputImage = coreImage
                filter.intensity = 1
                
                if let output = filter.outputImage(),
                   let cgImage = context.createCGImage(output, from: output.extent) {
                    print("outputting")
                    
                    let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: controller.openingImage.size.width, height: controller.openingImage.size.height))
                    self.image = filteredImage
                    
                    controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                } else {
                    print("nooutpout")
                }
                
            case .WhiteTransp:
                print("not implemented")
                let filter = WHITransparent()
                filter.inputImage = coreImage
                filter.threshold = slider1
                
                if let output = filter.outputImage(),
                   let cgImage = context.createCGImage(output, from: output.extent) {
                    print("outputting")
                    
                    let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: controller.openingImage.size.width, height: controller.openingImage.size.height))
                    self.image = filteredImage
                    
                    controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                } else {
                    print("nooutpout")
                }
                
            default:
                print("no implement")
//            case .Crystallize:
//
//                let filter = CIFilter.crystallize()
//                filter.inputImage = coreImage
//                filter.center = CGPoint(x: vecPoint.x * mainImage.size.width, y: vecPoint.y * mainImage.size.height)
//                filter.radius = slider1
//
//                self.createImage(from: filter, context: context)
//
//            case .Edges:
//
//                let filter = CIFilter.edges()
//                filter.inputImage = coreImage
//                filter.intensity = self.slider1
//
//                self.createImage(from: filter, context: context)
//
//            case .EdgeWork:
//
//                let filter = CIFilter.edgeWork()
//                filter.inputImage = coreImage
//                filter.radius = self.slider1
//
//                self.createImage(from: filter, context: context)
//
//            case .LineOverlay:
//
//                let filter = CIFilter.lineOverlay()
//                filter.nrNoiseLevel = 0.07
//                filter.nrSharpness = 0.71
//                filter.edgeIntensity = self.slider1
//                filter.threshold = self.slider2
//                filter.contrast = self.slider3
//
//                self.createImage(from: filter, context: context)
//
//            case .Spotlight:
//
//                let filter = CIFilter.spotLight()
//                filter.inputImage = coreImage
//                let imSize = controller.openingImage.size
//                let lpX = imSize.width / 2 + vecPoint.x * imSize.width
//                let lpY = imSize.height / 2 + vecPoint.y * imSize.height
//                filter.lightPosition = CIVector(values: [lpX, lpY, 256], count: 3)
//                filter.lightPointsAt = CIVector(cgPoint: vecPoint2)
//                filter.brightness = self.slider1
//                filter.concentration = self.slider2
//
//                self.createImage(from: filter, context: context)
//
//            case .Bloom:
//                let filter = CIFilter.bloom()
//                filter.inputImage = coreImage
//                filter.radius = slider1
//                filter.intensity = slider2
//
//                self.createImage(from: filter, context: context)
//
//            case .SharpenLumina:
//                // Center, radius, refraction, width
//                let filter = CIFilter.sharpenLuminance()
//                filter.inputImage = coreImage
//                filter.sharpness = slider1
//
//                self.createImage(from: filter, context: context)
//
//            case .UnsharpMask:
//                // Center, Radius, Angle
//                let filter = CIFilter.unsharpMask()
//                filter.inputImage = coreImage
//                filter.radius = slider1
//                filter.intensity = slider2
//
//                createImage(from: filter, context: context)
//
//            case .NormalMap:
//                let filter = NormalMapFilter()
//                filter.inputImage = coreImage
//                filter.tileSize = Float(mainImage.size.width)
//
//                if let output = filter.outputImage(),
//                   let cgImage = context.createCGImage(output, from: output.extent) {
//                    print("outputting")
//
//                    let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: controller.openingImage.size.width, height: controller.openingImage.size.height))
//                    self.image = filteredImage
//
//                    controller.updateImage(new: filteredImage, isPreview: isPreviewing)
//                } else {
//                    print("nooutpout")
//                }
                
                
            //                createImage(from: filter, context: context)
            
            //            default: print("Not implemented")
        }
    }
    
    func createImage(from filter: CIFilter, context:CIContext) {
        
        print("Creating Image")
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            print("⚠️ No output image")
            return
        }
        
        // let cgImage = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: controller.textureSize.size))
        
        let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: controller.textureSize.size.width, height: controller.textureSize.size.height))
        self.image = filteredImage
        
        controller.updateImage(new: filteredImage, isPreview: isPreviewing)
        
    }
    
    /// Applies the effect
    func apply() {
        
        // To apply, pass a function from the parent view
        // and return a NSImage when the effects are ready
        guard let image = image else {
            print("No image")
            return
        }
        
        applied(image)
    }
    
}

struct FXOtherView_Previews: PreviewProvider {
    static var previews: some View {
        FXOtherView(controller: ImageFXController(image: nil))
    }
}
