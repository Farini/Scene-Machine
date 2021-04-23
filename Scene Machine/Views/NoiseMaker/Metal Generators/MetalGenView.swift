//
//  MetalGenView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/23/21.
//

import SwiftUI

struct MetalGenView: View {
    
    @State var textureSize:TextureSize = .medium
    @State var image:NSImage = NSImage(size: NSSize(width: 1024, height: 1024))
    
    var body: some View {
        NavigationView {
            Text("Left")
            VStack {
                HStack {
                    Picker("Size", selection: $textureSize) {
                        ForEach(TextureSize.allCases, id:\.self) { tSize in
                            Text(tSize.fullLabel)
                        }
                        .onChange(of: textureSize, perform: { value in
                            self.image = NSImage(size: value.size)
                        })
                    }
                    .frame(width: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    
                    Button("Caustic") {
                        print("foobar")
                        caustic()
                    }
                    
                    Button("Hexagon") {
                        print("foobar")
                    }
                    Button("Truchet") {
                        print("foobar")
                    }
                }
                .padding(6)
                
                ScrollView {
                    Image(nsImage: image)
                        .padding(20)
                }
            }
            
        }
    }
    
    func caustic() {
        
        let context = CIContext()
        
        let caustic = CausticNoiseMetal() //CausticNoise()
        
        let baseImage = NSImage(size: NSSize(width: CGFloat(1024), height: CGFloat(1024)))
        guard let inputData = baseImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: inputData),
              let inputCIImage = CIImage(bitmapImageRep: bitmap) else {
            print("Missing something")
            return
        }
        
        caustic.inputImage = inputCIImage
        caustic.tileSize = Float(image.size.width)
        
        
        
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = caustic.outputImage() else { return }
        
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:image.size)
            self.image = nsImage
        }
    }
}

struct MetalGenView_Previews: PreviewProvider {
    static var previews: some View {
        MetalGenView()
    }
}
