//
//  MetalTilesView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/26/21.
//

import SwiftUI

struct MetalTilesView: View {
    
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
    
    enum MetalTileType:String, CaseIterable {
        case Hexagons
        case Checkerboard
        // case Voronoi
        case RandomMaze
        case Truchet
        case Bricks
    }
    
    @State var tileType:MetalTileType = .Hexagons
    
    var body: some View {
        VStack {
            Text("Tiles").foregroundColor(.orange).font(.title2)
            Picker("Type", selection: $tileType) {
                ForEach(MetalTileType.allCases, id:\.self) { tile in
                    Text(tile.rawValue)
                }
                .onChange(of: tileType, perform: { value in
                    self.updatePreview()
                })
            }
            
            switch tileType {
                case .Hexagons:
                    Text("Hexagons")
                    // Number of tiles, Color inside?, Color outside?
                    CounterInput(value: $stepCount1, range: 1...20, title: "Time")
                    CounterInput(value: $stepCount2, range: 5...20, title: "Tile Count")
                case .Checkerboard:
                    CounterInput(value: $stepCount1, range: 5...20, title: "Tile Count")
                    CounterInput(value: $stepCount2, range: 1...3, title: "Method")
                    Text("Method 1: Gradient, 2 = Random, 3 = white")
                case .RandomMaze:
                    CounterInput(value: $stepCount1, range: 1...20, title: "Tile Count")
                case .Truchet:
                    CounterInput(value: $stepCount1, range: 1...20, title: "Tile Count")
                case .Bricks:
                    CounterInput(value: $stepCount1, range: 1...20, title: "Tile Count")
                    SliderInputView(value: 0.5, vRange: 0.5...1.5, title: "Normal / Color") { value in
                        self.slider1 = Float(value)
                    }
                    
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
    
    // Image used to Preview effect
    @State var image:NSImage? = NSImage(named:"Checkerboard")
    @State private var isPreviewing:Bool = true
    var imgPreview: some View {
        VStack {
            Toggle("Preview", isOn: $isPreviewing)
            if isPreviewing {
                let img = controller.previewImage ?? controller.image
                
//                if let img = image {
                    Image(nsImage: img)
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
        let mainImage = controller.previewImage ?? controller.image
        guard let imageData = mainImage.tiffRepresentation,
              let imageBitmap = NSBitmapImageRep(data:imageData),
              let coreImage = CIImage(bitmapImageRep: imageBitmap) else {
            return
        }
        
        let context = CIContext()
        
        switch tileType {
            case .Hexagons:
                print("Hexagons")
                
                let filter = HexagonFilter()
                filter.inputImage = coreImage
                filter.tileSize = Float(controller.textureSize.size.width)
                
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                
//                self.image = filteredImage
                controller.updatePreview(image: filteredImage)
                
            case .Checkerboard:
                print("Checkerboard")
                
                let filter = CheckerMetal()
                filter.inputImage = coreImage
                filter.tileSize = Float(controller.textureSize.size.width)
                filter.tileCount = stepCount1
                
                if stepCount2 == 1 { filter.method = .Gradient }
                else if stepCount2 == 2 { filter.method = .Random }
                else if stepCount2 == 3 { filter.method = .White }
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                
//                self.image = filteredImage
                controller.updatePreview(image: filteredImage)
                
            case .RandomMaze:
                print("Maze")
                
                let filter = RandomMaze()
                filter.inputImage = coreImage
                filter.tileSize = Float(controller.textureSize.size.width)
                filter.tileCount = stepCount1
                
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                
//                self.image = filteredImage
                controller.updatePreview(image: filteredImage)
                
            case .Truchet:
                
                let context = CIContext()
                
                let truchet = TruchetFilter() //CausticNoise()
                
                let noise = CIFilter.randomGenerator()
                let noiseImage = noise.outputImage!
                
                truchet.inputImage = noiseImage
                truchet.tileSize = Float(controller.textureSize.size.width)
                truchet.tileCount = stepCount1
                
                // get a CIImage from our filter or exit if that fails
                guard let outputImage = truchet.outputImage(),
                      let cgOutput = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: controller.textureSize.size)) else { return }
                
                // attempt to get a CGImage from our CIImage
//                if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))) {
//                    // convert that to a UIImage
//                    let nsImage = NSImage(cgImage: cgimg, size:CGSize(width: 1024, height: 1024))
//                    self.image = nsImage
//                }
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                controller.updatePreview(image: filteredImage)
                
            case .Bricks:
                
                let context = CIContext()
                
                let bricks = BricksFilter() //CausticNoise()
                
                let noise = CIFilter.randomGenerator()
                let noiseImage = noise.outputImage!
                
                bricks.inputImage = noiseImage
                bricks.tileSize = Float(controller.textureSize.size.width)
                bricks.tileCount = stepCount1 == 1 ? 10:stepCount1
                bricks.time = Double(slider1)
                
                // get a CIImage from our filter or exit if that fails
                guard let outputImage = bricks.outputImage(),
                      let cgOutput = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: controller.textureSize.size)) else { return }
                
                // attempt to get a CGImage from our CIImage
                //                if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))) {
                //                    // convert that to a UIImage
                //                    let nsImage = NSImage(cgImage: cgimg, size:CGSize(width: 1024, height: 1024))
                //                    self.image = nsImage
                //                }
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                controller.updatePreview(image: filteredImage)
            
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
        controller.image = image
    }
}

struct MetalTilesView_Previews: PreviewProvider {
    static var previews: some View {
        MetalTilesView(controller: MetalGenController(select: .Tiles))
    }
}
