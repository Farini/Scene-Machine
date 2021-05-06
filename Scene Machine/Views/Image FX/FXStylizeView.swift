//
//  FXStylizeView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/30/21.
//

import SwiftUI

struct FXStylizeView: View {
    
    @ObservedObject var controller:ImageFXController
    
    /// Completion function. Returns an image
    var applied: (_ image:NSImage) -> Void = {_ in }
    
    @State var stylizeType:StylizeType = .Crystallize
    
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
    
    enum StylizeType:String, CaseIterable {
        case Crystallize
        case Edges
        case EdgeWork
        case LineOverlay
        case Spotlight
        case Bloom
        
        case SharpenLumina
        case UnsharpMask
        case NormalMap
    }
    
    var body: some View {
        
            
            VStack {
                
                // Header and Picker
                Group {
                    HStack {
                        Text("Stylize Effect")
                        Spacer()
                        Image(systemName:"wand.and.stars")
                    }
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    
                    Picker("", selection: $stylizeType) {
                        ForEach(StylizeType.allCases, id:\.self) { dType in
                            Text(dType.rawValue)
                        }
                    }
                    Divider()
                }
                .padding(.horizontal, 6)
                
                
                switch stylizeType {
                    
                    case .Crystallize:
                        // Center, Radius
                        PointInput(tapLocation: .zero, dragLocation: .zero, multiplier: 1) { point in
                            self.vecPoint = point
                        }
                        
                        // Radius
                        SliderInputView(value: 10, vRange: 5...512, title: "Radius") { radiusValue in
                            self.slider1 = Float(radiusValue)
                        }
                        Text("Softens edges and applies a pleasant glow to an image.").foregroundColor(.gray)

                    case .Edges:
                        // Intensity
                        SliderInputView(value: 1, vRange: 0...1, title: "Intensity") { radiusValue in
                            self.slider1 = Float(radiusValue)
                        }
                        Text("Finds all edges in an image and displays them in color.").foregroundColor(.gray)
                        
                    case .EdgeWork:
                        // radius
                        // Radius (Distance) = 3
                        SliderInputView(value: 3, vRange:2...20, title: "Radius") { scale in
                            self.slider1 = Float(scale)
                        }
                        Text("Produces a stylized black-and-white rendition of an image that looks similar to a woodblock cutout.").foregroundColor(.gray)
                        
                    case .LineOverlay:
                        // NRNoiseLevel(0.07), NRSharpness(0.71), Edge Intensity(1.0), threshold(0.1), contrast(50)
                        SliderInputView(value: 1.0, vRange:0...1, title: "Intensity") { scale in
                            self.slider1 = Float(scale)
                        }
                        SliderInputView(value: 0.1, vRange:0...1, title: "Threshold") { scale in
                            self.slider2 = Float(scale)
                        }
                        SliderInputView(value: 50.0, vRange:0...100.0, title: "Contrast") { scale in
                            self.slider3 = Float(scale)
                        }
                        Text("Creates a sketch that outlines the edges of an image in black. The portions of the image that are not outlined are transparent.").foregroundColor(.gray)
                        
                    case .Spotlight:
                        // lightPosition, lightPointsAt, brightness, concentration, color
                        
                        // lightPosition ** VECTOR3 **
                        PointInput(tapLocation: .zero, dragLocation: .zero, multiplier: 1) { point in
                            self.vecPoint = point
                        }
                        // points at
                        PointInput(tapLocation: .zero, dragLocation: .zero, multiplier: 1) { point in
                            self.vecPoint2 = point
                        }
                        
                        // bright
                        SliderInputView(value: 300, vRange: 0...512, title: "Brightness") { radiusValue in
                            self.slider1 = Float(radiusValue)
                        }
                        // Scale (default 0.5)
                        SliderInputView(value: 0.5, vRange:0...1, title: "Concentration") { scale in
                            self.slider2 = Float(scale)
                        }
                        Text("Applies a directional spotlight effect to an image.").foregroundColor(.gray)
                        
                    case .Bloom:
                        // radius, intensity
                        SliderInputView(value: 10, vRange:0...512, title: "Radius") { sizeX in
                            self.slider1 = Float(sizeX).rounded()
                        }
                        // Size(y)
                        SliderInputView(value: 0.5, vRange:0...1, title: "Intensity") { scale in
                            self.slider2 = Float(scale).rounded()
                        }
                        Text("Softens edges and applies a pleasant glow to an image.").foregroundColor(.gray)
                    case .SharpenLumina:
                        // sharpness
                        SliderInputView(value: 0.4, vRange: 0...1, title: "Sharpness") { radiusValue in
                            self.slider1 = Float(radiusValue)
                        }
                        
                        Text("It operates on the luminance of the image; the chrominance of the pixels remains unaffected.").foregroundColor(.gray)
                        
                    case .UnsharpMask:
                        // radius, intensity
                        SliderInputView(value: 10, vRange:0...512, title: "Radius") { sizeX in
                            self.slider1 = Float(sizeX).rounded()
                        }
                        // Size(y)
                        SliderInputView(value: 0.5, vRange:0...1, title: "Intensity") { scale in
                            self.slider2 = Float(scale).rounded()
                        }
                        Text("Increases the contrast of the edges between pixels of different colors in an image.").foregroundColor(.gray)
                        
                    case .NormalMap:
                        Text("Normal map")
                        
//                    default: Text("Not implemented")
                }
                
                Divider()
                
                // Button & Preview
                Group {
                    imgPreview
                    
                    HStack {
                        // Undo
                        Button(action: {
//                            controller.previewUndo()
                            self.image = controller.openingImage
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
///                    self.undoImages.append(img)
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
        
        switch stylizeType {
            case .Crystallize:
                
                let filter = CIFilter.crystallize()
                filter.inputImage = coreImage
                filter.center = CGPoint(x: vecPoint.x * mainImage.size.width, y: vecPoint.y * mainImage.size.height)
                filter.radius = slider1
                
                self.createImage(from: filter, context: context)
                
            case .Edges:
                
                let filter = CIFilter.edges()
                filter.inputImage = coreImage
                filter.intensity = self.slider1
                
                self.createImage(from: filter, context: context)
                
            case .EdgeWork:
 
                let filter = CIFilter.edgeWork()
                filter.inputImage = coreImage
                filter.radius = self.slider1
                
                self.createImage(from: filter, context: context)
                
            case .LineOverlay:
              
                let filter = CIFilter.lineOverlay()
                filter.nrNoiseLevel = 0.07
                filter.nrSharpness = 0.71
                filter.edgeIntensity = self.slider1
                filter.threshold = self.slider2
                filter.contrast = self.slider3
                
                self.createImage(from: filter, context: context)
                
            case .Spotlight:
                
                let filter = CIFilter.spotLight()
                filter.inputImage = coreImage
                let imSize = controller.openingImage.size
                let lpX = vecPoint.x * imSize.width
                let lpY = imSize.height - vecPoint.y * imSize.height
                filter.lightPosition = CIVector(values: [lpX, lpY, 256], count: 3)
                let ppX = vecPoint2.x * imSize.width
                let ppY = imSize.height - vecPoint2.y * imSize.height
                filter.lightPointsAt = CIVector(cgPoint: CGPoint(x: ppX, y: ppY))
                filter.brightness = self.slider1
                filter.concentration = self.slider2
                
                self.createImage(from: filter, context: context)
            
            case .Bloom:
                let filter = CIFilter.bloom()
                filter.inputImage = coreImage
                filter.radius = slider1
                filter.intensity = slider2
                
                self.createImage(from: filter, context: context)
                
            case .SharpenLumina:
                // Center, radius, refraction, width
                let filter = CIFilter.sharpenLuminance()
                filter.inputImage = coreImage
                filter.sharpness = slider1
                
                self.createImage(from: filter, context: context)
            
            case .UnsharpMask:
                // Center, Radius, Angle
                let filter = CIFilter.unsharpMask()
                filter.inputImage = coreImage
                filter.radius = slider1
                filter.intensity = slider2
                
                createImage(from: filter, context: context)
                
            case .NormalMap:
                let filter = NormalMapFilter()
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
    
//    func updateUI() {
//        switch distortType {
//            case .BumpDistortion:
//                self.slider1 = 10
//                self.slider2 = 0.5
//
//            default: print("Not implemented")
//        }
//    }
}

struct FXStylizeView_Previews: PreviewProvider {
    static var previews: some View {
        FXStylizeView(controller: ImageFXController(image: nil))
    }
}
