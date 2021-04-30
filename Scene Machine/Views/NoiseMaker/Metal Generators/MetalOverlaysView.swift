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
                        center = CGPoint(x: point.x * controller.textureSize.size.width, y: controller.textureSize.size.height - (point.y * controller.textureSize.size.height))
                        updatePreview()
                    }
                    .padding(.vertical, 8)
                    
                case .Halo:
                    Text("Halo")
                    PointInput(tapLocation: CGPoint.zero, dragLocation: CGPoint.zero, multiplier: 1) { point in
                        // Convert Point to Image
                        center = CGPoint(x: point.x * controller.textureSize.size.width, y: controller.textureSize.size.height - (point.y * controller.textureSize.size.height))
                        updatePreview()
                    }
                    .padding(.vertical, 8)
//                    filter.color = CIColor(color: NSColor(color1))!
//                    filter.haloRadius = max(5, slider1)
//                    filter.haloWidth = max(12, slider2)
//                    filter.striationStrength = max(1, slider3)
//                    filter.striationContrast = 0.5
//                    filter.haloOverlap = 0.77
                    // Width
                    Text("Width")
                    InputSlider(sliderRange: 10...200, value: 30) { slideInput in
                        self.slider1 = Float(slideInput)
                        self.updatePreview()
                    }
                    // Striation strength
                    Text("Striation strength")
                    InputSlider(sliderRange: 0...1, value: 0.5) { slideInput in
                        self.slider2 = Float(slideInput)
                        self.updatePreview()
                    }
                    // radius
                    Text("Center Radius")
                    InputSlider(sliderRange: 5...100, value: 10) { slideInput in
                        self.slider3 = Float(slideInput)
                        self.updatePreview()
                    }
                    
                    
                case .Sunbeam:
                    Text("Sunbeam")
                    PointInput(tapLocation: CGPoint.zero, dragLocation: CGPoint.zero, multiplier: 1) { point in
                        // Convert Point to Image
                        center = CGPoint(x: point.x * controller.textureSize.size.width, y: controller.textureSize.size.height - (point.y * controller.textureSize.size.height)) //point
                        updatePreview()
                    }
                    Text("Radius")
                    InputSlider(sliderRange: 20...200, value: 50, finish: { slide in
                        self.slider1 = Float(slide)
                        self.updatePreview()
                    })
                    Text("Contrast")
                    InputSlider(sliderRange: 0...2, value: 1, finish: { slide in
                        self.slider2 = Float(slide)
                        self.updatePreview()
                    })
                    Text("Strength")
                    InputSlider(sliderRange: 0...1, value: 1, finish: { slide in
                        self.slider3 = Float(slide)
                        self.updatePreview()
                    })
                    
                    
                    /*
                     //                filter.maxStriationRadius // Float
                     //                filter.striationContrast
                     //                filter.striationStrength
                     */
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
                        self.undoImages.append(self.image!)
                        self.updatePreview()
                    }, label: {
                        Image(systemName:"arrow.triangle.2.circlepath.circle")
                        Text("Update")
                    })
                    .help("Update Preview")
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
                filter.inputSize = CIVector(cgPoint: CGPoint(x: controller.textureSize.size.width, y: controller.textureSize.size.height))//CIVector(cgRect: CGRect(origin: .zero, size: controller.textureSize.size))
                
                filter.inputOrigin = CIVector(cgPoint: center)
                
                // get a CIImage from our filter or exit if that fails
//                guard let outputImage = filter.outputImage else { return }
                
                guard let output = filter.outputImage,
                      let cgOutput = context.createCGImage(output, from: CGRect(origin: CGPoint.zero, size: controller.textureSize.size))
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                
                //                self.image = filteredImage
//                controller.updatePreview(image: filteredImage)
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
            case .Halo:
                
                let filter = CIFilter.lenticularHaloGenerator()
                
                filter.center = center
                filter.color = CIColor(color: NSColor(color1))!
                filter.haloRadius = max(5, slider3)
                filter.haloWidth = max(10, slider1)
                filter.striationStrength = max(0.1, slider2)
                filter.striationContrast = 0.5
                filter.haloOverlap = 0.77
                
                // get a CIImage from our filter or exit if that fails
                guard let outputImage = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: CGPoint.zero, size: controller.textureSize.size)) {
                    
                    // convert that to a UIImage
                    let nsImage = NSImage(cgImage: cgimg, size:controller.textureSize.size)
//                    controller.updatePreview(image: nsImage)
                    controller.updateImage(new: nsImage, isPreview: isPreviewing)
                } else {
                    print("⚠️ No output image")
                    return
                }
                
            case .Sunbeam:
                
                let filter = CIFilter.sunbeamsGenerator()
                filter.center = center
                filter.color = .white
                filter.sunRadius = slider1 * 0.8
                filter.time = 1
                filter.maxStriationRadius = max(10, slider1)
                filter.striationContrast = slider2
                filter.striationStrength = slider3
            
                // get a CIImage from our filter or exit if that fails
                guard let outputImage = filter.outputImage else { return }
                
                // attempt to get a CGImage from our CIImage
                if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: CGPoint.zero, size: controller.textureSize.size)) {
                    
                    // convert that to a UIImage
                    let nsImage = NSImage(cgImage: cgimg, size:controller.textureSize.size)
//                    controller.updatePreview(image: nsImage)
                    controller.updateImage(new: nsImage, isPreview: isPreviewing)
                } else {
                    print("⚠️ No output image")
                    return
                }
                
            case .Caustic:
                
                let filter = CausticRefraction()
                filter.inputTileSize = controller.textureSize.size.width
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
//                    controller.updatePreview(image: nsImage)
                    controller.updateImage(new: nsImage, isPreview: isPreviewing)
                } else {
                    print("⚠️ No output image")
                    return
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
