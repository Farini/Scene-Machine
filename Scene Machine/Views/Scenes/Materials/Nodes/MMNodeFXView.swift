//
//  MMNodeFXView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/27/21.
//

import SwiftUI
import SceneKit

/// Right Node View - Displays Effects applied to image of `MaterialMode`
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
    
    @State var wrapS:SCNWrapMode = SCNWrapMode.clamp
    @State var wrapT:SCNWrapMode = SCNWrapMode.clamp
    
    var body: some View {
        VStack {
            
            // Buttons
            HStack {
                Text("FX")
                Spacer()
                
                // Select Effect
                Button(action: {
                    popFX.toggle()
                }, label: {
                    Image(systemName: "wand.and.stars")
                })
                .popover(isPresented: $popFX, content: {
                    VStack {
                        Button("Blur") {
                            self.applyBlur()
                        }
                        Text("More effects coming soon.")
                    }
                    .padding()
                })
                // .disabled(effectImage == nil)
                .help("Select an effect to apply to the image")
                
                // Apply
                Button(action: {
                    guard let image = effectImage else { return }
                    controller.updateUVImage(image: image)
                }, label: {
                    Image(systemName:"rectangle.badge.checkmark")
                })
                .disabled(effectImage == nil)
                .help("Apply effect")
            }
            
            
            HStack {
                Text("Wrap")
                Picker("S", selection: $wrapS) {
                    ForEach(SCNWrapMode.allCases, id:\.self) { wrapMode in
                        Text(wrapMode.toString())
                    }
                }
                .onChange(of: wrapS, perform: { value in
                    self.updateMaterialWrapping()
                })
                
                Picker("T", selection: $wrapT) {
                    ForEach(SCNWrapMode.allCases, id:\.self) { wrapMode in
                        Text(wrapMode.toString())
                    }
                }
                .onChange(of: wrapT, perform: { value in
                    self.updateMaterialWrapping()
                })
            }
            
            if let image = effectImage {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 200, height: 200, alignment: .center)
                    .border(Color.gray, width: 0.5)
            } else if let image = original {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 200, height: 200, alignment: .center)
                    .border(Color.gray, width: 0.5)
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
    
    /// Updates `WrapS` and `wrapT` properties of material
    func updateMaterialWrapping() {
        switch controller.materialMode {
            case .Diffuse:
                controller.material.diffuse.wrapS = wrapS
                controller.material.diffuse.wrapT = wrapT
            case .Roughness:
                controller.material.roughness.wrapS = wrapS
                controller.material.roughness.wrapT = wrapT
            case .AO:
                controller.material.ambientOcclusion.wrapS = wrapS
                controller.material.ambientOcclusion.wrapT = wrapT
            case .Emission:
                controller.material.emission.wrapS = wrapS
                controller.material.emission.wrapT = wrapT
            case .Normal:
                controller.material.normal.wrapS = wrapS
                controller.material.normal.wrapT = wrapT
        }
    }
}

/* The popover that shows the Effects that can be applied */
struct MMFXPopoverView: View {
    
    var body: some View {
        VStack {
            Button("Blur") {
//                self.applyBlur()
            }
            // Color monochrome
            // Color vibrance
            // Crystalize
            // Edge
            // Bloom
            // Sharpen
            // Transparents
            // Normal Map
            
            Text("More effects coming soon.")
        }
        .padding()
    }
}

struct FXNode_Previews: PreviewProvider {
    static var previews: some View {
        MMNodeFXView(controller: MaterialMachineController(), original: nil, effectImage: nil)
    }
}

struct FXPopover_Previews: PreviewProvider {
    static var previews: some View {
        MMFXPopoverView()
    }
}
