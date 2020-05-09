import Foundation

func roundedInt(_ floatVal: Float) -> Int {
    return lroundf(floatVal)
}

func roundedInt(_ doubleVal: Double) -> Int {
    return lround(doubleVal)
}

func floorInt(_ floatVal: Float) -> Int {
    return Int(floorf(floatVal))
}

func floorInt(_ doubleVal: Double) -> Int {
    return Int(floor(doubleVal))
}
