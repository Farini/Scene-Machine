//
//  TileComposerView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/29/21.
//

import SwiftUI

struct TileComposerView: View {
    
    @State var dragOver:Bool = false
    @State var droppedImage:NSImage?
    @State var tiledImage:NSImage?
    @State var status:String = ""
    
    var body: some View {
        NavigationView {
            //
            VStack {
                HStack {
                    Text("Tile Composer")
                    Text("Status: \(status)")
                    Spacer()
                    Button("Go") {
                        if iterations == 0 {
                            self.iterations = 3
                        }
                        self.runFilter()
                    }
                }
                .padding(.horizontal)
                
                // Original
                ZStack {
                    if let image = self.droppedImage {
                        Image(nsImage: image)
                            .resizable()
                            .frame(width: 256, height: 256, alignment: .center)
                        
                    } else {
                        Rectangle()
                            .frame(width: 256, height: 256, alignment: .center)
                            .foregroundColor(.black.opacity(0.2))
                            .cornerRadius(12)
                    }
                    
                    Text("Drop")
                }
                .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
                    providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                        if let data = data, let uu = URL(dataRepresentation: data, relativeTo: nil) {
                            if let dropImage = NSImage(contentsOf: uu) {
                                self.droppedImage = dropImage
                            }
                        }
                    })
                    return true
                }
                HStack {
                    Text("Iterations: \(iterations)")
                    TextField("Input", value:$iterations, formatter: NumberFormatter.doubleDigit)
                }
                HStack {
                    Text("Margin: \(iterations)")
                    TextField("Input", value:$margin, formatter: NumberFormatter.doubleDigit)
                }
                
            }
            .frame(width:280)
            
            VStack(spacing:0) {
                
                // Tiled
                HStack(spacing:0) {
                    if let image = self.tiledImage {
                        Image(nsImage: image)
                            .resizable()
                            .frame(width: 256, height: 256, alignment: .center)
                        Image(nsImage: image)
                            .resizable()
                            .frame(width: 256, height: 256, alignment: .center)
                    } else
                    if let image = self.droppedImage {
                        Image(nsImage: image)
                            .resizable()
                            .frame(width: 256, height: 256, alignment: .center)
                        Image(nsImage: image)
                            .resizable()
                            .frame(width: 256, height: 256, alignment: .center)
                    } else {
                        Rectangle()
                            .frame(width: 256, height: 256, alignment: .center)
                            .foregroundColor(.black.opacity(0.2))
                        
                        Rectangle()
                            .frame(width: 256, height: 256, alignment: .center)
                            .foregroundColor(.black.opacity(0.2))
                    }
                }
                HStack(spacing:0) {
                    if let image = self.tiledImage {
                        Image(nsImage: image)
                            .resizable()
                            .frame(width: 256, height: 256, alignment: .center)
                        Image(nsImage: image)
                            .resizable()
                            .frame(width: 256, height: 256, alignment: .center)
                    } else
                    if let image = self.droppedImage {
                        Image(nsImage: image)
                            .resizable()
                            .frame(width: 256, height: 256, alignment: .center)
                        Image(nsImage: image)
                            .resizable()
                            .frame(width: 256, height: 256, alignment: .center)
                    } else {
                        Rectangle()
                            .frame(width: 256, height: 256, alignment: .center)
                            .foregroundColor(.black.opacity(0.2))
                        
                        Rectangle()
                            .frame(width: 256, height: 256, alignment: .center)
                            .foregroundColor(.black.opacity(0.2))
                    }
                }
            }
        }
        
    }
    
    @State var iterations:Int = 0
    @State var margin:Int = 10
    
    func runFilter() {
        
        if iterations <= 0 {
            return
        }
        
        self.status = "running..."
        
        guard let originalImage = droppedImage else {
            print("No original")
            status = "no original"
            return
        }
        
        guard let imageData = originalImage.tiffRepresentation,
              let imageBitmap = NSBitmapImageRep(data:imageData),
              let coreImage = CIImage(bitmapImageRep: imageBitmap) else {
            print("No data")
            status = "no data"
            return
        }
        
        
        let context = CIContext()
        let filter = TileMaker()
        filter.inputImage = coreImage
        filter.margin = self.margin
        
        if let output = filter.outputImage(), let cgOutput = context.createCGImage(output, from: output.extent) {
            
            status = "output + CG"
            
            let filteredImage = NSImage(cgImage: cgOutput, size: output.extent.size)
            print("output !!!")
            self.tiledImage = filteredImage
            status = "tiled"
        
        } else {
            print("No output")
            status = "failed"
            self.droppedImage = NSImage(named: "Checkerboard")
        }
        
        iterations -= 1
        self.droppedImage = tiledImage
        self.runFilter()
    }
}

struct TileComposerView_Previews: PreviewProvider {
    static var previews: some View {
        TileComposerView()
            .frame(minWidth: 700, idealWidth: 800, maxWidth: .infinity, minHeight: 600, idealHeight: 600, maxHeight: .infinity, alignment: .center)
    }
}
