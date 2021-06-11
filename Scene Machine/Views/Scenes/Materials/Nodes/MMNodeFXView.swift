//
//  MMNodeFXView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/27/21.
//

import SwiftUI
import SceneKit



/// Right Node View - Displays Effects applied to image of `MaterialMode`
struct MMNodeFXView:View {
    
    // Apply the effect to the material property only.
    // That way, it will only save when the user saves the material.
    // or.....
    // Have an "apply" button, with an image view.
    // if you like the image, apply to the material and change the image
    
    @ObservedObject var controller:MaterialMachineController
    var original:NSImage?
    @State var effectImage:NSImage?
    
    @State private var popFX:Bool = false
    
    @State var wrapS:SCNWrapMode = SCNWrapMode.clamp
    @State var wrapT:SCNWrapMode = SCNWrapMode.clamp
    
    var body: some View {
        VStack {
            
            // Buttons
            HStack {
                Text("FX")
                Spacer()
                
                // Select Effect
                Button(action: {
                    popFX.toggle()
                }, label: {
                    Image(systemName: "wand.and.stars")
                })
                .popover(isPresented: $popFX, content: {
                    MMFXPopoverView(controller:controller) { newImage in
//                        controller.uvImage = newImage
                        controller.updateUVImage(image: newImage)
                    }
//                    VStack {
//                        Button("Blur") {
//                            self.applyBlur()
//                        }
//                        Text("More effects coming soon.")
//                    }
//                    .padding()
                })
                // .disabled(effectImage == nil)
                .help("Select an effect to apply to the image")
                
                // Apply
                Button(action: {
                    guard let image = effectImage else { return }
                    controller.updateUVImage(image: image)
                }, label: {
                    Image(systemName:"rectangle.badge.checkmark")
                })
                .disabled(effectImage == nil)
                .help("Apply effect")
            }
            
            
            HStack {
                Text("Wrap")
                Picker("S", selection: $wrapS) {
                    ForEach(SCNWrapMode.allCases, id:\.self) { wrapMode in
                        Text(wrapMode.toString())
                    }
                }
                .onChange(of: wrapS, perform: { value in
                    self.updateMaterialWrapping()
                })
                
                Picker("T", selection: $wrapT) {
                    ForEach(SCNWrapMode.allCases, id:\.self) { wrapMode in
                        Text(wrapMode.toString())
                    }
                }
                .onChange(of: wrapT, perform: { value in
                    self.updateMaterialWrapping()
                })
            }
            
            if let image = effectImage {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 200, height: 200, alignment: .center)
                    .border(Color.gray, width: 0.5)
            } else if let image = original {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 200, height: 200, alignment: .center)
                    .border(Color.gray, width: 0.5)
            }
            // Blur (disk, box)
            // Monochrome
            // ColorAdjust, Exposure adjust, vibrance
            // Invert Colors
            // Normal shader
        }
        .frame(width:200)
    }
    
    func applyBlur() {
        guard let image = original else { return }
        guard let imageData = image.tiffRepresentation,
              let imageBitmap = NSBitmapImageRep(data:imageData),
              let coreImage = CIImage(bitmapImageRep: imageBitmap) else {
            return
        }
        
        let context = CIContext()
        
        let filter = CIFilter.boxBlur()
        filter.inputImage = coreImage
        filter.radius = 20
        
        guard let output = filter.outputImage,
              let cgOutput = context.createCGImage(output, from: output.extent)
        else {
            print("⚠️ No output image")
            return
        }
        
        let filteredImage = NSImage(cgImage: cgOutput, size: image.size)
        
        self.effectImage = filteredImage
        
    }
    
    /// Updates `WrapS` and `wrapT` properties of material
    func updateMaterialWrapping() {
        switch controller.materialMode {
            case .Diffuse:
                controller.material.diffuse.wrapS = wrapS
                controller.material.diffuse.wrapT = wrapT
            case .Roughness:
                controller.material.roughness.wrapS = wrapS
                controller.material.roughness.wrapT = wrapT
            case .AO:
                controller.material.ambientOcclusion.wrapS = wrapS
                controller.material.ambientOcclusion.wrapT = wrapT
            case .Emission:
                controller.material.emission.wrapS = wrapS
                controller.material.emission.wrapT = wrapT
            case .Normal:
                controller.material.normal.wrapS = wrapS
                controller.material.normal.wrapT = wrapT
        }
    }
}

// Color monochrome
// Color vibrance
// Crystalize
// Edge
// Bloom
// Sharpen
// Transparents
// Normal Map

enum MMFXType:String, CaseIterable {
    case Blur
    case Monochrome
    case Vibrance
    case Crystalize
    case Pixellate
    case Edge
    case Bloom
    case Sharpen
    case WHITransparent
    case BLKTransparent
    case NormalMap
}

/* The popover that shows the Effects that can be applied */
struct MMFXPopoverView: View {
    
    @ObservedObject var controller:MaterialMachineController
    
    @State var fxType:MMFXType = .Blur
    
    @State private var slider1:Float = 0
    @State private var slider2:Float = 0
    @State private var slider3:Float = 0
    
    @State private var color:Color = .black
    @State private var color2:Color = .white
    
    /// The image with the effecct applied
    @State var fxImage:NSImage = NSImage(size:CGSize(width: 1024, height: 1024))
    
    /// Backup of the image
    @State var undoImage:NSImage = NSImage(size:CGSize(width: 1024, height: 1024))
    
    /// Completion function. Returns an image
    var applied: (_ image:NSImage) -> Void = {_ in }
    
    var body: some View {
        HStack(alignment:.top) {
            VStack {
                
                HStack {
                    Text("FX")
                    Spacer()
                    Picker("", selection: $fxType) {
                        ForEach(MMFXType.allCases, id:\.self) { fx in
                            Text(fx.rawValue)
                        }
                    }
                }
                .frame(width:200)
                
                Divider()
                    .frame(width:200)
                
                switch fxType {
                    case .Blur:
                        // Level Slider
                        Slider(value: $slider1, in: 2.0...50.0, step: 1.0)
                    case .Monochrome:
                        ColorPicker("Color", selection: $color)
                        SliderInputView(value: 0.5, vRange: 0...1, title: "Intensity") { newValue in
                            self.slider1 = Float(newValue)
                        }
                        
                    case .Vibrance:
                        SliderInputView(value: 0.5, vRange: 0...1, title: "Intensity") { newValue in
                            self.slider1 = Float(newValue)
                        }
                    case .Crystalize:
                        Slider(value: $slider1, in: 2.0...50.0, step: 1.0)
                        
                    case .Pixellate:
                        Slider(value: $slider1, in: 2.0...50.0, step: 1.0)
                        
                    case .Edge:
                        SliderInputView(value: 0.5, vRange: 0...1, title: "Intensity") { newValue in
                            self.slider1 = Float(newValue)
                        }
                    case .Bloom:
                        // Radius
                        Slider(value: $slider1, in: 2.0...30.0, step: 1.0)
                        // Intensity
                        SliderInputView(value: 0.5, vRange: 0...1, title: "Intensity") { newValue in
                            self.slider2 = Float(newValue)
                        }
                    case .Sharpen:
                        SliderInputView(value: 0.5, vRange: 0...1, title: "Sharpness") { newValue in
                            self.slider1 = Float(newValue)
                        }
                    case .WHITransparent:
                        SliderInputView(value: 0.5, vRange: 0...1, title: "Threshold") { newValue in
                            self.slider1 = Float(newValue)
                        }
                    case .BLKTransparent:
                        SliderInputView(value: 0.5, vRange: 0...1, title: "Threshold") { newValue in
                            self.slider1 = Float(newValue)
                        }
                    case .NormalMap:
                        Text("No input").foregroundColor(.gray)
                        
                }
                
                Divider()
                    .frame(width:200)
                
                HStack {
                    Button("Apply") {
                        applied(fxImage)
                    }
                    Spacer()
                    Button("Cancel") {
                        applied(undoImage)
                    }
                }
                
            }
            .frame(width:200)
            .padding()
            
            Divider()
                .frame(height:250)
            
            VStack {
                Text("Image")
                Image(nsImage:fxImage)
                    .resizable()
                    .frame(width:250, height:250)
            }
            
        }
        .padding()
        .onAppear() {
            updateUIContext()
        }
        .onChange(of:fxType) { newfx in
            updateUIContext()
        }
        .onChange(of:slider1) { value in
            previewEffect()
        }
        .onChange(of:slider2) { value in
            previewEffect()
        }
        .onChange(of:color) { value in
            previewEffect()
        }
        
    }
    
    func updateUIContext() {
        switch fxType {
            case .Crystalize, .Pixellate, .Blur: self.slider1 = 2.0
            case .Monochrome, .Vibrance, .Edge, .Sharpen: self.slider1 = 0.5
            case .Bloom:
                slider1 = 2.0
                slider2 = 0.5
            case .WHITransparent, .BLKTransparent: self.slider1 = 0.12
            default: self.slider1 = 1.0
        }
        previewEffect()
    }
    
    func previewEffect() {
        
        guard let mainImage = controller.uvImage else { return }
        self.undoImage = mainImage
        
        guard let imageData = mainImage.tiffRepresentation,
              let imageBitmap = NSBitmapImageRep(data:imageData),
              let coreImage = CIImage(bitmapImageRep: imageBitmap) else {
            return
        }
        
        
        let context = CIContext()
        
        switch fxType {
            case .Blur:
                let filter = CIFilter.discBlur()
                filter.inputImage = coreImage
                filter.radius = self.slider1
                
                self.createImage(from: filter, context: context)
                
            case .Monochrome:
                let filter = CIFilter.colorMonochrome()
                filter.inputImage = coreImage
                filter.color = CIColor(cgColor: color.cgColor!)
                filter.intensity = slider1
                
                self.createImage(from: filter, context: context)
                
            case .Vibrance:
                let filter = CIFilter.vibrance()
                filter.inputImage = coreImage
                filter.amount = slider1
                
                self.createImage(from: filter, context: context)
                
            case .Crystalize:
                let filter = CIFilter.crystallize()
                filter.inputImage = coreImage
                filter.center = CGPoint(x: mainImage.size.width / 2, y: mainImage.size.height / 2)
                filter.radius = slider1
                
                self.createImage(from: filter, context: context)
                
            case .Pixellate:
                let filter = CIFilter.pixellate()
                filter.inputImage = coreImage
                filter.center = CGPoint(x: mainImage.size.width / 2, y: mainImage.size.height / 2)
                filter.scale = slider1
                
                self.createImage(from: filter, context: context)
                
            case .Edge:
                let filter = CIFilter.edges()
                filter.inputImage = coreImage
                filter.intensity = self.slider1
                self.createImage(from: filter, context: context)
                
            case .Bloom:
                let filter = CIFilter.bloom()
                filter.inputImage = coreImage
                filter.radius = slider1
                filter.intensity = slider2
                self.createImage(from: filter, context: context)
                
            case .Sharpen:
                let filter = CIFilter.sharpenLuminance()
                filter.inputImage = coreImage
                filter.sharpness = slider1
                self.createImage(from: filter, context: context)
                
            case .WHITransparent:
                let filter = WHITransparent()
                filter.inputImage = coreImage
                filter.threshold = slider1
                self.createImage(from: filter, context: context)
                
            case .BLKTransparent:
                let filter = BLKTransparent()
                filter.inputImage = coreImage
                filter.threshold = slider1
                self.createImage(from: filter, context: context)
                
            case .NormalMap:
                let filter = NormalMapFilter()
                filter.inputImage = coreImage
                filter.tileSize = Float(mainImage.size.width)
                self.createImage(from: filter, context: context)
        }
                

    }
    
    func createImage(from filter: CIFilter, context:CIContext) {
        
        print("Creating Image")
        guard let mainImage = controller.uvImage else { return }
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            print("⚠️ No output image")
            return
        }
        
        // let cgImage = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: controller.textureSize.size))
        
        let filteredImage = NSImage(cgImage: cgImage, size: NSSize(width: mainImage.size.width, height: mainImage.size.height))
        self.fxImage = filteredImage
        
//        controller.updateImage(new: filteredImage, isPreview: isPreviewing)
        
    }
    
}

struct FXNode_Previews: PreviewProvider {
    static var previews: some View {
        MMNodeFXView(controller: MaterialMachineController(), original: nil, effectImage: nil)
    }
}

struct FXPopover_Previews: PreviewProvider {
    static var previews: some View {
        MMFXPopoverView(controller: MaterialMachineController())
//        Text("Hi")
        
    }
}
