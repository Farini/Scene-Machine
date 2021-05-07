//
//  SceneKit+Extensions.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/21/21.
//

import Foundation
import SceneKit

extension SCNGeometry: Identifiable {
    static func ==(lhs:SCNGeometry, rhs:SCNGeometry) -> Bool {
        return lhs.isEqual(rhs)
    }
}
extension SCNMaterial: Identifiable {
    static func ==(lhs:SCNMaterial, rhs:SCNMaterial) -> Bool {
        return lhs.isEqual(rhs)
    }
}

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
