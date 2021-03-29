//
//  SpriteNoiseMaker.swift
//  Scene Machine
//
//  Created by Carlos Farini on 3/29/21.
//

import SwiftUI
import SpriteKit
import GameKit

struct SpriteNoiseMaker: View {
    
    var scene: GameScene = GameScene(size: CGSize(width: 600, height: 600))
    
    @State var frequencyString:String = "2.0"
    @State var octavesString:String = "4"
    @State var persistanceString:String = "0.5"
    @State var lacunaString:String = "0.5"
    
    var body: some View {
        VStack {
            HStack {
                Text("GK Noise Maps").font(.title3).padding()
                Text("Freq:")
                TextField("Freq.", text: $frequencyString)
                    .frame(maxWidth:50)
                Text("Octaves:")
                TextField("Octaves.", text: $octavesString)
                    .frame(maxWidth:50)
                Text("Persist.:")
                TextField("Persistance", text: $persistanceString)
                    .frame(maxWidth:50)
                Text("Lacuna:")
                TextField("Lacunarity.", text: $lacunaString)
                    .frame(maxWidth:50)
                Group {
                    Button("Build") {
                        self.prepMap()
                    }
                    Button("Save") {
                        self.saveTexture()
                    }
                }
            }
            
            Divider()
            SpriteView(scene: scene).frame(width: 600, height: 600)
        }
    }
    
    func prepMap() {
        self.scene.frequency = Double(frequencyString) ?? 2.0
        self.scene.octaves = Int(octavesString) ?? 4
        self.scene.persistance = Double(persistanceString) ?? 0.5
        self.scene.lacunarity = Double(lacunaString) ?? 0.5
        
        self.scene.makePerlin()
    }
    
    func saveTexture() {
        
        guard let texture = scene.texture else { return }
        let randomNumber:Int = Int.random(in: 1...1000)
        let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Noise_\(randomNumber).png")
        
        let img = texture.cgImage()
        let image = NSImage(cgImage: img, size: texture.size())
        let data = image.tiffRepresentation
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: data, attributes: nil)
            print("File created")
            return
        }
    }
}

struct SpriteNoiseMaker_Previews: PreviewProvider {
    static var previews: some View {
        SpriteNoiseMaker()
            .frame(width: 700, height: 500, alignment: .top)
    }
}

// A simple game scene with falling boxes
class GameScene: SKScene {
    var texture:SKTexture?
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let lbl = SKLabelNode(text: "Where ????")
        self.addChild(lbl)
        
        let noiseMap = createNoiseMap()

        let texture = SKTexture(noiseMap: noiseMap)
        let sprite = SKSpriteNode(texture: texture, size: CGSize(width: 512, height: 512))
        addChild(sprite)
    }
    
    func makePerlin() {
        self.removeAllChildren()
        
        print("Children removed. -> New Map")
        print("Freq: \(frequency)")
        print("Octa: \(octaves)")
        print("Lacu: \(lacunarity)")
        print("Pers: \(persistance)")
        
        let source = GKPerlinNoiseSource(frequency: frequency, octaveCount: octaves, persistence: persistance, lacunarity: lacunarity, seed: 1)
        
//        let source = GKRidgedNoiseSource(frequency: 6.0, octaveCount: 4, lacunarity: 0.9, seed: 5)
        let noise = GKNoise.init(source)
        let map = GKNoiseMap.init(noise, size: vector2(1.0, 1.0), origin: vector2(0, 0), sampleCount: vector2(50, 50), seamless: true)
        self.makeSpriteTexture(noiseMap: map)
       
    }
    
    func makeSpriteTexture(noiseMap:GKNoiseMap) {
        let texture = SKTexture(noiseMap: noiseMap)
        let sprite = SKSpriteNode(texture: texture, size: CGSize(width: 512, height: 512))
        self.texture = texture
        self.addChild(sprite)
//        self.view?.needsDisplay = true
    }
    
    var frequency:Double = 2.0
    var octaves:Int = 4
    var persistance:Double = 0.5
    var lacunarity:Double = 0.5
    var displacement:Double = 1.0
    
    func createNoiseMap() -> GKNoiseMap {
        //Get our noise source, this can be customized further
        
//        let source = GKPerlinNoiseSource()
//        let source = GKPerlinNoiseSource(frequency: 2.0, octaveCount: 3, persistence: 0.5, lacunarity: 3.0, seed: 1)
        let source = GKBillowNoiseSource(frequency: 2.0, octaveCount: 6, persistence: 0.1, lacunarity: 2.0, seed: 32)
//        let source = GKRidgedNoiseSource(frequency: 6.0, octaveCount: 4, lacunarity: 0.9, seed: 5)
//        let source = GKVoronoiNoiseSource(frequency: 6.0, displacement: 1.0, distanceEnabled: true, seed: 1)
        
//        let source = GKCylindersNoiseSource(frequency: 2)
//        let source = GKSpheresNoiseSource(frequency: 3)
//        let source = GKCheckerboardNoiseSource(squareSize: 0.1)
        
        
        //Initalize our GKNoise object with our source
        let noise = GKNoise.init(source)
        //Create our map,
        //sampleCount = to the number of tiles in the grid (row, col)
        let map = GKNoiseMap.init(noise, size: vector2(1.0, 1.0), origin: vector2(0, 0), sampleCount: vector2(10, 10), seamless: true)
        return map
    }
    
    func makeImage() -> NSImage? {
        guard let texture = self.texture else { return nil }
        let img = texture.cgImage()
        let image = NSImage(cgImage: img, size: texture.size())
        return image
    }
}
