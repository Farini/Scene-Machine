//
//  SceneKit+Extensions.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/21/21.
//

import Foundation
import SceneKit

// MARK: - Geometry Element

extension SCNGeometryElement {
    
    /// Gets the `Element` vertices
    func getVertices() -> [SCNVector3] {
        
        func vectorFromData<UInt: BinaryInteger>(_ float: UInt.Type, index: Int) -> SCNVector3 {
            assert(bytesPerIndex == MemoryLayout<UInt>.size)
            let vectorData = UnsafeMutablePointer<UInt>.allocate(capacity: bytesPerIndex)
            let buffer = UnsafeMutableBufferPointer(start: vectorData, count: primitiveCount)
            let stride = 3 * index
//            let rangeStart = primitiveRange.lowerBound
//            let rangeEnd = primitiveRange.upperBound
            self.data.copyBytes(to: buffer, from: stride * bytesPerIndex..<(stride * bytesPerIndex) + 3)
            return SCNVector3(
                CGFloat.NativeType(vectorData[0]),
                CGFloat.NativeType(vectorData[1]),
                CGFloat.NativeType(vectorData[2])
            )
        }
        
        let vectors = [SCNVector3](repeating: SCNVector3Zero, count: self.primitiveCount)
        return vectors.indices.map { index -> SCNVector3 in
            switch bytesPerIndex {
                case 2:
                    return vectorFromData(Int16.self, index: index)
                case 4:
                    return vectorFromData(Int.self, index: index)
                case 8:
                    return SCNVector3Zero // vectorFromData(Float80.self, index: index)
                default:
                    return SCNVector3Zero
            }
        }
    }
}

// MARK: - Geometry Source

extension SCNGeometrySource {
    
    /// Use this if the source is `SCNGeometrySourceSemanticVertex` or `SCNGeometrySourceSemanticNormal`
    var vertices: [SCNVector3] {
        let stride = self.dataStride
        let offset = self.dataOffset
        let componentsPerVector = self.componentsPerVector
        let bytesPerVector = componentsPerVector * self.bytesPerComponent
        
        func vectorFromData<FloatingPoint: BinaryFloatingPoint>(_ float: FloatingPoint.Type, index: Int) -> SCNVector3 {
            assert(bytesPerComponent == MemoryLayout<FloatingPoint>.size)
            let vectorData = UnsafeMutablePointer<FloatingPoint>.allocate(capacity: componentsPerVector)
            let buffer = UnsafeMutableBufferPointer(start: vectorData, count: componentsPerVector)
            let rangeStart = index * stride + offset
            self.data.copyBytes(to: buffer, from: rangeStart..<(rangeStart + bytesPerVector))
            return SCNVector3(
                CGFloat.NativeType(vectorData[0]),
                CGFloat.NativeType(vectorData[1]),
                CGFloat.NativeType(vectorData[2])
            )
        }
        
        let vectors = [SCNVector3](repeating: SCNVector3Zero, count: self.vectorCount)
        return vectors.indices.map { index -> SCNVector3 in
            switch bytesPerComponent {
                case 4:
                    return vectorFromData(Float32.self, index: index)
                case 8:
                    return vectorFromData(Float64.self, index: index)
                case 16:
                    return SCNVector3Zero // vectorFromData(Float80.self, index: index)
                default:
                    return SCNVector3Zero
            }
        }
    }
    
    
    /// Use this to get a `UVMap` from the Geometry source
    var uv: [CGPoint] {
        let stride = self.dataStride
        let offset = self.dataOffset
        let componentsPerVector = self.componentsPerVector
        let bytesPerVector = componentsPerVector * self.bytesPerComponent
        
        func vectorFromData<FloatingPoint: BinaryFloatingPoint>(_ float: FloatingPoint.Type, index: Int) -> CGPoint {
            assert(bytesPerComponent == MemoryLayout<FloatingPoint>.size)
            let vectorData = UnsafeMutablePointer<FloatingPoint>.allocate(capacity: componentsPerVector)
            let buffer = UnsafeMutableBufferPointer(start: vectorData, count: componentsPerVector)
            let rangeStart = index * stride + offset
            self.data.copyBytes(to: buffer, from: rangeStart..<(rangeStart + bytesPerVector))
            return CGPoint(
                x:CGFloat.NativeType(vectorData[0]),
                y:CGFloat.NativeType(vectorData[1])
            )
        }
        
        let vectors = [CGPoint](repeating: CGPoint.zero, count: self.vectorCount)
        //        let vectors = [SCNVector3](repeating: SCNVector3Zero, count: self.vectorCount)
        return vectors.indices.map { index -> CGPoint in
            switch bytesPerComponent {
                case 4:
                    return vectorFromData(Float32.self, index: index)
                case 8:
                    return vectorFromData(Float64.self, index: index)
                case 16:
                    return CGPoint.zero//vectorFromData(Float80.self, index: index)
                default:
                    return CGPoint.zero
            }
        }
    }
}

// MARK: - Conforming

/**
 To conform to enums, and Views that need `identifiable` objects
 */

extension SCNGeometry: Identifiable {
    static func ==(lhs:SCNGeometry, rhs:SCNGeometry) -> Bool {
        return lhs.isEqual(rhs)
    }
}

extension SCNMaterial: Identifiable {
    static func ==(lhs:SCNMaterial, rhs:SCNMaterial) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    /// An example material, diffuse, roughness and emission
    static var example:SCNMaterial {
        let m = SCNMaterial()
        m.name = "Example M"
        m.lightingModel = .physicallyBased
        m.diffuse.contents = "Scenes.scnassets/UVMaps/CausticNoise.png"//(byReferencingFile:"Scenes.scnassets/UVMaps/CausticNoise.png")
        m.roughness.contents = 0.3
        m.emission.contents = 0.1
        return m
    }
}

extension SCNWrapMode:Equatable {
    
    public static func ==(lhs:SCNWrapMode, rhs:SCNWrapMode) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    func toString() -> String {
        switch self.rawValue {
            case 1: return "Clamp"
            case 2: return "`Repeat`"
            case 3: return "Clamp border"
            case 4: return "Mirror"
            default: return "N/A"
        }
    }
}

extension SCNWrapMode:Codable, CaseIterable {
    
    public static var allCases: [SCNWrapMode] {
        return [SCNWrapMode.clamp, SCNWrapMode.clampToBorder, SCNWrapMode.mirror, SCNWrapMode.repeat]
    }
}
