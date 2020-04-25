import Cocoa

class ColorScheme {
    
    var name: String

    var general: GeneralColorScheme
    var player: PlayerColorScheme
    var playlist: PlaylistColorScheme
    var effects: EffectsColorScheme
    
    func toString() -> String {
        return String(describing: JSONMapper.map(ColorSchemeState(self)))
    }
    
    let systemDefined: Bool
    
    convenience init(_ name: String) {
        self.init(name, ColorSchemePreset.defaultScheme, false)
    }
    
    init(_ name: String, _ appState: ColorSchemeState, _ systemDefined: Bool) {
        
        self.name = name
        self.systemDefined = systemDefined
        
        self.general = GeneralColorScheme(appState.general)
        self.player = PlayerColorScheme(appState.player)
        self.playlist = PlaylistColorScheme(appState.playlist)
        self.effects = EffectsColorScheme(appState.effects)
    }
    
    init(_ name: String, _ preset: ColorSchemePreset, _ systemDefined: Bool = true) {
        
        self.name = name
        self.systemDefined = systemDefined
        
        self.general = GeneralColorScheme(preset)
        self.player = PlayerColorScheme(preset)
        self.playlist = PlaylistColorScheme(preset)
        self.effects = EffectsColorScheme(preset)
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.general = GeneralColorScheme(preset)
        self.player = PlayerColorScheme(preset)
        self.playlist = PlaylistColorScheme(preset)
        self.effects = EffectsColorScheme(preset)
    }
    
    var persistentState: ColorSchemeState {
        return ColorSchemeState(self)
    }
}

class GeneralColorScheme {
    
    var appLogoColor: NSColor
    var backgroundColor: NSColor
    
    var viewControlButtonColor: NSColor
    var functionButtonColor: NSColor
    var toggleButtonOffStateColor: NSColor
    var selectedTabButtonColor: NSColor
    
    var mainCaptionTextColor: NSColor
    var tabButtonTextColor: NSColor
    var selectedTabButtonTextColor: NSColor
    var functionButtonTextColor: NSColor
    
    init(_ appState: GeneralColorSchemeState) {
        
        self.appLogoColor = appState.appLogoColor.toColor()
        self.backgroundColor = appState.backgroundColor.toColor()
        
        self.viewControlButtonColor = appState.viewControlButtonColor.toColor()
        self.functionButtonColor = appState.functionButtonColor.toColor()
        self.toggleButtonOffStateColor = appState.toggleButtonOffStateColor.toColor()
        self.selectedTabButtonColor = appState.selectedTabButtonColor.toColor()
        
        self.mainCaptionTextColor = appState.mainCaptionTextColor.toColor()
        self.tabButtonTextColor = appState.tabButtonTextColor.toColor()
        self.selectedTabButtonTextColor = appState.selectedTabButtonTextColor.toColor()
        self.functionButtonTextColor = appState.functionButtonTextColor.toColor()
    }
   
    init(_ preset: ColorSchemePreset) {
        
        self.appLogoColor = preset.appLogoColor
        self.backgroundColor = preset.backgroundColor
        
        self.viewControlButtonColor = preset.viewControlButtonColor
        self.functionButtonColor = preset.functionButtonColor
        self.toggleButtonOffStateColor = preset.toggleButtonOffStateColor
        self.selectedTabButtonColor = preset.selectedTabButtonColor
        
        self.mainCaptionTextColor = preset.mainCaptionTextColor
        self.tabButtonTextColor = preset.tabButtonTextColor
        self.selectedTabButtonTextColor = preset.selectedTabButtonTextColor
        self.functionButtonTextColor = preset.functionButtonTextColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.appLogoColor = preset.appLogoColor
        self.backgroundColor = preset.backgroundColor
        
        self.viewControlButtonColor = preset.viewControlButtonColor
        self.functionButtonColor = preset.functionButtonColor
        self.toggleButtonOffStateColor = preset.toggleButtonOffStateColor
        self.selectedTabButtonColor = preset.selectedTabButtonColor
        
        self.mainCaptionTextColor = preset.mainCaptionTextColor
        self.tabButtonTextColor = preset.tabButtonTextColor
        self.selectedTabButtonTextColor = preset.selectedTabButtonTextColor
        self.functionButtonTextColor = preset.functionButtonTextColor
    }
    
    var persistentState: GeneralColorSchemeState {
        return GeneralColorSchemeState(self)
    }
}

class PlayerColorScheme {
    
    var trackInfoPrimaryTextColor: NSColor
    var trackInfoSecondaryTextColor: NSColor
    var trackInfoTertiaryTextColor: NSColor
    var sliderValueTextColor: NSColor
    
    var sliderForegroundColor: NSColor
    var sliderForegroundGradientType: GradientType
    var sliderForegroundGradientAmount: Int
    
    var sliderBackgroundColor: NSColor
    var sliderKnobColor: NSColor
    var sliderKnobColorSameAsForeground: Bool
    var sliderLoopSegmentColor: NSColor
    
    init(_ appState: PlayerColorSchemeState) {
        
        self.trackInfoPrimaryTextColor = appState.trackInfoPrimaryTextColor.toColor()
        self.trackInfoSecondaryTextColor = appState.trackInfoSecondaryTextColor.toColor()
        self.trackInfoTertiaryTextColor = appState.trackInfoTertiaryTextColor.toColor()
        self.sliderValueTextColor = appState.sliderValueTextColor.toColor()
        
        self.sliderBackgroundColor = appState.sliderBackgroundColor.toColor()
        
        self.sliderForegroundColor = appState.sliderForegroundColor.toColor()
        self.sliderForegroundGradientType = appState.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = appState.sliderForegroundGradientAmount
        
        self.sliderKnobColor = appState.sliderKnobColor.toColor()
        self.sliderKnobColorSameAsForeground = appState.sliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = appState.sliderLoopSegmentColor.toColor()
    }
    
    init(_ preset: ColorSchemePreset) {
        
        self.trackInfoPrimaryTextColor = preset.playerTrackInfoPrimaryTextColor
        self.trackInfoSecondaryTextColor = preset.playerTrackInfoSecondaryTextColor
        self.trackInfoTertiaryTextColor = preset.playerTrackInfoTertiaryTextColor
        self.sliderValueTextColor = preset.playerSliderValueTextColor
        
        self.sliderBackgroundColor = preset.playerSliderBackgroundColor
        
        self.sliderForegroundColor = preset.playerSliderForegroundColor
        self.sliderForegroundGradientType = preset.playerSliderForegroundGradientType
        self.sliderForegroundGradientAmount = preset.playerSliderForegroundGradientAmount
        
        self.sliderKnobColor = preset.playerSliderKnobColor
        self.sliderKnobColorSameAsForeground = preset.playerSliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = preset.playerSliderLoopSegmentColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.trackInfoPrimaryTextColor = preset.playerTrackInfoPrimaryTextColor
        self.trackInfoSecondaryTextColor = preset.playerTrackInfoSecondaryTextColor
        self.trackInfoTertiaryTextColor = preset.playerTrackInfoTertiaryTextColor
        self.sliderValueTextColor = preset.playerSliderValueTextColor
        
        self.sliderBackgroundColor = preset.playerSliderBackgroundColor
        
        self.sliderForegroundColor = preset.playerSliderForegroundColor
        self.sliderForegroundGradientType = preset.playerSliderForegroundGradientType
        self.sliderForegroundGradientAmount = preset.playerSliderForegroundGradientAmount
        
        self.sliderKnobColor = preset.playerSliderKnobColor
        self.sliderLoopSegmentColor = preset.playerSliderLoopSegmentColor
    }
    
    var persistentState: PlayerColorSchemeState {
        return PlayerColorSchemeState(self)
    }
}

class PlaylistColorScheme {
    
    var trackNameTextColor: NSColor
    var groupNameTextColor: NSColor
    var indexDurationTextColor: NSColor
    
    var trackNameSelectedTextColor: NSColor
    var groupNameSelectedTextColor: NSColor
    var indexDurationSelectedTextColor: NSColor
    
    var summaryInfoColor: NSColor
    
    var playingTrackIconColor: NSColor
    var selectionBoxColor: NSColor
    
    var groupIconColor: NSColor
    var groupDisclosureTriangleColor: NSColor
    
    init(_ appState: PlaylistColorSchemeState) {
        
        self.trackNameTextColor = appState.trackNameTextColor.toColor()
        self.groupNameTextColor = appState.groupNameTextColor.toColor()
        self.indexDurationTextColor = appState.indexDurationTextColor.toColor()
        
        self.trackNameSelectedTextColor = appState.trackNameSelectedTextColor.toColor()
        self.groupNameSelectedTextColor = appState.groupNameSelectedTextColor.toColor()
        self.indexDurationSelectedTextColor = appState.indexDurationSelectedTextColor.toColor()
        
        self.summaryInfoColor = appState.summaryInfoColor.toColor()
        
        self.selectionBoxColor = appState.selectionBoxColor.toColor()
        self.playingTrackIconColor = appState.playingTrackIconColor.toColor()
        
        self.groupIconColor = appState.groupIconColor.toColor()
        self.groupDisclosureTriangleColor = appState.groupDisclosureTriangleColor.toColor()
    }
    
    init(_ preset: ColorSchemePreset) {
        
        self.trackNameTextColor = preset.playlistTrackNameTextColor
        self.groupNameTextColor = preset.playlistGroupNameTextColor
        self.indexDurationTextColor = preset.playlistIndexDurationTextColor
        
        self.trackNameSelectedTextColor = preset.playlistTrackNameSelectedTextColor
        self.groupNameSelectedTextColor = preset.playlistGroupNameSelectedTextColor
        self.indexDurationSelectedTextColor = preset.playlistIndexDurationSelectedTextColor
        
        self.summaryInfoColor = preset.playlistSummaryInfoColor
        
        self.selectionBoxColor = preset.playlistSelectionBoxColor
        self.playingTrackIconColor = preset.playlistPlayingTrackIconColor
        
        self.groupIconColor = preset.playlistGroupIconColor
        self.groupDisclosureTriangleColor = preset.playlistGroupDisclosureTriangleColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.trackNameTextColor = preset.playlistTrackNameTextColor
        self.groupNameTextColor = preset.playlistGroupNameTextColor
        self.indexDurationTextColor = preset.playlistIndexDurationTextColor
        
        self.trackNameSelectedTextColor = preset.playlistTrackNameSelectedTextColor
        self.groupNameSelectedTextColor = preset.playlistGroupNameSelectedTextColor
        self.indexDurationSelectedTextColor = preset.playlistIndexDurationSelectedTextColor
        
        self.summaryInfoColor = preset.playlistSummaryInfoColor
        
        self.selectionBoxColor = preset.playlistSelectionBoxColor
        self.playingTrackIconColor = preset.playlistPlayingTrackIconColor
        
        self.groupIconColor = preset.playlistGroupIconColor
        self.groupDisclosureTriangleColor = preset.playlistGroupDisclosureTriangleColor
    }
    
    var persistentState: PlaylistColorSchemeState {
        return PlaylistColorSchemeState(self)
    }
}

class EffectsColorScheme {
    
    var functionCaptionTextColor: NSColor
    var functionValueTextColor: NSColor
    
    var sliderBackgroundColor: NSColor
    
    var sliderKnobColor: NSColor
    var sliderKnobColorSameAsForeground: Bool
    
    var activeUnitStateColor: NSColor
    var bypassedUnitStateColor: NSColor
    var suppressedUnitStateColor: NSColor
    
    init(_ appState: EffectsColorSchemeState) {
        
        self.functionCaptionTextColor = appState.functionCaptionTextColor.toColor()
        self.functionValueTextColor = appState.functionValueTextColor.toColor()
        
        self.sliderBackgroundColor = appState.sliderBackgroundColor.toColor()
        self.sliderKnobColor = appState.sliderKnobColor.toColor()
        self.sliderKnobColorSameAsForeground = appState.sliderKnobColorSameAsForeground
        
        self.activeUnitStateColor = appState.activeUnitStateColor.toColor()
        self.bypassedUnitStateColor = appState.bypassedUnitStateColor.toColor()
        self.suppressedUnitStateColor = appState.suppressedUnitStateColor.toColor()
    }
    
    init(_ preset: ColorSchemePreset) {
        
        self.functionCaptionTextColor = preset.effectsFunctionCaptionTextColor
        self.functionValueTextColor = preset.effectsFunctionValueTextColor
        
        self.sliderBackgroundColor = preset.effectsSliderBackgroundColor
        self.sliderKnobColor = preset.effectsSliderKnobColor
        self.sliderKnobColorSameAsForeground = preset.effectsSliderKnobColorSameAsForeground
        
        self.activeUnitStateColor = preset.effectsActiveUnitStateColor
        self.bypassedUnitStateColor = preset.effectsBypassedUnitStateColor
        self.suppressedUnitStateColor = preset.effectsSuppressedUnitStateColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {

        self.functionCaptionTextColor = preset.effectsFunctionCaptionTextColor
        self.functionValueTextColor = preset.effectsFunctionValueTextColor
        
        self.sliderBackgroundColor = preset.effectsSliderBackgroundColor
        self.sliderKnobColor = preset.effectsSliderKnobColor
        self.sliderKnobColorSameAsForeground = preset.effectsSliderKnobColorSameAsForeground
        
        self.activeUnitStateColor = preset.effectsActiveUnitStateColor
        self.bypassedUnitStateColor = preset.effectsBypassedUnitStateColor
        self.suppressedUnitStateColor = preset.effectsSuppressedUnitStateColor
    }
    
    var persistentState: EffectsColorSchemeState {
        return EffectsColorSchemeState(self)
    }
}

enum GradientType: String {
    
    case none
    case darken
    case brighten
}
