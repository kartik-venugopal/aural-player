//
//  NSColorExtensions.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSColor {
    
    convenience init(white: CGFloat) {
        self.init(white: white, alpha: 1)
    }
    
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    // Returns whether or not this color is opaque (i.e. alpha == 1)
    var isOpaque: Bool {
        return self.alphaComponent == 1
    }
    
    // Computes a shadow color that would be visible in contrast to this color.
    // eg. if this color is white, black would be a visible shadow color. However, if this color is black, we would need a bit of brightness in the shadow.
    var visibleShadowColor: NSColor {
        
        // Convert to RGB color space to be able to determine the brightness.
        let rgb = toRGB()
        
        let myBrightness = rgb.brightnessComponent
        
        // If the brightness is under a threshold, it is too dark for black to be visible as its shadow. In that case, return a shadow color that has a bit of brightness to it.
        if myBrightness < 0.15 {
            return NSColor(white: min(0.2, myBrightness + 0.15))
        }
        
        // For reasonably bright colors, black is the best shadow color.
        return NSColor.black
    }
    
    // Clones this color, but with the alpha component set to a specified value.
    func clonedWithTransparency(_ alpha: CGFloat) -> NSColor {
        
        switch self.colorSpace.colorSpaceModel {
            
        case .gray: return NSColor(white: self.whiteComponent, alpha: alpha)
            
        case .rgb:  return NSColor(red: self.redComponent, green: self.greenComponent, blue: self.blueComponent, alpha: alpha)
            
        case .cmyk: return NSColor(deviceCyan: self.cyanComponent, magenta: self.magentaComponent, yellow: self.yellowComponent, black: self.blackComponent, alpha: alpha)
            
        default: return self
            
        }
    }
    
    // If necessary, converts this color to the RGB color space.
    func toRGB() -> NSColor {
        
        // Not in RGB color space, need to convert.
        if self.colorSpace.colorSpaceModel != .rgb, let rgb = self.usingColorSpace(.deviceRGB) {
            return rgb
        }
        
        // Already in RGB color space, no need to convert.
        return self
    }
    
    // Returns a color that is darker than this color by a certain percentage.
    // NOTE - The percentage parameter represents a percentage within the range of possible values.
    // eg. For black, the range would be zero, so this function would have no effect. For white, the range would be the entire [0.0, 1.0]
    // For a color in between black and white, the range would be [0, B] where B represents the brightness component of this color.
    func darkened(_ percentage: CGFloat) -> NSColor {
        
        let rgbSelf = self.toRGB()
        
        let curBrightness = rgbSelf.brightnessComponent
        let newBrightness = curBrightness - (percentage * curBrightness / 100)
        
        return NSColor(hue: rgbSelf.hueComponent, saturation: rgbSelf.saturationComponent, brightness: min(max(0, newBrightness), 1), alpha: rgbSelf.alphaComponent)
    }
    
    // Returns a color that is brighter than this color by a certain percentage.
    // NOTE - The percentage parameter represents a percentage within the range of possible values.
    // eg. For white, the range would be zero, so this function would have no effect. For black, the range would be the entire [0.0, 1.0]
    // For a color in between black and white, the range would be [B, 1.0] where B represents the brightness component of this color.
    func brightened(_ percentage: CGFloat) -> NSColor {
        
        let rgbSelf = self.toRGB()
        
        let curBrightness = rgbSelf.brightnessComponent
        let range: CGFloat = 1 - curBrightness
        let newBrightness = curBrightness + (percentage * range / 100)
        
        return NSColor(hue: rgbSelf.hueComponent, saturation: rgbSelf.saturationComponent, brightness: min(max(0, newBrightness), 1), alpha: rgbSelf.alphaComponent)
    }
    
    /**
     * Interpolates between two NSColors
     * EXAMPLE: NSColor.green.interpolate(.blue, 0.5)
     * NOTE: There is also a native alternative: NSColor.green.blended(withFraction: 0.5, of: .blue)
     */
    func interpolate(_ to:NSColor,_ scalar:CGFloat)->NSColor{
        
        func interpolate(_ start:CGFloat,_ end:CGFloat,_ scalar:CGFloat)->CGFloat{
            return start + (end - start) * scalar
        }
        
        let fromRGBColor:NSColor = self.usingColorSpace(.genericRGB)!
        let toRGBColor:NSColor = to.usingColorSpace(.genericRGB)!
        let red:CGFloat = interpolate(fromRGBColor.redComponent, toRGBColor.redComponent,scalar)
        let green:CGFloat = interpolate(fromRGBColor.greenComponent, toRGBColor.greenComponent,scalar)
        let blue:CGFloat = interpolate(fromRGBColor.blueComponent, toRGBColor.blueComponent,scalar)
        let alpha:CGFloat = interpolate(fromRGBColor.alphaComponent, toRGBColor.alphaComponent,scalar)
        
        return NSColor.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
