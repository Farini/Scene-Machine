//
//  SpriteKitNoiseController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/6/21.
//

import Foundation
import Cocoa
import SwiftUI
import SpriteKit
import GameKit

class SpriteKitNoiseController:ObservableObject {
    
    @Published var currentImage:NSImage?
    @Published var fileName:String = "SKNoise"
    @Published var scene:GameScene = GameScene(size: CGSize(width: 1024, height: 1024))
    
    // New
    @Published var textureSize:TextureSize = .medium
    @Published var noiseType:NoiseType = .Perlin
    
    // Noise Properties
    @Published var frequency:Double = 2.0
    @Published var octaves:Int = 4
    @Published var persistance:Double = 0.5
    @Published var lacunarity:Double = 0.5
    @Published var seed:Int = 1
    @Published var displacement:Double = 1
    @Published var squareSize:Double = 0.1
    
    @Published var noiseColors:[NSNumber:NSColor] = [NSNumber(value:-1):NSColor(deviceRed: 0, green: 0, blue: 0, alpha: 1), NSNumber(value:1):NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 1)]
    
    /// Prepares the Noise and updates the scene
    func updateNoise() {
        
        var noise:GKNoise!
        switch noiseType {
            case .Perlin:
                let source = GKPerlinNoiseSource(frequency: frequency, octaveCount: octaves, persistence: persistance, lacunarity: lacunarity, seed: Int32(seed))
                noise = GKNoise(source)
            case .Billow:
                let source = GKBillowNoiseSource(frequency: frequency, octaveCount: octaves, persistence: persistance, lacunarity: lacunarity, seed: Int32(seed))
                noise = GKNoise(source)
            case .Ridged:
                let source = GKRidgedNoiseSource(frequency: frequency, octaveCount: octaves, lacunarity: lacunarity, seed: Int32(seed))
                noise = GKNoise(source)
            case .Voronoi:
                let source = GKVoronoiNoiseSource(frequency: frequency, displacement: displacement, distanceEnabled: true, seed: Int32(seed))
                noise = GKNoise(source)
            
                // Other Patterns
            
            case .Checker:
                let source = GKCheckerboardNoiseSource(squareSize: squareSize)
                noise = GKNoise(source)
                
            case .Cylinder:
                let source = GKCylindersNoiseSource(frequency: frequency)
                noise = GKNoise(source)
            case .Sphere:
                let source = GKSpheresNoiseSource(frequency: frequency)
                noise = GKNoise(source)
        }
        
        // Gradients
        noise.gradientColors = noiseColors
        
        // Map
        let texSize = textureSize.size
        let map = GKNoiseMap(noise, size: vector2(1.0, 1.0), origin: vector2(0, 0), sampleCount:vector2(Int32(texSize.width), Int32(texSize.height)), seamless: true)
        
        // Render
        scene.makeSpriteTexture(noiseMap: map, size:texSize)
        
    }
    
    func updateSizes() {
        let sceneSize = textureSize.size
        self.scene = GameScene(size: sceneSize)
    }
    
    // This opens the Finder, but not to save...
    func openSavePanel() {
        guard let image = scene.makeImage() else {
            print("Couldn't make an image")
            return
        }
        
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

// A simple game scene for textures
class GameScene: SKScene {
    
    var texture:SKTexture?
    var noiseType:NoiseType = .Perlin
    var noiseColors:[NSNumber:NSColor]?
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let lbl = SKLabelNode(text: "Where ????")
        self.addChild(lbl)
        
        let noiseMap = createNoiseMap()
        
        let texture = SKTexture(noiseMap: noiseMap)
        let sprite = SKSpriteNode(texture: texture, size: self.size)
        addChild(sprite)
        
    }
    
    func makeSpriteTexture(noiseMap:GKNoiseMap, size:CGSize) {
        
        self.removeAllChildren()
        
        let texture = SKTexture(noiseMap: noiseMap)
        let sprite = SKSpriteNode(texture: texture, size: size)
        
        self.texture = texture
        self.addChild(sprite)
    }
    
    func createNoiseMap() -> GKNoiseMap {
        //Get our noise source, this can be customized further
        
        let source = GKPerlinNoiseSource()
        
        //Initalize our GKNoise object with our source
        let noise = GKNoise.init(source)
        //Create our map,
        //sampleCount = to the number of tiles in the grid (row, col)
        let map = GKNoiseMap.init(noise, size: vector2(1.0, 1.0), origin: vector2(0, 0), sampleCount: vector2(100, 100), seamless: true)
        return map
    }
    
    func makeImage() -> NSImage? {
        guard let texture = self.texture else { return nil }
        let img = texture.cgImage()
        let image = NSImage(cgImage: img, size: texture.size())
        return image
    }
}
