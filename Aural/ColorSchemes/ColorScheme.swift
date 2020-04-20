import Cocoa

class ColorScheme {
    
    static var systemScheme: ColorScheme = ColorScheme()

    var logoTextColor: NSColor

    var backgroundColor: NSColor
    var controlButtonColor: NSColor
    var controlButtonOffStateColor: NSColor

    var primaryTextColor: NSColor
    var secondaryTextColor: NSColor
    
    var playerSliderForegroundColor: NSColor
    var playerSliderBackgroundColor: NSColor
    var playerSliderKnobColor: NSColor
    var playerSliderLoopSegmentColor: NSColor
    
    convenience init() {
        self.init(ColorSchemePreset.defaultScheme)
    }
    
    init(_ preset: ColorSchemePreset) {
        
        self.logoTextColor = preset.logoTextColor
        
        self.backgroundColor = preset.backgroundColor
        self.controlButtonColor = preset.controlButtonColor
        self.controlButtonOffStateColor = preset.controlButtonOffStateColor
        
        self.primaryTextColor = preset.primaryTextColor
        self.secondaryTextColor = preset.secondaryTextColor
        
        self.playerSliderBackgroundColor = preset.playerSliderBackgroundColor
        self.playerSliderForegroundColor = preset.playerSliderForegroundColor
        self.playerSliderKnobColor = preset.playerSliderKnobColor
        self.playerSliderLoopSegmentColor = preset.playerSliderLoopSegmentColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.logoTextColor = preset.logoTextColor
        
        self.backgroundColor = preset.backgroundColor
        self.controlButtonColor = preset.controlButtonColor
        self.controlButtonOffStateColor = preset.controlButtonOffStateColor
        
        self.primaryTextColor = preset.primaryTextColor
        self.secondaryTextColor = preset.secondaryTextColor
        
        self.playerSliderBackgroundColor = preset.playerSliderBackgroundColor
        self.playerSliderForegroundColor = preset.playerSliderForegroundColor
        self.playerSliderKnobColor = preset.playerSliderKnobColor
        self.playerSliderLoopSegmentColor = preset.playerSliderLoopSegmentColor
    }
}

enum ColorSchemePreset: String {
    
    case darkBackgroundLightForeground
    
    case lightBackgroundDarkForeground
    
    static var defaultScheme: ColorSchemePreset {
        return darkBackgroundLightForeground
    }
    
    var logoTextColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return Colors.Constants.white80Percent
            
        case .lightBackgroundDarkForeground:  return NSColor.black
            
        }
    }
    
    var backgroundColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return NSColor.black
            
        case .lightBackgroundDarkForeground:  return Colors.Constants.white80Percent
            
        }
    }
    
    var controlButtonColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return Colors.Constants.white80Percent
            
        case .lightBackgroundDarkForeground:  return NSColor.black
            
        }
    }
    
    var controlButtonOffStateColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return Colors.Constants.white20Percent
            
        case .lightBackgroundDarkForeground:  return Colors.Constants.white60Percent
            
        }
    }
    
    var primaryTextColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return Colors.Constants.white80Percent
            
        case .lightBackgroundDarkForeground:  return NSColor.black
            
        }
    }
    
    var secondaryTextColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return Colors.Constants.white60Percent
            
        case .lightBackgroundDarkForeground:  return NSColor.darkGray
            
        }
    }
    
    var playerSliderForegroundColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return Colors.Constants.white60Percent
            
        case .lightBackgroundDarkForeground:  return NSColor.darkGray
            
        }
    }
    
    var playerSliderBackgroundColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return Colors.Constants.white20Percent
            
        case .lightBackgroundDarkForeground:  return Colors.Constants.white50Percent
            
        }
    }
    
    var playerSliderKnobColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return Colors.Constants.white50Percent
            
        case .lightBackgroundDarkForeground:  return NSColor.darkGray
            
        }
    }
    
    var playerSliderLoopSegmentColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return NSColor(red: 0, green: 0.625, blue: 0, alpha: 1)
            
        case .lightBackgroundDarkForeground:  return NSColor(red: 0, green: 0.625, blue: 0, alpha: 1)
            
        }
    }
}
