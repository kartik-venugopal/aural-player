import Cocoa

/*
    Encapsulates all persistent app state for color schemes.
 */
class ColorSchemesState: PersistentState {

    var userSchemes: [ColorSchemeState] = []
    var systemScheme: ColorSchemeState?
    
    init() {}
    
    init(_ systemScheme: ColorSchemeState, _ userSchemes: [ColorSchemeState]) {
        
        self.systemScheme = systemScheme
        self.userSchemes = userSchemes
    }
    
    static func deserialize(_ map: NSDictionary) -> ColorSchemesState {
        
        let state = ColorSchemesState()
        
        if let arr = map["userSchemes"] as? [NSDictionary] {
            state.userSchemes = arr.map {ColorSchemeState.deserialize($0)}
        }
        
        if let dict = map["systemScheme"] as? NSDictionary {
            state.systemScheme = ColorSchemeState.deserialize(dict)
        }
        
        return state
    }
}

/*
    Encapsulates persistent app state for a single color scheme.
 */
class ColorSchemeState: PersistentState {
    
    var name: String = ""
    
    var general: GeneralColorSchemeState?
    var player: PlayerColorSchemeState?
    var playlist: PlaylistColorSchemeState?
    var effects: EffectsColorSchemeState?
    
    init() {}
    
    // When saving app state to disk
    init(_ scheme: ColorScheme) {
        
        self.name = scheme.name
        
        self.general = GeneralColorSchemeState(scheme.general)
        self.player = PlayerColorSchemeState(scheme.player)
        self.playlist = PlaylistColorSchemeState(scheme.playlist)
        self.effects = EffectsColorSchemeState(scheme.effects)
    }
    
    static func deserialize(_ map: NSDictionary) -> ColorSchemeState {
        
        let state = ColorSchemeState()
        
        if let name = map["name"] as? String {
            state.name = name
        }
        
        if let dict = map["general"] as? NSDictionary {
            state.general = GeneralColorSchemeState.deserialize(dict)
        }
        
        if let dict = map["player"] as? NSDictionary {
            state.player = PlayerColorSchemeState.deserialize(dict)
        }
        
        if let dict = map["playlist"] as? NSDictionary {
            state.playlist = PlaylistColorSchemeState.deserialize(dict)
        }
        
        if let dict = map["effects"] as? NSDictionary {
            state.effects = EffectsColorSchemeState.deserialize(dict)
        }
        
        return state
    }
}

/*
    Encapsulates persistent app state for a single GeneralColorScheme.
 */
class GeneralColorSchemeState: PersistentState {
    
    var appLogoColor: ColorState?
    var backgroundColor: ColorState?
    
    var viewControlButtonColor: ColorState?
    var functionButtonColor: ColorState?
    var textButtonMenuColor: ColorState?
    var toggleButtonOffStateColor: ColorState?
    var selectedTabButtonColor: ColorState?
    
    var mainCaptionTextColor: ColorState?
    var tabButtonTextColor: ColorState?
    var selectedTabButtonTextColor: ColorState?
    var buttonMenuTextColor: ColorState?
    
    init() {}
    
    init(_ scheme: GeneralColorScheme) {
        
        self.appLogoColor = ColorState.fromColor(scheme.appLogoColor)
        self.backgroundColor = ColorState.fromColor(scheme.backgroundColor)
        
        self.viewControlButtonColor = ColorState.fromColor(scheme.viewControlButtonColor)
        self.functionButtonColor = ColorState.fromColor(scheme.functionButtonColor)
        self.textButtonMenuColor = ColorState.fromColor(scheme.textButtonMenuColor)
        self.toggleButtonOffStateColor = ColorState.fromColor(scheme.toggleButtonOffStateColor)
        self.selectedTabButtonColor = ColorState.fromColor(scheme.selectedTabButtonColor)
        
        self.mainCaptionTextColor = ColorState.fromColor(scheme.mainCaptionTextColor)
        self.tabButtonTextColor = ColorState.fromColor(scheme.tabButtonTextColor)
        self.selectedTabButtonTextColor = ColorState.fromColor(scheme.selectedTabButtonTextColor)
        self.buttonMenuTextColor = ColorState.fromColor(scheme.buttonMenuTextColor)
    }
    
    static func deserialize(_ map: NSDictionary) -> GeneralColorSchemeState {
        
        let state = GeneralColorSchemeState()
        
        if let colorDict = map["appLogoColor"] as? NSDictionary {
            state.appLogoColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["backgroundColor"] as? NSDictionary {
            state.backgroundColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["viewControlButtonColor"] as? NSDictionary {
            state.viewControlButtonColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["functionButtonColor"] as? NSDictionary {
            state.functionButtonColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["textButtonMenuColor"] as? NSDictionary {
            state.textButtonMenuColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["toggleButtonOffStateColor"] as? NSDictionary {
            state.toggleButtonOffStateColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["selectedTabButtonColor"] as? NSDictionary {
            state.selectedTabButtonColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["mainCaptionTextColor"] as? NSDictionary {
            state.mainCaptionTextColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["tabButtonTextColor"] as? NSDictionary {
            state.tabButtonTextColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["selectedTabButtonTextColor"] as? NSDictionary {
            state.selectedTabButtonTextColor =  ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["buttonMenuTextColor"] as? NSDictionary {
            state.buttonMenuTextColor =  ColorState.deserialize(colorDict)
        }
        
        return state
    }
}

/*
    Encapsulates persistent app state for a single PlayerColorScheme.
 */
class PlayerColorSchemeState: PersistentState {
    
    var trackInfoPrimaryTextColor: ColorState?
    var trackInfoSecondaryTextColor: ColorState?
    var trackInfoTertiaryTextColor: ColorState?
    var sliderValueTextColor: ColorState?
    
    var sliderBackgroundColor: ColorState?
    var sliderBackgroundGradientType: GradientType = .none
    var sliderBackgroundGradientAmount: Int = 50
    
    var sliderForegroundColor: ColorState?
    var sliderForegroundGradientType: GradientType = .none
    var sliderForegroundGradientAmount: Int = 50
    
    
    var sliderKnobColor: ColorState?
    var sliderKnobColorSameAsForeground: Bool = true
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
    
    static func deserialize(_ map: NSDictionary) -> PlayerColorSchemeState {
        
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

/*
    Encapsulates persistent app state for a single PlaylistColorScheme.
 */
class PlaylistColorSchemeState: PersistentState {
    
    var trackNameTextColor: ColorState?
    var groupNameTextColor: ColorState?
    var indexDurationTextColor: ColorState?
    
    var trackNameSelectedTextColor: ColorState?
    var groupNameSelectedTextColor: ColorState?
    var indexDurationSelectedTextColor: ColorState?
    
    var summaryInfoColor: ColorState?
    
    var playingTrackIconColor: ColorState?
    var selectionBoxColor: ColorState?
    
    var groupIconColor: ColorState?
    var groupDisclosureTriangleColor: ColorState?
    
    init() {}
    
    init(_ scheme: PlaylistColorScheme) {
        
        self.trackNameTextColor = ColorState.fromColor(scheme.trackNameTextColor)
        self.groupNameTextColor = ColorState.fromColor(scheme.groupNameTextColor)
        self.indexDurationTextColor = ColorState.fromColor(scheme.indexDurationTextColor)
        
        self.trackNameSelectedTextColor = ColorState.fromColor(scheme.trackNameSelectedTextColor)
        self.groupNameSelectedTextColor = ColorState.fromColor(scheme.groupNameSelectedTextColor)
        self.indexDurationSelectedTextColor = ColorState.fromColor(scheme.indexDurationSelectedTextColor)
        
        self.groupIconColor = ColorState.fromColor(scheme.groupIconColor)
        self.groupDisclosureTriangleColor = ColorState.fromColor(scheme.groupDisclosureTriangleColor)
        self.selectionBoxColor = ColorState.fromColor(scheme.selectionBoxColor)
        self.playingTrackIconColor = ColorState.fromColor(scheme.playingTrackIconColor)
        self.summaryInfoColor = ColorState.fromColor(scheme.summaryInfoColor)
    }
    
    static func deserialize(_ map: NSDictionary) -> PlaylistColorSchemeState {
        
        let state = PlaylistColorSchemeState()
        
        if let colorDict = map["trackNameTextColor"] as? NSDictionary {
            state.trackNameTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["groupNameTextColor"] as? NSDictionary {
            state.groupNameTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["indexDurationTextColor"] as? NSDictionary {
            state.indexDurationTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["trackNameSelectedTextColor"] as? NSDictionary {
            state.trackNameSelectedTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["groupNameSelectedTextColor"] as? NSDictionary {
            state.groupNameSelectedTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["indexDurationSelectedTextColor"] as? NSDictionary {
            state.indexDurationSelectedTextColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["groupIconColor"] as? NSDictionary {
            state.groupIconColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["groupDisclosureTriangleColor"] as? NSDictionary {
            state.groupDisclosureTriangleColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["selectionBoxColor"] as? NSDictionary {
            state.selectionBoxColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["playingTrackIconColor"] as? NSDictionary {
            state.playingTrackIconColor = ColorState.deserialize(colorDict)
        }
        
        if let colorDict = map["summaryInfoColor"] as? NSDictionary {
            state.summaryInfoColor = ColorState.deserialize(colorDict)
        }
        
        return state
    }
}

/*
    Encapsulates persistent app state for a single EffectsColorScheme.
 */
class EffectsColorSchemeState: PersistentState {
    
    var functionCaptionTextColor: ColorState?
    var functionValueTextColor: ColorState?
    
    var sliderBackgroundColor: ColorState?
    var sliderBackgroundGradientType: GradientType = .none
    var sliderBackgroundGradientAmount: Int = 50
    
    var sliderForegroundGradientType: GradientType = .none
    var sliderForegroundGradientAmount: Int = 50
    
    var sliderKnobColor: ColorState?
    var sliderKnobColorSameAsForeground: Bool = true
    
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
    
    static func deserialize(_ map: NSDictionary) -> EffectsColorSchemeState {
        
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
