import Cocoa

/*
    Encapsulates persistent app state for a single NSColor.
 */
class ColorPersistentState: PersistentStateProtocol, PersistentStateFactoryProtocol {
    
    // Gray, RGB, or CMYK
    let colorSpace: Int
    let alpha: CGFloat
    
    // Default color to use when deserializing and cannot construct a color.
    static let defaultInstance: ColorPersistentState = GrayscaleColorPersistentState(1, 1)
    
    init(_ colorSpace: Int, _ alpha: CGFloat) {
        
        self.colorSpace = colorSpace
        self.alpha = alpha
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let colorSpace = map.intValue(forKey: "colorSpace"),
              let alpha = map.cgFloatValue(forKey: "alpha") else {return nil}
        
        self.colorSpace = colorSpace
        self.alpha = alpha
    }
    
    // Maps an NSColor to a ColorPersistentState object that can be persisted.
    static func fromColor<T: ColorPersistentState>(_ color: NSColor) -> T {
        
        switch color.colorSpace.colorSpaceModel {
            
        case .gray:
            
            return GrayscaleColorPersistentState(color.whiteComponent, color.alphaComponent) as! T
            
        case .rgb:
            
            return RGBColorPersistentState(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent) as! T
            
        case .cmyk:
            
            return CMYKColorPersistentState(color.cyanComponent, color.magentaComponent, color.yellowComponent, color.blackComponent, color.alphaComponent) as! T
            
        default:
            
            return ColorPersistentState.fromColor(NSColor.black) as! T
        }
    }
    
    // Dummy implementation (meant to be overriden).
    func toColor() -> NSColor {
        return NSColor.white
    }
    
    // Deserializes persistent state for a single NSColor.
    static func deserialize(_ map: NSDictionary) -> ColorPersistentState? {
        
        // Depending on the color space of the color, construct different objects.
        if let colorSpace = map.intValue(forKey: "colorSpace") {
            
            switch colorSpace {
                
            case NSColorSpace.Model.gray.rawValue:
                
                return GrayscaleColorPersistentState(map)
                
            case NSColorSpace.Model.rgb.rawValue:
                
                return RGBColorPersistentState(map)
                
            case NSColorSpace.Model.cmyk.rawValue:
                
                return CMYKColorPersistentState(map)
                
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
class GrayscaleColorPersistentState: ColorPersistentState {
    
    var white: CGFloat = 1
    
    init(_ white: CGFloat, _ alpha: CGFloat) {
        
        super.init(NSColorSpace.Model.gray.rawValue, alpha)
        self.white = white
    }
    
    override func toColor() -> NSColor {
        return NSColor(white: white, alpha: alpha)
    }

    required init?(_ map: NSDictionary) {
        
        guard let alpha = map.cgFloatValue(forKey: "alpha"),
              let white = map.cgFloatValue(forKey: "white") else {return nil}
        
        super.init(NSColorSpace.Model.gray.rawValue, alpha)
        self.white = white
    }
}

/*
    Represents persistent state for a single NSColor defined in the RGB color space.
 */
class RGBColorPersistentState: ColorPersistentState {
    
    var red: CGFloat = 1
    var green: CGFloat = 1
    var blue: CGFloat = 1
    
    init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) {
        
        super.init(NSColorSpace.Model.rgb.rawValue, alpha)
        
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    override func toColor() -> NSColor {
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let alpha = map.cgFloatValue(forKey: "alpha"),
              let red = map.cgFloatValue(forKey: "red"),
              let green = map.cgFloatValue(forKey: "green"),
              let blue = map.cgFloatValue(forKey: "blue") else {return nil}
        
        super.init(NSColorSpace.Model.rgb.rawValue, alpha)
        
        self.red = red
        self.green = green
        self.blue = blue
    }
}

/*
    Represents persistent state for a single NSColor defined in the CMYK color space.
 */
class CMYKColorPersistentState: ColorPersistentState {
    
    var cyan: CGFloat = 1
    var magenta: CGFloat = 1
    var yellow: CGFloat = 1
    var black: CGFloat = 1
    
    init(_ cyan: CGFloat, _ magenta: CGFloat, _ yellow: CGFloat, _ black: CGFloat, _ alpha: CGFloat) {
        
        super.init(NSColorSpace.Model.cmyk.rawValue, alpha)
        
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
        self.black = black
    }
    
    override func toColor() -> NSColor {
        return NSColor(deviceCyan: cyan, magenta: magenta, yellow: yellow, black: black, alpha: alpha)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let alpha = map.cgFloatValue(forKey: "alpha"),
              let cyan = map.cgFloatValue(forKey: "cyan"),
              let magenta = map.cgFloatValue(forKey: "magenta"),
              let yellow = map.cgFloatValue(forKey: "yellow"),
              let black = map.cgFloatValue(forKey: "black") else {return nil}
        
        super.init(NSColorSpace.Model.cmyk.rawValue, alpha)
        
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
        self.black = black
    }
}
