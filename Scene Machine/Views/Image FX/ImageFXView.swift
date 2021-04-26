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
    case Color
}

struct ImageFXView: View {
    
    @ObservedObject var controller:ImageFXController = ImageFXController(image: nil)
    
    @State private var popover:Bool = false
    @State private var state:FXState = .empty
    @State private var zoomLevel:Double = 1.0
    
    @State var sliderValue:Double = 0
    
    var body: some View {
        NavigationView {
            VStack {
                switch state {
                    case .empty:
                        Text("Select filter type").foregroundColor(.gray)
                            .padding()
                    case .Blurr:
                        FXBlurrView(controller: controller, applied: { img in
                                        apply(image: img) },
                                    image: controller.openingImage)
                    case .Color:
                        FXColorView(value: 1,
                                    applied: { (image) in
                            apply(image: image)},
                                    image: controller.openingImage,
                                    inputColor: .white)
                        
                    default:
                        Text("Left View")
                        Text("Needs implementation")
                }
                Spacer()
            }
            
            VStack {
                
                // Top Bar
                HStack {
                    
                    Button("Save") {
                        self.saveImage()
                    }
                    
                    Button("Load") {
                        // Load an image
                        print("Load an image")
                        controller.loadImage()
                    }
                    
                    Divider().frame(height:32)
                    
                    Button("Blur") {
//                        let v = CIVector(values: [2, 3, 4], count: 3)
                        self.state = .Blurr
                    }
                    
                    Button("Color") {
                        self.state = .Color
                    }
                    
                    Button("Other") {
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
                            Button("Black2Alpha") {
                                controller.metalBlackToTransparent()
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
                    
                    
                    Spacer()
                    
                    
                    // Zoom -
                    Button(action: {
                        if zoomLevel > 0.25 {
                            zoomLevel -= 0.2
                        }
                    }, label: {
                        Image(systemName:"minus.magnifyingglass")
                    }).font(.title2)
                    
                    // Zoom Label
                    let zoomString = String(format: "Zoom: %.2f", zoomLevel)
                    Text(zoomString)
                    
                    // Zoom +
                    Button(action: {
                        if zoomLevel <= 8 {
                            zoomLevel += 0.2
                        }
                    }, label: {
                        Image(systemName:"plus.magnifyingglass")
                    }).font(.title2)
                }
                .padding(.horizontal, 8)
                
                // Current Image
//                ScrollView {
//                    Image(nsImage: controller.openingImage)
//                        .resizable()
//                        .scaledToFit()
//                        .padding(20)
//                }
                
                // Image View
                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    
                    Image(nsImage: controller.openingImage)
                        .resizable()
                        .frame(width: controller.openingImage.size.width * CGFloat(zoomLevel), height: controller.openingImage.size.height * CGFloat(zoomLevel), alignment: .center)
                        .padding()
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
        }
    }
    

    /// Used When Filter views wants to Apply image
    func apply(image:NSImage) {
        // Set the image in the controller
        controller.openingImage = image
    }
    
    func saveImage() {
        
        // Saving with SwiftUI
        // https://stackoverflow.com/questions/56645819/how-to-open-file-dialog-with-swiftui-on-platform-uikit-for-mac
        // Swift 5
        // https://ourcodeworld.com/articles/read/1117/how-to-implement-a-file-and-directory-picker-in-macos-using-swift-5
        
        controller.openSavePanel(for: controller.openingImage)
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
            .frame(width: 800, height: 600, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
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
