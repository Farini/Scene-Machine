//
//  Hacking.swift
//  Scene Machine
//
//  Created by Carlos Farini on 1/23/21.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct Hacking: View {
    
    @ObservedObject var controller:ImageFXController = ImageFXController(image: nil)
    
    @State private var image: Image = Image("Example")
    @State private var nsimage:NSImage?
    @State private var imageName:String = "Untitled"
    @State private var popover:Bool = false
    
    var body: some View {
        VStack {
            Image(nsImage: controller.openingImage)
                .resizable()
                .scaledToFit()
                .padding(8)
            
            Divider()
            HStack {
                TextField("Image name", text: $imageName)
                    .frame(width: 100)
                Button("Save") {
                    self.saveImage()
                }
                Button("More") {
                    popover.toggle()
                }
                .popover(isPresented: $popover) {
                    VStack {
                        
                        Group {
                            Button("Blurr") {
                                controller.blurrImage()
                            }
                            Button("Crystalize") {
                                controller.crystallize()
                            }
                            Button("Pixellate") {
                                controller.pixellate()
                            }
                            Button("Twirl") {
                                controller.twirlDistortion()
                            }
                        }
                        
                        Group {
                            Button("Caustic Noise") {
                                controller.causticNoise()
                            }
                            Button("Caustic Refraction") {
                                controller.causticRefraction()
                            }
                            Button("Lens Flare") {
                                controller.lensFlare()
                            }
                        }
                        
                        Button("Metal Color") {
                            controller.metalColor()
                        }
                        Button("Mix last") {
                            controller.mixImages()
                        }
                        .disabled(controller.secondImage == nil)
                        
                        Divider()
                        Button("Save") {
                            self.saveImage()
                        }
                    }
                    .padding()
                    
                }
            }
            .padding([.top, .bottom], 6)
        }
    }
    
    func saveImage() {
        
        // Saving with SwiftUI
        // https://stackoverflow.com/questions/56645819/how-to-open-file-dialog-with-swiftui-on-platform-uikit-for-mac
        // Swift 5
        // https://ourcodeworld.com/articles/read/1117/how-to-implement-a-file-and-directory-picker-in-macos-using-swift-5
        
        // ----------
        // Change the following using the above tutorials/sources
        // ==========
        
        let fileUrl = folder.appendingPathComponent("\(imageName).png")
        
        let savingImage = controller.openingImage
        let data = savingImage.tiffRepresentation
        
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: data, attributes: nil)
            print("File created")
            return
        }
    }
    
    private var folder:URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            fatalError("Default folder for ap not found")
        }
        return url
    }
}

struct Hacking_Previews: PreviewProvider {
    static var previews: some View {
        Hacking()
    }
}
