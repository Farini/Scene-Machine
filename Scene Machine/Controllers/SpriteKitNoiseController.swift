//
//  SpriteKitNoiseController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/6/21.
//

import Foundation
import Cocoa

class SpriteKitNoiseController:ObservableObject {
    
    @Published var currentImage:NSImage?
    @Published var fileName:String = "SKNoise"
    @Published var scene: GameScene = GameScene(size: CGSize(width: 600, height: 600))
    
    @Published var noiseType:NoiseType = .Perlin
    @Published var frequency:Double = 2.0
    @Published var octaves:Int = 4
    @Published var persistance:Double = 0.5
    @Published var lacunarity:Double = 0.5
    
    func updateScene() {
        scene.noiseType = noiseType
        scene.frequency = frequency
        scene.octaves = octaves
        scene.persistance = persistance
        scene.lacunarity = lacunarity
        scene.makePerlin()
    }
    
    // This opens the Finder, but not to save...
    func openSavePanel(for image:NSImage) {
        
        let data = image.tiffRepresentation
        
        let dialog = NSSavePanel() //NSOpenPanel();
        
        dialog.title                   = "Choose a directory";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        
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
                
                
                do {
                    try data?.write(to: URL(fileURLWithPath: path))
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
}
