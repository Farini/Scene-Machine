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
}

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
                
                // CIFilter Noise
                VStack {
                    Image("Core_Image_icon")
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .center)
                    // Core_Image_icon
                    Text("CIFilter Noise")
                }
                .onTapGesture {
                    NSApp.sendAction(#selector(AppDelegate.openSpecialCIFilters), to: nil, from: nil)
                }
            }
        }
        .toolbar(content: {
            Button("Tool") {
                print("Tool button clicked")
            }
        })
    }
}

struct ImageFXMenuView: View {
    
    var body: some View {
        VStack {
            Text("Image Effects").font(.title2).foregroundColor(.orange)
                .padding()
            
            Text("Image effects need an Input image to transform it into an Output image. Be prepared to have an image as source")
                .foregroundColor(.gray)
                .frame(maxWidth:400)
            
            Button("Composition") {
//                NSApp.sendAction(#selector(AppDelegate.openNoiseMaker), to: nil, from: nil)
                // openCompositionView
                NSApp.sendAction(#selector(AppDelegate.openCompositionView), to: nil, from: nil)
            }
            .padding()
            
            Button("Other Generators") {
                print("Not implemented yet")
                // BarCode generator
                // QR Generator
                // Sky Generator?
                // HDRI Images?
            }
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
    
    // Needs a Grid showing the pictures
    var body: some View {
        VStack {
            Text("Files").font(.title2).foregroundColor(.orange)
                .padding()
            
            Text("Directory Picker")
            Divider()
            Group {
                Text("File: 1")
                Text("File: 2")
                Text("File: 3")
                Text("File: 4")
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

struct OpenSceneView: View {
    var body: some View {
        VStack {
            Text("Scenekit Scenes").font(.title2).foregroundColor(.orange)
            Text("Scene Picker")
            Divider()
            
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
