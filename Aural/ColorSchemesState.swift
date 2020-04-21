import Cocoa

class ColorSchemesState {
    
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

class ColorSchemeState {
    
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
}

class GeneralColorSchemeState {
    
    var logoTextColor: ColorState
    var backgroundColor: ColorState
    var controlButtonColor: ColorState
    var controlButtonOffStateColor: ColorState
    
    init(_ scheme: GeneralColorScheme) {
        
        self.logoTextColor = ColorState.fromNSColor(scheme.logoTextColor)
        self.backgroundColor = ColorState.fromNSColor(scheme.backgroundColor)
        self.controlButtonColor = ColorState.fromNSColor(scheme.controlButtonColor)
        self.controlButtonOffStateColor = ColorState.fromNSColor(scheme.controlButtonOffStateColor)
    }
}

class PlayerColorSchemeState {
    
    var primaryTextColor: ColorState
    var secondaryTextColor: ColorState
    
    var sliderForegroundColor: ColorState
    var sliderBackgroundColor: ColorState
    var sliderKnobColor: ColorState
    var sliderLoopSegmentColor: ColorState
    
    init(_ scheme: PlayerColorScheme) {
        
        self.primaryTextColor = ColorState.fromNSColor(scheme.primaryTextColor)
        self.secondaryTextColor = ColorState.fromNSColor(scheme.secondaryTextColor)
        
        self.sliderBackgroundColor = ColorState.fromNSColor(scheme.sliderBackgroundColor)
        self.sliderForegroundColor = ColorState.fromNSColor(scheme.sliderForegroundColor)
        self.sliderKnobColor = ColorState.fromNSColor(scheme.sliderKnobColor)
        self.sliderLoopSegmentColor = ColorState.fromNSColor(scheme.sliderLoopSegmentColor)
    }
}

class PlaylistColorSchemeState {
    
    var trackNameTextColor: ColorState
    var groupNameTextColor: ColorState
    var playlistIndexDurationTextColor: ColorState
    
    var trackNameSelectedTextColor: ColorState
    var groupNameSelectedTextColor: ColorState
    var playlistIndexDurationSelectedTextColor: ColorState
    
    var groupIconColor: ColorState
    var selectionBoxColor: ColorState
    var playingTrackIconColor: ColorState
    var summaryInfoColor: ColorState
    
    init(_ scheme: PlaylistColorScheme) {
        
        self.trackNameTextColor = ColorState.fromNSColor(scheme.trackNameTextColor)
        self.groupNameTextColor = ColorState.fromNSColor(scheme.groupNameTextColor)
        self.playlistIndexDurationTextColor = ColorState.fromNSColor(scheme.indexDurationTextColor)
        
        self.trackNameSelectedTextColor = ColorState.fromNSColor(scheme.trackNameSelectedTextColor)
        self.groupNameSelectedTextColor = ColorState.fromNSColor(scheme.groupNameSelectedTextColor)
        self.playlistIndexDurationSelectedTextColor = ColorState.fromNSColor(scheme.indexDurationSelectedTextColor)
        
        self.groupIconColor = ColorState.fromNSColor(scheme.groupIconColor)
        self.selectionBoxColor = ColorState.fromNSColor(scheme.selectionBoxColor)
        self.playingTrackIconColor = ColorState.fromNSColor(scheme.playingTrackIconColor)
        self.summaryInfoColor = ColorState.fromNSColor(scheme.summaryInfoColor)
    }
}

class EffectsColorSchemeState {
    
    init(_ scheme: EffectsColorScheme) {
        
    }
}
