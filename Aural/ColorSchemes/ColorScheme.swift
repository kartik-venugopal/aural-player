import Cocoa

class ColorScheme {
    
    var name: String

    var general: GeneralColorScheme
    var player: PlayerColorScheme
    var playlist: PlaylistColorScheme
    var effects: EffectsColorScheme
    
    func toString() -> String {
        return String(describing: JSONMapper.map(ColorSchemeState(self.name, self)))
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
        
        self.general.applyPreset(preset)
        self.player.applyPreset(preset)
        self.playlist.applyPreset(preset)
        self.effects.applyPreset(preset)
    }
    
    func applyScheme(_ scheme: ColorScheme) {
        
        self.general.applyScheme(scheme.general)
        self.player.applyScheme(scheme.player)
        self.playlist.applyScheme(scheme.playlist)
        self.effects.applyScheme(scheme.effects)
    }
    
    var persistentState: ColorSchemeState {
        return ColorSchemeState(self.name, self)
    }
}

class GeneralColorScheme {
    
    var appLogoColor: NSColor
    var backgroundColor: NSColor
    
    var viewControlButtonColor: NSColor
    var functionButtonColor: NSColor
    var textButtonMenuColor: NSColor
    var toggleButtonOffStateColor: NSColor
    var selectedTabButtonColor: NSColor
    
    var mainCaptionTextColor: NSColor
    var tabButtonTextColor: NSColor
    var selectedTabButtonTextColor: NSColor
    var buttonMenuTextColor: NSColor
    
    init(_ appState: GeneralColorSchemeState) {
        
        self.appLogoColor = appState.appLogoColor.toColor()
        self.backgroundColor = appState.backgroundColor.toColor()
        
        self.viewControlButtonColor = appState.viewControlButtonColor.toColor()
        self.functionButtonColor = appState.functionButtonColor.toColor()
        self.textButtonMenuColor = appState.textButtonMenuColor.toColor()
        self.toggleButtonOffStateColor = appState.toggleButtonOffStateColor.toColor()
        self.selectedTabButtonColor = appState.selectedTabButtonColor.toColor()
        
        self.mainCaptionTextColor = appState.mainCaptionTextColor.toColor()
        self.tabButtonTextColor = appState.tabButtonTextColor.toColor()
        self.selectedTabButtonTextColor = appState.selectedTabButtonTextColor.toColor()
        self.buttonMenuTextColor = appState.buttonMenuTextColor.toColor()
    }
    
    convenience init() {
        self.init(ColorSchemePreset.defaultScheme)
    }
   
    init(_ preset: ColorSchemePreset) {
        
        self.appLogoColor = preset.appLogoColor
        self.backgroundColor = preset.backgroundColor
        
        self.viewControlButtonColor = preset.viewControlButtonColor
        self.functionButtonColor = preset.functionButtonColor
        self.textButtonMenuColor = preset.textButtonMenuColor
        self.toggleButtonOffStateColor = preset.toggleButtonOffStateColor
        self.selectedTabButtonColor = preset.selectedTabButtonColor
        
        self.mainCaptionTextColor = preset.mainCaptionTextColor
        self.tabButtonTextColor = preset.tabButtonTextColor
        self.selectedTabButtonTextColor = preset.selectedTabButtonTextColor
        self.buttonMenuTextColor = preset.buttonMenuTextColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.appLogoColor = preset.appLogoColor
        self.backgroundColor = preset.backgroundColor
        
        self.viewControlButtonColor = preset.viewControlButtonColor
        self.functionButtonColor = preset.functionButtonColor
        self.textButtonMenuColor = preset.textButtonMenuColor
        self.toggleButtonOffStateColor = preset.toggleButtonOffStateColor
        self.selectedTabButtonColor = preset.selectedTabButtonColor
        
        self.mainCaptionTextColor = preset.mainCaptionTextColor
        self.tabButtonTextColor = preset.tabButtonTextColor
        self.selectedTabButtonTextColor = preset.selectedTabButtonTextColor
        self.buttonMenuTextColor = preset.buttonMenuTextColor
    }
    
    func applyScheme(_ scheme: GeneralColorScheme) {
        
        self.appLogoColor = scheme.appLogoColor
        self.backgroundColor = scheme.backgroundColor
        
        self.viewControlButtonColor = scheme.viewControlButtonColor
        self.functionButtonColor = scheme.functionButtonColor
        self.textButtonMenuColor = scheme.textButtonMenuColor
        self.toggleButtonOffStateColor = scheme.toggleButtonOffStateColor
        self.selectedTabButtonColor = scheme.selectedTabButtonColor
        
        self.mainCaptionTextColor = scheme.mainCaptionTextColor
        self.tabButtonTextColor = scheme.tabButtonTextColor
        self.selectedTabButtonTextColor = scheme.selectedTabButtonTextColor
        self.buttonMenuTextColor = scheme.buttonMenuTextColor
    }
    
    func clone() -> GeneralColorScheme {
        
        let copy = GeneralColorScheme()
        
        copy.appLogoColor = self.appLogoColor
        copy.backgroundColor = self.backgroundColor
        
        copy.viewControlButtonColor = self.viewControlButtonColor
        copy.functionButtonColor = self.functionButtonColor
        copy.textButtonMenuColor = self.textButtonMenuColor
        copy.toggleButtonOffStateColor = self.toggleButtonOffStateColor
        copy.selectedTabButtonColor = self.selectedTabButtonColor
        
        copy.mainCaptionTextColor = self.mainCaptionTextColor
        copy.tabButtonTextColor = self.tabButtonTextColor
        copy.selectedTabButtonTextColor = self.selectedTabButtonTextColor
        copy.buttonMenuTextColor = self.buttonMenuTextColor
        
        return copy
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
    
    // TODO: Remove all these didSets. This is a bug (should only be called if this scheme is the system scheme) ! Move this code to the Color Schemes UI view controller.
    
    var sliderBackgroundColor: NSColor {
    
        didSet {
            Colors.Player.updateSliderBackgroundColor()
        }
    }
    
    var sliderBackgroundGradientType: GradientType {
        
        didSet {
            Colors.Player.updateSliderBackgroundColor()
        }
    }
    
    var sliderBackgroundGradientAmount: Int {
        
        didSet {
            Colors.Player.updateSliderBackgroundColor()
        }
    }
    
    var sliderForegroundColor: NSColor {
        
        didSet {
            Colors.Player.updateSliderForegroundColor()
        }
    }
    
    var sliderForegroundGradientType: GradientType {
        
        didSet {
            Colors.Player.updateSliderForegroundColor()
        }
    }
    
    var sliderForegroundGradientAmount: Int {
        
        didSet {
            Colors.Player.updateSliderForegroundColor()
        }
    }
    
    var sliderKnobColor: NSColor
    var sliderKnobColorSameAsForeground: Bool
    var sliderLoopSegmentColor: NSColor
    
    init(_ appState: PlayerColorSchemeState) {
        
        self.trackInfoPrimaryTextColor = appState.trackInfoPrimaryTextColor.toColor()
        self.trackInfoSecondaryTextColor = appState.trackInfoSecondaryTextColor.toColor()
        self.trackInfoTertiaryTextColor = appState.trackInfoTertiaryTextColor.toColor()
        self.sliderValueTextColor = appState.sliderValueTextColor.toColor()
        
        self.sliderBackgroundColor = appState.sliderBackgroundColor.toColor()
        self.sliderBackgroundGradientType = appState.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = appState.sliderBackgroundGradientAmount
        
        self.sliderForegroundColor = appState.sliderForegroundColor.toColor()
        self.sliderForegroundGradientType = appState.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = appState.sliderForegroundGradientAmount
        
        self.sliderKnobColor = appState.sliderKnobColor.toColor()
        self.sliderKnobColorSameAsForeground = appState.sliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = appState.sliderLoopSegmentColor.toColor()
    }
    
    convenience init() {
        self.init(ColorSchemePreset.defaultScheme)
    }
    
    init(_ preset: ColorSchemePreset) {
        
        self.trackInfoPrimaryTextColor = preset.playerTrackInfoPrimaryTextColor
        self.trackInfoSecondaryTextColor = preset.playerTrackInfoSecondaryTextColor
        self.trackInfoTertiaryTextColor = preset.playerTrackInfoTertiaryTextColor
        self.sliderValueTextColor = preset.playerSliderValueTextColor
        
        self.sliderBackgroundColor = preset.playerSliderBackgroundColor
        self.sliderBackgroundGradientType = preset.playerSliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = preset.playerSliderBackgroundGradientAmount
        
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
        self.sliderBackgroundGradientType = preset.playerSliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = preset.playerSliderBackgroundGradientAmount
        
        self.sliderForegroundColor = preset.playerSliderForegroundColor
        self.sliderForegroundGradientType = preset.playerSliderForegroundGradientType
        self.sliderForegroundGradientAmount = preset.playerSliderForegroundGradientAmount
        
        self.sliderKnobColor = preset.playerSliderKnobColor
        self.sliderKnobColorSameAsForeground = preset.playerSliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = preset.playerSliderLoopSegmentColor
    }
    
    func applyScheme(_ scheme: PlayerColorScheme) {

        self.trackInfoPrimaryTextColor = scheme.trackInfoPrimaryTextColor
        self.trackInfoSecondaryTextColor = scheme.trackInfoSecondaryTextColor
        self.trackInfoTertiaryTextColor = scheme.trackInfoTertiaryTextColor
        self.sliderValueTextColor = scheme.sliderValueTextColor
        
        self.sliderBackgroundColor = scheme.sliderBackgroundColor
        self.sliderBackgroundGradientType = scheme.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = scheme.sliderBackgroundGradientAmount
        
        self.sliderForegroundColor = scheme.sliderForegroundColor
        self.sliderForegroundGradientType = scheme.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = scheme.sliderForegroundGradientAmount
        
        self.sliderKnobColor = scheme.sliderKnobColor
        self.sliderKnobColorSameAsForeground = scheme.sliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = scheme.sliderLoopSegmentColor
    }
    
    func clone() -> PlayerColorScheme {
        
        let copy = PlayerColorScheme()
        
        copy.trackInfoPrimaryTextColor = self.trackInfoPrimaryTextColor
        copy.trackInfoSecondaryTextColor = self.trackInfoSecondaryTextColor
        copy.trackInfoTertiaryTextColor = self.trackInfoTertiaryTextColor
        copy.sliderValueTextColor = self.sliderValueTextColor
        
        copy.sliderBackgroundColor = self.sliderBackgroundColor
        copy.sliderBackgroundGradientType = self.sliderBackgroundGradientType
        copy.sliderBackgroundGradientAmount = self.sliderBackgroundGradientAmount
        
        copy.sliderForegroundColor = self.sliderForegroundColor
        copy.sliderForegroundGradientType = self.sliderForegroundGradientType
        copy.sliderForegroundGradientAmount = self.sliderForegroundGradientAmount
        
        copy.sliderKnobColor = self.sliderKnobColor
        copy.sliderKnobColorSameAsForeground = self.sliderKnobColorSameAsForeground
        copy.sliderLoopSegmentColor = self.sliderLoopSegmentColor
        
        return copy
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
    
    convenience init() {
        self.init(ColorSchemePreset.defaultScheme)
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
    
    func applyScheme(_ scheme: PlaylistColorScheme) {
        
        self.trackNameTextColor = scheme.trackNameTextColor
        self.groupNameTextColor = scheme.groupNameTextColor
        self.indexDurationTextColor = scheme.indexDurationTextColor
        
        self.trackNameSelectedTextColor = scheme.trackNameSelectedTextColor
        self.groupNameSelectedTextColor = scheme.groupNameSelectedTextColor
        self.indexDurationSelectedTextColor = scheme.indexDurationSelectedTextColor
        
        self.summaryInfoColor = scheme.summaryInfoColor
        
        self.selectionBoxColor = scheme.selectionBoxColor
        self.playingTrackIconColor = scheme.playingTrackIconColor
        
        self.groupIconColor = scheme.groupIconColor
        self.groupDisclosureTriangleColor = scheme.groupDisclosureTriangleColor
    }
    
    func clone() -> PlaylistColorScheme {
        
        let copy = PlaylistColorScheme()
        
        copy.trackNameTextColor = self.trackNameTextColor
        copy.groupNameTextColor = self.groupNameTextColor
        copy.indexDurationTextColor = self.indexDurationTextColor
        
        copy.trackNameSelectedTextColor = self.trackNameSelectedTextColor
        copy.groupNameSelectedTextColor = self.groupNameSelectedTextColor
        copy.indexDurationSelectedTextColor = self.indexDurationSelectedTextColor
        
        copy.summaryInfoColor = self.summaryInfoColor
        
        copy.selectionBoxColor = self.selectionBoxColor
        copy.playingTrackIconColor = self.playingTrackIconColor
        
        copy.groupIconColor = self.groupIconColor
        copy.groupDisclosureTriangleColor = self.groupDisclosureTriangleColor
        
        return copy
    }
    
    var persistentState: PlaylistColorSchemeState {
        return PlaylistColorSchemeState(self)
    }
}

class EffectsColorScheme {
    
    var functionCaptionTextColor: NSColor
    var functionValueTextColor: NSColor
    
    var sliderBackgroundColor: NSColor
    var sliderBackgroundGradientType: GradientType
    var sliderBackgroundGradientAmount: Int
    
    var sliderForegroundGradientType: GradientType
    var sliderForegroundGradientAmount: Int
    
    var sliderKnobColor: NSColor
    var sliderKnobColorSameAsForeground: Bool
    
    var sliderTickColor: NSColor
    
    var activeUnitStateColor: NSColor
    var bypassedUnitStateColor: NSColor
    var suppressedUnitStateColor: NSColor
    
    init(_ appState: EffectsColorSchemeState) {
        
        self.functionCaptionTextColor = appState.functionCaptionTextColor.toColor()
        self.functionValueTextColor = appState.functionValueTextColor.toColor()
        
        self.sliderBackgroundColor = appState.sliderBackgroundColor.toColor()
        self.sliderBackgroundGradientType = appState.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = appState.sliderBackgroundGradientAmount
        
        self.sliderForegroundGradientType = appState.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = appState.sliderForegroundGradientAmount
        
        self.sliderKnobColor = appState.sliderKnobColor.toColor()
        self.sliderKnobColorSameAsForeground = appState.sliderKnobColorSameAsForeground
        
        self.sliderTickColor = appState.sliderTickColor.toColor()
        
        self.activeUnitStateColor = appState.activeUnitStateColor.toColor()
        self.bypassedUnitStateColor = appState.bypassedUnitStateColor.toColor()
        self.suppressedUnitStateColor = appState.suppressedUnitStateColor.toColor()
    }
    
    convenience init() {
        self.init(ColorSchemePreset.defaultScheme)
    }
    
    init(_ preset: ColorSchemePreset) {
        
        self.functionCaptionTextColor = preset.effectsFunctionCaptionTextColor
        self.functionValueTextColor = preset.effectsFunctionValueTextColor
        
        self.sliderBackgroundColor = preset.effectsSliderBackgroundColor
        self.sliderBackgroundGradientType = preset.effectsSliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = preset.effectsSliderBackgroundGradientAmount
        
        self.sliderForegroundGradientType = preset.effectsSliderForegroundGradientType
        self.sliderForegroundGradientAmount = preset.effectsSliderForegroundGradientAmount
        
        self.sliderKnobColor = preset.effectsSliderKnobColor
        self.sliderKnobColorSameAsForeground = preset.effectsSliderKnobColorSameAsForeground
        
        self.sliderTickColor = preset.effectsSliderTickColor
        
        self.activeUnitStateColor = preset.effectsActiveUnitStateColor
        self.bypassedUnitStateColor = preset.effectsBypassedUnitStateColor
        self.suppressedUnitStateColor = preset.effectsSuppressedUnitStateColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {

        self.functionCaptionTextColor = preset.effectsFunctionCaptionTextColor
        self.functionValueTextColor = preset.effectsFunctionValueTextColor
        
        self.sliderBackgroundColor = preset.effectsSliderBackgroundColor
        self.sliderBackgroundGradientType = preset.effectsSliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = preset.effectsSliderBackgroundGradientAmount
        
        self.sliderForegroundGradientType = preset.effectsSliderForegroundGradientType
        self.sliderForegroundGradientAmount = preset.effectsSliderForegroundGradientAmount
        
        self.sliderKnobColor = preset.effectsSliderKnobColor
        self.sliderKnobColorSameAsForeground = preset.effectsSliderKnobColorSameAsForeground
        
        self.sliderTickColor = preset.effectsSliderTickColor
        
        self.activeUnitStateColor = preset.effectsActiveUnitStateColor
        self.bypassedUnitStateColor = preset.effectsBypassedUnitStateColor
        self.suppressedUnitStateColor = preset.effectsSuppressedUnitStateColor
    }
    
    func applyScheme(_ scheme: EffectsColorScheme) {
        
        self.functionCaptionTextColor = scheme.functionCaptionTextColor
        self.functionValueTextColor = scheme.functionValueTextColor
        
        self.sliderBackgroundColor = scheme.sliderBackgroundColor
        self.sliderBackgroundGradientType = scheme.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = scheme.sliderBackgroundGradientAmount
        
        self.sliderForegroundGradientType = scheme.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = scheme.sliderForegroundGradientAmount
        
        self.sliderKnobColor = scheme.sliderKnobColor
        self.sliderKnobColorSameAsForeground = scheme.sliderKnobColorSameAsForeground
        
        self.sliderTickColor = scheme.sliderTickColor
        
        self.activeUnitStateColor = scheme.activeUnitStateColor
        self.bypassedUnitStateColor = scheme.bypassedUnitStateColor
        self.suppressedUnitStateColor = scheme.suppressedUnitStateColor
    }
    
    func clone() -> EffectsColorScheme {
        
        let copy = EffectsColorScheme()
        
        copy.functionCaptionTextColor = self.functionCaptionTextColor
        copy.functionValueTextColor = self.functionValueTextColor
        
        copy.sliderBackgroundColor = self.sliderBackgroundColor
        copy.sliderBackgroundGradientType = self.sliderBackgroundGradientType
        copy.sliderBackgroundGradientAmount = self.sliderBackgroundGradientAmount
        
        copy.sliderForegroundGradientType = self.sliderForegroundGradientType
        copy.sliderForegroundGradientAmount = self.sliderForegroundGradientAmount
        
        copy.sliderKnobColor = self.sliderKnobColor
        copy.sliderKnobColorSameAsForeground = self.sliderKnobColorSameAsForeground
        
        copy.sliderTickColor = self.sliderTickColor
        
        copy.activeUnitStateColor = self.activeUnitStateColor
        copy.bypassedUnitStateColor = self.bypassedUnitStateColor
        copy.suppressedUnitStateColor = self.suppressedUnitStateColor
        
        return copy
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
