import Cocoa

class ColorScheme {
    
    var name: String

    var general: GeneralColorScheme
    var player: PlayerColorScheme
    var playlist: PlaylistColorScheme
    var effects: EffectsColorScheme
    
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
    
    func persistentState() -> GeneralColorSchemeState {
        return GeneralColorSchemeState(self)
    }
    
    var logoTextColor: NSColor
    var backgroundColor: NSColor
    var controlButtonColor: NSColor
    var controlButtonOffStateColor: NSColor
    
    init(_ appState: GeneralColorSchemeState) {
        
        self.logoTextColor = appState.logoTextColor.toColor()
        self.backgroundColor = appState.backgroundColor.toColor()
        self.controlButtonColor = appState.controlButtonColor.toColor()
        self.controlButtonOffStateColor = appState.controlButtonOffStateColor.toColor()
    }
   
    init(_ preset: ColorSchemePreset) {
        
        self.logoTextColor = preset.logoTextColor
        self.backgroundColor = preset.backgroundColor
        self.controlButtonColor = preset.controlButtonColor
        self.controlButtonOffStateColor = preset.controlButtonOffStateColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.logoTextColor = preset.logoTextColor
        self.backgroundColor = preset.backgroundColor
        self.controlButtonColor = preset.controlButtonColor
        self.controlButtonOffStateColor = preset.controlButtonOffStateColor
    }
}

class PlayerColorScheme {
    
    var persistentState: PlayerColorSchemeState {
        return PlayerColorSchemeState(self)
    }
    
    var trackInfoPrimaryTextColor: NSColor
    var trackInfoSecondaryTextColor: NSColor
    var trackInfoTertiaryTextColor: NSColor
    var controlTextColor: NSColor
    
    var sliderForegroundColor: NSColor
    var sliderBackgroundColor: NSColor
    var sliderKnobColor: NSColor
    var sliderLoopSegmentColor: NSColor
    
    init(_ appState: PlayerColorSchemeState) {
        
        self.trackInfoPrimaryTextColor = appState.trackInfoPrimaryTextColor.toColor()
        self.trackInfoSecondaryTextColor = appState.trackInfoSecondaryTextColor.toColor()
        self.trackInfoTertiaryTextColor = appState.trackInfoTertiaryTextColor.toColor()
        
        self.controlTextColor = appState.controlTextColor.toColor()
        
        self.sliderBackgroundColor = appState.sliderBackgroundColor.toColor()
        self.sliderForegroundColor = appState.sliderForegroundColor.toColor()
        self.sliderKnobColor = appState.sliderKnobColor.toColor()
        self.sliderLoopSegmentColor = appState.sliderLoopSegmentColor.toColor()
    }
    
    init(_ preset: ColorSchemePreset) {
        
        self.trackInfoPrimaryTextColor = preset.playerTrackInfoPrimaryTextColor
        self.trackInfoSecondaryTextColor = preset.playerTrackInfoSecondaryTextColor
        self.trackInfoTertiaryTextColor = preset.playerTrackInfoTertiaryTextColor
        
        self.controlTextColor = preset.playerControlTextColor
        
        self.sliderBackgroundColor = preset.playerSliderBackgroundColor
        self.sliderForegroundColor = preset.playerSliderForegroundColor
        self.sliderKnobColor = preset.playerSliderKnobColor
        self.sliderLoopSegmentColor = preset.playerSliderLoopSegmentColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.trackInfoPrimaryTextColor = preset.playerTrackInfoPrimaryTextColor
        self.trackInfoSecondaryTextColor = preset.playerTrackInfoSecondaryTextColor
        self.trackInfoTertiaryTextColor = preset.playerTrackInfoTertiaryTextColor
        
        self.controlTextColor = preset.playerControlTextColor
        
        self.sliderBackgroundColor = preset.playerSliderBackgroundColor
        self.sliderForegroundColor = preset.playerSliderForegroundColor
        self.sliderKnobColor = preset.playerSliderKnobColor
        self.sliderLoopSegmentColor = preset.playerSliderLoopSegmentColor
    }
}

class PlaylistColorScheme {
    
    var persistentState: PlaylistColorSchemeState {
        return PlaylistColorSchemeState(self)
    }
    
    var trackNameTextColor: NSColor
    var groupNameTextColor: NSColor
    var indexDurationTextColor: NSColor
    
    var trackNameSelectedTextColor: NSColor
    var groupNameSelectedTextColor: NSColor
    var indexDurationSelectedTextColor: NSColor
    
    var summaryInfoColor: NSColor
    var tabButtonTextColor: NSColor
    var selectedTabButtonTextColor: NSColor
    
    var playingTrackIconColor: NSColor
    var selectionBoxColor: NSColor
    
    var groupIconColor: NSColor
    var groupDisclosureTriangleColor: NSColor
    
    var selectedTabButtonColor: NSColor
    
    init(_ preset: PlaylistColorSchemeState) {
        
        self.trackNameTextColor = preset.trackNameTextColor.toColor()
        self.groupNameTextColor = preset.groupNameTextColor.toColor()
        self.indexDurationTextColor = preset.indexDurationTextColor.toColor()
        
        self.trackNameSelectedTextColor = preset.trackNameSelectedTextColor.toColor()
        self.groupNameSelectedTextColor = preset.groupNameSelectedTextColor.toColor()
        self.indexDurationSelectedTextColor = preset.indexDurationSelectedTextColor.toColor()
        
        self.summaryInfoColor = preset.summaryInfoColor.toColor()
        self.tabButtonTextColor = preset.tabButtonTextColor.toColor()
        self.selectedTabButtonTextColor = preset.selectedTabButtonTextColor.toColor()
        
        self.groupIconColor = preset.groupIconColor.toColor()
        self.groupDisclosureTriangleColor = preset.groupDisclosureTriangleColor.toColor()
        self.selectionBoxColor = preset.selectionBoxColor.toColor()
        self.selectedTabButtonColor = preset.selectedTabButtonColor.toColor()
        self.playingTrackIconColor = preset.playingTrackIconColor.toColor()
    }
    
    init(_ preset: ColorSchemePreset) {
        
        self.trackNameTextColor = preset.playlistTrackNameTextColor
        self.groupNameTextColor = preset.playlistGroupNameTextColor
        self.indexDurationTextColor = preset.playlistIndexDurationTextColor
        
        self.trackNameSelectedTextColor = preset.playlistTrackNameSelectedTextColor
        self.groupNameSelectedTextColor = preset.playlistGroupNameSelectedTextColor
        self.indexDurationSelectedTextColor = preset.playlistIndexDurationSelectedTextColor
        
        self.summaryInfoColor = preset.playlistSummaryInfoColor
        self.tabButtonTextColor = preset.playlistTabButtonTextColor
        self.selectedTabButtonTextColor = preset.playlistSelectedTabButtonTextColor
        
        self.groupIconColor = preset.playlistGroupIconColor
        self.groupDisclosureTriangleColor = preset.playlistGroupDisclosureTriangleColor
        self.selectionBoxColor = preset.playlistSelectionBoxColor
        self.selectedTabButtonColor = preset.playlistSelectedTabButtonColor
        self.playingTrackIconColor = preset.playlistPlayingTrackIconColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.trackNameTextColor = preset.playlistTrackNameTextColor
        self.groupNameTextColor = preset.playlistGroupNameTextColor
        self.indexDurationTextColor = preset.playlistIndexDurationTextColor
        
        self.trackNameSelectedTextColor = preset.playlistTrackNameSelectedTextColor
        self.groupNameSelectedTextColor = preset.playlistGroupNameSelectedTextColor
        self.indexDurationSelectedTextColor = preset.playlistIndexDurationSelectedTextColor
        
        self.summaryInfoColor = preset.playlistSummaryInfoColor
        self.tabButtonTextColor = preset.playlistTabButtonTextColor
        self.selectedTabButtonTextColor = preset.playlistSelectedTabButtonTextColor
        
        self.groupIconColor = preset.playlistGroupIconColor
        self.groupDisclosureTriangleColor = preset.playlistGroupDisclosureTriangleColor
        self.selectionBoxColor = preset.playlistSelectionBoxColor
        self.selectedTabButtonColor = preset.playlistSelectedTabButtonColor
        self.playingTrackIconColor = preset.playlistPlayingTrackIconColor
    }
}

class EffectsColorScheme {
    
    var mainCaptionTextColor: NSColor
    var functionCaptionTextColor: NSColor
    
    var sliderBackgroundColor: NSColor
    
    var activeUnitStateColor: NSColor
    var bypassedUnitStateColor: NSColor
    var suppressedUnitStateColor: NSColor
    
    var tabButtonTextColor: NSColor
    var selectedTabButtonTextColor: NSColor
    var selectedTabButtonColor: NSColor
    
    var functionButtonColor: NSColor
    var functionButtonTextColor: NSColor
    
    init(_ appState: EffectsColorSchemeState) {
        
        self.mainCaptionTextColor = appState.mainCaptionTextColor.toColor()
        self.functionCaptionTextColor = appState.functionCaptionTextColor.toColor()
        
        self.sliderBackgroundColor = appState.sliderBackgroundColor.toColor()
        
        self.activeUnitStateColor = appState.activeUnitStateColor.toColor()
        self.bypassedUnitStateColor = appState.bypassedUnitStateColor.toColor()
        self.suppressedUnitStateColor = appState.suppressedUnitStateColor.toColor()
        
        self.tabButtonTextColor = appState.tabButtonTextColor.toColor()
        self.selectedTabButtonTextColor = appState.selectedTabButtonTextColor.toColor()
        self.selectedTabButtonColor = appState.selectedTabButtonColor.toColor()
        
        self.functionButtonColor = appState.functionButtonColor.toColor()
        self.functionButtonTextColor = appState.functionButtonTextColor.toColor()
    }
    
    init(_ preset: ColorSchemePreset) {
        
        self.mainCaptionTextColor = preset.effectsMainCaptionTextColor
        self.functionCaptionTextColor = preset.effectsFunctionCaptionTextColor
        
        self.sliderBackgroundColor = preset.effectsSliderBackgroundColor
        
        self.activeUnitStateColor = preset.effectsActiveUnitStateColor
        self.bypassedUnitStateColor = preset.effectsBypassedUnitStateColor
        self.suppressedUnitStateColor = preset.effectsSuppressedUnitStateColor
        
        self.tabButtonTextColor = preset.effectsTabButtonTextColor
        self.selectedTabButtonTextColor = preset.effectsSelectedTabButtonTextColor
        self.selectedTabButtonColor = preset.effectsSelectedTabButtonColor
        
        self.functionButtonColor = preset.effectsFunctionButtonColor
        self.functionButtonTextColor = preset.effectsFunctionButtonTextColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {

        self.mainCaptionTextColor = preset.effectsMainCaptionTextColor
        self.functionCaptionTextColor = preset.effectsFunctionCaptionTextColor
        
        self.sliderBackgroundColor = preset.effectsSliderBackgroundColor
        
        self.activeUnitStateColor = preset.effectsActiveUnitStateColor
        self.bypassedUnitStateColor = preset.effectsBypassedUnitStateColor
        self.suppressedUnitStateColor = preset.effectsSuppressedUnitStateColor
        
        self.tabButtonTextColor = preset.effectsTabButtonTextColor
        self.selectedTabButtonTextColor = preset.effectsSelectedTabButtonTextColor
        self.selectedTabButtonColor = preset.effectsSelectedTabButtonColor
        
        self.functionButtonColor = preset.effectsFunctionButtonColor
        self.functionButtonTextColor = preset.effectsFunctionButtonTextColor
    }
    
    var persistentState: EffectsColorSchemeState {
        return EffectsColorSchemeState(self)
    }
}
