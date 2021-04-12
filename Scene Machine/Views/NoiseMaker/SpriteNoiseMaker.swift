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
    
    @State var scene: GameScene = GameScene(size: CGSize(width: 600, height: 600))
    @ObservedObject var controller:SpriteKitNoiseController = SpriteKitNoiseController()
    
    // Colors Sources
    // Color palette
    // Image Size: 256, 512, 1024, 2048, 4096
    
    @State var noisePop:Bool = false
    @State var sizePop:Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            
            SpriteView(scene: controller.scene).frame(width: scene.size.width, height: scene.size.height)
            
            VStack {
                HStack {
                    Text("GK Noise").font(.title3).padding().foregroundColor(.orange)
                    
                    Group {
                        Button("Grow") {
                            sizePop = true
                        }
                        .popover(isPresented: $sizePop, content: {
                            List(TextureSize.allCases, id:\.self) { imSize in
                                HStack {
                                    Text("\(imSize.label)")
                                    Spacer()
                                    
                                }
                                .onTapGesture {
                                    self.scene = GameScene(size: CGSize(width: imSize.size.width, height: imSize.size.height))
                                }
                            }
                            .frame(minWidth:300)
                        })
                        Button("Update") {
                            self.prepMap()
                        }
                        Button("Save") {
                            self.saveTexture()
                        }
                        Button("Noise") {
                            noisePop.toggle()
                        }
                        .popover(isPresented: $noisePop, content: {
                            SpriteNoisePopover(controller:controller)
                        })
                    }
                }
                Divider()
            }
            .frame(height:40)
            .background(Color.black.opacity(0.5))
        }
  
    }
    
    func prepMap() {
        controller.updateScene()
    }
    
    func saveTexture() {
        
        guard let texture = controller.scene.texture else { return }
        
        let img = texture.cgImage()
        let image = NSImage(cgImage: img, size: texture.size())
        
        // Call the Save Panel
        controller.openSavePanel(for: image)
    }
}

struct SpriteNoisePopover:View {
    
    @ObservedObject var controller:SpriteKitNoiseController
    
    @State var noiseType:NoiseType = .Perlin
    @State var frequencyString:String = "2.0"
    @State var octavesString:String = "4"
    @State var persistanceString:String = "0.5"
    @State var lacunaString:String = "0.5"
    
    var body: some View {
        VStack {
            
            Text("GK Noise Maps").font(.title3).padding().foregroundColor(.orange)
            Picker(selection: $noiseType, label: Text("Noise Type"), content: {
                ForEach(NoiseType.allCases, id:\.self) { nType in
                    Text("\(nType.rawValue)")
                        .onTapGesture {
                            controller.noiseType = nType
                        }
                }
            })
            .frame(maxWidth:200)
            Divider()
                .frame(maxWidth:250)
            
            Group {
                HStack {
                    Text("Frequency")
                    TextField("Freq.", text: $frequencyString)
                        .frame(maxWidth:50)
                }
                HStack {
                    Text("Octaves")
                    TextField("Octaves.", text: $octavesString)
                        .frame(maxWidth:50)
                }
                HStack {
                    Text("Persistency")
                    TextField("Persistance", text: $persistanceString)
                        .frame(maxWidth:50)
                }
                HStack {
                    Text("Lacunarity")
                    TextField("Lacunarity.", text: $lacunaString)
                        .frame(maxWidth:50)
                }
            }
            
            Divider()
                .frame(maxWidth:250)
            
            Group {
                Button("Build") {
                      self.prepMap()
                }
                .padding(.bottom, 8)
            }
        }
    }
    
    func prepMap() {
        controller.noiseType = noiseType
        controller.frequency = Double(frequencyString) ?? 2.0
        controller.octaves = Int(octavesString) ?? 4
        controller.persistance = Double(persistanceString) ?? 0.5
        controller.lacunarity = Double(lacunaString) ?? 0.5
        controller.updateScene()
    }
}

struct SpriteNoiseMaker_Previews: PreviewProvider {
    static var previews: some View {
        SpriteNoiseMaker()
//            .frame(width: 700, height: 700, alignment: .top)
            .frame(minWidth: 400, maxWidth: 2048, minHeight: 700, maxHeight: 1856, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        
    }
}

struct SpritePopover_Previews:PreviewProvider {
    static var previews: some View {
        SpriteNoisePopover(controller:SpriteKitNoiseController())
    }
}

enum NoiseType:String, CaseIterable {
    case Perlin
    case Billow
    case Ridged
    case Voronoi
    case Cylinder
    case Sphere
    case Checker
}

// A simple game scene with falling boxes
class GameScene: SKScene {
    var texture:SKTexture?
    var noiseType:NoiseType = .Perlin
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let lbl = SKLabelNode(text: "Where ????")
        self.addChild(lbl)
        
        let noiseMap = createNoiseMap()

        let texture = SKTexture(noiseMap: noiseMap)
        let sprite = SKSpriteNode(texture: texture, size: self.size)
        addChild(sprite)
        
//        if texture.size().height > view.bounds.size.height {
//            let scale = view.bounds.height / sprite.size.height
//            sprite.scale(to: CGSize(width: scale*texture.size().width, height: scale*texture.size().height))
//        }
    }
    
    func makePerlin() {
        self.removeAllChildren()
        
        print("Children removed. -> New Map")
        print("Freq: \(frequency)")
        print("Octa: \(octaves)")
        print("Lacu: \(lacunarity)")
        print("Pers: \(persistance)")
        
        var source:GKNoiseSource!
        switch noiseType {
            case .Perlin:
                source = GKPerlinNoiseSource(frequency: frequency, octaveCount: octaves, persistence: persistance, lacunarity: lacunarity, seed: 1)
            case .Billow:
                source = GKBillowNoiseSource(frequency: frequency, octaveCount: octaves, persistence: persistance, lacunarity: lacunarity, seed: 1)
            case .Checker:
                source = GKCheckerboardNoiseSource(squareSize: frequency)
            case .Cylinder, .Sphere:
                source = GKCylindersNoiseSource(frequency: frequency)
            case .Ridged:
                source = GKRidgedNoiseSource(frequency: frequency, octaveCount: octaves, lacunarity: lacunarity, seed: 1)
            case .Voronoi:
                source = GKVoronoiNoiseSource(frequency: frequency, displacement: 1, distanceEnabled: true, seed: 1)
        }
        
        
        
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
        
        let source = GKPerlinNoiseSource()
//        let source = GKPerlinNoiseSource(frequency: 2.0, octaveCount: 3, persistence: 0.5, lacunarity: 3.0, seed: 1)
//        let source = GKBillowNoiseSource(frequency: 3.0, octaveCount: 4, persistence: 0.4, lacunarity: 3, seed: 32)
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
