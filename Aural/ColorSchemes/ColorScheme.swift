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
    
    var persistentState: EffectsColorSchemeState {
        return EffectsColorSchemeState(self)
    }
    
    init(_ preset: ColorSchemePreset) {
        
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {

    }
}
