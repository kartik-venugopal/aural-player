/*
    Utility that encapsulates size information, and provides readable string representations of the size.
*/

import Foundation

class Size: NSObject {
    
    var sizeUnit: SizeUnit = .B
    var size: Double = 0
    var sizeBytes: UInt = 0
    
    static let ZERO: Size = Size(sizeBytes: 0)  // Constant useful as a default value
    static let KB: UInt = 1024
    static let MB: UInt = 1024 * KB
    static let GB: UInt = 1024 * MB
    static let TB: UInt = 1024 * GB
    
    init(sizeBytes: UInt) {
        super.init()
        self.sizeBytes = sizeBytes
        calculateSizeFromBytes()
    }
    
    init(size: Double, sizeUnit: SizeUnit) {
        super.init()
        self.size = size
        self.sizeUnit = sizeUnit
        calculateSizeFromUnit()
    }
    
    private func calculateSizeFromBytes() {
        
        var bytesTemp = sizeBytes
        
        let tb = bytesTemp / Size.TB
        bytesTemp -= tb * Size.TB
        
        if (tb > 0) {
            size = Double(sizeBytes) / Double(Size.TB)
            sizeUnit = SizeUnit.TB
            return
        }
        
        let gb = bytesTemp / Size.GB
        bytesTemp -= gb * Size.GB
        
        if (gb > 0) {
            size = Double(sizeBytes) / Double(Size.GB)
            sizeUnit = SizeUnit.GB
            return
        }
        
        let mb = bytesTemp / Size.MB
        bytesTemp -= mb * Size.MB
        
        if (mb > 0) {
            size = Double(sizeBytes) / Double(Size.MB)
            sizeUnit = SizeUnit.MB
            return
        }
        
        let kb = bytesTemp / Size.KB
        bytesTemp -= kb * Size.KB
        
        if (kb > 0) {
            size = Double(sizeBytes) / Double(Size.KB)
            sizeUnit = SizeUnit.KB
            return
        }
    }
    
    private func calculateSizeFromUnit() {
        
        let su: SizeUnit = sizeUnit
        
        switch su {
        case SizeUnit.TB: sizeBytes = UInt(round(Double(Size.TB) * size))
        case SizeUnit.GB: sizeBytes = UInt(round(Double(Size.GB) * size))
        case SizeUnit.MB: sizeBytes = UInt(round(Double(Size.MB) * size))
        case SizeUnit.KB: sizeBytes = UInt(round(Double(Size.KB) * size))
        case SizeUnit.B: sizeBytes = UInt(round(size))
        }
    }
    
    func toString() -> String {
        return String(format: "%.2lf %@", size, sizeUnit.toString)
    }
    
    func greaterThan(otherSize: Size) -> Bool {
        
        let compare = sizeUnit.compareTo(otherSize.sizeUnit)
        
        if (compare > 0) {
            return true
        } else if (compare < 0) {
            return false
        }
        
        // Size units are the same, need to compare size in bytes
        return sizeBytes > otherSize.sizeBytes
    }
}