import Cocoa

/*
    Encapsulates persistent app state for a single NSColor.
 */
class ColorState: PersistentState {
    
    // Gray, RGB, or CMYK
    var colorSpace: Int = 1
    var alpha: CGFloat = 1
    
    // Default color to use when deserializing and cannot construct a color.
    static let defaultInstance: ColorState = GrayscaleColorState(1, 1)
    
    // Maps an NSColor to a ColorState object that can be persisted.
    static func fromColor(_ color: NSColor) -> ColorState {
        
        switch color.colorSpace.colorSpaceModel {
            
        case .gray:
            
            return GrayscaleColorState(color.whiteComponent, color.alphaComponent)
            
        case .rgb:
            
            return RGBColorState(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent)
            
        case .cmyk:
            
            return CMYKColorState(color.cyanComponent, color.magentaComponent, color.yellowComponent, color.blackComponent, color.alphaComponent)
            
        default:
            
            return ColorState.fromColor(NSColor.black)
        }
    }
    
    // Dummy implementation (meant to be overriden).
    func toColor() -> NSColor {
        return NSColor.white
    }
    
    // Deserializes persistent state for a single NSColor.
    static func deserialize(_ map: NSDictionary) -> ColorState {
        
        // Depending on the color space of the color, construct different objects.
        if let colorSpace = map["colorSpace"] as? NSNumber {
            
            switch colorSpace.intValue {
                
            case NSColorSpace.Model.gray.rawValue:
                
                return GrayscaleColorState.fromMap(map)
                
            case NSColorSpace.Model.rgb.rawValue:
                
                return RGBColorState.fromMap(map)
                
            case NSColorSpace.Model.cmyk.rawValue:
                
                return CMYKColorState.fromMap(map)
                
            default:
                
                // Impossible
                return defaultInstance
            }
        }

        // Impossible
        return defaultInstance
    }
}

/*
    Represents persistent state for a single NSColor defined in the Grayscale color space.
 */
class GrayscaleColorState: ColorState {
    
    var white: CGFloat = 1
    
    init(_ white: CGFloat, _ alpha: CGFloat) {
        
        super.init()
        
        self.colorSpace = NSColorSpace.Model.gray.rawValue
        
        self.white = white
        self.alpha = alpha
    }
    
    override func toColor() -> NSColor {
        return NSColor(white: white, alpha: alpha)
    }

    static func fromMap(_ map: NSDictionary) -> GrayscaleColorState {
        
        let grayColor = GrayscaleColorState(1, 1)
        
        if let white = map["white"] as? NSNumber {
            grayColor.white = CGFloat(white.floatValue)
        }
        
        if let alpha = map["alpha"] as? NSNumber {
            grayColor.alpha = CGFloat(alpha.floatValue)
        }
        
        return grayColor
    }
}

/*
    Represents persistent state for a single NSColor defined in the RGB color space.
 */
class RGBColorState: ColorState {
    
    var red: CGFloat = 1
    var green: CGFloat = 1
    var blue: CGFloat = 1
    
    init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) {
        
        super.init()
        
        self.colorSpace = NSColorSpace.Model.rgb.rawValue
        
        self.red = red
        self.green = green
        self.blue = blue
        
        self.alpha = alpha
    }
    
    override func toColor() -> NSColor {
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func fromMap(_ map: NSDictionary) -> RGBColorState {
        
        let rgbColor = RGBColorState(1, 1, 1, 1)
        
        if let red = map["red"] as? NSNumber {
            rgbColor.red = CGFloat(red.floatValue)
        }
        
        if let green = map["green"] as? NSNumber {
            rgbColor.green = CGFloat(green.floatValue)
        }
        
        if let blue = map["blue"] as? NSNumber {
            rgbColor.blue = CGFloat(blue.floatValue)
        }
        
        if let alpha = map["alpha"] as? NSNumber {
            rgbColor.alpha = CGFloat(alpha.floatValue)
        }
        
        return rgbColor
    }
}

/*
    Represents persistent state for a single NSColor defined in the CMYK color space.
 */
class CMYKColorState: ColorState {
    
    var cyan: CGFloat = 1
    var magenta: CGFloat = 1
    var yellow: CGFloat = 1
    var black: CGFloat = 1
    
    init(_ cyan: CGFloat, _ magenta: CGFloat, _ yellow: CGFloat, _ black: CGFloat, _ alpha: CGFloat) {
        
        super.init()
        
        self.colorSpace = NSColorSpace.Model.cmyk.rawValue
        
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
        self.black = black
        
        self.alpha = alpha
    }
    
    override func toColor() -> NSColor {
        return NSColor(deviceCyan: cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha)
    }
    
    static func fromMap(_ map: NSDictionary) -> CMYKColorState {
        
        let cmykColor = CMYKColorState(1, 1, 1, 1, 1)
        
        if let cyan = map["cyan"] as? NSNumber {
            cmykColor.cyan = CGFloat(cyan.floatValue)
        }
        
        if let magenta = map["magenta"] as? NSNumber {
            cmykColor.magenta = CGFloat(magenta.floatValue)
        }
        
        if let yellow = map["yellow"] as? NSNumber {
            cmykColor.yellow = CGFloat(yellow.floatValue)
        }
        
        if let black = map["black"] as? NSNumber {
            cmykColor.black = CGFloat(black.floatValue)
        }
        
        if let alpha = map["alpha"] as? NSNumber {
            cmykColor.alpha = CGFloat(alpha.floatValue)
        }
        
        return cmykColor
    }
}
