//
//  FrontView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/13/21.
//

import SwiftUI

struct FrontView: View {
    
    enum NavigationItem {
        case noise
        case imageFX
        case open
        case scene
    }
    
    @State private var selection:NavigationItem? = .noise
    
    // To Open New Window:
    // https://stackoverflow.com/questions/62779479/button-to-open-view-in-new-window-swiftui-5-3-for-mac-os-x
    
    var body: some View {
        NavigationView {
            List(selection:$selection) {
                
                NavigationLink(destination: NoiseMenuView(), tag: NavigationItem.noise, selection: $selection) {
                    Label("Noise", systemImage: "puzzlepiece")
                }
                .tag(NavigationItem.noise)
                
                NavigationLink(destination: ImageFXMenuView(), tag: NavigationItem.imageFX, selection: $selection) {
                    Label("Image FX", systemImage: "puzzlepiece")
                }
                .tag(NavigationItem.imageFX)
                
                NavigationLink(destination: OpenFileView(), tag: NavigationItem.open, selection: $selection) {
                    Label("Open", systemImage: "folder")
                }
                .tag(NavigationItem.open)
                
                NavigationLink(destination: OpenSceneView(), tag: NavigationItem.scene, selection: $selection) {
                    Label("Scenes", systemImage: "film")
                }
                .tag(NavigationItem.scene)
            }
            
            Text("Select menu item")
        }
    }
    
    static func loadableImages() -> [NSImage] {
        let directory:URL = LocalDatabase.folder
        let fileManager = FileManager.default
        var array:[NSImage] = []
        if let fileItems = try? fileManager.contentsOfDirectory(atPath: directory.path) {
            for file in fileItems {
                let url = URL(fileURLWithPath: file)
                if let image = NSImage(contentsOf: url) {
                    array.append(image)
                }
            }
        }
        return array
    }
}

// MARK: - Menu Views

struct NoiseMenuView: View {
    var body: some View {
        VStack {
            Text("Noise Generators").font(.title2).foregroundColor(.orange)
                .padding()
            
            HStack(spacing:12) {
                
                // SpriteKit Noise
                VStack {
                    Image("SpriteKitIcon")
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .center)
                    Text("SpriteKit Noise")
                }.onTapGesture {
                    NSApp.sendAction(#selector(AppDelegate.openSpriteNoiseWindow), to: nil, from: nil)
                }
                
                // Metal Noise
                VStack {
                    Image("MetalIcon")
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .center)
                    // Core_Image_icon
                    Text("Pedal 2 Metal")
                }
                .onTapGesture {
                    NSApp.sendAction(#selector(AppDelegate.openMetalGenerators), to: nil, from: nil)
                }
                
                VStack {
                    Image("SpriteBot")
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .center)
                    Text("Quick Noise")
                }
                .onTapGesture {
                    NSApp.sendAction(#selector(AppDelegate.openNoiseMaker), to: nil, from: nil)
                }
            }
        }
        .navigationTitle("Noise")
    }
}

struct ImageFXMenuView: View {
    
    var body: some View {
        VStack {
            
            Group {
                Text("Image Effects").font(.title2).foregroundColor(.orange).padding()
                
                Text("Image effects need an Input image to transform it into an Output image. Be prepared to have an image as source")
                    .foregroundColor(.gray)
                    .frame(maxWidth:400)
                
                Divider()
            }
            
            HStack {
                Text("Compose Images. The CompositionView uses 2 images, and merge them using one of the chosen operations").foregroundColor(.gray)
                Spacer()
                VStack {
                    Image("Core_Image_icon")
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .center)
                        
                    Text("Compose")
                }
                .onTapGesture {
                    NSApp.sendAction(#selector(AppDelegate.openCompositionView), to: nil, from: nil)
                }
            }
            .padding()
            
            HStack {
                Text("Apply Image FX. The Image FX View has filters that can be applied to an image").foregroundColor(.gray)
                Spacer()
                Button("Image FX") {
                    NSApp.sendAction(#selector(AppDelegate.openImageFXView), to: nil, from: nil)
                }
            }
            .padding()
            
            HStack {
                Text("Other CI Filters are kept here.").foregroundColor(.gray)
                Spacer()
                Button("Filter FX") {
                    NSApp.sendAction(#selector(AppDelegate.openSpecialCIFilters), to: nil, from: nil)
                }
            }
            .padding()
            
            // BarCode generator
            // QR Generator
            // Sky Generator?
            // HDRI Images?
        }
        .toolbar(content: {
            Button("Tool") {
                print("Tool button clicked")
            }
        })
    }
}

struct OpenFileView: View {
    
    @State var materials = LocalDatabase.shared.materials
    @State var urls = LocalDatabase.shared.savedURLS
    
    var dirImages:[NSImage] = FrontView.loadableImages()
    
    // Needs a Grid showing the pictures
    var body: some View {
        ScrollView {
            VStack {
                Group {
                    Text("Files").font(.title2).foregroundColor(.orange)
                        .padding(6)
                    Text("You may also go to File >> Open Finder to see what is there").foregroundColor(.gray)
                    Divider()
                }
                .padding(6)
                
                Text("App Directory").font(.title2).foregroundColor(.orange)
                LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                    
                    ForEach(0..<dirImages.count) { idx in
                        Image(nsImage:dirImages[idx])
                            .resizable()
                            .frame(width:200, height:200, alignment:.center)
                    }
                })
                
                
                Divider()
                Group {
                    Text("Saved URLs").font(.title2).foregroundColor(.orange)
                        .padding()
                    Text("File: 1...")
                    LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .center, spacing: 8, pinnedViews: [], content: {
                        
                        ForEach(0..<urls.count) { idx in
                            Text(urls[idx].lastPathComponent)
                                .onTapGesture {
                                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: urls[idx].absoluteString)
                                }
                        }
                    })
                }
                
                Divider()
                
                // Materials
                Text("Materials").font(.title2).foregroundColor(.orange)
                    .padding()
                Group {
                    ForEach(materials) { material in
                        Text("Material \(material.id.uuidString)")
                    }
                }
            }
        }
    }
}

struct OpenSceneView: View {
    var body: some View {
        VStack {
            
            Group {
                Image("SceneKitIcon")
                    .resizable()
                    .frame(width: 64, height: 64, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Text("SceneKit Scenes").font(.title2).foregroundColor(.orange)
                
                Divider()
            }
            
            Group {
                Text("Terrain Editor")
                Button("Terrain") {
                    NSApp.sendAction(#selector(AppDelegate.openTerrainWindow), to: nil, from: nil)
                }
                Divider()
            }
            
            Group {
                Text("Material Editor")
                Button("Suzanne") {
                    NSApp.sendAction(#selector(AppDelegate.displayMonkeyTest), to: nil, from: nil)
                }
                Divider()
            }
            
            Group {
                Text("⚙️ Scene Machine")
                Button("Open") {
                    NSApp.sendAction(#selector(AppDelegate.openSceneMachine), to: nil, from: nil)
                }
                Divider()
            }
            
            
            Text("Others").font(.title3).foregroundColor(.orange)
            Text("(Needs Implementation)").foregroundColor(.gray)
            
            Text("Woman")
            Text("DNA")
        }
    }
}

struct FrontView_Previews: PreviewProvider {
    static var previews: some View {
        FrontView()
    }
}
