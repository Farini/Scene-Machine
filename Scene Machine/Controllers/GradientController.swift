//
//  GradientController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/13/21.
//

import Foundation
import SwiftUI

/// Facilitate the generation and visualization of `SCNMaterials`
class GradientController:ObservableObject {
    
    @Published var compGradient:[GradientStop]
    
    init() {
        self.compGradient = GradientStop.basicExample()
    }
    
    func addGradient() {
        var oldGradient = compGradient
        let newStop = GradientStop(color: .white, location: 1)
        oldGradient.append(newStop)
        
        self.compGradient = oldGradient
    }
    
    func removeGradient(at idx:Int) {
        compGradient.remove(at: idx)
    }
    
    func setcolor(color:Color, stop:GradientStop) {
        self.compGradient.first(where:  { $0.id == stop.id })!.color = color
    }
    
    func changeit(stop:GradientStop) {
        var array = compGradient
        if let idx = array.firstIndex(where: { $0.id == stop.id }) {
            array[idx] = stop
        }
        self.compGradient = array
    }
    
}

/// A Gradient Point
class GradientStop:Identifiable, Equatable {
    
    var id:UUID = UUID()
    var color:Color
    var location:CGFloat
    
    init(color:Color, location:CGFloat) {
        self.color = color
        self.location = location
    }
    
    static func basicExample() -> [GradientStop] {
        let g1 = GradientStop(color: .black, location: -1)
        let g2 = GradientStop(color: .white, location: 1)
        return [g1, g2]
    }
    
    func getNSColor() -> NSColor {
        return NSColor(color).usingColorSpace(.deviceRGB)!
    }
    
    static func == (lhs: GradientStop, rhs: GradientStop) -> Bool {
        return lhs.id == rhs.id
    }
}
