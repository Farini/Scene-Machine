//
//  FXColorView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/19/21.
//

import SwiftUI

struct FXColorView: View {
    
    @ObservedObject var controller:ImageFXController
    
//    @State var sliderRange:ClosedRange<Float> = 0...1
//    @State var value:Float = 0
    @State private var slider1:Float = 0
    @State private var slider2:Float = 0
    @State private var slider3:Float = 0
    
    /// Completion function. Returns an image
    var applied: (_ image:NSImage) -> Void = {_ in }
    
    @State var colorType:ColorType = .Threshold
    
    // Image used to Preview effect
    @State var image:NSImage? = NSImage(named:"ModuleBake4")
    
    @State var isPreviewing:Bool = true
    
    @State var inputColor:Color = .white
    @State var inputPoint:CGPoint = .zero
    
    @State private var undoImages:[NSImage] = []
    
    var body: some View {
        VStack {
            HStack {
                Text("Color Effects")
                Spacer()
                Image(systemName:"wand.and.stars")
            }
            .font(.title2)
            .foregroundColor(.accentColor)
            
            Picker("", selection: $colorType) {
                ForEach(ColorType.allCases, id:\.self) { bType in
                    Text(bType.rawValue)
                }
            }
            
            Divider()
            
            switch colorType {
                case .Threshold:
                    SliderInputView(value: 0.5, vRange: 0...1, title: "Threshold") { threshold in
                        self.slider1 = Float(threshold)
                    }
                    HStack {
                        Spacer()
                        Text("Threshold: \(slider1)")
                        Spacer()
                    }
                    
                case .Monochrome:
                    // Color, and Intensity
                    HStack {
                        Text("Color")
                        Spacer()
                        ColorPicker("", selection:$inputColor)
                            .onChange(of: inputColor) { color in
                                self.slider1 = max(0.5, slider1)
                            }
                    }
                    
                    
                    SliderInputView(value: 0.5, vRange: 0...1, title: "Intensity") { newValue in
                        self.slider1 = Float(newValue)
                    }
                    .padding(.bottom, 20)
                    
                    Text(colorType.descriptor)
                
                case .ColorControls:
                    // Saturation 1.0 (0 - 2), Brightness 1.0 (0 - 2), Contrast 1.0 (0 - 2)
                    SliderInputView(value: 0.0, vRange: -1...1, title: "Saturation") { saturation in
                        self.slider1 = Float(saturation)
                    }
                    SliderInputView(value: 0.0, vRange: -1...1, title: "Brighness") { brightness in
                        self.slider2 = Float(brightness)
                    }
                    SliderInputView(value: 0.0, vRange: -1...1, title: "Contrast") { contrast in
                        self.slider3 = Float(contrast)
                    }
                    
                    Text(colorType.descriptor)
                    
                case .ExposureAdjust:
                    // ev
                    SliderInputView(value: 0.5, vRange: -1...1, title: "Exposure") { exposure in
                        self.slider1 = Float(exposure)
                    }
                    Text(colorType.descriptor)
                    
                case .Vibrance:
                    SliderInputView(value: 0.5, vRange: 0...1, title: "Amount") { amount in
                        self.slider1 = Float(amount)
                    }
                    Text(colorType.descriptor)
                    
                case .WhitepointAdjust:
                    ColorPicker("Color", selection:$inputColor)
                    Text(colorType.descriptor)
                    
                case .ColorInvert:
                    Text(colorType.descriptor)
                    Text("No input other than an image").foregroundColor(.gray)
                    
                case .VignetteEffect:
                    // Center, Intensity, Radius
                    PointInput(tapLocation: .zero, dragLocation: .zero, multiplier: 1) { point in
                        self.inputPoint = point
                    }
                    SliderInputView(value: 1.0, vRange: 0...1, title: "Intensity") { intensity in
                        self.slider1 = Float(intensity)
                    }
                    SliderInputView(value: 0.0, vRange: 0...1, title: "Radius") { radius in
                        self.slider2 = Float(radius)
                    }
                    
                    Text(colorType.descriptor)
            }
            
            Divider()
            
            // Button & Preview
            imgPreview
            
            HStack {
                // Undo
                Button(action: {
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
        .frame(width:250)
        .padding(8)
        .onAppear() {
            if let img = image {
                self.undoImages.append(img)
            }
        }
    }
    
    /// The preview Image
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
    
    // MARK: - Methods
    
    
    /// Updates the image preview
    func updatePreview() {
        print("Updating Preview")
        let nsimage = controller.openingImage
        let context = CIContext()
        
        guard
            let bitmap = nsimage.tiffRepresentation,
            let dataIn = NSBitmapImageRep(data: bitmap),
            let ciimage = CIImage(bitmapImageRep: dataIn) else {
            print("Error. Something is missing")
            return
        }
        
        switch colorType {
            case .Threshold:
                
                let filter = CIFilter.colorThreshold()
                filter.inputImage = ciimage
                filter.threshold = self.slider1
                
                // get a CIImage from our filter or exit if that fails
                guard let outputImage = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                    // convert that to a UIImage
                    let nsImage = NSImage(cgImage: cgimg, size:ciimage.extent.size)
                    self.image = nsImage
                }
                
            case .Monochrome:
                
                let filter = CIFilter.colorMonochrome()
                filter.inputImage = ciimage
                filter.color = CIColor(cgColor: inputColor.cgColor!)
                filter.intensity = self.slider1
                
                // get a CIImage from our filter or exit if that fails
                guard let outputImage = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                    // convert that to a UIImage
                    let nsImage = NSImage(cgImage: cgimg, size:ciimage.extent.size)
                    self.image = nsImage
                }
                
            case .ColorControls:
                
                let filter = CIFilter.colorControls()
                filter.inputImage = ciimage
                filter.saturation = slider1
                filter.brightness = slider2
                filter.contrast = slider3
                
                guard let output = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(output, from: ciimage.extent) {
                    // convert that to a UIImage
                    let newImage = NSImage(cgImage: cgimg, size:ciimage.extent.size)
                    self.image = newImage
                }
                
            case .ExposureAdjust:
                
                let filter = CIFilter.exposureAdjust()
                filter.inputImage = ciimage
                filter.ev = slider1
                
                guard let output = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(output, from: ciimage.extent) {
                    // convert that to a UIImage
                    let newImage = NSImage(cgImage: cgimg, size:ciimage.extent.size)
                    self.image = newImage
                }
                
            case .Vibrance:
                
                let filter = CIFilter.vibrance()
                filter.inputImage = ciimage
                filter.amount = slider1
                
                guard let output = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(output, from: ciimage.extent) {
                    // convert that to a UIImage
                    let newImage = NSImage(cgImage: cgimg, size:ciimage.extent.size)
                    self.image = newImage
                }
                
            case .WhitepointAdjust:
                
                let filter = CIFilter.whitePointAdjust()
                filter.inputImage = ciimage
                filter.color = CIColor(cgColor: inputColor.cgColor!)
                
                guard let output = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(output, from: ciimage.extent) {
                    // convert that to a UIImage
                    let newImage = NSImage(cgImage: cgimg, size:ciimage.extent.size)
                    self.image = newImage
                }
                
            case .ColorInvert:
                
                let filter = CIFilter.colorInvert()
                filter.inputImage = ciimage
                
                guard let output = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(output, from: ciimage.extent) {
                    // convert that to a UIImage
                    let newImage = NSImage(cgImage: cgimg, size:ciimage.extent.size)
                    self.image = newImage
                }
                
            case .VignetteEffect:
                
                let filter = CIFilter.vignetteEffect()
                filter.inputImage = ciimage
                filter.center = CGPoint(x: inputPoint.x * image!.size.width, y: image!.size.height - inputPoint.y * image!.size.height)
                
                    // CGPoint(x:inputPoint.x * image!.size.width, y: inputPoint.y * image!.size.height)
                filter.intensity = slider1
                filter.radius = slider2 * Float(image!.size.width)
                
                guard let output = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(output, from: ciimage.extent) {
                    // convert that to a UIImage
                    let newImage = NSImage(cgImage: cgimg, size:ciimage.extent.size)
                    self.image = newImage
                }
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
    
    enum ColorType:String, CaseIterable {
        
        case Threshold
        case Monochrome
        
        // New
        case ColorControls
        case ExposureAdjust
        case Vibrance
        case WhitepointAdjust
        case ColorInvert
        case VignetteEffect
        
        var descriptor:String {
            switch self {
                case .Threshold: return "Applies a threshold from wich intensity of colors won't pass."
                case .Monochrome: return "Remaps colors so they fall within shades of a single color."
                case .ColorControls: return "Adjusts saturation, brightness, and contrast values."
                case .ExposureAdjust: return "Adjusts the exposure setting for an image similar to the way you control exposure for a camera when you change the F-stop."
                case .Vibrance: return "Adjusts the saturation of an image while keeping pleasing skin tones."
                case .WhitepointAdjust:
                    return "Adjusts the reference white point for an image and maps all colors in the source using the new reference."
                case .ColorInvert: return "Inverts the colors in an image."
                case .VignetteEffect: return "Modifies the brightness of an image around the periphery of a specified region."
//                default: return ""
            }
        }
    }
}

struct FXColorView_Previews: PreviewProvider {
    static var previews: some View {
        FXColorView(controller: ImageFXController(image: nil))
    }
}
