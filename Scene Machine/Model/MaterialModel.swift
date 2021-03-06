//
//  MaterialModel.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/13/21.
//

import Cocoa
import Foundation
import SwiftUI
import SceneKit

/// An object that stores `SCNMaterial` properties
class SceneMaterial: Codable, Identifiable, Equatable {
    
    /// An identity assigned, to keep track and differentiate materials
    var id:UUID
    
    /// Name of the material
    var name:String?
    
    /// Shading type (Physically based, phong, etc.)
    var lightModel:MaterialShading?
    
    /// Parts of the material
    var diffuse:SubMaterialData?
    var metalness:SubMaterialData?
    var roughness:SubMaterialData?
    var normal:SubMaterialData?
    var occlusion:SubMaterialData?
    var emission:SubMaterialData?
    
    /**
     Material Modes
     - Diffuse
     - Metalness
     - Roughness
     - Normal
     - Transparent
     - Occlusion
     - Illumination
     - Emission
     - Multiply
     - Coat
     - CoatNormal
     - CoatRoughness
     - Displacement
     */
    
    // Shaders:
    // 1. Surface
    // 2. Fragment
    // 3. LightingModel
    
    /// Shader snippets written in Metal
    var surfaceShader:String?
    var fragmentShader:String?
    var lighShader:String?
    
    // MARK: - Methods
    
    func make() -> SCNMaterial {
        let material = SCNMaterial()
        material.name = self.name ?? "untitled"
        
        material.lightingModel = lightModel?.make() ?? .physicallyBased
        
        material.diffuse.contents =  diffuse?.makeAnyProperty()
        
//        material.diffuse.wrapS = .repeat
//        material.diffuse.wrapT = .repeat
        
        material.metalness.contents = metalness?.makeAnyProperty() ?? 0.0
        material.roughness.contents = roughness?.makeAnyProperty() ?? 0.4
        material.normal.contents = roughness?.makeAnyProperty() ?? Color.white
        material.ambientOcclusion.contents = occlusion?.makeAnyProperty() ?? Color.white
        material.emission.contents = emission?.makeAnyProperty() ?? NSColor.black
        material.selfIllumination.contents = NSColor.black
        material.multiply.contents = 0.5
        
        return material
    }
    
    /// Makes an example material with a color resembling that of a `Skin`
    static func skinExample() -> SceneMaterial {
        
        let mat = SceneMaterial()
        mat.lightModel = .PhysicallyBased
        
        let d2:SubMaterialData = SubMaterialData(spectrum: 1, sColor: ColorData(r: 0.9, g: 0.5, b: 0.5, a: 1))
        let d3 = d2.specColor!
        let d4 = d3.makeNSColor()
        print("DDD | \(d4.debugDescription) | \(d3) | \(d2)")
        
        mat.diffuse = d2
        
        return mat
    }
    
    /// Initialize an empty one (to create)
    init() {
        self.id = UUID()
    }
    
    static func == (lhs: SceneMaterial, rhs: SceneMaterial) -> Bool {
        return lhs.id == rhs.id
    }
    
    func save() {
        if let idx = LocalDatabase.shared.materials.firstIndex(where: { $0.id == id }) {
            LocalDatabase.shared.materials[idx] = self
            LocalDatabase.shared.saveMaterial(material: self)
        }
    }
    
    func delete() {
        if let idx = LocalDatabase.shared.materials.firstIndex(where: { $0.id == id }) {
            LocalDatabase.shared.materials.remove(at: idx)
            LocalDatabase.shared.saveMaterialsList()
        }
    }
    
    /// Initialize from a SceneKit Material
    init(material:SCNMaterial) {
        
        self.id = UUID()
        
        self.name = material.name
        self.lightModel = MaterialShading.fromMaterial(material: material)
        
        
        // Contents
        if let diffuseContent = material.diffuse.contents {
            self.diffuse = SubMaterialData()
            self.diffuse?.storeAnyProperty(property: diffuseContent)
            self.diffuse?.intensity = Double(material.diffuse.intensity)
            if let image = diffuseContent as? NSImage {
                if let url = LocalDatabase.shared.saveImage(image, material: self, mode: .Diffuse) {
                    self.diffuse?.imageURL = url
                }
            }
        }
        
        if let metalnessContent = material.metalness.contents {
            self.metalness = SubMaterialData()
            self.metalness?.storeAnyProperty(property: metalnessContent)
            self.metalness?.intensity = Double(material.metalness.intensity)
            if let image = metalnessContent as? NSImage {
                if let url = LocalDatabase.shared.saveImage(image, material: self, mode: .Roughness) {
                    self.metalness?.imageURL = url
                }
            }
        }
        if let roughContent = material.roughness.contents {
            self.roughness = SubMaterialData()
            self.roughness?.storeAnyProperty(property: roughContent)
            self.roughness?.intensity = Double(material.roughness.intensity)
            if let image = roughContent as? NSImage {
                if let url = LocalDatabase.shared.saveImage(image, material: self, mode: .Roughness) {
                    self.roughness?.imageURL = url
                }
            }
        }
        if let normalContent = material.normal.contents {
            self.normal = SubMaterialData()
            self.normal?.storeAnyProperty(property: normalContent)
            self.normal?.intensity = Double(material.normal.intensity)
            if let image = normalContent as? NSImage {
                if let url = LocalDatabase.shared.saveImage(image, material: self, mode: .Normal) {
                    self.normal?.imageURL = url
                }
            }
        }
        if let occlusionContents = material.ambientOcclusion.contents {
            self.occlusion = SubMaterialData()
            self.occlusion?.storeAnyProperty(property: occlusionContents)
            self.occlusion?.intensity = Double(material.ambientOcclusion.intensity)
            if let image = occlusionContents as? NSImage {
                if let url = LocalDatabase.shared.saveImage(image, material: self, mode: .AO) {
                    self.occlusion?.imageURL = url
                }
            }
        }
        if let emissionContents = material.emission.contents {
            self.emission = SubMaterialData()
            self.emission?.storeAnyProperty(property: emissionContents)
            self.emission?.intensity = Double(material.emission.intensity)
            if let image = emissionContents as? NSImage {
                if let url = LocalDatabase.shared.saveImage(image, material: self, mode: .Emission) {
                    self.emission?.imageURL = url
                }
            }
        }
    }
    
    func updateWith(material:SCNMaterial) {
        
        self.name = material.name
        self.lightModel = MaterialShading.fromMaterial(material: material)
        
        // Contents
        if let diffuseContent = material.diffuse.contents {
            self.diffuse = SubMaterialData()
            self.diffuse?.storeAnyProperty(property: diffuseContent)
            self.diffuse?.intensity = Double(material.diffuse.intensity)
            if let image = diffuseContent as? NSImage {
                if let url = LocalDatabase.shared.saveImage(image, material: self, mode: .Diffuse) {
                    self.diffuse?.imageURL = url
                }
            }
        }
        
        if let metalnessContent = material.metalness.contents {
            self.metalness = SubMaterialData()
            self.metalness?.storeAnyProperty(property: metalnessContent)
            self.metalness?.intensity = Double(material.metalness.intensity)
            if let image = metalnessContent as? NSImage {
                if let url = LocalDatabase.shared.saveImage(image, material: self, mode: .Roughness) {
                    self.metalness?.imageURL = url
                }
            }
        }
        if let roughContent = material.roughness.contents {
            self.roughness = SubMaterialData()
            self.roughness?.storeAnyProperty(property: roughContent)
            self.roughness?.intensity = Double(material.roughness.intensity)
            if let image = roughContent as? NSImage {
                if let url = LocalDatabase.shared.saveImage(image, material: self, mode: .Roughness) {
                    self.roughness?.imageURL = url
                }
            }
        }
        if let normalContent = material.normal.contents {
            self.normal = SubMaterialData()
            self.normal?.storeAnyProperty(property: normalContent)
            self.normal?.intensity = Double(material.normal.intensity)
            if let image = normalContent as? NSImage {
                if let url = LocalDatabase.shared.saveImage(image, material: self, mode: .Normal) {
                    self.normal?.imageURL = url
                }
            }
        }
        if let occlusionContents = material.ambientOcclusion.contents {
            self.occlusion = SubMaterialData()
            self.occlusion?.storeAnyProperty(property: occlusionContents)
            self.occlusion?.intensity = Double(material.ambientOcclusion.intensity)
            if let image = occlusionContents as? NSImage {
                if let url = LocalDatabase.shared.saveImage(image, material: self, mode: .AO) {
                    self.occlusion?.imageURL = url
                }
            }
        }
        if let emissionContents = material.emission.contents {
            self.emission = SubMaterialData()
            self.emission?.storeAnyProperty(property: emissionContents)
            self.emission?.intensity = Double(material.emission.intensity)
            if let image = emissionContents as? NSImage {
                if let url = LocalDatabase.shared.saveImage(image, material: self, mode: .Emission) {
                    self.emission?.imageURL = url
                }
            }
        }
    }
    
    /// Returns how many images are founf in this material
    func imageScore() -> Int {
        var score = 0
        if diffuse?.imageURL != nil {
            score += 1
        }
        if roughness?.imageURL != nil {
            score += 1
        }
        if emission?.imageURL != nil {
            score += 1
        }
        if occlusion?.imageURL != nil {
            score += 1
        }
        if normal?.imageURL != nil {
            score += 1
        }
        return score
    }
    
    static func examples() -> [SceneMaterial] {
        
        var appMaterials:[SceneMaterial] = []
        
        let exm1 = SCNMaterial.example
        let ex1 = SceneMaterial(material: exm1)
        ex1.name = "SCN Example"
        appMaterials.append(ex1)
        
        let rubber = SceneMaterial()
        rubber.diffuse = SubMaterialData(spectrum: 1.0, sColor:  ColorData(r: 0.25, g: 0.25, b: 0.25, a: 1.0))
        rubber.roughness = SubMaterialData(spectrum: 0.9, sColor: nil)
        rubber.name = "Rubber"
        appMaterials.append(rubber)
        
        let sleekPlastic = SceneMaterial()
        sleekPlastic.diffuse = SubMaterialData(spectrum: 1.0, sColor: ColorData(r: 0.15, g: 0.15, b: 0.15, a: 1.0))
        sleekPlastic.roughness = SubMaterialData(spectrum: 0.1, sColor: nil)
        sleekPlastic.name = "Sleek plastic"
        appMaterials.append(sleekPlastic)
        
        let goldenNugget = SceneMaterial()
        goldenNugget.diffuse = SubMaterialData(spectrum: 1.0, sColor: ColorData(r: 1.0, g: 0.7, b: 0.3, a: 1.0))
        goldenNugget.roughness = SubMaterialData(spectrum: 0.05, sColor: nil)
        goldenNugget.name = "Gold"
        appMaterials.append(goldenNugget)
        
        let silver = SceneMaterial()
        silver.diffuse = SubMaterialData(spectrum: 1.0, sColor: ColorData(r: 0.6, g: 0.6, b: 0.601, a: 1.0))
        silver.roughness = SubMaterialData(spectrum: 0.05, sColor: nil)
        silver.name = "Silver"
        appMaterials.append(silver)
        
        let caustic = SceneMaterial()
        caustic.diffuse = SubMaterialData(spectrum: 1.0, sColor: ColorData(r: 0.75, g: 0.75, b: 0.78, a: 1.0))
        if let bnd = Bundle.main.url(forResource: "/Scenes.scnassets/UVMaps/CausticNoise", withExtension: ".png") {
            caustic.diffuse?.imageURL = bnd
        }
        caustic.roughness = SubMaterialData(spectrum: 0.05, sColor: nil)
        caustic.name = "Caustic"
        appMaterials.append(caustic)
        
        let wood = SceneMaterial()
        wood.diffuse = SubMaterialData(spectrum: 1.0, sColor: ColorData(r: 0.75, g: 0.75, b: 0.78, a: 1.0))
        if let url = URL.localURLForXCAsset(name: "WoodDiffuse") {
            // code
            wood.diffuse?.imageURL = url
        }
        wood.normal = SubMaterialData(spectrum: 1.0, sColor: nil)
        if let url = URL.localURLForXCAsset(name: "WoodNormal") {
            wood.normal!.imageURL = url
        }
        // wood.roughness = SubMaterialData(spectrum: 0.8, sColor: nil)
        wood.name = "Wood"
        appMaterials.append(wood)
        
        
        
        
        return appMaterials
    }
}

/// An object that stores `SCNMaterialProperty` variables
class SubMaterialData:Codable {
    
    /// For materials that need a number only
    var spectrum:Double = 0
    
    /// A Color, for some material types
    var specColor:ColorData?
    
    /// An Image associated with this material
    var imageURL:URL?
    
    /// The intensity in wich this data displays
    var intensity:Double = 1.0
    
    /// Wrapping methods for the image (if any)
    var wrapS:SCNWrapMode = .clamp
    
    /// Wrapping methods for the image (if any)
    var wrapT:SCNWrapMode = .clamp
    
    init() {
        
    }
    
    init(spectrum:Double, sColor:ColorData?) {
        if let color = sColor {
            self.specColor = color
        } else {
            self.spectrum = spectrum
        }
        self.spectrum = spectrum
    }
    
    /// Sets the Intensity of the material
    func changeIntensity(new:Double) {
        self.intensity = new
    }
    
    /// Any must be an `Image`, a` Color`, or a `Double`
    func makeAnyProperty() -> Any {
        
        // Any must be an Image, a Color, or a Float
        
        if let url = imageURL {
            print("Submaterial URL: \(url)")
            if let data = try? Data(contentsOf: url) {
                print("Submaterial DATA")
                if let nsimage = NSImage(data: data) {
                    print("Submaterial image")
                    // let image = Image(nsImage: nsimage)
                    return nsimage
                }
            }
        }
        
        if let colorData = specColor {
            print("Submaterial Color(r): \(colorData.r)")
            let suicol = colorData.getColor()
            let nscol = colorData.makeNSColor()
            print("SUI Color: \(suicol.description)")
            print("NS Color: \(nscol.description)")
            // let suiColor = colorData.makeNSColor()
            return colorData.makeNSColor() // getColor() //makeNSColor()
        } else {
            return spectrum
        }
    }
    
    func storeAnyProperty(property:Any) {
        if let color = property as? NSColor {
            let colorData = ColorData(nsColor: color)
            self.specColor = colorData
        } else if let dNumber = property as? Double {
            self.spectrum = dNumber
        } else if let url = property as? URL {
            self.imageURL = url
        }
    }
}

/// An object that stores `Color`
struct ColorData: Codable {
    
    var r: Double
    var g: Double
    var b: Double
    var a: Double
    
    init(suiColor:Color) {
        print("DE: \(suiColor.cgColor.debugDescription)")
        let nativeColor = NSColor(suiColor).usingColorSpace(.deviceRGB)!
        var (r, g, b, a) = (CGFloat.zero, CGFloat.zero, CGFloat.zero, CGFloat.zero)
        nativeColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.r = Double(r)
        self.g = Double(g)
        self.b = Double(b)
        self.a = Double(a)
    }
    
    init(nsColor:NSColor) {
        var (r, g, b, a) = (CGFloat.zero, CGFloat.zero, CGFloat.zero, CGFloat.zero)
        nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.r = Double(r)
        self.g = Double(g)
        self.b = Double(b)
        self.a = Double(a)
    }
    
    init(r:Double, g:Double, b:Double, a:Double) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    func getColor() -> Color {
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
    
    func makeNSColor() -> NSColor {
        return NSColor(calibratedRed: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a)).usingColorSpace(.sRGB)!
    }
}

/// `LightingModel` Data used for Rendering
enum MaterialShading:String, Codable, CaseIterable {
    
    case PhysicallyBased
    case Lambert
    case Blinn
    case Phong
    
    func make() -> SCNMaterial.LightingModel {
        switch self {
            case .PhysicallyBased: return .physicallyBased
            case .Lambert: return .lambert
            case .Blinn: return .blinn
            case .Phong: return .phong
        }
    }
    
    static func fromMaterial(material:SCNMaterial) -> MaterialShading {
        switch material.lightingModel {
            case .physicallyBased: return .PhysicallyBased
            case .lambert: return .Lambert
            case .blinn: return .Blinn
            case .phong: return .Phong
            default: return .PhysicallyBased
        }
    }
}

// MARK: - To Do
// TODO: - Renaming

// Names
// SMMaterial
// SMMaterialProperty
// SMMaterialFX
