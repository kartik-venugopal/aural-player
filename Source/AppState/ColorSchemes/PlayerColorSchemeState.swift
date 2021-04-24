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
    
    required init?(_ map: NSDictionary) {
        
        if let colorDict = map["trackInfoPrimaryTextColor"] as? NSDictionary {
            self.trackInfoPrimaryTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["trackInfoSecondaryTextColor"] as? NSDictionary {
            self.trackInfoSecondaryTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["trackInfoTertiaryTextColor"] as? NSDictionary {
            self.trackInfoTertiaryTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["sliderValueTextColor"] as? NSDictionary {
            self.sliderValueTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["sliderBackgroundColor"] as? NSDictionary {
            self.sliderBackgroundColor = ColorState.deserialize(colorDict)
        }
        
        self.sliderBackgroundGradientType = map.enumValue(forKey: "sliderBackgroundGradientType",
                                                              ofType: GradientType.self)
        
        self.sliderBackgroundGradientAmount = map.intValue(forKey: "sliderBackgroundGradientAmount")
        
        if let colorDict = map["sliderForegroundColor"] as? NSDictionary {
            self.sliderForegroundColor = ColorState.deserialize(colorDict)
        }
        
        self.sliderForegroundGradientType = map.enumValue(forKey: "sliderForegroundGradientType",
                                                              ofType: GradientType.self)
        
        self.sliderForegroundGradientAmount = map.intValue(forKey: "sliderForegroundGradientAmount")
        
        if let colorDict = map["sliderKnobColor"] as? NSDictionary {
            self.sliderKnobColor = ColorState.deserialize(colorDict)
        }
        
        self.sliderKnobColorSameAsForeground = map.boolValue(forKey: "sliderKnobColorSameAsForeground")
        
        if let colorDict = map["sliderLoopSegmentColor"] as? NSDictionary {
            self.sliderLoopSegmentColor = ColorState.deserialize(colorDict)
        }
    }
}
