import Foundation

/*
    Encapsulates persistent app state for a single EffectsColorScheme.
 */
class EffectsColorSchemeState: PersistentStateProtocol {
    
    var functionCaptionTextColor: ColorState?
    var functionValueTextColor: ColorState?
    
    var sliderBackgroundColor: ColorState?
    var sliderBackgroundGradientType: GradientType?
    var sliderBackgroundGradientAmount: Int?
    
    var sliderForegroundGradientType: GradientType?
    var sliderForegroundGradientAmount: Int?
    
    var sliderKnobColor: ColorState?
    var sliderKnobColorSameAsForeground: Bool?
    
    var sliderTickColor: ColorState?
    
    var activeUnitStateColor: ColorState?
    var bypassedUnitStateColor: ColorState?
    var suppressedUnitStateColor: ColorState?
    
    init() {}
    
    init(_ scheme: EffectsColorScheme) {
     
        self.functionCaptionTextColor = ColorState.fromColor(scheme.functionCaptionTextColor)
        self.functionValueTextColor = ColorState.fromColor(scheme.functionValueTextColor)
        
        self.sliderBackgroundColor = ColorState.fromColor(scheme.sliderBackgroundColor)
        self.sliderBackgroundGradientType = scheme.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = scheme.sliderBackgroundGradientAmount
        
        self.sliderForegroundGradientType = scheme.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = scheme.sliderForegroundGradientAmount
        
        self.sliderKnobColor = ColorState.fromColor(scheme.sliderKnobColor)
        self.sliderKnobColorSameAsForeground = scheme.sliderKnobColorSameAsForeground
        
        self.sliderTickColor = ColorState.fromColor(scheme.sliderTickColor)
        
        self.activeUnitStateColor = ColorState.fromColor(scheme.activeUnitStateColor)
        self.bypassedUnitStateColor = ColorState.fromColor(scheme.bypassedUnitStateColor)
        self.suppressedUnitStateColor = ColorState.fromColor(scheme.suppressedUnitStateColor)
    }
    
    required init?(_ map: NSDictionary) {
        
        if let colorDict = map["functionCaptionTextColor"] as? NSDictionary {
            self.functionCaptionTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["functionValueTextColor"] as? NSDictionary {
            self.functionValueTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["sliderBackgroundColor"] as? NSDictionary {
            self.sliderBackgroundColor = ColorState.deserialize(colorDict)
        }
        
        self.sliderBackgroundGradientType = map.enumValue(forKey: "sliderBackgroundGradientType",
                                                          ofType: GradientType.self)
        
        self.sliderBackgroundGradientAmount = map.intValue(forKey: "sliderBackgroundGradientAmount")
        
        self.sliderForegroundGradientType = map.enumValue(forKey: "sliderForegroundGradientType",
                                                          ofType: GradientType.self)
        
        self.sliderForegroundGradientAmount = map.intValue(forKey: "sliderForegroundGradientAmount")
        
        if let colorDict = map["sliderKnobColor"] as? NSDictionary {
            self.sliderKnobColor = ColorState.deserialize(colorDict)
        }
        
        self.sliderKnobColorSameAsForeground = map.boolValue(forKey: "sliderKnobColorSameAsForeground")
        
        if let colorDict = map["sliderTickColor"] as? NSDictionary {
            self.sliderTickColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["activeUnitStateColor"] as? NSDictionary {
            self.activeUnitStateColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["bypassedUnitStateColor"] as? NSDictionary {
            self.bypassedUnitStateColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["suppressedUnitStateColor"] as? NSDictionary {
            self.suppressedUnitStateColor = ColorState.deserialize(colorDict)
        }
    }
}
