//
//  MetalGenView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/23/21.
//

import SwiftUI

enum MetalGenType:String, CaseIterable {
    case CIGenerators
    case Noise
    case Tiles
    case Overlay
    case Other
}

struct MetalGenView: View {
    
    @ObservedObject var controller:MetalGenController = MetalGenController()
    
    @State var textureSize:TextureSize = .medium
    @State var image:NSImage = NSImage(size: NSSize(width: 1024, height: 1024))
    @State var selection:MetalGenType = .Noise
    
    @State private var zoomLevel:Double = 1.0
    
    var topBar: some View {
        HStack {
            
            Picker("Size", selection: $controller.textureSize) {
                ForEach(TextureSize.allCases, id:\.self) { tSize in
                    Text(tSize.fullLabel)
                }
                .onChange(of: controller.textureSize, perform: { value in
                    //                            self.image = NSImage(size: value.size)
                    let imSize:CGSize = value.size
                    let image = MetalGenController.noiseImage(size: imSize)
                    controller.image = image
                })
            }
            .frame(width: 150)
            
            Group {
                
                Picker("Gen", selection: $controller.selection) {
                    ForEach(MetalGenType.allCases, id:\.self) { genn in
                        Text("\(genn.rawValue)")
                    }
                }
                .frame(width: 150)
                
                Button(action: {
                    controller.saveImage()
                }, label: {
                    Image(systemName: "opticaldisc")
                    Text("Save")
                })
            }
            
            // Zoom
            Group {
                // Zoom -
                Button(action: {
                    if controller.zoomLevel > 0.25 {
                        controller.zoomLevel -= 0.2
                    }
                }, label: {
                    Image(systemName:"minus.magnifyingglass")
                }).font(.title2)
                
                // Zoom Label
                let zoomString = String(format: "x %.2f", zoomLevel)
                Text(zoomString)
                
                // Zoom +
                Button(action: {
                    if controller.zoomLevel <= 8 {
                        controller.zoomLevel += 0.2
                    }
                }, label: {
                    Image(systemName:"plus.magnifyingglass")
                }).font(.title2)
            }
            
        }
        .padding(6)
        .background(Color.black.opacity(0.2))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    switch controller.selection {
                        case .CIGenerators:
                            CIGenView(applied: { (newImage) in
                                controller.image = newImage
                            }, generatorType: .Checkerboard, image: image)
                        case .Noise:
                            MetalNoiseView(controller: controller, applied: { newImage in
                                controller.image = newImage
                            })
                        case .Tiles:
                            MetalTilesView(controller: controller, applied: { newImage in
                                controller.image = newImage
                            }, image: self.image)
                        case .Overlay:
                            MetalOverlaysView(controller: controller, applied: { newImage in
                                controller.image = newImage
                            })
                        case .Other:
                            MetalOthersView(controller: controller, applied: { newImage in
                                controller.image = newImage
                            })
//                        default: Text("Not Implemented").foregroundColor(.gray)
                    }
                }
            }
            .frame(width: 250)
            
            VStack {
                
                // Toolbar
                topBar

                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    HStack(alignment:.top) {
                        Spacer()
                        Image(nsImage: controller.image)
                            .resizable()
                            .frame(width: textureSize.size.width * CGFloat(zoomLevel), height: textureSize.size.height * CGFloat(zoomLevel), alignment: .center)
                            .padding(20)
                        Spacer()
                    }
                    
                }
                .frame(minWidth: 400, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            
        }
    }
}

struct MetalGenView_Previews: PreviewProvider {
    static var previews: some View {
        MetalGenView()
            .frame(minWidth: 800, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity, alignment: .center)
    }
}
