//
//  NoiseController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 3/29/21.
//

import Foundation
import SpriteKit

class NoiseController:ObservableObject {
    
    @Published var currentImage:NSImage
    
    init() {
        let texture = SKTexture.init(noiseWithSmoothness: 0.5, size: CGSize(width: 512, height: 512), grayscale: true)
        let img = texture.cgImage()
        let image = NSImage(cgImage: img, size: texture.size())
        self.currentImage = image
    }
    
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
        dialog.canChooseFiles = false;
        
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
    
}
