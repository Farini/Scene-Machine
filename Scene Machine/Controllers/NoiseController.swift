//
//  NoiseController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 3/29/21.
//

import Foundation
import SpriteKit

class NoiseController:ObservableObject {
    
//    @Published var noises:[String]
    @Published var currentImage:NSImage
    
    @Published var fileName:String = "Noise"
    
    init() {
//        self.noises = ["Tester"]
        let texture = SKTexture.init(noiseWithSmoothness: 0.5, size: CGSize(width: 512, height: 512), grayscale: true)
        let img = texture.cgImage()
        let image = NSImage(cgImage: img, size: texture.size())
        self.currentImage = image
    }
    
//    func addNoise() {
//        print("Adding noise ??")
//        self.noises.append("Noise \(noises.count)")
//        for n in noises {
//            print("\(n)")
//        }
//    }
    
    func generateNode(smooth:CGFloat) {
        let texture = SKTexture.init(noiseWithSmoothness: smooth, size: CGSize(width: 512, height: 512), grayscale: true)
        let img = texture.cgImage()
        let image = NSImage(cgImage: img, size: texture.size())
        self.currentImage = image
    }
    
    // This opens the Finder, but not to save...
    func openSavePanel() {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a directory";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = true;
        dialog.canChooseFiles = true;
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if let result = result {
                if result.isFileURL {
                    print("Picked a file")
                } else {
                    // this doesn't happen
                    print("Picked what?")
                }
                let path: String = result.path
                print("Picked Path: \(path)")
            }
            
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    // Deprecate
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
    
    // Deprecate
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
