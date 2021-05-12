//
//  FXDistortView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/30/21.
//

import SwiftUI

struct FXDistortView: View {
    
    @ObservedObject var controller:ImageFXController
    
    /// Completion function. Returns an image
    var applied: (_ image:NSImage) -> Void = {_ in }
    
    @State var distortType:DistortType = .BumpDistortion
    
    // Slider values
    @State private var slider1:Float = 0
    @State private var slider2:Float = 0
    @State private var slider3:Float = 0
    @State private var slider4:Float = 0
    
    // CGPoint, or Vector
    @State private var vecPoint:CGPoint = .zero
    
    @State private var undoImages:[NSImage] = []
    
    enum DistortType:String, CaseIterable {
        case BumpDistortion
        case CircleSplash
        case Displacement
        case Glass
        case Pinch
        case StretchCrop
        case Torus
        case Twirl
    }
    
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
    
    var body: some View {
        
        VStack {
            
            // Header and Picker
            Group {
                HStack {
                    Text("Distort Effect")
                    Spacer()
                    Image(systemName:"wand.and.stars")
                }
                .font(.title2)
                .foregroundColor(.accentColor)
                
                Picker("", selection: $distortType) {
                    ForEach(DistortType.allCases, id:\.self) { dType in
                        Text(dType.rawValue)
                    }
                }
                Divider()
            }
            .padding(.horizontal, 6)
            
            switch distortType {
                case .BumpDistortion:
                    // Center, Radius and Scale
                    PointInput(tapLocation: .zero, dragLocation: .zero, multiplier: 1) { point in
                        self.vecPoint = point
                    }
                    
                    // Radius
                    SliderInputView(value: 10, vRange: 5...512, title: "Radius") { radiusValue in
                        self.slider1 = Float(radiusValue)
                    }
                    // Scale (0 to 1)?
                    SliderInputView(value: 10, vRange:5...512, title: "Scale") { scale in
                        self.slider2 = Float(scale)
                    }
                case .CircleSplash:
                    // Center, Radius
                    PointInput(tapLocation: .zero, dragLocation: .zero, multiplier: 1) { point in
                        self.vecPoint = point
                    }
                    SliderInputView(value: 10, vRange: 5...100, title: "Radius") { radiusValue in
                        self.slider1 = Float(radiusValue)
                    }
                case .Displacement:
                    // displ. Image, scale
                    droppableImage
                    // Scale default 50
                    SliderInputView(value: 50, vRange:5...100, title: "Scale") { scale in
                        self.slider2 = Float(scale)
                    }
                case .Glass:
                    // texture, center, scale
                    droppableImage
                    // Center
                    PointInput(tapLocation: .zero, dragLocation: .zero, multiplier: 1) { point in
                        self.vecPoint = point
                    }
                    // Scale (default 200)
                    SliderInputView(value: 200, vRange:10...1000, title: "Scale") { scale in
                        self.slider2 = Float(scale)
                    }
                    
                case .Pinch:
                    // Center, radius, scale
                    // Center
                    PointInput(tapLocation: .zero, dragLocation: .zero, multiplier: 1) { point in
                        self.vecPoint = point
                    }
                    // Radius
                    SliderInputView(value: 300, vRange: 0...512, title: "Radius") { radiusValue in
                        self.slider1 = Float(radiusValue)
                    }
                    // Scale (default 0.5)
                    SliderInputView(value: 0.5, vRange:0...1, title: "Scale") { scale in
                        self.slider2 = Float(scale)
                    }
                    
                case .StretchCrop:
                    // Size, Crop Ammount, Stretch Ammount
                    // Size(x)
                    SliderInputView(value: 0.5, vRange:0...1, title: "Size(x)") { sizeX in
                        self.slider1 = Float(sizeX).rounded()
                    }
                    // Size(y)
                    SliderInputView(value: 0.5, vRange:0...1, title: "Size(y)") { scale in
                        self.slider2 = Float(scale).rounded()
                    }
                    /*
                 Crop Amount:
                 An NSNumber object whose display name is CropAmount. This value determines if, and how much, cropping should be used to achieve the target size. If the value is 0, the image is stretched but not cropped. If the value is 1, the image is cropped but not stretched. Values in-between use stretching and cropping proportionally.
                 */
                    // Crop
                    SliderInputView(value: 0, vRange:0...1, title: "Crop amt") { cropper in
                        self.slider3 = Float(cropper).rounded()
                    }
                    // Center Stretch Amount
                    /*
                     An NSNumber object whose display name is CenterStretchAmount. This value determines how much stretching to apply to the center of the image, if stretching is indicated by the inputCropAmount value. A value of 0 causes the center of the image to maintain its original aspect ratio. A value of 1 causes the image to be stretched uniformly.
                     */
                    SliderInputView(value: 0.5, vRange:0...1, title: "Stretch") { stretch in
                        self.slider4 = Float(stretch).rounded()
                    }
                
                case .Torus:
                    // Center, radius, refraction, width
                    // Center
                    PointInput(tapLocation: .zero, dragLocation: .zero, multiplier: 1) { point in
                        self.vecPoint = point
                        self.updatePreview()
                    }
                    // Radius
                    SliderInputView(value: 160, vRange: 0...512, title: "Radius") { radiusValue in
                        self.slider1 = Float(radiusValue)
                    }
                    // Refraction
                    SliderInputView(value: 1.7, vRange:0...3, title: "Refraction") { sizeX in
                        self.slider2 = Float(sizeX).rounded()
                    }
                    // Width (80)
                    SliderInputView(value: 80, vRange:5...250, title: "Width") { width in
                        self.slider3 = Float(width).rounded()
                    }
                    Text("Creates a torus-shaped lens and distorts the portion of the image over which the lens is placed.").foregroundColor(.gray)
                    
                case .Twirl:
                    // Center, Radius, Angle
                    // Center
                    PointInput(tapLocation: .zero, dragLocation: .zero, multiplier: 1) { point in
                        self.vecPoint = point
                        self.updatePreview()
                    }
                    // Radius
                    SliderInputView(value: 160, vRange: 0...512, title: "Radius") { radiusValue in
                        self.slider1 = Float(radiusValue)
                    }
                    // Angle
                    SliderInputView(value: 3.14, vRange:0...3, title: "Refraction") { sizeX in
                        self.slider2 = Float(sizeX).rounded()
                    }
                    Text("Rotates pixels around a point to give a twirling effect.").foregroundColor(.gray)
                    
//                default: Text("Not implemented")
            }
            
            Divider()
            
            // Button & Preview
            Group {
                imgPreview
                
                HStack {
                    // Undo
                    Button(action: {
//                        controller.previewUndo()
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
                
//                HStack {
//                    Button("Apply") {
//                        print("Apply effect")
//                        self.apply()
//                    }
//                    Spacer()
//                    Button("↩️ Undo") {
//                        if let lastImage = undoImages.dropLast().first {
//                            self.image = lastImage
//                        }
//                    }.disabled(undoImages.isEmpty)
//                    Button("🔄 Update") {
//                        print("Update Preview")
//                        self.undoImages.append(self.image!)
//                        self.updatePreview()
//                    }
//
//                }
            }
        }
        .frame(width:250)
        .padding(8)
        .onAppear() {
            self.image = controller.openingImage
            if let img = image {
                self.undoImages.append(img)
            }
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
        
        switch distortType {
            case .BumpDistortion:
                
                let filter = CIFilter.bumpDistortion()
                filter.inputImage = coreImage
                filter.center = CGPoint(x: vecPoint.x * mainImage.size.width, y: vecPoint.y * mainImage.size.height) //vecPoint
                filter.radius = slider1
                filter.scale = slider2
                
                guard let outputImage = filter.outputImage,
                      let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                    print("⚠️ No output image")
                    return
                }
                
                print("Filtered?")
                
                let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: controller.textureSize.size.width, height: controller.textureSize.size.height))
                
                self.image = filteredImage
            
            case .CircleSplash:
                
                let filter = CIFilter.circleSplashDistortion()
                filter.inputImage = coreImage
                filter.center = CGPoint(x: vecPoint.x * mainImage.size.width, y: (1 - vecPoint.y) * mainImage.size.height)
                filter.radius = slider1 * Float(image!.size.width)
                
                guard let outputImage = filter.outputImage,
                      let cgImage = context.createCGImage(outputImage, from: coreImage.extent) else {
                    print("⚠️ No output image")
                    return
                }
                
                print("Filtered?")
                
                let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: controller.textureSize.size.width, height: controller.textureSize.size.height))
                
                self.image = filteredImage
                
            case .Displacement:
                // Convert displacement image
                guard let dispImageData = mainImage.tiffRepresentation,
                      let dispBitmap = NSBitmapImageRep(data:dispImageData),
                      let dispImage:CIImage = CIImage(bitmapImageRep: dispBitmap) else {
                    return
                }
                
                let filter = CIFilter.displacementDistortion()
                filter.inputImage = coreImage
                filter.displacementImage = dispImage
                filter.scale = self.slider2
                
                self.createImage(from: filter, context: context)
                
            case .Glass:
                // Convert glass image
                guard let glassImageData = mainImage.tiffRepresentation,
                      let glassBitmap = NSBitmapImageRep(data:glassImageData),
                      let glassImage:CIImage = CIImage(bitmapImageRep: glassBitmap) else {
                    return
                }
                
                let filter = CIFilter.glassDistortion()
                filter.inputImage = coreImage
                filter.textureImage = glassImage
                filter.center = CGPoint(x: vecPoint.x * mainImage.size.width, y: vecPoint.y * mainImage.size.height)
                filter.scale = slider2
                
                self.createImage(from: filter, context: context)
                
            case .Pinch:
                
                let filter = CIFilter.pinchDistortion()
                filter.inputImage = coreImage
                filter.center = CGPoint(x: vecPoint.x * mainImage.size.width, y: vecPoint.y * mainImage.size.height)
                filter.radius = 300 //slider1
                filter.scale = 0.5 //slider2
                
                guard let outputImage = filter.outputImage,
                      let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                    
                    
                    print("⚠️ No output image")
                    return
                }
                
                print("Filtered?")
                
                let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: controller.textureSize.size.width, height: controller.textureSize.size.height))
                
                self.image = filteredImage
                
//                self.createImage(from: filter, context: context)
                
            case .StretchCrop:
                let filter = CIFilter.stretchCrop()
                filter.inputImage = coreImage
                filter.size = CGPoint(x: CGFloat(slider1) * image!.size.width, y: CGFloat(slider2) * image!.size.height)
                filter.cropAmount = slider3 * Float(image!.size.width)
                filter.centerStretchAmount = slider4 * Float(image!.size.width)
                
                self.createImage(from: filter, context: context)
                
            case .Torus:
                // Center, radius, refraction, width
                let filter = CIFilter.torusLensDistortion()
                filter.inputImage = coreImage
                filter.center = CGPoint(x: vecPoint.x * mainImage.size.width, y: (1 - vecPoint.y) * mainImage.size.height)
                filter.radius = slider1
                filter.refraction = slider2
                filter.width = slider3
                
                guard let outputImage = filter.outputImage,
                      let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                    
                    print("⚠️ No output image")
                    return
                }
                
                print("Filtered?")
                
                let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: controller.textureSize.size.width, height: controller.textureSize.size.height))
                
                self.image = filteredImage
                
//                self.createImage(from: filter, context: context)
            
            case .Twirl:
                // Center, Radius, Angle
                let filter = CIFilter.twirlDistortion()
                filter.inputImage = coreImage
                filter.center = CGPoint(x: vecPoint.x * mainImage.size.width, y: (1 - vecPoint.y) * mainImage.size.height)
                
                filter.radius = slider1
                filter.angle = slider2
                
                guard let outputImage = filter.outputImage,
                      let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                    print("⚠️ No output image")
                    return
                }
                
                print("Filtered?")
                
                let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: controller.textureSize.size.width, height: controller.textureSize.size.height))
                
                self.image = filteredImage
                
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
    
    func updateUI() {
        switch distortType {
            case .BumpDistortion:
                self.slider1 = 10
                self.slider2 = 0.5
            
            default: print("Not implemented")
        }
    }
    
}

struct FXDistortView_Previews: PreviewProvider {
    static var previews: some View {
        FXDistortView(controller: ImageFXController(image: nil))
    }
}
