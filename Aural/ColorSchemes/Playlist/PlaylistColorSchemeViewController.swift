import Cocoa

class PlaylistColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!

    @IBOutlet weak var trackNameTextColorPicker: NSColorWell!
    @IBOutlet weak var groupNameTextColorPicker: NSColorWell!
    @IBOutlet weak var indexDurationTextColorPicker: NSColorWell!

    @IBOutlet weak var trackNameSelectedTextColorPicker: NSColorWell!
    @IBOutlet weak var groupNameSelectedTextColorPicker: NSColorWell!
    @IBOutlet weak var indexDurationSelectedTextColorPicker: NSColorWell!
    
    @IBOutlet weak var summaryInfoColorPicker: NSColorWell!

    @IBOutlet weak var groupIconColorPicker: NSColorWell!
    @IBOutlet weak var groupDisclosureTriangleColorPicker: NSColorWell!
    
    @IBOutlet weak var selectionBoxColorPicker: NSColorWell!
    @IBOutlet weak var playingTrackIconColorPicker: NSColorWell!
    
    
    override var nibName: NSNib.Name? {return "PlaylistColorScheme"}
    
    @IBAction func trackNameTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.trackNameTextColor = trackNameTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistTrackNameTextColor, trackNameTextColorPicker.color))
    }
    
    @IBAction func groupNameTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupNameTextColor = groupNameTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistGroupNameTextColor, groupNameTextColorPicker.color))
    }
    
    @IBAction func indexDurationTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.indexDurationTextColor = indexDurationTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistIndexDurationTextColor, indexDurationTextColorPicker.color))
    }
    
    @IBAction func trackNameSelectedTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.trackNameSelectedTextColor = trackNameSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistTrackNameSelectedTextColor, trackNameSelectedTextColorPicker.color))
    }
    
    @IBAction func groupNameSelectedTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupNameSelectedTextColor = groupNameSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistGroupNameSelectedTextColor, groupNameSelectedTextColorPicker.color))
    }
    
    @IBAction func indexDurationSelectedTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.indexDurationSelectedTextColor = indexDurationSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistIndexDurationSelectedTextColor, indexDurationSelectedTextColorPicker.color))
    }
    
    @IBAction func groupIconColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupIconColor = groupIconColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistGroupIconColor, groupIconColorPicker.color))
    }
    
    @IBAction func groupDisclosureTriangleColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupDisclosureTriangleColor = groupDisclosureTriangleColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistGroupDisclosureTriangleColor, groupDisclosureTriangleColorPicker.color))
    }
    
    @IBAction func selectionBoxColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.selectionBoxColor = selectionBoxColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistSelectionBoxColor, selectionBoxColorPicker.color))
    }
    
    @IBAction func playingTrackIconColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.playingTrackIconColor = playingTrackIconColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlaylistPlayingTrackIconColor, playingTrackIconColorPicker.color))
    }
    
    @IBAction func summaryInfoColorAction(_ sender: Any) {
        
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
