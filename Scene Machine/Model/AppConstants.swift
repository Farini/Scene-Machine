//
//  AppConstants.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/9/21.
//

import Foundation
import SceneKit

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
                let scene = SCNScene(named: "Scenes.scnassets/Monkey5.scn")
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
    case SMB1
    case SMB2
    case SMB3
    case NightSky
    case CityNight
    
    var content:String {
        switch self {
            case .Lava1: return "LavaWorldBlur.hdr"
            case .Lava2: return "LavaWorldBlur2.hdr"
            case .SMB1: return "SMB_1.hdr"
            case .SMB2: return "SMB_2.hdr"
            case .SMB3: return "SMB_3.hdr"
            case .NightSky: return "NightSky.hdr"
            case .CityNight: return "CityNight.hdr"
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
