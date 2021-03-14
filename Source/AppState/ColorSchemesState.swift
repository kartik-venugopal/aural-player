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
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = ColorSchemesState()
        
        if let arr = map["userSchemes"] as? NSArray {
            
            for dict in arr {
                
                if let theDict = dict as? NSDictionary, let userScheme = ColorSchemeState.deserialize(theDict) as? ColorSchemeState {
                    state.userSchemes.append(userScheme)
                }
            }
        }
        
        if let dict = map["systemScheme"] as? NSDictionary, let scheme = ColorSchemeState.deserialize(dict) as? ColorSchemeState {
            state.systemScheme = scheme
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
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = ColorSchemeState()
        
        if let name = map["name"] as? String {
            state.name = name
        }
        
        if let dict = map["general"] as? NSDictionary, let generalState = GeneralColorSchemeState.deserialize(dict) as? GeneralColorSchemeState {
            state.general = generalState
        }
        
        if let dict = map["player"] as? NSDictionary, let playerState = PlayerColorSchemeState.deserialize(dict) as? PlayerColorSchemeState {
            state.player = playerState
        }
        
        if let dict = map["playlist"] as? NSDictionary, let playlistState = PlaylistColorSchemeState.deserialize(dict) as? PlaylistColorSchemeState {
            state.playlist = playlistState
        }
        
        if let dict = map["effects"] as? NSDictionary, let effectsState = EffectsColorSchemeState.deserialize(dict) as? EffectsColorSchemeState {
            state.effects = effectsState
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
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = GeneralColorSchemeState()
        
        if let colorDict = map["appLogoColor"] as? NSDictionary, let color = ColorState.deserialize(colorDict) as? ColorState {
            state.appLogoColor = color
        }
        
        if let colorDict = map["backgroundColor"] as? NSDictionary, let color = ColorState.deserialize(colorDict) as? ColorState {
            state.backgroundColor = color
        }
        
        if let colorDict = map["viewControlButtonColor"] as? NSDictionary, let color = ColorState.deserialize(colorDict) as? ColorState {
            state.viewControlButtonColor = color
        }
        
        if let colorDict = map["functionButtonColor"] as? NSDictionary, let color = ColorState.deserialize(colorDict) as? ColorState {
            state.functionButtonColor = color
        }
        
        if let colorDict = map["textButtonMenuColor"] as? NSDictionary, let color = ColorState.deserialize(colorDict) as? ColorState {
            state.textButtonMenuColor = color
        }
        
        if let colorDict = map["toggleButtonOffStateColor"] as? NSDictionary, let color = ColorState.deserialize(colorDict) as? ColorState {
            state.toggleButtonOffStateColor = color
        }
        
        if let colorDict = map["selectedTabButtonColor"] as? NSDictionary, let color = ColorState.deserialize(colorDict) as? ColorState {
            state.selectedTabButtonColor = color
        }
        
        if let colorDict = map["mainCaptionTextColor"] as? NSDictionary, let color = ColorState.deserialize(colorDict) as? ColorState {
            state.mainCaptionTextColor = color
        }
        
        if let colorDict = map["tabButtonTextColor"] as? NSDictionary, let color = ColorState.deserialize(colorDict) as? ColorState {
            state.tabButtonTextColor = color
        }
        
        if let colorDict = map["selectedTabButtonTextColor"] as? NSDictionary, let color = ColorState.deserialize(colorDict) as? ColorState {
            state.selectedTabButtonTextColor = color
        }
        
        if let colorDict = map["buttonMenuTextColor"] as? NSDictionary, let color = ColorState.deserialize(colorDict) as? ColorState {
            state.buttonMenuTextColor = color
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
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlayerColorSchemeState()
        
        if let colorDict = map["trackInfoPrimaryTextColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.trackInfoPrimaryTextColor = color
        }
        
        if let colorDict = map["trackInfoSecondaryTextColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.trackInfoSecondaryTextColor = color
        }
        
        if let colorDict = map["trackInfoTertiaryTextColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.trackInfoTertiaryTextColor = color
        }
        
        if let colorDict = map["sliderValueTextColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.sliderValueTextColor = color
        }
        
        if let colorDict = map["sliderBackgroundColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.sliderBackgroundColor = color
        }
        
        if let gradientTypeStr = map["sliderBackgroundGradientType"] as? String,
            let gradientType = GradientType(rawValue: gradientTypeStr) {
            
            state.sliderBackgroundGradientType = gradientType
        }
        
        if let amountNum = map["sliderBackgroundGradientAmount"] as? NSNumber {
            state.sliderBackgroundGradientAmount = amountNum.intValue
        }
        
        if let colorDict = map["sliderForegroundColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.sliderForegroundColor = color
        }
        
        if let gradientTypeStr = map["sliderForegroundGradientType"] as? String,
            let gradientType = GradientType(rawValue: gradientTypeStr) {
            
            state.sliderForegroundGradientType = gradientType
        }
        
        if let amountNum = map["sliderForegroundGradientAmount"] as? NSNumber {
            state.sliderForegroundGradientAmount = amountNum.intValue
        }
        
        if let colorDict = map["sliderKnobColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.sliderKnobColor = color
        }
        
        if let useForegroundColor = map["sliderKnobColorSameAsForeground"] as? Bool {
            state.sliderKnobColorSameAsForeground = useForegroundColor
        }
        
        if let colorDict = map["sliderLoopSegmentColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.sliderLoopSegmentColor = color
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
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = PlaylistColorSchemeState()
        
        if let colorDict = map["trackNameTextColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.trackNameTextColor = color
        }
        
        if let colorDict = map["groupNameTextColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.groupNameTextColor = color
        }
        
        if let colorDict = map["indexDurationTextColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.indexDurationTextColor = color
        }
        
        if let colorDict = map["trackNameSelectedTextColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.trackNameSelectedTextColor = color
        }
        
        if let colorDict = map["groupNameSelectedTextColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.groupNameSelectedTextColor = color
        }
        
        if let colorDict = map["indexDurationSelectedTextColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.indexDurationSelectedTextColor = color
        }
        
        if let colorDict = map["groupIconColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.groupIconColor = color
        }
        
        if let colorDict = map["groupDisclosureTriangleColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.groupDisclosureTriangleColor = color
        }
        
        if let colorDict = map["selectionBoxColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.selectionBoxColor = color
        }
        
        if let colorDict = map["playingTrackIconColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.playingTrackIconColor = color
        }
        
        if let colorDict = map["summaryInfoColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.summaryInfoColor = color
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
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = EffectsColorSchemeState()
        
        if let colorDict = map["functionCaptionTextColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.functionCaptionTextColor = color
        }
        
        if let colorDict = map["functionValueTextColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.functionValueTextColor = color
        }
        
        if let colorDict = map["sliderBackgroundColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.sliderBackgroundColor = color
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
        
        if let colorDict = map["sliderKnobColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.sliderKnobColor = color
        }
        
        if let useForegroundColor = map["sliderKnobColorSameAsForeground"] as? Bool {
            state.sliderKnobColorSameAsForeground = useForegroundColor
        }
        
        if let colorDict = map["sliderTickColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.sliderTickColor = color
        }
        
        if let colorDict = map["activeUnitStateColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.activeUnitStateColor = color
        }
        
        if let colorDict = map["bypassedUnitStateColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.bypassedUnitStateColor = color
        }
        
        if let colorDict = map["suppressedUnitStateColor"] as? NSDictionary,
            let color = ColorState.deserialize(colorDict) as? ColorState {
            state.suppressedUnitStateColor = color
        }
        
        return state
    }
}
