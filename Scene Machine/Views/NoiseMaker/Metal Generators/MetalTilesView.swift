//
//  MetalTilesView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/26/21.
//

import SwiftUI

struct MetalTilesView: View {
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
    }
    
    @State var tileType:MetalTileType = .Hexagons
    
    var body: some View {
        VStack {
            Text("Tiles")
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
        
        switch tileType {
            case .Hexagons:
                print("Voronoi")
                
                let filter = HexagonFilter()
                filter.inputImage = coreImage
                filter.tileSize = 512
                
                
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

struct MetalTilesView_Previews: PreviewProvider {
    static var previews: some View {
        MetalTilesView()
    }
}
