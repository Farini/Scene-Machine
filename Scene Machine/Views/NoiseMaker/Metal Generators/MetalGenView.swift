//
//  MetalGenView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/23/21.
//

import SwiftUI


struct MetalGenView: View {
    
    @ObservedObject var controller:MetalGenController = MetalGenController()
    
    @State var textureSize:TextureSize = .medium
    @State var image:NSImage = NSImage(size: NSSize(width: 1024, height: 1024))
    @State var selection:MetalGenType = .Noise
    
    @State private var popAppImages:Bool = false
    
    var topBar: some View {
        HStack {
            
            // Left Group (Generator, Size, Save
            Group {
                
                // Generator Type
                Picker("Generator", selection: $controller.selection) {
                    ForEach(MetalGenType.allCases, id:\.self) { genn in
                        Text("\(genn.rawValue)")
                    }
                }
                .frame(width: 150)
                
                // Size Picker
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
                
                // Save
                Button(action: {
                    controller.saveImage()
                }, label: {
                    // Image(systemName: "opticaldisc")
                    Text("💾")
                })
                .help("Saves the main image shown below")
            }
            
            Spacer()
            
            // Right: Library
            Button(action: {
                popAppImages.toggle()
            }, label: {
                Image(systemName: "books.vertical")
                Text("Library")
            })
            .help("Images in App's Library")
            .popover(isPresented: $popAppImages) {
                VStack {
                    ForEach(AppTextures.allCases, id:\.self) { texture in
                        HStack {
                            Text(texture.labelName)
                            Spacer()
                            Button("+") {
                                if let image = texture.image {
                                    controller.image = image
                                }
                            }
                        }
                        .frame(width:165)
                    }
                }
                .padding()
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
                let zoomString = String(format: "x %.2f", controller.zoomLevel)
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
        .padding(.horizontal, 8)
        .background(Color.black.opacity(0.2))
        .cornerRadius(8)
    }
    
    var body: some View {
        NavigationView {
            
            // Left: Method
            ScrollView {
                VStack {
                    switch controller.selection {
                        case .Noise:
                            MetalNoiseView(controller: controller, applied: { newImage in
                                controller.image = newImage
                            })
                        case .Tiles:
                            MetalTilesView(controller: controller, applied: { newImage in
                                controller.image = newImage
                            })
                        case .Overlay:
                            MetalOverlaysView(controller: controller, applied: { newImage in
                                controller.image = newImage
                            })
                    }
                }
            }
            .frame(width: 250)
            
            // Big Image + bar
            VStack {
                
                // Toolbar
                topBar
                
                // Main Image
                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    HStack(alignment:.top) {
                        Spacer()
                        Image(nsImage: controller.image)
                            .resizable()
                            .frame(width: textureSize.size.width * CGFloat(controller.zoomLevel), height: textureSize.size.height * CGFloat(controller.zoomLevel), alignment: .center)
                            .padding(20)
                            .gesture(MagnificationGesture()
                                        .onChanged { val in
                                            let delta = (1.0 - Double(val)) / controller.zoomLevel
                                            let dd = controller.zoomLevel + delta
                                            if dd < 1 {
                                                controller.zoomLevel = 1
                                            } else if dd > 8 {
                                                controller.zoomLevel = 8
                                            } else {
                                                controller.zoomLevel = dd
                                            }
                                        })
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
