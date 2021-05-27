//
//  MMNodeFXView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/27/21.
//

import SwiftUI

struct MMNodeFXView:View {
    
    // Apply the effect to the material property only.
    // That way, it will only save when the user saves the material.
    // or.....
    // Have an "apply" button, with an image view.
    // if you like the image, apply to the material and change the image
    
    @ObservedObject var controller:MaterialMachineController
    var original:NSImage?
    @State var effectImage:NSImage?
    
    @State private var popFX:Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("FX")
                Spacer()
                Image(systemName: "photo.fill").font(.title)
                    .onTapGesture {
                        popFX.toggle()
                    }
                    .popover(isPresented: $popFX, content: {
                        VStack {
                            Text("Poppity pop !!!")
                            Text("Properties")
                            Text("Poppity pop !!!")
                            Button("Blur") {
                                self.applyBlur()
                            }
                        }
                    })
                Button("✅") {
                    guard let image = effectImage else { return }
                    controller.updateUVImage(image: image)
                }
                .disabled(effectImage == nil)
            }
            
            if let image = effectImage {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 200, height: 200, alignment: .center)
            } else if let image = original {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 200, height: 200, alignment: .center)
            }
            // Blur (disk, box)
            // Monochrome
            // ColorAdjust, Exposure adjust, vibrance
            // Invert Colors
            // Normal shader
        }
        .frame(width:200)
    }
    
    func applyBlur() {
        guard let image = original else { return }
        guard let imageData = image.tiffRepresentation,
              let imageBitmap = NSBitmapImageRep(data:imageData),
              let coreImage = CIImage(bitmapImageRep: imageBitmap) else {
            return
        }
        
        let context = CIContext()
        
        let filter = CIFilter.boxBlur()
        filter.inputImage = coreImage
        filter.radius = 20
        
        guard let output = filter.outputImage,
              let cgOutput = context.createCGImage(output, from: output.extent)
        else {
            print("⚠️ No output image")
            return
        }
        
        let filteredImage = NSImage(cgImage: cgOutput, size: image.size)
        
        self.effectImage = filteredImage
        
    }
}

struct FXNode_Previews: PreviewProvider {
    static var previews: some View {
        MMNodeFXView(controller: MaterialMachineController(), original: nil, effectImage: nil)
    }
}
