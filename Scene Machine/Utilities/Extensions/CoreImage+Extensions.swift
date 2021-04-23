//
//  CoreImage+Extensions.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/23/21.
//

import Cocoa
import CoreImage

func + <T, U>(left: Dictionary<T, U>, right: Dictionary<T, U>) -> Dictionary<T, U> {
    
    var target = Dictionary<T, U>()
    
    for (key, value) in left
    {
        target[key] = value
    }
    
    for (key, value) in right
    {
        target[key] = value
    }
    
    return target
}

extension CIVector {
    
    func toArray() -> [CGFloat] {
        var returnArray = [CGFloat]()
        
        for i in 0 ..< self.count {
            returnArray.append(self.value(at: i))
        }
        
        return returnArray
    }
    
    func normalize() -> CIVector {
        
        var sum: CGFloat = 0
        
        for i in 0 ..< self.count
        {
            sum += self.value(at: i)
        }
        
        if sum == 0
        {
            return self
        }
        
        var normalizedValues = [CGFloat]()
        
        for i in 0 ..< self.count
        {
            normalizedValues.append(self.value(at: i) / sum)
        }
        
        return CIVector(values: normalizedValues,
                        count: normalizedValues.count)
    }
    
    func multiply(value: CGFloat) -> CIVector {
        
        let n = self.count
        var targetArray = [CGFloat]()
        
        for i in 0 ..< n
        {
            targetArray.append(self.value(at: i) * value)
        }
        
        return CIVector(values: targetArray, count: n)
    }
    
    func interpolateTo(target: CIVector, value: CGFloat) -> CIVector {
        return CIVector(
            x: self.x + ((target.x - self.x) * value),
            y: self.y + ((target.y - self.y) * value))
    }
    
}


extension NSBezierPath {
    
    func interpolatePointsWithHermite(interpolationPoints : [CGPoint]) {
        
        let n = interpolationPoints.count - 1
        
        for ii in 0 ..< n
        {
            var currentPoint = interpolationPoints[ii]
            
            if ii == 0
            {
                self.move(to: interpolationPoints[0])
            }
            
            var nextii = (ii + 1) % interpolationPoints.count
            var previi = (ii - 1 < 0 ? interpolationPoints.count - 1 : ii-1);
            var previousPoint = interpolationPoints[previi]
            var nextPoint = interpolationPoints[nextii]
            let endPoint = nextPoint;
            var mx : CGFloat = 0.0
            var my : CGFloat = 0.0
            
            if ii > 0
            {
                mx = (nextPoint.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint.x) * 0.5;
                my = (nextPoint.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint.y) * 0.5;
            }
            else
            {
                mx = (nextPoint.x - currentPoint.x) * 0.5;
                my = (nextPoint.y - currentPoint.y) * 0.5;
            }
            
            let controlPoint1 = CGPoint(x: currentPoint.x + mx / 3.0, y: currentPoint.y + my / 3.0)
            
            currentPoint = interpolationPoints[nextii]
            nextii = (nextii + 1) % interpolationPoints.count
            previi = ii;
            previousPoint = interpolationPoints[previi]
            nextPoint = interpolationPoints[nextii]
            
            if ii < n - 1
            {
                mx = (nextPoint.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint.x) * 0.5;
                my = (nextPoint.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint.y) * 0.5;
            }
            else
            {
                mx = (currentPoint.x - previousPoint.x) * 0.5;
                my = (currentPoint.y - previousPoint.y) * 0.5;
            }
            
            let controlPoint2 = CGPoint(x: currentPoint.x - mx / 3.0, y: currentPoint.y - my / 3.0)
            
            self.curve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
    }
    
}

