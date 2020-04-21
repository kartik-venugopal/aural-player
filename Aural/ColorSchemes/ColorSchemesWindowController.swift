import Cocoa

class ColorSchemesWindowController: NSWindowController {
    
    // TODO: Store history of changes for each color (to allow Undo feature)
    @IBOutlet weak var playlistTabScrollView: NSScrollView!
    
    @IBOutlet weak var backgroundColorPicker: NSColorWell!
    
    @IBOutlet weak var controlButtonColorPicker: NSColorWell!
    @IBOutlet weak var controlButtonOffStateColorPicker: NSColorWell!
    
    @IBOutlet weak var logoTextColorPicker: NSColorWell!
    
    // Player colors
    
    @IBOutlet weak var primaryTextColorPicker: NSColorWell!
    @IBOutlet weak var secondaryTextColorPicker: NSColorWell!
    
    @IBOutlet weak var sliderBackgroundColorPicker: NSColorWell!
    @IBOutlet weak var sliderForegroundColorPicker: NSColorWell!
    @IBOutlet weak var sliderKnobColorPicker: NSColorWell!
    @IBOutlet weak var sliderLoopSegmentColorPicker: NSColorWell!
    
    // Playlist colors
    
    @IBOutlet weak var playlistTrackNameTextColorPicker: NSColorWell!
    @IBOutlet weak var playlistGroupNameTextColorPicker: NSColorWell!
    @IBOutlet weak var playlistIndexDurationTextColorPicker: NSColorWell!

    @IBOutlet weak var playlistTrackNameSelectedTextColorPicker: NSColorWell!
    @IBOutlet weak var playlistGroupNameSelectedTextColorPicker: NSColorWell!
    @IBOutlet weak var playlistIndexDurationSelectedTextColorPicker: NSColorWell!

    @IBOutlet weak var playlistGroupIconColorPicker: NSColorWell!
    @IBOutlet weak var playlistSelectionBoxColorPicker: NSColorWell!
    @IBOutlet weak var playlistPlayingTrackIconColorPicker: NSColorWell!
    @IBOutlet weak var playlistSummaryInfoColorPicker: NSColorWell!
    
    override var windowNibName: NSNib.Name? {return "ColorSchemes"}
    
    private var wm: WindowManagerProtocol = ObjectGraph.windowManager
    
    override func windowDidLoad() {
        
        NSColorPanel.shared.showsAlpha = true
        playlistTabScrollView.contentView.scroll(to: NSMakePoint(0, playlistTabScrollView.contentView.frame.height))
    }
    
    @IBAction func backgroundColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.backgroundColor = backgroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeBackgroundColor, backgroundColorPicker.color))
    }
    
    @IBAction func primaryTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.primaryTextColor = primaryTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePrimaryTextColor, primaryTextColorPicker.color))
    }
    
    @IBAction func secondaryTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.secondaryTextColor = secondaryTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeSecondaryTextColor, secondaryTextColorPicker.color))
    }
    
    @IBAction func controlButtonColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.controlButtonColor = controlButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeControlButtonColor, controlButtonColorPicker.color))
    }
    
    @IBAction func controlButtonOffStateColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.controlButtonOffStateColor = controlButtonOffStateColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeControlButtonOffStateColor, controlButtonOffStateColorPicker.color))
    }
    
    @IBAction func sliderBackgroundColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderBackgroundColor = sliderBackgroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderBackgroundColor, sliderBackgroundColorPicker.color))
    }
    
    @IBAction func sliderForegroundColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderForegroundColor = sliderForegroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderForegroundColor, sliderForegroundColorPicker.color))
    }
    
    @IBAction func sliderKnobColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderKnobColor = sliderKnobColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderKnobColor, sliderKnobColorPicker.color))
    }
    
    @IBAction func sliderLoopSegmentColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.player.sliderLoopSegmentColor = sliderLoopSegmentColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderLoopSegmentColor, sliderLoopSegmentColorPicker.color))
    }
    
    @IBAction func logoTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.logoTextColor = logoTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeLogoTextColor, logoTextColorPicker.color))
    }
    
    // MARK: Playlist color scheme actions ------------------------------------------------------------------------------------------------------------
    
    @IBAction func playlistTrackNameTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.trackNameTextColor = playlistTrackNameTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistTrackNameTextColor, playlistTrackNameTextColorPicker.color))
    }
    
    @IBAction func playlistGroupNameTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupNameTextColor = playlistGroupNameTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistGroupNameTextColor, playlistGroupNameTextColorPicker.color))
    }
    
    @IBAction func playlistIndexDurationTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.indexDurationTextColor = playlistIndexDurationTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistIndexDurationTextColor, playlistIndexDurationTextColorPicker.color))
    }
    
    @IBAction func playlistTrackNameSelectedTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.trackNameSelectedTextColor = playlistTrackNameSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistTrackNameSelectedTextColor, playlistTrackNameSelectedTextColorPicker.color))
    }
    
    @IBAction func playlistGroupNameSelectedTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupNameSelectedTextColor = playlistGroupNameSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistGroupNameSelectedTextColor, playlistGroupNameSelectedTextColorPicker.color))
    }
    
    @IBAction func playlistIndexDurationSelectedTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.indexDurationSelectedTextColor = playlistIndexDurationSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistIndexDurationSelectedTextColor, playlistIndexDurationSelectedTextColorPicker.color))
    }
    
    @IBAction func playlistGroupIconColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupIconColor = playlistGroupIconColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistGroupIconColor, playlistGroupIconColorPicker.color))
    }
    
    @IBAction func playlistSelectionBoxColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.selectionBoxColor = playlistSelectionBoxColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistSelectionBoxColor, playlistSelectionBoxColorPicker.color))
    }
    
    @IBAction func playlistPlayingTrackIconColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.playingTrackIconColor = playlistPlayingTrackIconColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistPlayingTrackIconColor, playlistPlayingTrackIconColorPicker.color))
    }
    
    @IBAction func playlistSummaryInfoColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.summaryInfoColor = playlistSummaryInfoColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistSummaryInfoColor, playlistSummaryInfoColorPicker.color))
    }
}
