//
//  ImageFXView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/19/21.
//

import SwiftUI

enum FXState {
    case empty
    case Blurr
}

struct ImageFXView: View {
    
    @ObservedObject var controller:ImageFXController = ImageFXController(image: nil)
    
    @State private var imageName:String = "Untitled"
    @State private var popover:Bool = false
    @State private var state:FXState = .empty
    
    @State var sliderValue:Double = 0
    
    var body: some View {

        VStack {
            
            HStack {
                
                
                TextField("Image name", text: $imageName)
                    .frame(width: 100)
                Button("Save") {
                    self.saveImage()
                }
                
                Spacer()
                
                switch state {
                    case .empty:
                        Button("More") {
                            popover.toggle()
                        }
                        .popover(isPresented: $popover) {
                            VStack {
                                
                                Group {
                                    Button("Blurr") {
//                                        controller.blurrImage()
                                        self.state = .Blurr
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
                    case .Blurr:
//                        VStack {
                        Text("Blurr amount")
                        InputSlider(sliderRange: 0...100, value: 10, finish: didSetSlier(value:))
                        Text("Slider: \(self.sliderValue)")
//                        }
                        
                        
                        Button("Apply") {
                            controller.blurrImage(radius: sliderValue)
                        }
                }
            }
            
            Divider()
            
            ScrollView {
                Image(nsImage: controller.openingImage)
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            }
        }
        
    }
    
    func didSetSlier(value:Double) {
        print("Did set slider: \(value)")
        self.sliderValue = value
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

struct InputSlider: View {
    
    var sliderRange:ClosedRange<Float> = 0...1
    
    @State var value:Float = 0
    
    var finish: (_ value:Double) -> Void = {_ in }
    
    var body: some View {
        VStack {
            Slider(value: $value, in: sliderRange)
                .onChange(of: value, perform: { value in
                    finish(Double(value))
                })
            HStack {
                Button("/10") {
                    print("divide magnitude")
                }
                Spacer()
                Text("Value: \(value)")
                Spacer()
                Button("x10") {
                    print("multiply magnitude")
                }
            }
        }
    }
}

struct ImageFXView_Previews: PreviewProvider {
    static var previews: some View {
        ImageFXView()
    }
}

struct InputViews_Previews: PreviewProvider {
    static var previews: some View {
        InputSlider()
    }
}

extension NumberFormatter {
    static var slider:NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return f
    }
}
