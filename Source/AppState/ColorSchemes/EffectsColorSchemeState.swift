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
    
    required init?(_ map: NSDictionary) -> EffectsColorSchemeState? {
        
        let state = EffectsColorSchemeState()
        
        if let colorDict = map["functionCaptionTextColor"] as? NSDictionary {
            state.functionCaptionTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["functionValueTextColor"] as? NSDictionary {
            state.functionValueTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["sliderBackgroundColor"] as? NSDictionary {
            state.sliderBackgroundColor = ColorState.deserialize(colorDict)
        }
        
        if let gradientTypeStr = map["sliderBackgroundGradientType"] as? String,
            let gradientType = GradientType(rawValue: gradientTypeStr) {
            
            state.sliderBackgroundGradientType = gradientType
        }
        
        if let amountNum = map["sliderBackgroundGradientAmount"] as? NSNumber {
            state.sliderBackgroundGradientAmount = amountNum.intValue
        }
        
        if let gradientTypeStr = map["sliderForegroundGradientType"] as? String,
            let gradientType = GradientType(rawValue: gradientTypeStr) {
            
            state.sliderForegroundGradientType = gradientType
        }
        
        if let amountNum = map["sliderForegroundGradientAmount"] as? NSNumber {
            state.sliderForegroundGradientAmount = amountNum.intValue
        }
        
        if let colorDict = map["sliderKnobColor"] as? NSDictionary {
            state.sliderKnobColor = ColorState.deserialize(colorDict)
        }
        
        if let useForegroundColor = map["sliderKnobColorSameAsForeground"] as? Bool {
            state.sliderKnobColorSameAsForeground = useForegroundColor
        }
        
        if let colorDict = map["sliderTickColor"] as? NSDictionary {
            state.sliderTickColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["activeUnitStateColor"] as? NSDictionary {
            state.activeUnitStateColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["bypassedUnitStateColor"] as? NSDictionary {
            state.bypassedUnitStateColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["suppressedUnitStateColor"] as? NSDictionary {
            state.suppressedUnitStateColor = ColorState.deserialize(colorDict)
        }
        
        return state
    }
}
