import Cocoa

class ColorSchemesState: PersistentState {

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

class ColorSchemeState: PersistentState {
    
    var general: GeneralColorSchemeState
    var player: PlayerColorSchemeState
    var playlist: PlaylistColorSchemeState
    var effects: EffectsColorSchemeState
    
    convenience init() {
        self.init(ColorSchemes.systemScheme)
    }
    
    init(_ scheme: ColorScheme) {
        
        self.general = GeneralColorSchemeState(scheme.general)
        self.player = PlayerColorSchemeState(scheme.player)
        self.playlist = PlaylistColorSchemeState(scheme.playlist)
        self.effects = EffectsColorSchemeState(scheme.effects)
    }
    
    static func deserialize(_ map: NSDictionary) -> PersistentState {
        
        let state = ColorSchemeState()
        
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

class GeneralColorSchemeState: PersistentState {
    
    var appLogoColor: ColorState = ColorState.defaultInstance
    var backgroundColor: ColorState = ColorState.defaultInstance
    
    var viewControlButtonColor: ColorState = ColorState.defaultInstance
    var functionButtonColor: ColorState = ColorState.defaultInstance
    var textButtonMenuColor: ColorState = ColorState.defaultInstance
    var toggleButtonOffStateColor: ColorState = ColorState.defaultInstance
    var selectedTabButtonColor: ColorState = ColorState.defaultInstance
    
    var mainCaptionTextColor: ColorState = ColorState.defaultInstance
    var tabButtonTextColor: ColorState = ColorState.defaultInstance
    var selectedTabButtonTextColor: ColorState = ColorState.defaultInstance
    var buttonMenuTextColor: ColorState = ColorState.defaultInstance
    
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

class PlayerColorSchemeState: PersistentState {
    
    var trackInfoPrimaryTextColor: ColorState = ColorState.defaultInstance
    var trackInfoSecondaryTextColor: ColorState = ColorState.defaultInstance
    var trackInfoTertiaryTextColor: ColorState = ColorState.defaultInstance
    var sliderValueTextColor: ColorState = ColorState.defaultInstance
    
    var sliderBackgroundColor: ColorState = ColorState.defaultInstance
    var sliderBackgroundGradientType: GradientType = .none
    var sliderBackgroundGradientAmount: Int = 50
    
    var sliderForegroundColor: ColorState = ColorState.defaultInstance
    var sliderForegroundGradientType: GradientType = .none
    var sliderForegroundGradientAmount: Int = 50
    
    
    var sliderKnobColor: ColorState = ColorState.defaultInstance
    var sliderKnobColorSameAsForeground: Bool = true
    var sliderLoopSegmentColor: ColorState = ColorState.defaultInstance
    
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

class PlaylistColorSchemeState: PersistentState {
    
    var trackNameTextColor: ColorState = ColorState.defaultInstance
    var groupNameTextColor: ColorState = ColorState.defaultInstance
    var indexDurationTextColor: ColorState = ColorState.defaultInstance
    
    var trackNameSelectedTextColor: ColorState = ColorState.defaultInstance
    var groupNameSelectedTextColor: ColorState = ColorState.defaultInstance
    var indexDurationSelectedTextColor: ColorState = ColorState.defaultInstance
    
    var summaryInfoColor: ColorState = ColorState.defaultInstance
    
    var playingTrackIconColor: ColorState = ColorState.defaultInstance
    var selectionBoxColor: ColorState = ColorState.defaultInstance
    
    var groupIconColor: ColorState = ColorState.defaultInstance
    var groupDisclosureTriangleColor: ColorState = ColorState.defaultInstance
    
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

class EffectsColorSchemeState: PersistentState {
    
    var functionCaptionTextColor: ColorState = ColorState.defaultInstance
    var functionValueTextColor: ColorState = ColorState.defaultInstance
    
    var sliderBackgroundColor: ColorState = ColorState.defaultInstance
    var sliderBackgroundGradientType: GradientType = .none
    var sliderBackgroundGradientAmount: Int = 50
    
    var sliderForegroundGradientType: GradientType = .none
    var sliderForegroundGradientAmount: Int = 50
    
    var sliderKnobColor: ColorState = ColorState.defaultInstance
    var sliderKnobColorSameAsForeground: Bool = true
    
    var activeUnitStateColor: ColorState = ColorState.defaultInstance
    var bypassedUnitStateColor: ColorState = ColorState.defaultInstance
    var suppressedUnitStateColor: ColorState = ColorState.defaultInstance
    
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
