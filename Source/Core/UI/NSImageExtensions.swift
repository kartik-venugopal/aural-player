//
//  NSImageExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Cocoa

extension NSImage {
    
    convenience init(gradientColors: [NSColor], imageSize: NSSize) {
        
        let gradient = NSGradient(colors: gradientColors)!
        let rect = NSRect(origin: CGPoint.zero, size: imageSize)
        self.init(size: rect.size)
        
        let path = NSBezierPath(rect: rect)
        self.lockFocus()
        gradient.draw(in: path, angle: 90.0)
        self.unlockFocus()
    }
    
    func writeToFile(fileType: NSBitmapImageRep.FileType, file: URL) throws {
        
        if let bits = self.representations.first as? NSBitmapImageRep,
           let data = bits.representation(using: fileType, properties: [:]) {
            
            try data.write(to: file)
        }
    }
    
    // Returns a copy of this image filled with a given color. Used by several UI components for system color scheme conformance.
    func filledWithColor(_ color: NSColor) -> NSImage {

        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()
        
        return image
    }
    
    // Returns a copy of this image tinted with a given color. Used by several UI components for system color scheme conformance.
    func tintedWithColor(_ color: NSColor) -> NSImage {
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        color.set()
        
        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)
        
        image.unlockFocus()
        
        return image
    }
    
    func tintedUsingCIFilterWithColor(_ color: NSColor) -> NSImage {

        let size: NSSize = self.size
        let bounds: NSRect = NSRect(origin: NSPoint.zero, size: size)
        let tmg: NSImage = NSImage(size: size)

        tmg.lockFocus()

        let colorGenerator: CIFilter = CIFilter(name: "CIConstantColorGenerator")!
        let ciColor: CIColor = CIColor(color: color)!

        colorGenerator.setValue(ciColor, forKey: "inputColor")
    
        let monoFilter: CIFilter = CIFilter(name: "CIColorMonochrome")!
        let baseImg: CIImage = CIImage(data: self.tiffRepresentation!)!
        
        monoFilter.setValue(baseImg, forKey: "inputImage")
        monoFilter.setValue(CIColor(color: NSColor(red: 0.75, green: 0.75, blue: 0.75))!, forKey: "inputColor")
        monoFilter.setValue(NSNumber(floatLiteral: 1.0), forKey: "inputIntensity")
        
        let compFilter: CIFilter = CIFilter(name: "CIMultiplyCompositing")!
        compFilter.setValue(colorGenerator.value(forKey: "outputImage")!, forKey: "inputImage")
        compFilter.setValue(monoFilter.value(forKey: "outputImage")!, forKey: "inputBackgroundImage")
        
        let outImg: CIImage = compFilter.value(forKey: "outputImage") as! CIImage
        
        outImg.draw(at: NSPoint.zero, from: bounds, operation: .copy, fraction: 1.0)
        tmg.unlockFocus()

        return tmg
    }
    
    func copy(ofSize size: CGSize) -> NSImage {
        
        let copy = imageCopy()
        copy.size = size
        
        return copy
    }
    
    func imageCopy() -> NSImage {
        self.copy() as! NSImage
    }
}
