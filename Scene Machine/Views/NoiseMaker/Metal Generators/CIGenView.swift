//
//  CIGenView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/24/21.
//

import SwiftUI



struct CIGenView: View {
    
    // Slider values
    @State private var slider1:Float = 0
    @State private var slider2:Float = 0
    @State private var slider3:Float = 0
    
    @State private var center:CGPoint = CGPoint.zero
    @State private var color0 = Color.black
    @State private var color1 = Color.white
    
    // CGPoint, or Vector
    @State private var vecPoint:CGPoint = .zero
    
    @State private var undoImages:[NSImage] = []
    
    /// Completion function. Returns an image
    var applied: (_ image:NSImage) -> Void = {_ in }
    
    enum CIGenType:String, CaseIterable {
        case Checkerboard
        case Halo
        case RandomColor
        case Sunbeam
    }
    
    @State var generatorType:CIGenType = .Checkerboard
    
    var body: some View {
        VStack {
            // Header and Picker
            Group {
                Text("CI Generators").font(.title2).foregroundColor(.accentColor)
                Picker("", selection: $generatorType) {
                    ForEach(CIGenType.allCases, id:\.self) { bType in
                        Text(bType.rawValue)
                    }
                }
                Divider()
            }
            .padding(.horizontal, 6)
            
            switch generatorType {
                case .Checkerboard:
                    Text("Checkerboard")
                    // Inputs
                    // center, color0, color1, width, sharpness
                    PointInput(tapLocation: CGPoint.zero, multiplier: 1) { (point) in
                        print("Input point: Needs to be converted")
                        self.center = point
                    }
                    ColorPicker("Color 0", selection: $color0)
                    ColorPicker("Color 1", selection: $color1)
                    SliderInputView(value: 100, vRange: 10...512, title: "Width") { width in
                        self.slider1 = Float(width)
                    }
                    .padding(.bottom, 20)
                    SliderInputView(value: 1, vRange: 0...1, title: "Sharpness") { sharp in
                        self.slider2 = Float(sharp)
                    }
                    .padding(.bottom, 20)
                    
                case .Halo:
                    Text("Halo")
                    // Inputs
                    // Center, color, radius, width, overlap, striationStrengh, striationContrast
                    PointInput(tapLocation: CGPoint.zero, multiplier: 1) { (point) in
                        print("Input point: Needs to be converted")
                        self.center = point
                    }
                    ColorPicker("Color", selection: $color0)
                    // Radius default: 70.0
                    SliderInputView(value: 70, vRange: 40...1024, title: "Radius") { radius in
                        self.slider1 = Float(radius)
                    }
                    .padding(.bottom, 20)
                    // Width default: 87
                    SliderInputView(value: 87, vRange: 50...256, title: "Width") { width in
                        self.slider2 = Float(width)
                    }
                    .padding(.bottom, 20)
                    // Striation strengh default: 0.5
                    SliderInputView(value: 87, vRange: 50...256, title: "Width") { strength in
                        self.slider3 = Float(strength)
                    }
                    .padding(.bottom, 20)
                    
                default:
                    Text("Not Imaplemented")
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
    
    
    /// Updates the image preview
    func updatePreview() {
        print("Updating Preview")
        switch generatorType {
            case .Checkerboard:
                // Inputs
                // center, color0, color1, width, sharpness
                
                    
                    let context = CIContext()
                    let currentFilter = CIFilter.checkerboardGenerator()
                    currentFilter.center = center
                    currentFilter.color0 = CIColor(color: NSColor(color0))!
                    currentFilter.color1 = CIColor(color: NSColor(color1))!
                    currentFilter.width = slider1
                    currentFilter.sharpness = slider2
                
                    // get a CIImage from our filter or exit if that fails
                    guard let outputImage = currentFilter.outputImage else { return }
                    
                    // attempt to get a CGImage from our CIImage
                    if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: CGPoint.zero, size: CGSize(width: 1024, height: 1024))) {
                        // convert that to a UIImage
                        let nsImage = NSImage(cgImage: cgimg, size:CGSize(width: 1024, height: 1024))
                        self.image = nsImage
                    }
                
            case .Halo:
                // Center, color, radius, width, overlap, striationStrengh, striationContrast
                let context = CIContext()
                let currentFilter = CIFilter.lenticularHaloGenerator()
                currentFilter.center = center
                currentFilter.color = CIColor(color: NSColor(color0))!
                currentFilter.haloRadius = slider1
                currentFilter.haloWidth = slider2
                currentFilter.striationStrength = slider3
                // (Not implemented
                currentFilter.striationContrast = 0.5
                currentFilter.haloOverlap = 0.77
                
                // get a CIImage from our filter or exit if that fails
                guard let outputImage = currentFilter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: CGPoint.zero, size: CGSize(width: 1024, height: 1024))) {
                    
                    // convert that to a UIImage
                    let nsImage = NSImage(cgImage: cgimg, size:CGSize(width: 1024, height: 1024))
                    self.image = nsImage
                }
            default:print("Not implemented")
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
    
}

struct CIGenView_Previews: PreviewProvider {
    static var previews: some View {
        CIGenView()
    }
}
