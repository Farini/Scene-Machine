//
//  MetalNoiseView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/26/21.
//

import SwiftUI

struct MetalNoiseView: View {
    
    @ObservedObject var controller:MetalGenController
    
    // Slider values
    @State private var slider1:Float = 1
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
    
    enum MetalNoiseType:String, CaseIterable {
        case Voronoi
        case Caustic
        case Waves
        case Epitrochoidal
        case Plasma
    }
    
    @State var noiseType:MetalNoiseType = .Voronoi
    
    var body: some View {
        VStack {
            Text("Metal Noise").foregroundColor(.orange).font(.title2)
            
            Picker("Type", selection: $noiseType) {
                ForEach(MetalNoiseType.allCases, id:\.self) { noise in
                    Text(noise.rawValue)
                }
                .onChange(of: noiseType, perform: { value in
                    self.updatePreview()
                })
            }
            
            Divider()
            
            switch noiseType {
                case .Voronoi:
                    Text("Voronoi")
                    // Number of tiles, Color inside?, Color outside?
                    CounterInput(value: $stepCount1, range: 1...20, title: "Time")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
                    CounterInput(value: $stepCount2, range: 5...17, title: "Tile Count")
                        .onChange(of: stepCount2) { _ in
                            updatePreview()
                        }
                case .Caustic:
                    Text("Caustic")
                    // Tile size
                    // Time
                    CounterInput(value: $stepCount1, range: 1...20, title: "Time")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
                    SliderInputView(value: slider1, vRange: 0.1...1.0, title: "Tile size") { (tileSize) in
                        self.slider1 = Float(tileSize)
                        updatePreview()
                    }
                case .Waves:
                    Text("Waves")
                    
                    CounterInput(value: $stepCount1, range: 1...20, title: "Time")
                case .Epitrochoidal:
                    // zoom, time
                    
                    SliderInputView(value: slider1, vRange: 0.1...1.0, title: "Time") { time in
                        self.slider1 = Float(time)
                        updatePreview()
                    }
                    CounterInput(value: $stepCount1, range: 3...10, title: "Zoom")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
                    Text("Produces Epitrochoidal Waves.")
                case .Plasma:
                    
                    CounterInput(value: $stepCount1, range: 3...10, title: "Iterations")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
                    SliderInputView(value: 1, vRange: 1...24, title: "Time") { newTime in
                        self.slider1 = Float(newTime)
                        updatePreview()
                    }
                    SliderInputView(value: 1, vRange: 0...2, title: "Sharpness") { newTime in
                        self.slider2 = Float(newTime)
                        updatePreview()
                    }
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
            
            Spacer()
        }
        .frame(width:250)
        .padding(6)
        .onAppear() {
            updatePreview()
        }
    }
    
    // Image used to Preview effect
//    @State var image:NSImage? = NSImage(named:"Checkerboard")
    @State private var isPreviewing:Bool = true
    var imgPreview: some View {
        VStack {
            Toggle("Preview", isOn: $isPreviewing)
            if isPreviewing {
//                if let img = image {
                Image(nsImage: controller.previewImage ?? controller.image)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(minWidth: 200, maxWidth: 250, minHeight: 200, maxHeight: 250, alignment: .center)
//                } else {
//                    Text("No preview Image").foregroundColor(.gray).padding(12)
//                }
            } else {
                Text("Preview is off").foregroundColor(.gray).padding(12)
            }
        }
    }
    
    // MARK: - Update & Apply
    
    /// Updates the image preview
    func updatePreview() {
        
        print("Updating Preview")
        let mainImage = controller.image
        guard let imageData = mainImage.tiffRepresentation,
              let imageBitmap = NSBitmapImageRep(data:imageData),
              let coreImage = CIImage(bitmapImageRep: imageBitmap) else {
            return
        }
        
        let context = CIContext()
        
        switch noiseType {
            case .Voronoi:
                print("Voronoi")
                
                let filter = VoronoiFilter()
                filter.inputImage = coreImage
                filter.tileSize = Float(controller.textureSize.size.width)
                filter.tileCount = stepCount2
                filter.time = stepCount1
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
//                if isPreviewing {
//                    controller.previewImage = filteredImage
//                } else {
//                    controller.image = filteredImage
//                }
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
                
            case .Caustic:
                print("Caustic")
                
                let filter = CausticNoiseMetal()
                filter.inputImage = coreImage
//                filter.tileSize = (slider1 * Float(image!.size.width)).rounded()
                filter.tileSize = Float(controller.textureSize.size.width)
                filter.time = stepCount1
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
            case .Waves:
                
                let filter = WavesFilter()
                filter.inputImage = coreImage
                filter.tileSize = Float(controller.textureSize.size.width)
                filter.time = Double(stepCount1)
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
//                if isPreviewing {
//                    controller.previewImage = filteredImage
//                } else {
//                    controller.image = filteredImage
//                }
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
            case .Epitrochoidal:
                
                let filter = EpitrochoidalWaves()
                filter.inputImage = coreImage
                filter.tileSize = Float(controller.textureSize.size.width)
                filter.time = slider1
                filter.zoom = stepCount1
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
            case .Plasma:
                
                let filter = PlasmaFilter()
                filter.inputImage = coreImage
                filter.tileSize = Float(controller.textureSize.size.width)
                filter.time = slider1
                filter.iterations = Float(stepCount1)
                filter.sharpness = slider2
                
//                filter.zoom = stepCount1
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
//            default:print("Not implemented")
                
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

struct MetalNoiseView_Previews: PreviewProvider {
    static var previews: some View {
        MetalNoiseView(controller: MetalGenController(select: .Noise))
    }
}
