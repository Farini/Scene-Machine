//
//  GradientController.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/13/21.
//

import Foundation
import SwiftUI

class GradientController:ObservableObject {
    
    @Published var compGradient:[GradientStop] = GradientStop.basicExample()
    
    func addGradient() {
        compGradient.append(GradientStop(color: .white, location: 1))
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
