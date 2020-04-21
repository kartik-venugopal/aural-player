import Cocoa

class ColorSchemesState {
    
    var userSchemes: [ColorSchemeState] = []
    var systemScheme: ColorSchemeState
    
    convenience init() {
        self.init(ColorSchemeState(), [])
    }
    
    init(_ systemScheme: ColorSchemeState, _ userSchemes: [ColorSchemeState]) {
        
        self.systemScheme = systemScheme
        self.userSchemes = userSchemes
    }
}

class ColorSchemeState {
 
    var logoTextColor: ColorState
    
    var backgroundColor: ColorState
    var controlButtonColor: ColorState
    var controlButtonOffStateColor: ColorState
    
    var primaryTextColor: ColorState
    var secondaryTextColor: ColorState
    
    var playerSliderForegroundColor: ColorState
    var playerSliderBackgroundColor: ColorState
    var playerSliderKnobColor: ColorState
    var playerSliderLoopSegmentColor: ColorState
    
    var playlistTrackNameTextColor: ColorState
    var playlistGroupNameTextColor: ColorState
    var playlistIndexDurationTextColor: ColorState
    
    var playlistTrackNameSelectedTextColor: ColorState
    var playlistGroupNameSelectedTextColor: ColorState
    var playlistIndexDurationSelectedTextColor: ColorState
    
    var playlistGroupIconColor: ColorState
    var playlistSelectionBoxColor: ColorState
    var playlistPlayingTrackIconColor: ColorState
    var playlistSummaryInfoColor: ColorState
    
    convenience init() {
        self.init(ColorScheme.systemScheme)
    }
    
    init(_ scheme: ColorScheme) {
        
        self.logoTextColor = ColorState.fromNSColor(scheme.logoTextColor)
        
        self.backgroundColor = ColorState.fromNSColor(scheme.backgroundColor)
        self.controlButtonColor = ColorState.fromNSColor(scheme.controlButtonColor)
        self.controlButtonOffStateColor = ColorState.fromNSColor(scheme.controlButtonOffStateColor)
        
        self.primaryTextColor = ColorState.fromNSColor(scheme.primaryTextColor)
        self.secondaryTextColor = ColorState.fromNSColor(scheme.secondaryTextColor)
        
        self.playerSliderForegroundColor = ColorState.fromNSColor(scheme.playerSliderForegroundColor)
        self.playerSliderBackgroundColor = ColorState.fromNSColor(scheme.playerSliderBackgroundColor)
        self.playerSliderKnobColor = ColorState.fromNSColor(scheme.playerSliderKnobColor)
        self.playerSliderLoopSegmentColor = ColorState.fromNSColor(scheme.playerSliderLoopSegmentColor)
        
        self.playlistTrackNameTextColor = ColorState.fromNSColor(scheme.playlistTrackNameTextColor)
        self.playlistGroupNameTextColor = ColorState.fromNSColor(scheme.playlistGroupNameTextColor)
        self.playlistIndexDurationTextColor = ColorState.fromNSColor(scheme.playlistIndexDurationTextColor)
        
        self.playlistTrackNameSelectedTextColor = ColorState.fromNSColor(scheme.playlistTrackNameSelectedTextColor)
        self.playlistGroupNameSelectedTextColor = ColorState.fromNSColor(scheme.playlistGroupNameSelectedTextColor)
        self.playlistIndexDurationSelectedTextColor = ColorState.fromNSColor(scheme.playlistIndexDurationSelectedTextColor)
        
        self.playlistGroupIconColor = ColorState.fromNSColor(scheme.playlistGroupIconColor)
        self.playlistSelectionBoxColor = ColorState.fromNSColor(scheme.playlistSelectionBoxColor)
        self.playlistPlayingTrackIconColor = ColorState.fromNSColor(scheme.playlistPlayingTrackIconColor)
        self.playlistSummaryInfoColor = ColorState.fromNSColor(scheme.playlistSummaryInfoColor)
    }
}

class ColorState {
    
    // Gray, RGB, or CMYK
    var colorSpace: Int = 1
    var alpha: CGFloat = 1
    
    static func fromNSColor(_ color: NSColor) -> ColorState {
        
        switch color.colorSpace.colorSpaceModel {
            
        case .gray:
            
            return GrayscaleColorState(color.whiteComponent, color.alphaComponent)
            
        case .rgb:
            
            return RGBColorState(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent)
            
        case .cmyk:
            
            return CMYKColorState(color.cyanComponent, color.magentaComponent, color.yellowComponent, color.blackComponent, color.alphaComponent)
            
        default:
            
            return ColorState.fromNSColor(NSColor.black)
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
