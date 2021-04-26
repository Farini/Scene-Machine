//
//  MetalNoiseView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/26/21.
//

import SwiftUI

struct MetalNoiseView: View {
    
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
                    CounterInput(value: $stepCount2, range: 5...20, title: "Tile Count")
                case .Caustic:
                    Text("Caustic")
                    // Tile size
                    // Time
                    CounterInput(value: $stepCount1, range: 1...20, title: "Time")
                    SliderInputView(value: slider1, vRange: 0.1...1.0, title: "Tile size") { (tileSize) in
                        self.slider1 = Float(tileSize)
                    }
                case .Waves:
                    Text("Waves")
                    Text("Not yet implemented").foregroundColor(.gray)
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
    
    // Image used to Preview effect
    @State var image:NSImage? = NSImage(named:"Checkerboard")
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
        let mainImage = image ?? NSImage(named:"Checkerboard")!
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
                filter.tileSize = 512
                filter.tileCount = stepCount2
                filter.time = stepCount1
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                self.image = filteredImage
                
            case .Caustic:
                print("Caustic")
                
                let filter = CausticNoiseMetal()
                filter.inputImage = coreImage
                filter.tileSize = (slider1 * Float(image!.size.width)).rounded()
                filter.time = stepCount1
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: mainImage.size)
                
                self.image = filteredImage
                
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

struct MetalNoiseView_Previews: PreviewProvider {
    static var previews: some View {
        MetalNoiseView()
    }
}
