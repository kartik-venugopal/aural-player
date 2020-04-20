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
        
        self.playerSliderBackgroundColor = preset.sliderBackgroundColor
        self.playerSliderForegroundColor = preset.sliderForegroundColor
        self.playerSliderKnobColor = preset.sliderKnobColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.logoTextColor = preset.logoTextColor
        
        self.backgroundColor = preset.backgroundColor
        self.controlButtonColor = preset.controlButtonColor
        self.controlButtonOffStateColor = preset.controlButtonOffStateColor
        
        self.primaryTextColor = preset.primaryTextColor
        self.secondaryTextColor = preset.secondaryTextColor
        
        self.playerSliderBackgroundColor = preset.sliderBackgroundColor
        self.playerSliderForegroundColor = preset.sliderForegroundColor
        self.playerSliderKnobColor = preset.sliderKnobColor
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
    
    var sliderForegroundColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return Colors.Constants.white60Percent
            
        case .lightBackgroundDarkForeground:  return NSColor.darkGray
            
        }
    }
    
    var sliderBackgroundColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return Colors.Constants.white20Percent
            
        case .lightBackgroundDarkForeground:  return Colors.Constants.white50Percent
            
        }
    }
    
    var sliderKnobColor: NSColor {
        
        switch self {
            
        case .darkBackgroundLightForeground:  return Colors.Constants.white50Percent
            
        case .lightBackgroundDarkForeground:  return NSColor.darkGray
            
        }
    }
}
