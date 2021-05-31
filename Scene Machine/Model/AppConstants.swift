//
//  AppConstants.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/9/21.
//

import Foundation
import SceneKit

// MARK: - Images

/// A helper to identify the sizes of a texture
enum TextureSize:Double, CaseIterable {
    
    /// 256 x 256
    case small = 256
    
    /// 512 x 512
    case medSmall = 512
    
    /// 1024 x 1024
    case medium = 1024
    
    /// 2048 x 2048
    case medLarge = 2048
    
    /// 4096 x 4096
    case large = 4096
    
    /// The size of this texture
    var size:CGSize {
        return CGSize(width: self.rawValue, height: self.rawValue)
    }
    
    /// Convenience to get the `width` without the size
    var width:CGFloat {
        return CGFloat(self.rawValue)
    }
    
    /// Convenience to get the `height` without the size
    var height:CGFloat {
        return CGFloat(self.rawValue)
    }
    
    /// The label (name)
    var label:String {
        switch self {
            case .small: return "small \(self.rawValue)"
            case .medSmall: return "medSmall \(self.rawValue)"
            case .medium: return "medium \(self.rawValue)"
            case .medLarge: return "medLarge \(self.rawValue)"
            case .large: return "large \(self.rawValue)"
        }
    }
    
    /// The description of the size of this texture
    var fullLabel:String {
        switch self {
            case .small: return "256 x 256"
            case .medSmall: return "512 x 512"
            case .medium: return "1024 x 1024"
            case .medLarge: return "2048 x 2048"
            case .large: return "4096 x 4096"
        }
    }
}

/// Texture Images included in the App.
enum AppTextures: String, CaseIterable {
    
    // Note: Keep the rawValue of this enum equal to the name of the image in Assets.xcassets
    
    case AsphaltDiffuse
    case AsphaltNormal
    case AsphaltRoughness
    
    case WallDiffuse
    case WallNormal
    
    case WoodDiffuse
    case WoodNormal
    
    case UVGrid
    case UVLabels
    
    var image:NSImage? {
        return NSImage(named: self.rawValue)
    }
    
    var labelName:String {
        switch self  {
            case .AsphaltDiffuse: return "Asphalt Diffuse"
            case .AsphaltNormal: return "Asphalt Normal"
            case .AsphaltRoughness: return "Asphalt Roughness"
            case .WallDiffuse: return "Wall Diffuse"
            case .WallNormal: return "Wall Normal"
            case .WoodDiffuse: return "Wood Diffuse"
            case .WoodNormal: return "Wood Normal"
            case .UVGrid: return "UV Grid"
            case .UVLabels: return "UV Labels"
        }
    }
}

// MARK: - Scenes

/// Additional Geometries offered by the App
enum AppGeometries:String, CaseIterable {
    
    case Suzanne
    case Woman
    case Prototype
    case SquareTree
    case EggTree
    case LibertyLady
    case PostWithLamp
    
    func getGeometry() -> SCNNode? {
        //        var scene:SCNScene!
        var node:SCNNode?
        switch self {
            case .Suzanne:
                let scene = SCNScene(named: "Scenes.scnassets/Monkey4.scn")
                node = scene?.rootNode.childNode(withName: "Armature", recursively: false)?.clone()
                node?.position.y += 1
                node?.scale = SCNVector3(0.25, 0.25, 0.25)
            case .Woman:
                let scene = SCNScene(named: "Scenes.scnassets/Woman.scn")
                node = scene?.rootNode.childNode(withName: "Body_M_GeoRndr", recursively: false)?.clone()
                node?.scale = SCNVector3(0.12, 0.12, 0.12)
            case .Prototype:
                let scene = SCNScene(named: "Scenes.scnassets/PrototypeCar.scn")
                node = scene?.rootNode.childNode(withName: "CarBody", recursively: false)?.clone()
                node?.scale = SCNVector3(0.35, 0.35, 0.35)
            case .SquareTree:
                let scene = SCNScene(named: "Scenes.scnassets/SceneDeco.scn")
                node = scene?.rootNode.childNode(withName: "SmallPlant", recursively: false)?.clone()
            case .EggTree:
                let scene = SCNScene(named: "Scenes.scnassets/SceneDeco.scn")
                node = scene?.rootNode.childNode(withName: "EggTree", recursively: false)?.clone()
            case .LibertyLady:
                let scene = SCNScene(named: "Scenes.scnassets/SceneDeco.scn")
                node = scene?.rootNode.childNode(withName: "LibertyLady", recursively: false)?.clone()
            case .PostWithLamp:
                let scene = SCNScene(named: "Scenes.scnassets/SceneDeco.scn")
                node = scene?.rootNode.childNode(withName: "Post", recursively: false)?.clone()
        }
        return node
    }
}

/// Additional HDRI Images offered by the App
enum AppBackgrounds: String, CaseIterable {
    
    case Lava1
    case Lava2
    case Mountains
    case NightSky
    case CityDay
    case CityNight
    
    var content:String {
        switch self {
            case .Lava1: return "LavaWorldBlur.hdr"
            case .Lava2: return "LavaWorldBlur2.hdr"
            case .Mountains: return "SMB_3.hdr"
            case .NightSky: return "NightSky.hdr"
            case .CityDay: return "CityDay.hdr"
            case .CityNight: return "CityNight.hdr"
        }
    }
}
