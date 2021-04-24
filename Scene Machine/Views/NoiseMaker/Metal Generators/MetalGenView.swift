//
//  MetalGenView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/23/21.
//

import SwiftUI

enum MetalGenType {
    case CIGenerators
    case Patterns
}

struct MetalGenView: View {
    
    @State var textureSize:TextureSize = .medium
    @State var image:NSImage = NSImage(size: NSSize(width: 1024, height: 1024))
    @State var selection:MetalGenType = .CIGenerators
    
    var body: some View {
        NavigationView {
            VStack {
                switch selection {
                    case .CIGenerators:
                        CIGenView(applied: { (newImage) in
                            self.image = newImage
                        }, generatorType: .Checkerboard, image: image)
                    default: Text("Not Implemented").foregroundColor(.gray)
                }
            }
            
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
                        checkerboard()
                    }
                    Button("Truchet") {
                        print("foobar")
                        truchet()
                    }
                    Button("CI Gen") {
                        print("CI Gen")
                        self.selection = .CIGenerators
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
    
    func truchet() {
        let context = CIContext()
        
        let caustic = TruchetFilter() //CausticNoise()
        
        let noise = CIFilter.randomGenerator()
        let noiseImage = noise.outputImage!
        
        caustic.inputImage = noiseImage
        caustic.tileSize = Float(image.size.width)

        // get a CIImage from our filter or exit if that fails
        guard let outputImage = caustic.outputImage() else { return }
        
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))) {
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:image.size)
            self.image = nsImage
        }
    }
    
    func caustic() {
        
        let context = CIContext()
        let caustic = CausticNoiseMetal() //CausticNoise()
        
        let noise = CIFilter.randomGenerator()
        let noiseImage = noise.outputImage!
        
        caustic.inputImage = noiseImage //inputCIImage
        caustic.tileSize = Float(image.size.width)
        
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = caustic.outputImage() else { return }
        
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))) { // outputImage.extent
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:image.size)
            self.image = nsImage
        }
    }
    
    func checkerboard() {
        
        print("Checkerboard")
        let context = CIContext()
        // Center, Amount
        let currentFilter = CIFilter.checkerboardGenerator()
        currentFilter.width = 128
        currentFilter.color0 = CIColor(red: 1, green: 0.5, blue: 0.5)
        currentFilter.color1 = CIColor(red: 0.5, green: 0.5, blue: 1.0)
        currentFilter.center = CGPoint(x: 512, y: 512)
    
        print("Checkerboard")
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = currentFilter.outputImage else { return }
        print("Output")
        
        
        
        // attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: CGRect(origin: CGPoint.zero, size: CGSize(width: 1024, height: 1024))) {
            
            print("CGImage")
            // convert that to a UIImage
            let nsImage = NSImage(cgImage: cgimg, size:CGSize(width: 1024, height: 1024))
            self.image = nsImage
        }
        print("Check end")
    }
}

struct MetalGenView_Previews: PreviewProvider {
    static var previews: some View {
        MetalGenView()
    }
}
