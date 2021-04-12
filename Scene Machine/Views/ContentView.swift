//
//  ContentView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 12/2/20.
//

import SwiftUI
import SpriteKit

// Remake
// Make a Split View
// No need for scene


struct ContentView: View {
    
    @ObservedObject var controller:NoiseController = NoiseController()
    @State var noises:[String] = []
    @State var sliderVal:Float = Float(0.5)
    
    init() {
//        self.noises = controller.noises
    }
    
    var body: some View {
        HSplitView {
            
                List {
                    Button("Save") {
                        print("Should save. Where?")
                        LastNode.shared.saveTexture()
                    }
                    Button("Change (Add)") {
                        print("Should change")
                    }
                    Slider(value: $sliderVal, in: 0...1) { changed in
                        print("Slider Changed")
                    }

                }
                .listStyle(SidebarListStyle())
                .toolbar {
                    Button(action: {
                        recordProgress()
                    }, label: {
                        Label("Record", systemImage: "book.circle")
                    })
                    
                }
                
            
            .frame(maxWidth: 180, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            VStack {
                HStack {
                    // Buttons
                    Button("Save") {
                        print("Should save. Where?")
                    }
                    Button("Change (Add)") {
                        print("Should change")
                    }
                }
                ScrollView(.horizontal, showsIndicators: true){
                    
                    HStack {
                        SpriteKitContainer(smoothness: CGFloat(sliderVal)) // or 256x256 for full screen
                                .frame(width: 512, height: 512)
                                .onTapGesture {
                                    print("Select Noise ??")
                                }
                    }
                }
                .frame(maxWidth: 1024, minHeight: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
        }
    }
    
    func recordProgress() {
        print("Action!")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SpriteKitContainer: NSViewRepresentable {
    
    typealias NSViewType = SKView
    //    typealias UIViewType = SKView
    
    var skScene: SKScene
    
    init(smoothness:CGFloat? = 0.5) {
        skScene = SKScene(size: CGSize(width: 256, height: 256))
        //        self.skScene.scaleMode = .aspectFill
        let texture = SKTexture.init(noiseWithSmoothness: smoothness!, size: CGSize(width: 512, height: 512), grayscale: true)
        let node = SKSpriteNode(texture: texture)
        skScene.addChild(node)
        LastNode.shared.updateNode(node, texture: texture)
    }
    
    class Coordinator: NSObject {
        var scene: SKScene?
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.scene = self.skScene
        return coordinator
    }
    
    // MARK: - Make Views
    
    func makeNSView(context: Context) -> SKView {
        
        let view = SKView(frame: .zero)
        view.preferredFramesPerSecond = 60
        view.showsFPS = true
        view.showsNodeCount = true
        return view
    }
    
    /*
     func makeUIView(context: Context) -> SKView {
     let view = SKView(frame: .zero)
     view.preferredFramesPerSecond = 60
     view.showsFPS = true
     view.showsNodeCount = true
     return view
     }
     */
    
    // MARK: - Updates
    /*
     func updateUIView(_ view: SKView, context: Context) {
     view.presentScene(context.coordinator.scene)
     }
     */
    
    func updateNSView(_ nsView: SKView, context: Context) {
        nsView.presentScene(context.coordinator.scene)
    }
    
    
}


