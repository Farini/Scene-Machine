//
//  FrontView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/13/21.
//

import SwiftUI
import SceneKit

struct FrontView: View {
    
    enum NavigationItem {
        case noise
        case imageFX
        case open
        case scene
    }
    
    @State private var selection:NavigationItem? = .noise
//    @Environment(\.managedObjectContext)
    
    
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
            Text("Noise & Generators").font(.title2).foregroundColor(.orange)
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
                    Text("Pedal 2D Metal")
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
        ScrollView {
            VStack {
                
                Group {
                    
                    Image("Core_Image_icon")
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .center)
                        .padding(.top)
                    
                    Text("Image Effects").font(.title2).foregroundColor(.orange).padding()
                    
                    Divider()
                }
                
                // Mixer Group
                HStack {
                    
                    VStack(alignment:.leading) {
                        Text("Mix Images").font(.title2).foregroundColor(.blue)
                        Text("Mix Images. The CompositionView uses 2 images, and merge them using one of the chosen operations").foregroundColor(.gray)
                    }
                    .padding(6)
                    
                    Spacer()
                    VStack {
                        Image(systemName:"square.stack.3d.forward.dottedline")
                            .resizable()
                            .frame(width: 64, height: 64, alignment: .center)
                        
                        Text("Mixer")
                    }
                    .padding(8)
                    .onTapGesture {
                        NSApp.sendAction(#selector(AppDelegate.openCompositionView), to: nil, from: nil)
                    }
                }
                .padding()
                
                // Effects Group
                HStack {
                    VStack(alignment:.leading) {
                        Text("Image FX").font(.title2).foregroundColor(.blue)
                        Text("Apply Image FX. The Image FX View has filters that can be applied to an image").foregroundColor(.gray)
                    }
                    .padding(6)
                    
                    Spacer()
                    VStack {
                        Image(systemName: "wand.and.stars")
                            .resizable()
                            .frame(width: 64, height: 64, alignment: .center)
                        Text("Image FX")
                    }
                    .padding(8)
                    .onTapGesture {
                        NSApp.sendAction(#selector(AppDelegate.openImageFXView), to: nil, from: nil)
                    }
                    
                }
                .padding()
                
            }
            .toolbar(content: {
                Button("Tool") {
                    print("Tool button clicked")
                }
            })
        
        }
    }
        
}

struct OpenFileView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    // CoreData Tutorial: https://blckbirds.com/post/core-data-and-swiftui/
    
//    @State var materials = LocalDatabase.shared.materials
    @State var urls = LocalDatabase.shared.savedURLS
    @State var errorMessage:String = ""
    
    @FetchRequest(entity: SMMaterial.entity(), sortDescriptors: []) var materials: FetchedResults<SMMaterial>
    
    var dirImages:[NSImage] = FrontView.loadableImages()
    
    // Needs a Grid showing the pictures
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                Text(errorMessage)
                    .font(errorMessage.isEmpty ? .body:.title2.bold())
                    .foregroundColor(errorMessage.isEmpty ? .clear:.red)
                    .padding(errorMessage.isEmpty ? 0:8)
                    // .animation(errorMessage.isEmpty ? nil:Animation.spring(response: 0.35, dampingFraction: 0.7).delay(0.75))
                
                Group {
                    Text("Files").font(.title2).foregroundColor(.orange)
                        .padding(6)
                    Text("You may also go to File >> Open Finder to see what is there").foregroundColor(.gray)
                    Divider()
                }
                .padding(6)
                
                Text("Image").font(.title2).foregroundColor(.orange)
                
                HStack {
                    Text("Open an image with Image FX, and apply effects to an image.")
                        .foregroundColor(.gray)
                    Spacer()
                    VStack {
                        Image(systemName: "folder")//.font(.title)
                            .resizable()
                            .frame(width: 64, height: 64, alignment: .center)
                            .padding(6)
                        Text("Image FX")
                    }
                    .padding(8)
                    .onTapGesture {
                        openPanel()
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                Group {
                    Text("Scene").font(.title2).foregroundColor(.orange)
                        .padding(8)
                    HStack {
                        Text("Open a scene to edit with SceneKit").foregroundColor(.gray)
                        Spacer()
                        VStack {
                            Image("SceneKitIcon")
                                .resizable()
                                .frame(width: 64, height: 64, alignment: .center)
                                .padding(6)
                            Text("Scene")
                        }
                        .padding(8)
                        .onTapGesture {
                            openPanel()
                        }
                    }
                    .padding(.horizontal)
                }
                
                /*
                Divider()
                
                // Materials
                // This is working ok. Commented out because I intend to have it
                // for future versions
                
                Text("Materials").font(.title2).foregroundColor(.orange)
                    .padding(8)
                Group {
                    ForEach(materials) { material in
                        Text("Material \(material.id!.uuidString)")
                    }
                }
                Button("Add") {
                    let newMat = SMMaterial(context: viewContext)
                    newMat.id = UUID()
                    newMat.lightModel = MaterialShading.PhysicallyBased.rawValue
                    do {
                        try viewContext.save()
                        print("saved")
                    } catch {
                        print("could not save. \(error.localizedDescription)")
                    }
                }
                */
                
            }
        }
    }
    
    func openPanel() {
        let panel = NSOpenPanel()
        
        let imageTypes = ["png", "jpg", "jpeg", "tiff", "bmp"]
        let sceneTypes = ["scn", "dae", "obj"]
        
        panel.allowedFileTypes = imageTypes + sceneTypes
        
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.resolvesAliases = true
        panel.isAccessoryViewDisclosed = true
        panel.showsResizeIndicator    = true;
        panel.showsHiddenFiles        = false;
        
        if panel.runModal() == NSApplication.ModalResponse.OK {
            if let url = panel.url, url.isFileURL {
                let filext = url.pathExtension
                
                if imageTypes.contains(filext) {
                    if let image = NSImage(contentsOf: url) {
                        // Open an Image
                        NSApp.sendAction(#selector(AppDelegate.openImageFX(_:)), to: nil, from: image)
                        self.errorMessage = ""
                    } else {
                        withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.8).delay(0.75)) {
                            self.errorMessage = "Could not open image file: \(url.absoluteString)"
                        }
                    }
                    
                } else if sceneTypes.contains(filext) {
                    // Open a scene
                    if let scene = try? SCNScene(url: url, options: [SCNSceneSource.LoadingOption.convertToYUp:NSNumber(value:1)]) {
                        NSApp.sendAction(#selector(AppDelegate.openScene(_:)), to: nil, from: scene)
                    } else {
                        withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.8).delay(0.75)) {
                            self.errorMessage = "Could not open Scene file: \(url.absoluteString)"
                        }
                    }
                }
            }
        }
    }
}

struct OpenSceneView: View {
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                Group {
                    
                    Image("SceneKitIcon")
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .center)
                    
                    Text("SceneKit").font(.title2).foregroundColor(.orange)
                    
                    Divider()
                }
                .padding(.top)
                
                // Terrain Editor group
                Group {
                    HStack {
                        
                        VStack(alignment:.leading) {
                            Text("Terrain Editor").font(.title2).foregroundColor(.blue)
                            Text("Edit a terrain by giving it a displacement texture. Make sure the texture is white color. The white color displaces the terrain by a certain magnitude.").foregroundColor(.gray)
                        }
                        .padding(6)
                        
                        VStack {
                            Image(systemName:"map")
                                .resizable()
                                .frame(width: 64, height: 64, alignment: .center)
                                .padding(6)
                            Text("Terrain")
                        }
                        .padding(8)
                        .onTapGesture {
                            NSApp.sendAction(#selector(AppDelegate.openTerrainWindow), to: nil, from: nil)
                        }
                    }
                    
                    
                    Divider()
                }
                
                // Scene Machine Editor
                Group {
                    HStack {
                        VStack(alignment:.leading) {
                            Text("⚙️ Scene Machine").font(.title2).foregroundColor(.blue)
                            Text("Import and export '.dae', or '.scn' files. Checkout the materials, and also print the UVMap borders, to easily visualize Texture Painting.").foregroundColor(.gray)
                        }
                        .padding(6)
                        VStack {
                            Image(systemName:"square.stack.3d.up")
                                .resizable()
                                .frame(width: 64, height: 64, alignment: .center)
                                .padding(6)
                            Text("Machine")
                        }
                        .padding(8)
                        .onTapGesture {
                            NSApp.sendAction(#selector(AppDelegate.openSceneMachine), to: nil, from: nil)
                        }
                    }
                    
                    //                Button("Open") {
                    //                    NSApp.sendAction(#selector(AppDelegate.openSceneMachine), to: nil, from: nil)
                    //                }
                    //                Divider()
                }
            }
        }
    }
}

struct FrontView_Previews: PreviewProvider {
    static var previews: some View {
        FrontView()
        OpenFileView()
        OpenSceneView()
        ImageFXMenuView()
//        NoiseMenuView()
    }
}
