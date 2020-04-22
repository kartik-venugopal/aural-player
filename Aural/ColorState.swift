import Cocoa

class ColorState {
    
    // Gray, RGB, or CMYK
    var colorSpace: Int = 1
    var alpha: CGFloat = 1
    
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
    
    // Dummy implementation
    func toColor() -> NSColor {
        return NSColor.white
    }
}

class GrayscaleColorState: ColorState {
    
    var white: CGFloat = 1
    
    init(_ white: CGFloat, _ alpha: CGFloat) {
        
        super.init()
        
        self.colorSpace = NSColorSpace.Model.gray.rawValue
        
        self.white = white
        self.alpha = alpha
    }
    
    override func toColor() -> NSColor {
        return NSColor(calibratedWhite: white, alpha: alpha)
    }
    
//    static func deserialize(_ map: NSDictionary) -> PersistentState {
//
//        let state = GrayscaleColorState(1, 1)
//
//        if let colorSpace = map["colorSpace"] as? Int {
//
//            switch colorSpace {
//
//            case NSColorSpace.Model.gray.rawValue:
//
//                if
//            }
//        }
//
//        return state
//    }
}

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
        return NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
    }
}

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
}
