//
//  FXBlurrView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/19/21.
//

import SwiftUI

struct FXBlurrView: View {

    // Slider values
    @State private var slider1:Float = 0
    @State private var slider2:Float = 0
    @State private var slider3:Float = 0
    
    // CGPoint, or Vector
    @State private var vecPoint:CGPoint = .zero
    
    /// Completion function. Returns an image
    var applied: (_ image:NSImage) -> Void = {_ in }
    
    @State var blurrType:BlurrType = .Box
    
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
                
                HStack {
                    Button("Apply") {
                        print("Apply effect")
                        self.apply()
                    }
                    Spacer()
                    Button("↩️ Undo") {
                        if let lastImage = undoImages.dropLast().first {
                            self.image = lastImage
                        }
                    }
                    Button("🔄 Update") {
                        print("Update Preview")
                        self.undoImages.append(self.image!)
                        self.updatePreview()
                    }
                    
                }
            }
        }
        .frame(width:250)
        .padding(8)
    }
    
    // Image used to Preview effect
    @State var image:NSImage? = NSImage(named:"Example")
    @State var isPreviewing:Bool = true
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
        switch blurrType {
            case .Box:
                if let inputImage = image {
                    let inputData = inputImage.tiffRepresentation!
                    let bitmap = NSBitmapImageRep(data: inputData)!
                    let inputCIImage = CIImage(bitmapImageRep: bitmap)
                    
                    let context = CIContext()
                    let currentFilter = CIFilter.boxBlur()
                    currentFilter.inputImage = inputCIImage
                    currentFilter.radius = self.slider1
                    
                    // get a CIImage from our filter or exit if that fails
                    guard let outputImage = currentFilter.outputImage else { return }
                    
                    // attempt to get a CGImage from our CIImage
                    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                        // convert that to a UIImage
                        let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
                        self.image = nsImage
                    }
                }
            case .Disc:
                if let inputImage = image {
                    let inputData = inputImage.tiffRepresentation!
                    let bitmap = NSBitmapImageRep(data: inputData)!
                    let inputCIImage = CIImage(bitmapImageRep: bitmap)
                    
                    let context = CIContext()
                    let currentFilter = CIFilter.discBlur()
                    currentFilter.inputImage = inputCIImage
                    currentFilter.radius = self.slider1
                    
                    // get a CIImage from our filter or exit if that fails
                    guard let outputImage = currentFilter.outputImage else { return }
                    
                    // attempt to get a CGImage from our CIImage
                    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                        // convert that to a UIImage
                        let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
                        self.image = nsImage
                    }
                }
            case .Gaussian:
                if let inputImage = image {
                    let inputData = inputImage.tiffRepresentation!
                    let bitmap = NSBitmapImageRep(data: inputData)!
                    let inputCIImage = CIImage(bitmapImageRep: bitmap)
                    
                    let context = CIContext()
                    let currentFilter = CIFilter.gaussianBlur()
                    currentFilter.inputImage = inputCIImage
                    currentFilter.radius = self.slider1
                    
                    // get a CIImage from our filter or exit if that fails
                    guard let outputImage = currentFilter.outputImage else { return }
                    
                    // attempt to get a CGImage from our CIImage
                    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                        // convert that to a UIImage
                        let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
                        self.image = nsImage
                    }
                }
            case .MaskedVariable:
                if let inputImage = image, let maskImage = droppedImage {
                    let inputData = inputImage.tiffRepresentation!
                    let bitmap = NSBitmapImageRep(data: inputData)!
                    let inputCIImage = CIImage(bitmapImageRep: bitmap)
                    
                    let maskData = maskImage.tiffRepresentation!
                    let maskBitmap = NSBitmapImageRep(data: maskData)!
                    let maskCIImage = CIImage(bitmapImageRep: maskBitmap)
                    
                    let context = CIContext()
                    let currentFilter = CIFilter.maskedVariableBlur()
                    currentFilter.inputImage = inputCIImage
                    currentFilter.mask = maskCIImage
                    
                    currentFilter.radius = self.slider1
                    
                    // get a CIImage from our filter or exit if that fails
                    guard let outputImage = currentFilter.outputImage else { return }
                    
                    // attempt to get a CGImage from our CIImage
                    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                        // convert that to a UIImage
                        let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
                        self.image = nsImage
                    }
                }
            case .MedianFilter:
                if let inputImage = image {
                    let inputData = inputImage.tiffRepresentation!
                    let bitmap = NSBitmapImageRep(data: inputData)!
                    let inputCIImage = CIImage(bitmapImageRep: bitmap)
                
                    
                    let context = CIContext()
                    let currentFilter = CIFilter.median()
                    currentFilter.inputImage = inputCIImage
                    
                    // get a CIImage from our filter or exit if that fails
                    guard let outputImage = currentFilter.outputImage else { return }
                    
                    // attempt to get a CGImage from our CIImage
                    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                        // convert that to a UIImage
                        let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
                        self.image = nsImage
                    }
                }
            case .NoiseReduction:
                if let inputImage = image {
                    let inputData = inputImage.tiffRepresentation!
                    let bitmap = NSBitmapImageRep(data: inputData)!
                    let inputCIImage = CIImage(bitmapImageRep: bitmap)
                    
                    let context = CIContext()
                    let currentFilter = CIFilter.noiseReduction()
                    currentFilter.inputImage = inputCIImage
                    currentFilter.noiseLevel = slider1
                    currentFilter.sharpness = slider2
                    
                    // get a CIImage from our filter or exit if that fails
                    guard let outputImage = currentFilter.outputImage else { return }
                    
                    // attempt to get a CGImage from our CIImage
                    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                        // convert that to a UIImage
                        let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
                        self.image = nsImage
                    }
                }
            case .Motion:
                if let inputImage = image {
                    let inputData = inputImage.tiffRepresentation!
                    let bitmap = NSBitmapImageRep(data: inputData)!
                    let inputCIImage = CIImage(bitmapImageRep: bitmap)
                    
                    let context = CIContext()
                    let currentFilter = CIFilter.motionBlur()
                    currentFilter.inputImage = inputCIImage
                    currentFilter.radius = slider1
                    currentFilter.angle = slider2
                    
                    // get a CIImage from our filter or exit if that fails
                    guard let outputImage = currentFilter.outputImage else { return }
                    
                    // attempt to get a CGImage from our CIImage
                    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                        // convert that to a UIImage
                        let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
                        self.image = nsImage
                    }
                }
            case .Zoom:
                if let inputImage = image {
                    let inputData = inputImage.tiffRepresentation!
                    let bitmap = NSBitmapImageRep(data: inputData)!
                    let inputCIImage = CIImage(bitmapImageRep: bitmap)
                    
                    // Center, Amount
                    let context = CIContext()
                    let currentFilter = CIFilter.zoomBlur()
                    currentFilter.inputImage = inputCIImage
                    currentFilter.center = vecPoint
                    currentFilter.amount = slider1
                    
                    // get a CIImage from our filter or exit if that fails
                    guard let outputImage = currentFilter.outputImage else { return }
                    
                    // attempt to get a CGImage from our CIImage
                    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                        // convert that to a UIImage
                        let nsImage = NSImage(cgImage: cgimg, size:inputImage.size)
                        self.image = nsImage
                    }
                }
            
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
        FXBlurrView()
            .frame(minWidth: 249, maxWidth: 250, minHeight: 350, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
    }
}


