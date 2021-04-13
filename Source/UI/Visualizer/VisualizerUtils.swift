import Cocoa
import SceneKit
import SpriteKit

extension NSColor {
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

extension FloatingPoint {
    
    func clamp(to range: ClosedRange<Self>) -> Self {
        
        if range.contains(self) {return self}
        
        if self < range.lowerBound {
            return range.lowerBound
        }
        
        if self > range.upperBound {
            return range.upperBound
        }
        
        return self
    }
}

extension SKTexture {
    
    convenience init(size: CGSize, color1: CIColor, color2: CIColor) {
        
        let coreImageContext = CIContext(options: nil)
        
        let gradientFilter = CIFilter(name: "CILinearGradient")!
        gradientFilter.setDefaults()
        
        let startVector: CIVector = CIVector(x: size.width / 2, y: 0)
        let endVector: CIVector = CIVector(x: size.width / 2, y: size.height)
        
        gradientFilter.setValue(startVector, forKey: "inputPoint0")
        gradientFilter.setValue(endVector, forKey: "inputPoint1")
        gradientFilter.setValue(color1, forKey: "inputColor0")
        gradientFilter.setValue(color2, forKey: "inputColor1")
        
        let cgimg = coreImageContext.createCGImage(gradientFilter.outputImage!, from: CGRect(x: 0, y: 0, width: size.width, height: size.height))!
        self.init(cgImage:cgimg)
    }
}

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
    
    func tinting(_ color: NSColor) -> NSImage {

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
        monoFilter.setValue(CIColor(color: NSColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1))!, forKey: "inputColor")
        monoFilter.setValue(NSNumber(floatLiteral: 1.0), forKey: "inputIntensity")
        
        let compFilter: CIFilter = CIFilter(name: "CIMultiplyCompositing")!
        compFilter.setValue(colorGenerator.value(forKey: "outputImage")!, forKey: "inputImage")
        compFilter.setValue(monoFilter.value(forKey: "outputImage")!, forKey: "inputBackgroundImage")
        
        let outImg: CIImage = compFilter.value(forKey: "outputImage") as! CIImage
        
        outImg.draw(at: NSPoint.zero, from: bounds, operation: .copy, fraction: 1.0)
        tmg.unlockFocus()

        return tmg
    }
}

let piOver180: CGFloat = CGFloat.pi / 180
