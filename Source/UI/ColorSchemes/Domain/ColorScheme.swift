import Cocoa

/*
    Encapsulates all colors that determine a color scheme that can be appplied to the entire application.
 */
class ColorScheme: StringKeyedItem {
    
    // Displayed name
    var name: String
    
    var key: String {
        
        get {
            return name
        }
        
        set(newValue) {
            name = newValue
        }
    }

    // False if defined by the user
    let systemDefined: Bool

    var general: GeneralColorScheme
    var player: PlayerColorScheme
    var playlist: PlaylistColorScheme
    var effects: EffectsColorScheme
    
    // Utility function (for debugging purposes only)
    func toString() -> String {
        return String(describing: JSONMapper.map(ColorSchemeState(self)))
    }
    
    // Copy constructor ... creates a copy of the given scheme (used when creating a user-defined preset)
    init(_ name: String, _ systemDefined: Bool, _ scheme: ColorScheme) {
    
        self.name = name
        self.systemDefined = systemDefined
        
        self.general = scheme.general.clone()
        self.player = scheme.player.clone()
        self.playlist = scheme.playlist.clone()
        self.effects = scheme.effects.clone()
    }
    
    // Used when loading app state on startup
    init(_ appState: ColorSchemeState?, _ systemDefined: Bool) {
        
        self.name = appState?.name ?? ""
        self.systemDefined = systemDefined
        
        self.general = GeneralColorScheme(appState?.general)
        self.player = PlayerColorScheme(appState?.player)
        self.playlist = PlaylistColorScheme(appState?.playlist)
        self.effects = EffectsColorScheme(appState?.effects)
    }
    
    // Creates a scheme from a preset (eg. default scheme)
    init(_ name: String, _ preset: ColorSchemePreset) {
        
        self.name = name
        self.systemDefined = true
        
        self.general = GeneralColorScheme(preset)
        self.player = PlayerColorScheme(preset)
        self.playlist = PlaylistColorScheme(preset)
        self.effects = EffectsColorScheme(preset)
    }
    
    // Applies a system-defined preset to this scheme.
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.general.applyPreset(preset)
        self.player.applyPreset(preset)
        self.playlist.applyPreset(preset)
        self.effects.applyPreset(preset)
    }
    
    // Applies another color scheme to this scheme.
    func applyScheme(_ scheme: ColorScheme) {
        
        self.general.applyScheme(scheme.general)
        self.player.applyScheme(scheme.player)
        self.playlist.applyScheme(scheme.playlist)
        self.effects.applyScheme(scheme.effects)
    }
    
    // Creates an identical copy of this color scheme
    func clone() -> ColorScheme {
        return ColorScheme(self.name + "_clone", self.systemDefined, self)
    }
    
    // State that can be persisted to disk
    var persistentState: ColorSchemeState {
        return ColorSchemeState(self)
    }
}

/*
    Encapsulates color values that are generally applicable to the entire UI, e.g. window background color.
 */
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
    
    init(_ appState: GeneralColorSchemeState?) {
        
        self.appLogoColor = appState?.appLogoColor?.toColor() ?? ColorSchemes.defaultScheme.general.appLogoColor
        self.backgroundColor = appState?.backgroundColor?.toColor() ?? ColorSchemes.defaultScheme.general.backgroundColor
        
        self.viewControlButtonColor = appState?.viewControlButtonColor?.toColor() ?? ColorSchemes.defaultScheme.general.viewControlButtonColor
        
        self.functionButtonColor = appState?.functionButtonColor?.toColor() ?? ColorSchemes.defaultScheme.general.functionButtonColor
        
        self.textButtonMenuColor = appState?.textButtonMenuColor?.toColor() ?? ColorSchemes.defaultScheme.general.textButtonMenuColor
        
        self.toggleButtonOffStateColor = appState?.toggleButtonOffStateColor?.toColor() ?? ColorSchemes.defaultScheme.general.toggleButtonOffStateColor
        
        self.selectedTabButtonColor = appState?.selectedTabButtonColor?.toColor() ?? ColorSchemes.defaultScheme.general.selectedTabButtonColor
        
        self.mainCaptionTextColor = appState?.mainCaptionTextColor?.toColor() ?? ColorSchemes.defaultScheme.general.mainCaptionTextColor
        
        self.tabButtonTextColor = appState?.tabButtonTextColor?.toColor() ?? ColorSchemes.defaultScheme.general.tabButtonTextColor
        
        self.selectedTabButtonTextColor = appState?.selectedTabButtonTextColor?.toColor() ?? ColorSchemes.defaultScheme.general.selectedTabButtonTextColor
        
        self.buttonMenuTextColor = appState?.buttonMenuTextColor?.toColor() ?? ColorSchemes.defaultScheme.general.buttonMenuTextColor
    }
    
    init(_ scheme: GeneralColorScheme) {
        
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
        return GeneralColorScheme(self)
    }
    
    var persistentState: GeneralColorSchemeState {
        return GeneralColorSchemeState(self)
    }
}

/*
    Encapsulates color values that are applicable to the player UI, e.g. color of the track title.
 */
class PlayerColorScheme {
    
    var trackInfoPrimaryTextColor: NSColor
    var trackInfoSecondaryTextColor: NSColor
    var trackInfoTertiaryTextColor: NSColor
    var sliderValueTextColor: NSColor
    
    var sliderBackgroundColor: NSColor
    var sliderBackgroundGradientType: GradientType
    var sliderBackgroundGradientAmount: Int
    
    var sliderForegroundColor: NSColor
    var sliderForegroundGradientType: GradientType
    var sliderForegroundGradientAmount: Int
    
    var sliderKnobColor: NSColor
    var sliderKnobColorSameAsForeground: Bool
    var sliderLoopSegmentColor: NSColor
    
    init(_ appState: PlayerColorSchemeState?) {
        
        self.trackInfoPrimaryTextColor = appState?.trackInfoPrimaryTextColor?.toColor() ?? ColorSchemes.defaultScheme.player.trackInfoPrimaryTextColor
        
        self.trackInfoSecondaryTextColor = appState?.trackInfoSecondaryTextColor?.toColor() ?? ColorSchemes.defaultScheme.player.trackInfoSecondaryTextColor
        
        self.trackInfoTertiaryTextColor = appState?.trackInfoTertiaryTextColor?.toColor() ?? ColorSchemes.defaultScheme.player.trackInfoTertiaryTextColor
        
        self.sliderValueTextColor = appState?.sliderValueTextColor?.toColor() ?? ColorSchemes.defaultScheme.player.sliderValueTextColor
        
        self.sliderBackgroundColor = appState?.sliderBackgroundColor?.toColor() ?? ColorSchemes.defaultScheme.player.sliderBackgroundColor
        
        self.sliderBackgroundGradientType = appState?.sliderBackgroundGradientType ?? ColorSchemes.defaultScheme.player.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = appState?.sliderBackgroundGradientAmount ?? ColorSchemes.defaultScheme.player.sliderBackgroundGradientAmount
        
        self.sliderForegroundColor = appState?.sliderForegroundColor?.toColor() ?? ColorSchemes.defaultScheme.player.sliderForegroundColor
        
        self.sliderForegroundGradientType = appState?.sliderForegroundGradientType ?? ColorSchemes.defaultScheme.player.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = appState?.sliderForegroundGradientAmount ?? ColorSchemes.defaultScheme.player.sliderForegroundGradientAmount
        
        self.sliderKnobColor = appState?.sliderKnobColor?.toColor() ?? ColorSchemes.defaultScheme.player.sliderKnobColor
        self.sliderKnobColorSameAsForeground = appState?.sliderKnobColorSameAsForeground ?? ColorSchemes.defaultScheme.player.sliderKnobColorSameAsForeground
        
        self.sliderLoopSegmentColor = appState?.sliderLoopSegmentColor?.toColor() ?? ColorSchemes.defaultScheme.player.sliderLoopSegmentColor
    }
    
    init(_ scheme: PlayerColorScheme) {
        
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
        return PlayerColorScheme(self)
    }

    var persistentState: PlayerColorSchemeState {
        return PlayerColorSchemeState(self)
    }
}

/*
    Encapsulates color values that are applicable to the playlist UI, e.g. color of the track name or duration.
 */
class PlaylistColorScheme {
    
    var trackNameTextColor: NSColor
    var groupNameTextColor: NSColor
    var indexDurationTextColor: NSColor
    
    var trackNameSelectedTextColor: NSColor
    var groupNameSelectedTextColor: NSColor
    var indexDurationSelectedTextColor: NSColor
    
    var summaryInfoColor: NSColor
    
    var playingTrackIconColor: NSColor
    var playingTrackIconSelectedRowsColor: NSColor
    
    var selectionBoxColor: NSColor
    
    var groupIconColor: NSColor
    var groupIconSelectedRowsColor: NSColor
    
    var groupDisclosureTriangleColor: NSColor
    var groupDisclosureTriangleSelectedRowsColor: NSColor
    
    init(_ appState: PlaylistColorSchemeState?) {
        
        self.trackNameTextColor = appState?.trackNameTextColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.trackNameTextColor
        self.groupNameTextColor = appState?.groupNameTextColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.groupNameTextColor
        self.indexDurationTextColor = appState?.indexDurationTextColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.indexDurationTextColor
        
        self.trackNameSelectedTextColor = appState?.trackNameSelectedTextColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.trackNameSelectedTextColor
        
        self.groupNameSelectedTextColor = appState?.groupNameSelectedTextColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.groupNameSelectedTextColor
        
        self.indexDurationSelectedTextColor = appState?.indexDurationSelectedTextColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.indexDurationSelectedTextColor
        
        self.summaryInfoColor = appState?.summaryInfoColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.summaryInfoColor
        
        self.selectionBoxColor = appState?.selectionBoxColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.selectionBoxColor
        
        self.playingTrackIconColor = appState?.playingTrackIconColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.playingTrackIconColor
        
        self.playingTrackIconSelectedRowsColor = appState?.playingTrackIconSelectedRowsColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.playingTrackIconSelectedRowsColor
        
        self.groupIconColor = appState?.groupIconColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.groupIconColor
        
        self.groupIconSelectedRowsColor = appState?.groupIconSelectedRowsColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.groupIconSelectedRowsColor
        
        self.groupDisclosureTriangleColor = appState?.groupDisclosureTriangleColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.groupDisclosureTriangleColor
        
        self.groupDisclosureTriangleSelectedRowsColor = appState?.groupDisclosureTriangleSelectedRowsColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.groupDisclosureTriangleSelectedRowsColor
    }
    
    init(_ scheme: PlaylistColorScheme) {
        
        self.trackNameTextColor = scheme.trackNameTextColor
        self.groupNameTextColor = scheme.groupNameTextColor
        self.indexDurationTextColor = scheme.indexDurationTextColor
        
        self.trackNameSelectedTextColor = scheme.trackNameSelectedTextColor
        self.groupNameSelectedTextColor = scheme.groupNameSelectedTextColor
        self.indexDurationSelectedTextColor = scheme.indexDurationSelectedTextColor
        
        self.summaryInfoColor = scheme.summaryInfoColor
        
        self.selectionBoxColor = scheme.selectionBoxColor
        self.playingTrackIconColor = scheme.playingTrackIconColor
        self.playingTrackIconSelectedRowsColor = scheme.playingTrackIconSelectedRowsColor
        
        self.groupIconColor = scheme.groupIconColor
        self.groupIconSelectedRowsColor = scheme.groupIconSelectedRowsColor
        
        self.groupDisclosureTriangleColor = scheme.groupDisclosureTriangleColor
        self.groupDisclosureTriangleSelectedRowsColor = scheme.groupDisclosureTriangleSelectedRowsColor
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
        self.playingTrackIconSelectedRowsColor = preset.playlistPlayingTrackIconSelectedRowsColor
        
        self.groupIconColor = preset.playlistGroupIconColor
        self.groupIconSelectedRowsColor = preset.playlistGroupIconSelectedRowsColor
        
        self.groupDisclosureTriangleColor = preset.playlistGroupDisclosureTriangleColor
        self.groupDisclosureTriangleSelectedRowsColor = preset.playlistGroupDisclosureTriangleSelectedRowsColor
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
        return PlaylistColorScheme(self)
    }
    
    var persistentState: PlaylistColorSchemeState {
        return PlaylistColorSchemeState(self)
    }
}

/*
    Encapsulates color values that are applicable to the effects panel UI, e.g. color of the sliders.
 */
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
    
    init(_ appState: EffectsColorSchemeState?) {
        
        self.functionCaptionTextColor = appState?.functionCaptionTextColor?.toColor() ?? ColorSchemes.defaultScheme.effects.functionCaptionTextColor
        self.functionValueTextColor = appState?.functionValueTextColor?.toColor() ?? ColorSchemes.defaultScheme.effects.functionValueTextColor
        
        self.sliderBackgroundColor = appState?.sliderBackgroundColor?.toColor() ?? ColorSchemes.defaultScheme.effects.sliderBackgroundColor
        self.sliderBackgroundGradientType = appState?.sliderBackgroundGradientType ?? ColorSchemes.defaultScheme.effects.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = appState?.sliderBackgroundGradientAmount ?? ColorSchemes.defaultScheme.effects.sliderBackgroundGradientAmount
        
        self.sliderForegroundGradientType = appState?.sliderForegroundGradientType ?? ColorSchemes.defaultScheme.effects.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = appState?.sliderForegroundGradientAmount ?? ColorSchemes.defaultScheme.effects.sliderForegroundGradientAmount
        
        self.sliderKnobColor = appState?.sliderKnobColor?.toColor() ?? ColorSchemes.defaultScheme.effects.sliderKnobColor
        self.sliderKnobColorSameAsForeground = appState?.sliderKnobColorSameAsForeground ?? ColorSchemes.defaultScheme.effects.sliderKnobColorSameAsForeground
        
        self.sliderTickColor = appState?.sliderTickColor?.toColor() ?? ColorSchemes.defaultScheme.effects.sliderTickColor
        
        self.activeUnitStateColor = appState?.activeUnitStateColor?.toColor() ?? ColorSchemes.defaultScheme.effects.activeUnitStateColor
        self.bypassedUnitStateColor = appState?.bypassedUnitStateColor?.toColor() ?? ColorSchemes.defaultScheme.effects.bypassedUnitStateColor
        self.suppressedUnitStateColor = appState?.suppressedUnitStateColor?.toColor() ?? ColorSchemes.defaultScheme.effects.suppressedUnitStateColor
    }
    
    init(_ scheme: EffectsColorScheme) {
        
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
        return EffectsColorScheme(self)
    }
    
    var persistentState: EffectsColorSchemeState {
        return EffectsColorSchemeState(self)
    }
}

/*
    Enumerates all different types of gradients that can be applied to colors in a color scheme.
 */
enum GradientType: String {
    
    case none
    case darken
    case brighten
}

// A contract for any UI component that marks it as being able to apply a color scheme to itself.
protocol ColorSchemeable {
    
    // Apply the given color scheme to this component.
    func applyColorScheme(_ scheme: ColorScheme)
}
