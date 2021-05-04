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
    @Published var textureSize:TextureSize = .small
    
    init() {
        let texture = SKTexture.init(noiseWithSmoothness: 0.5, size: TextureSize.medSmall.size, grayscale: true)
        let img = texture.cgImage()
        let image = NSImage(cgImage: img, size: texture.size())
        self.currentImage = image
    }
    
    /// Generates a default `Perlin` noise with smoothness
    func generateNode(smooth:CGFloat) {
        let texture = SKTexture.init(noiseWithSmoothness: smooth, size: textureSize.size, grayscale: true)
        let img = texture.cgImage()
        let image = NSImage(cgImage: img, size: texture.size())
        self.currentImage = image
    }
    
    /// Opens the NSSave panel to save the `currentImage`
    func openSavePanel() {
        
        let dialog = NSSavePanel() //NSOpenPanel();
        
        dialog.title                   = "Choose destination";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowedFileTypes = ["png", "jpg", "jpeg"]
        dialog.message = "save scene"
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            
            if let result = dialog.url, let data = currentImage.tiffRepresentation {
                do {
                    try data.write(to: result)
                    print("File saved")
                } catch {
                    print("ERROR: \(error.localizedDescription)")
                }
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
