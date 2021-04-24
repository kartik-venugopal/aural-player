import Foundation

/*
    Encapsulates persistent app state for a single PlayerColorScheme.
 */
class PlayerColorSchemeState: PersistentStateProtocol {
    
    var trackInfoPrimaryTextColor: ColorState?
    var trackInfoSecondaryTextColor: ColorState?
    var trackInfoTertiaryTextColor: ColorState?
    var sliderValueTextColor: ColorState?
    
    var sliderBackgroundColor: ColorState?
    var sliderBackgroundGradientType: GradientType?
    var sliderBackgroundGradientAmount: Int?
    
    var sliderForegroundColor: ColorState?
    var sliderForegroundGradientType: GradientType?
    var sliderForegroundGradientAmount: Int?
    
    
    var sliderKnobColor: ColorState?
    var sliderKnobColorSameAsForeground: Bool?
    var sliderLoopSegmentColor: ColorState?
    
    init() {}
    
    init(_ scheme: PlayerColorScheme) {
        
        self.trackInfoPrimaryTextColor = ColorState.fromColor(scheme.trackInfoPrimaryTextColor)
        self.trackInfoSecondaryTextColor = ColorState.fromColor(scheme.trackInfoSecondaryTextColor)
        self.trackInfoTertiaryTextColor = ColorState.fromColor(scheme.trackInfoTertiaryTextColor)
        self.sliderValueTextColor = ColorState.fromColor(scheme.sliderValueTextColor)
        
        self.sliderBackgroundColor = ColorState.fromColor(scheme.sliderBackgroundColor)
        self.sliderBackgroundGradientType = scheme.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = scheme.sliderBackgroundGradientAmount
        
        self.sliderForegroundColor = ColorState.fromColor(scheme.sliderForegroundColor)
        self.sliderForegroundGradientType = scheme.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = scheme.sliderForegroundGradientAmount
        
        self.sliderKnobColor = ColorState.fromColor(scheme.sliderKnobColor)
        self.sliderKnobColorSameAsForeground = scheme.sliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = ColorState.fromColor(scheme.sliderLoopSegmentColor)
    }
    
    required init?(_ map: NSDictionary) -> PlayerColorSchemeState? {
        
        let state = PlayerColorSchemeState()
        
        if let colorDict = map["trackInfoPrimaryTextColor"] as? NSDictionary {
            state.trackInfoPrimaryTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["trackInfoSecondaryTextColor"] as? NSDictionary {
            state.trackInfoSecondaryTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["trackInfoTertiaryTextColor"] as? NSDictionary {
            state.trackInfoTertiaryTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["sliderValueTextColor"] as? NSDictionary {
            state.sliderValueTextColor = ColorState.deserialize(colorDict)
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
        
        if let colorDict = map["sliderForegroundColor"] as? NSDictionary {
            state.sliderForegroundColor = ColorState.deserialize(colorDict)
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
        
        if let colorDict = map["sliderLoopSegmentColor"] as? NSDictionary {
            state.sliderLoopSegmentColor = ColorState.deserialize(colorDict)
        }
        
        return state
    }
}
