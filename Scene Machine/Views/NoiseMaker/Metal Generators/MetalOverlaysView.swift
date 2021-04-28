//
//  MetalOverlaysView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/28/21.
//

import SwiftUI

struct MetalOverlaysView: View {
    
    @ObservedObject var controller:MetalGenController
    
    // Slider values
    @State private var slider1:Float = 0
    @State private var slider2:Float = 0
    @State private var slider3:Float = 0
    
    @State private var stepCount1:Int = 1
    @State private var stepCount2:Int = 10
    
    @State private var center:CGPoint = CGPoint.zero
    @State private var color0 = Color.black
    @State private var color1 = Color.white
    
    // CGPoint, or Vector
    @State private var vecPoint:CGPoint = .zero
    
    @State private var undoImages:[NSImage] = []
    
    /// Completion function. Returns an image
    var applied: (_ image:NSImage) -> Void = {_ in }
    
    enum OverlayType:String, CaseIterable {
        case LensFlare
        case Halo
        case Sunbeam
        case Caustic
    }
    
    @State var overlayType:OverlayType = .LensFlare
    
    var body: some View {
        VStack {
            Text("Overlays").foregroundColor(.orange).font(.title2)
            Picker("Type", selection: $overlayType) {
                ForEach(OverlayType.allCases, id:\.self) { overType in
                    Text(overType.rawValue)
                }
                .onChange(of: overlayType, perform: { value in
                    self.updatePreview()
                })
            }
            
            Divider()
            
            switch overlayType {
                case .LensFlare:
                    Text("Lens Flare")
                    // Number of tiles, Color inside?, Color outside?
//                    CounterInput(value: $stepCount1, range: 1...20, title: "Time")
//                    CounterInput(value: $stepCount2, range: 5...20, title: "Tile Count")
                    
                    PointInput(tapLocation: CGPoint.zero, dragLocation: CGPoint.zero, multiplier: 1) { point in
                        // Convert Point to Image
                        center = point
                        updatePreview()
                    }
                    .padding(.vertical, 8)
                    
                case .Halo:
                    Text("Halo")
                    PointInput(tapLocation: CGPoint.zero, dragLocation: CGPoint.zero, multiplier: 1) { point in
                        // Convert Point to Image
                        center = point
                        updatePreview()
                    }
                    .padding(.vertical, 8)
                    
                case .Sunbeam:
                    Text("Sunbeam")
                    PointInput(tapLocation: CGPoint.zero, dragLocation: CGPoint.zero, multiplier: 1) { point in
                        // Convert Point to Image
                        center = point
                        updatePreview()
                    }
                    .padding(.vertical, 8)
                    
                case .Caustic: // Refraction
                
                    Text("Caustic Refraction")
                    PointInput(tapLocation: CGPoint.zero, dragLocation: CGPoint.zero, multiplier: 1) { point in
                        // Convert Point to Image
                        center = point
                        updatePreview()
                    }
                    .padding(.vertical, 8)
                    
                default:
                    Text("Not Implemented").foregroundColor(.gray)
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
            
            Spacer()
        }
        .frame(width:250)
        .padding(6)
        
    }
    
    // MARK: - Image Preview
    
    // Image used to Preview effect
    @State var image:NSImage? = NSImage(named:"Checkerboard")
    @State private var isPreviewing:Bool = true
    var imgPreview: some View {
        VStack {
            Toggle("Preview", isOn: $isPreviewing)
            if isPreviewing {
                let img = controller.previewImage ?? controller.image
                
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(minWidth: 200, maxWidth: 250, minHeight: 200, maxHeight: 250, alignment: .center)
             
            } else {
                Text("Preview is off").foregroundColor(.gray).padding(12)
            }
        }
    }
    
    // MARK: - Update & Apply
    
    /// Updates the image preview
    func updatePreview() {
        print("Updating Preview")
        let mainImage = controller.previewImage ?? controller.image
        guard let imageData = mainImage.tiffRepresentation,
              let imageBitmap = NSBitmapImageRep(data:imageData),
              let coreImage = CIImage(bitmapImageRep: imageBitmap) else {
            return
        }
        
        let context = CIContext()
        
        switch overlayType {
            case .LensFlare:
                
                let filter = LensFlare()
                filter.inputSize = CIVector(cgRect: CGRect(origin: .zero, size: controller.textureSize.size))
                
                filter.inputOrigin = CIVector(cgPoint: center)
                
                guard let output = filter.outputImage,
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                
                //                self.image = filteredImage
                controller.updatePreview(image: filteredImage)
                
            case .Halo:
                
                let filter = CIFilter.lenticularHaloGenerator()
                
                filter.center = center
                filter.color = CIColor(color: NSColor(color0))!
                filter.haloRadius = slider1
                filter.haloWidth = slider2
                filter.striationStrength = slider3
                filter.striationContrast = 0.5
                filter.haloOverlap = 0.77
                
                // get a CIImage from our filter or exit if that fails
                guard let outputImage = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: CGPoint.zero, size: controller.textureSize.size)) {
                    
                    // convert that to a UIImage
                    let nsImage = NSImage(cgImage: cgimg, size:controller.textureSize.size)
                    controller.updatePreview(image: nsImage)
                }
                
            case .Sunbeam:
                
                let filter = CIFilter.sunbeamsGenerator()
                filter.center = center
//                filter.color
//                filter.maxStriationRadius // Float
//                filter.striationContrast
//                filter.striationStrength
            
                // get a CIImage from our filter or exit if that fails
                guard let outputImage = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: CGPoint.zero, size: controller.textureSize.size)) {
                    
                    // convert that to a UIImage
                    let nsImage = NSImage(cgImage: cgimg, size:controller.textureSize.size)
                    controller.updatePreview(image: nsImage)
                }
                
            case .Caustic:
                
                let filter = CausticRefraction()
                filter.inputImage = coreImage
//                filter.inputLensScale
//                filter.inputLightingAmount
//                filter.inputRefractiveIndex
//                filter.inputSoftening
            
                // get a CIImage from our filter or exit if that fails
                guard let outputImage = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: CGPoint.zero, size: controller.textureSize.size)) {
                    
                    // convert that to a UIImage
                    let nsImage = NSImage(cgImage: cgimg, size:controller.textureSize.size)
                    controller.updatePreview(image: nsImage)
                }
                
            default:print("Not implemented")
        }
    }
    
    /// Applies the effect
    func apply() {
        // To apply, pass a function from the parent view
        // and return a NSImage when the effects are ready
        let image = controller.previewImage ?? controller.image
        applied(image)
    }
}

struct MetalOverlaysView_Previews: PreviewProvider {
    static var previews: some View {
        MetalOverlaysView(controller: MetalGenController(select: .Overlay))
    }
}
