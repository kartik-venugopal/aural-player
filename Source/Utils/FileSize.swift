//
//  FileSize.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Utility that encapsulates file size information, and provides readable string representations of the size.
///
class FileSize: CustomStringConvertible {
    
    var sizeUnit: FileSizeUnit = .b
    var size: Double = 0
    var sizeBytes: UInt64 = 0
    
    static let zero: FileSize = FileSize(sizeBytes: 0)  // Constant useful as a default value
    
    static let KB: UInt64 = 1024
    static let MB: UInt64 = 1024 * KB
    static let GB: UInt64 = 1024 * MB
    static let TB: UInt64 = 1024 * GB
    
    init(sizeBytes: UInt64) {
        
        self.sizeBytes = sizeBytes
        calculateSizeFromBytes()
    }
    
    init(size: Double, sizeUnit: FileSizeUnit) {
        
        self.size = size
        self.sizeUnit = sizeUnit
        calculateSizeFromUnit()
    }
    
    private func calculateSizeFromBytes() {
        
        var bytesTemp = sizeBytes
        
        let tb = bytesTemp / Self.TB
        bytesTemp -= tb * Self.TB
        
        if tb > 0 {
            size = Double(sizeBytes) / Double(Self.TB)
            sizeUnit = FileSizeUnit.tb
            return
        }
        
        let gb = bytesTemp / Self.GB
        bytesTemp -= gb * Self.GB
        
        if gb > 0 {
            size = Double(sizeBytes) / Double(Self.GB)
            sizeUnit = FileSizeUnit.gb
            return
        }
        
        let mb = bytesTemp / Self.MB
        bytesTemp -= mb * Self.MB
        
        if mb > 0 {
            size = Double(sizeBytes) / Double(Self.MB)
            sizeUnit = FileSizeUnit.mb
            return
        }
        
        let kb = bytesTemp / Self.KB
        bytesTemp -= kb * Self.KB
        
        if kb > 0 {
            size = Double(sizeBytes) / Double(Self.KB)
            sizeUnit = FileSizeUnit.kb
            return
        }
        
        size = Double(sizeBytes)
        sizeUnit = FileSizeUnit.b
    }
    
    private func calculateSizeFromUnit() {
        
        switch sizeUnit {
            
        case .tb: sizeBytes = (Double(Self.TB) * size).roundedUInt64
        case .gb: sizeBytes = (Double(Self.GB) * size).roundedUInt64
        case .mb: sizeBytes = (Double(Self.MB) * size).roundedUInt64
        case .kb: sizeBytes = (Double(Self.KB) * size).roundedUInt64
        case .b: sizeBytes = size.roundedUInt64
            
        }
    }
    
    var description: String {
        
        sizeUnit == .b ?
            String(format: "%d %@", UInt64(size), sizeUnit.rawValue) :
            String(format: "%.2lf %@", size, sizeUnit.rawValue)
    }
}
