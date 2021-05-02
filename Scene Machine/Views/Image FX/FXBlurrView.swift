//
//  FXBlurrView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/19/21.
//

import SwiftUI

struct FXBlurrView: View {
    
    @ObservedObject var controller:ImageFXController

    /// Completion function. Returns an image
    var applied: (_ image:NSImage) -> Void = {_ in }
    
    @State var blurrType:BlurrType = .Box
    
    // Slider values
    @State private var slider1:Float = 0
    @State private var slider2:Float = 0
    @State private var slider3:Float = 0
    
    // CGPoint, or Vector
    @State private var vecPoint:CGPoint = .zero
  
    @State private var undoImages:[NSImage] = []
    
    var body: some View {
        VStack {
            
            // Header and Picker
            Group {
                Text("Blur Effect").font(.title2).foregroundColor(.accentColor)
                Picker("", selection: $blurrType) {
                    ForEach(BlurrType.allCases, id:\.self) { bType in
                        Text(bType.rawValue)
                    }
                }
                Divider()
            }
            .padding(.horizontal, 6)
            
            
            switch blurrType {
                case .Box:
                    Group {
                        // Radius Slider Default value: 5.00
                        SliderInputView(value: 5.0, vRange: 2...50, title: "Radius") { newValue in
                            self.slider1 = Float(newValue)
                        }
                    }
                    .padding(.bottom, 30)

                case .Disc:
                    Group {
                        // Radius Slider Default value: 8.00
                        SliderInputView(value: 8.0, vRange: 2...50, title: "Radius") { newValue in
                            self.slider1 = Float(newValue)
                        }
                    }
                    .padding(.bottom, 30)
                case .Gaussian:
                    Group {
                        // Radius Slider Default value: 10.00
                        SliderInputView(value: 10.0, vRange: 2...50, title: "Radius") { newValue in
                            self.slider1 = Float(newValue)
                        }
                    }
                    .padding(.bottom, 30)
                case .MaskedVariable:
                    Group {
                        // Radius Slider
                        SliderInputView(value: 5.0, vRange: 2...50, title: "Radius") { newValue in
                            self.slider1 = Float(newValue)
                        }
                        
                        droppableImage
                    }
                    .padding(.bottom, 30)
                    
                case .MedianFilter:
                    // (No input)
                    Text("There is no input for this filter").foregroundColor(.gray)
                case .Motion:
                    // Radius and angle
                    // Radius
                    SliderInputView(value: 5.0, vRange: 2...50, title: "Radius") { newValue in
                        self.slider1 = Float(newValue)
                    }
                    // Angle
                    SliderInputView(value: 0.0, vRange: -180...180, title: "Angle") { newValue in
                        self.slider2 = Float(newValue)
                    }
                    
                case .NoiseReduction:
                    // Noise Level, Sharpness
                    // Default values: 0.02, 0.4
                    Group {
                        // Level Slider
                        SliderInputView(value: 0.02, vRange: 0...1, title: "Level") { newValue in
                            self.slider1 = Float(newValue)
                        }
                        // Sharpness Slider
                        SliderInputView(value: 0.4, vRange: 0...1, title: "Sharpness") { newValue in
                            self.slider2 = Float(newValue)
                        }
                    }
                    .padding(.bottom, 30)
                
                case .Zoom:
                    Text("Input Point")
                    // Center, Amount
                    // Center Default value: [150 150]
                    let imnsSize:NSSize = image?.size ?? NSSize(width: 100, height: 100)
                    let imSize = CGSize(width: imnsSize.width, height: imnsSize.height)
                    let sizeBase = CGSize(width: 200, height: 200)
                    let multiplier = imSize.width / sizeBase.width
                    PointInput(multiplier: Float(multiplier)) { newPoint in
                        self.vecPoint = newPoint
                    }
                    // Amount Default value: 20.00
                    SliderInputView(value: 20.0, vRange: 2...50, title: "Sharpness") { newValue in
                        self.slider1 = Float(newValue)
                    }
            }
            
            Divider()
            
            // Button & Preview
            Group {
                imgPreview
                
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
                        controller.updateImage(new: self.image!, isPreview: isPreviewing)
                        
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
            if let img = image {
                self.undoImages.append(img)
            }
        }
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
        
        switch blurrType {
            case .Box:
                let filter = CIFilter.boxBlur()
                filter.inputImage = coreImage
                filter.radius = self.slider1
                
                guard let output = filter.outputImage,
                      let cgOutput = context.createCGImage(output, from: output.extent)
                       else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                self.image = filteredImage

            case .Disc:
                
                let filter = CIFilter.discBlur()
                filter.inputImage = coreImage
                filter.radius = self.slider1
                
                guard let output = filter.outputImage,
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                self.image = filteredImage
                
            case .Gaussian:
                
                let filter = CIFilter.gaussianBlur()
                filter.inputImage = coreImage
                filter.radius = self.slider1
                
                guard let output = filter.outputImage,
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                self.image = filteredImage
                
            case .MaskedVariable:
                
                let filter = CIFilter.maskedVariableBlur()
                filter.inputImage = coreImage
                if let mask = droppedImage,
                   let maskData = mask.tiffRepresentation,
                   let maskBitmap = NSBitmapImageRep(data: maskData),
                   let maskCIImage = CIImage(bitmapImageRep: maskBitmap) {
                    filter.mask = maskCIImage
                }
                filter.radius = self.slider1
                
                guard let output = filter.outputImage,
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                self.image = filteredImage
                
            case .MedianFilter:
                
                let filter = CIFilter.median()
                filter.inputImage = coreImage
                
                guard let output = filter.outputImage,
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                self.image = filteredImage
                
                
            case .NoiseReduction:
                
                let filter = CIFilter.noiseReduction()
                filter.inputImage = coreImage
                filter.noiseLevel = slider1
                filter.sharpness = slider2
                
                guard let output = filter.outputImage,
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                self.image = filteredImage
                
            case .Motion:
                
                let filter = CIFilter.motionBlur()
                filter.inputImage = coreImage
                filter.radius = slider1
                filter.angle = slider2
                
                guard let output = filter.outputImage,
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                self.image = filteredImage
                
            case .Zoom:
                
                let filter = CIFilter.zoomBlur()
                filter.inputImage = coreImage
                filter.center = vecPoint
                filter.amount = slider1
                
                guard let output = filter.outputImage,
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                self.image = filteredImage
                
            
//            default:
//                print("Needs Implementation")
        }
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
    
    enum BlurrType:String, CaseIterable {
        case Box
        case Disc
        case Gaussian
        case MaskedVariable
        case MedianFilter
        case Motion
        case NoiseReduction
        case Zoom
    }
}



// MARK: - Previews

struct FXBlurrView_Previews: PreviewProvider {
    static var previews: some View {
        FXBlurrView(controller: ImageFXController(image: nil))
            .frame(minWidth: 249, maxWidth: 250, minHeight: 350, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
    }
}


