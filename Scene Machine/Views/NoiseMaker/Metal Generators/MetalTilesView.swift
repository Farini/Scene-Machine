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
    @State private var stepCount2:Int = 4
    
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
        case Interlaced
        case Bricks
        case Circuitboard
        case TriangleGrid
        
        
        case Test
        
        case Tricapsule
        case CornerHole
        case CheckerScale
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
                
                // new
                case .Tricapsule:
                    Text("Tricapsules")
                    CounterInput(value: $stepCount1, range: 4...20, title: "Tile Count")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
                    
                case .CornerHole:
                    
                    Text("Corner Holes")
                    
                    CounterInput(value: $stepCount1, range: 4...20, title: "Tile Count")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
                    
                case .CheckerScale:
                    
                    Text("Checker Scale")
                    
                    CounterInput(value: $stepCount1, range: 4...20, title: "Tile Count")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
                    
                    SliderInputView(value: 1.0, vRange: 1.0...2.0, title: "Time") { value in
                        self.slider1 = Float(value)
                        updatePreview()
                    }
                
                // end new
                    
                case .Hexagons:
                    Text("Hexagons")
                    // Number of tiles, Color inside?, Color outside?
                    CounterInput(value: $stepCount1, range: 1...20, title: "Time")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
                    CounterInput(value: $stepCount2, range: 5...20, title: "Tile Count")
                        .onChange(of: stepCount2) { value in
                            updatePreview()
                        }
                    
                case .Checkerboard:
                    CounterInput(value: $stepCount1, range: 5...20, title: "Tile Count")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
                    CounterInput(value: $stepCount2, range: 1...3, title: "Method")
                        .onChange(of: stepCount2) { value in
                            updatePreview()
                        }
                    Text("Method 1: Gradient, 2 = Random, 3 = white")
                case .RandomMaze:
                    CounterInput(value: $stepCount1, range: 1...20, title: "Tile Count")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
                case .Truchet:
                    CounterInput(value: $stepCount1, range: 1...20, title: "Tile Count")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
                case .Bricks:
                    CounterInput(value: $stepCount1, range: 1...20, title: "Tile Count")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
                    SliderInputView(value: 0.5, vRange: 0.5...1.5, title: "Normal / Color") { value in
                        self.slider1 = Float(value)
                        updatePreview()
                    }
                case .Interlaced:
                    CounterInput(value: $stepCount1, range: 1...20, title: "Tile Count")
                        .onChange(of: stepCount1) { value in
                            updatePreview()
                        }
//                    SliderInputView(value: 0.5, vRange: 0.5...1.5, title: "Normal / Color") { value in
//                        self.slider1 = Float(value)
//                        updatePreview()
//                    }
                    ColorPicker("Color 1", selection: $color0)
                    ColorPicker("Color 2", selection: $color1)
                    
                case .Circuitboard:
                    Text("Circuitboard")
                    Text("No parameters").foregroundColor(.gray)
                    
                case .TriangleGrid:
                    Text("Triangle Grid")
                    
                    SliderInputView(value: 1, vRange: 1...2, title: "Time") { value in
                        self.slider1 = Float(value)
                        updatePreview()
                    }
                    
                case .Test:
                    Text("Testing new features").foregroundColor(.gray)
                    
//                default: Text("Not Implemented").foregroundColor(.gray)
                
            }
            
            Divider()
            
            // Button & Preview
            Group {
                
                // Preview
                imgPreview
                
                Divider()
                
                // Buttons
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
        .onAppear() {
            self.updatePreview()
        }
    }
    
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
    
    
//    func updateDefaultValues() {
//        switch tileType {
//            case .Checkerboard, .Bricks, .Hexagons, .RandomMaze, .Truchet:
//                self.stepCount1 = 4
//        }
//    }
    
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
        
        switch tileType {
            
            case .Tricapsule:
                
                let filter = TricapsuleGrid()
                filter.inputImage = coreImage
                filter.tileCount = 4
                filter.time = CGFloat(max(1, slider1))
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                
                self.image = filteredImage
                
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
            case .CornerHole:
                
                // Corner Holes
                let filter = CornerHoles()
                filter.inputImage = coreImage
                filter.tileCount = 4
                filter.time = max(1, slider1)
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                
                self.image = filteredImage
                
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
            case .CheckerScale:
                
                // Scaling Checkerboard
                
                let filter = ScalingCheckerboard()
                filter.inputImage = coreImage
                filter.tileCount = 4
                filter.time = max(1, slider1)
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                
                self.image = filteredImage
                
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
            case .Test:
                
               print("test")
            
            
                // Camera Raindrops
                /*
                let filter = CameraRainDrops()
                filter.inputImage = coreImage
                filter.tileCount = 4
                filter.time = CGFloat(max(1, slider1))
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                
                self.image = filteredImage
                
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                */
               
            
            case .Circuitboard:
                let noiseImageT = NSImage(named:"Example")!.tiffRepresentation
                let noiseBitmap = NSBitmapImageRep(data:noiseImageT!)
                //                let cgNoise = context.createCGImage(coreImage, from: CGRect(origin: .zero, size: TextureSize.medium.size))
                let ciimage = CIImage(bitmapImageRep: noiseBitmap!)
                
                let filter = CircuitMaker()
                filter.inputImage = ciimage
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: TextureSize.medium.size)
                
                self.image = filteredImage
                
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
            case .TriangleGrid:
                
                let filter = TriangledGrid()
                filter.inputImage = coreImage
                filter.tileSize = coreImage.extent.size
                filter.time = max(1, slider1)
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                
                self.image = filteredImage
                
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
            case .Interlaced:
                
                
                
                let filter = InterlacedTiles()
                filter.inputImage = coreImage
                filter.size = coreImage.extent.size
                filter.color1 = NSColor(color0)
                filter.color2 = NSColor(color1)
                filter.tileSize = CGFloat(stepCount1)

                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }

                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)

                self.image = filteredImage

                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
            case .Hexagons:
                print("Hexagons")
                
                let filter = HexagonFilter()
                filter.inputImage = coreImage
                filter.tileSize = Float(controller.textureSize.size.width)
                filter.tilecount = stepCount2
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                
                self.image = filteredImage
                
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
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
                
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
            case .RandomMaze:
                print("Maze")
                
                let filter = RandomMaze()
                filter.inputImage = coreImage
                filter.imageSize = Float(controller.textureSize.size.width)
                filter.tileCount = stepCount1
                
                guard let output = filter.outputImage(),
                      let cgOutput = context.createCGImage(output, from: output.extent)
                else {
                    print("⚠️ No output image")
                    return
                }
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
                
                controller.updateImage(new: filteredImage, isPreview: isPreviewing)
                
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
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)

                if isPreviewing {
                    controller.previewImage = filteredImage
                } else {
                    controller.image = filteredImage
                }
                
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
                
                let filteredImage = NSImage(cgImage: cgOutput, size: controller.textureSize.size)
//                controller.updatePreview(image: filteredImage)
                if isPreviewing {
                    controller.previewImage = filteredImage
                } else {
//                    controller.previewImage = nil
                    controller.image = filteredImage
                }
                
//            default:print("Not implemented")
        }
    }
    
    /// Applies the effect
    func apply() {
        // To apply, pass a function from the parent view
        // and return a NSImage when the effects are ready
        
//        guard let image = image else {
//            print("No image")
//            return
//        }
//        self.applied(image)
        
        let image = controller.previewImage ?? controller.image
        applied(image)
    }
}

struct MetalTilesView_Previews: PreviewProvider {
    static var previews: some View {
        MetalTilesView(controller: MetalGenController(select: .Tiles))
    }
}
