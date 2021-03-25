//
//  NoiseView.swift
//  Scene Machine
//
//  Created by Carlos Farini on 12/3/20.
//

import SwiftUI
import SpriteKit
import CoreImage

struct NoiseView: View {
    @ObservedObject var controller:NoiseController = NoiseController()
    @State var sliderVal:Float = Float(0.5)
    var body: some View {
        HSplitView {
            // Left
            List {
                Button("Save") {
                    
                    // Saving with SwiftUI
                    // https://stackoverflow.com/questions/56645819/how-to-open-file-dialog-with-swiftui-on-platform-uikit-for-mac
                    // Swift 5
                    // https://ourcodeworld.com/articles/read/1117/how-to-implement-a-file-and-directory-picker-in-macos-using-swift-5
                    
                    print("Should save. Where?")
                    LastNode.shared.saveTexture()
                }
                Button("Change (Add)") {
                    print("Should change")
                    controller.addNoise()
                }
                Button("MixImages") {
                    print("Sepia")
                    controller.mixImages()
                }
                Button("Filter dic") {
                    controller.buildFilterDictionary()
                }
                Slider(value: $sliderVal, in: 0...1) { changed in
                    print("Slider Changed")
                    controller.generateNode(smooth:CGFloat(sliderVal))
                }
            }
            .listStyle(SidebarListStyle())
            .frame(maxWidth:200, idealHeight: 1024, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            // Right
            ScrollView(.horizontal, showsIndicators: true) {
                Image(nsImage: controller.currentImage)
            }
            .frame(idealWidth:1024, idealHeight: 1024, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
    
    func runact() {
        print("actions")
    }
}

struct NoiseView_Previews: PreviewProvider {
    static var previews: some View {
        NoiseView()
    }
}

class NoiseController:ObservableObject {
    
    @Published var noises:[String]
    @Published var currentImage:NSImage
    
    init() {
        self.noises = ["Tester"]
        let texture = SKTexture.init(noiseWithSmoothness: 0.5, size: CGSize(width: 512, height: 512), grayscale: true)
        let img = texture.cgImage()
        let image = NSImage(cgImage: img, size: texture.size())
        self.currentImage = image
    }
    
    func addNoise() {
        print("Adding noise ??")
        self.noises.append("Noise \(noises.count)")
        for n in noises {
            print("\(n)")
        }
    }
    
    func generateNode(smooth:CGFloat) {
        let texture = SKTexture.init(noiseWithSmoothness: smooth, size: CGSize(width: 512, height: 512), grayscale: true)
        let img = texture.cgImage()
        let image = NSImage(cgImage: img, size: texture.size())
        self.currentImage = image
    }
    
    func mixImages() {
        let texture = SKTexture.init(noiseWithSmoothness: 0.5, size: CGSize(width: 512, height: 512), grayscale: true)
        let img = currentImage.cgImage(forProposedRect: nil, context: nil, hints: nil) ?? texture.cgImage()
        let ciimg = CIImage(cgImage: img)

        let newTexture = SKTexture.init(noiseWithSmoothness: 0.85, size: CGSize(width: 512, height: 512), grayscale: true).cgImage()
        let newImage = ciimg.composited(over: CIImage(cgImage:newTexture))
        
        let rep = NSCIImageRep(ciImage: newImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        self.currentImage = nsImage
    }
    
    func buildFilterDictionary() {
        print("Filter Dictionary")
        let filters = CIFilter.filterNames(inCategory: "CICategoryCompositeOperation")
        for filterName in filters {
            print("Filter name: \(filterName)")
        }
        
        // Filter Categories
        /*
         CICategoryBlur
         CICategoryColorAdjustment
         CICategoryColorEffect
         CICategoryCompositeOperation
         CICategoryDistortionEffect
         CICategoryGenerator
         CICategoryGeometryAdjustment
         CICategoryGradient
         CICategoryHalftoneEffect
         CICategoryReduction
         CICategorySharpen
         CICategoryStylize
         CICategoryTileEffect
         CICategoryTransition
         */
    }
    
}

class LastNode {
    static let shared = LastNode()
    private init() {
        let texture = SKTexture.init(noiseWithSmoothness: 0.5, size: CGSize(width: 512, height: 512), grayscale: true)
        let node = SKSpriteNode(texture: texture)
        self.node = node
        self.texture = texture
    }
    var node:SKNode?
    var texture:SKTexture?
    func updateNode(_ newNode:SKNode, texture:SKTexture) {
        print("updating")
        self.node = newNode
        self.texture = texture
    }
    func saveTexture() {
        guard let texture = texture else { fatalError() }
        let fileUrl = folder.appendingPathComponent("Noise.png")
        let img = texture.cgImage()
        let image = NSImage(cgImage: img, size: texture.size())
        let data = image.tiffRepresentation
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
