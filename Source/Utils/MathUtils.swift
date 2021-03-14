import Foundation

/*
    Some global Math-related functions
 */

// Rounds and converts a Float -> Int
func roundedInt(_ floatVal: Float) -> Int {
    return lroundf(floatVal)
}

func roundedInt(_ cgFloatVal: CGFloat) -> Int {
    return lroundf(Float(cgFloatVal))
}

// Rounds and converts a Double -> Int
func roundedInt(_ doubleVal: Double) -> Int {
    return lround(doubleVal)
}

// Floors and converts a Float -> Int
func floorInt(_ floatVal: Float) -> Int {
    return Int(floorf(floatVal))
}

// Floors and converts a Double -> Int
func floorInt(_ doubleVal: Double) -> Int {
    return Int(floor(doubleVal))
}
