import Cocoa

class PlaylistColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!

    @IBOutlet weak var trackNameTextColorPicker: NSColorWell!
    @IBOutlet weak var groupNameTextColorPicker: NSColorWell!
    @IBOutlet weak var indexDurationTextColorPicker: NSColorWell!

    @IBOutlet weak var trackNameSelectedTextColorPicker: NSColorWell!
    @IBOutlet weak var groupNameSelectedTextColorPicker: NSColorWell!
    @IBOutlet weak var indexDurationSelectedTextColorPicker: NSColorWell!

    @IBOutlet weak var groupIconColorPicker: NSColorWell!
    @IBOutlet weak var selectionBoxColorPicker: NSColorWell!
    @IBOutlet weak var playingTrackIconColorPicker: NSColorWell!
    @IBOutlet weak var summaryInfoColorPicker: NSColorWell!
    
    override var nibName: NSNib.Name? {return "PlaylistColorScheme"}
    
    @IBAction func playlistTrackNameTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.trackNameTextColor = trackNameTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistTrackNameTextColor, trackNameTextColorPicker.color))
    }
    
    @IBAction func playlistGroupNameTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupNameTextColor = groupNameTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistGroupNameTextColor, groupNameTextColorPicker.color))
    }
    
    @IBAction func playlistIndexDurationTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.indexDurationTextColor = indexDurationTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistIndexDurationTextColor, indexDurationTextColorPicker.color))
    }
    
    @IBAction func playlistTrackNameSelectedTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.trackNameSelectedTextColor = trackNameSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistTrackNameSelectedTextColor, trackNameSelectedTextColorPicker.color))
    }
    
    @IBAction func playlistGroupNameSelectedTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupNameSelectedTextColor = groupNameSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistGroupNameSelectedTextColor, groupNameSelectedTextColorPicker.color))
    }
    
    @IBAction func playlistIndexDurationSelectedTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.indexDurationSelectedTextColor = indexDurationSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistIndexDurationSelectedTextColor, indexDurationSelectedTextColorPicker.color))
    }
    
    @IBAction func playlistGroupIconColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupIconColor = groupIconColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistGroupIconColor, groupIconColorPicker.color))
    }
    
    @IBAction func playlistSelectionBoxColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.selectionBoxColor = selectionBoxColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistSelectionBoxColor, selectionBoxColorPicker.color))
    }
    
    @IBAction func playlistPlayingTrackIconColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.playingTrackIconColor = playingTrackIconColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistPlayingTrackIconColor, playingTrackIconColorPicker.color))
    }
    
    @IBAction func playlistSummaryInfoColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.summaryInfoColor = summaryInfoColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistSummaryInfoColor, summaryInfoColorPicker.color))
    }
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    func resetFields(_ scheme: ColorScheme) {
        
        scrollToTop()
    }
    
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
}
