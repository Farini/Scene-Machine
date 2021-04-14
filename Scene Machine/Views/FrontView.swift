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
        case open
        case scene
    }
    
    @State private var selection:NavigationItem? = .scene
    
    // To Open New Window:
    // https://stackoverflow.com/questions/62779479/button-to-open-view-in-new-window-swiftui-5-3-for-mac-os-x
    
    
    var body: some View {
        NavigationView {
            List(selection:$selection) {
                
                NavigationLink(destination: NoiseMenuView(), tag: NavigationItem.noise, selection: $selection) {
                    Label("New Noise", systemImage: "puzzlepiece")
                }
                .tag(NavigationItem.noise)
                
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
            Text("Noise").font(.title2).foregroundColor(.orange)
                .padding()
            
            Text("SpriteKit Noise")
            Button("Create") {
                NSApp.sendAction(#selector(AppDelegate.openSpriteNoiseWindow), to: nil, from: nil)
            }
            Text("Other Noise")
            Text("Lens Flare")
            Divider()
            Text("Size: ??")
        }
        .toolbar(content: {
            Button("Tool") {
                print("Tool button clicked")
            }
        })
    }
}

struct OpenFileView: View {
    
    // Needs a Grid showing the pictures
    var body: some View {
        VStack {
            Text("Open File")
            Text("Directory Picker")
            Divider()
            Text("File: 1")
            Text("File: 2")
            Text("File: 3")
            Text("File: 4")
        }
    }
}

struct OpenSceneView: View {
    var body: some View {
        VStack {
            Text("Choose Scene")
            Text("Scene Picker")
            Divider()
            Text("Suzanne")
            Text("Terrain")
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
