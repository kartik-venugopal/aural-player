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
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    func resetFields(_ scheme: ColorScheme) {
        
        trackNameTextColorPicker.color = scheme.playlist.trackNameTextColor
        groupNameTextColorPicker.color = scheme.playlist.groupNameTextColor
        indexDurationTextColorPicker.color = scheme.playlist.indexDurationTextColor
        
        trackNameSelectedTextColorPicker.color = scheme.playlist.trackNameSelectedTextColor
        groupNameSelectedTextColorPicker.color = scheme.playlist.groupNameSelectedTextColor
        indexDurationSelectedTextColorPicker.color = scheme.playlist.indexDurationSelectedTextColor
        
        summaryInfoColorPicker.color = scheme.playlist.summaryInfoColor
        
        groupIconColorPicker.color = scheme.playlist.groupIconColor
        groupDisclosureTriangleColorPicker.color = scheme.playlist.groupDisclosureTriangleColor
        
        selectionBoxColorPicker.color = scheme.playlist.selectionBoxColor
        playingTrackIconColorPicker.color = scheme.playlist.playingTrackIconColor
        
        scrollToTop()
    }
    
    func saveToScheme(_ scheme: ColorScheme) {
        
        scheme.playlist.trackNameTextColor = trackNameTextColorPicker.color
        scheme.playlist.groupNameTextColor = groupNameTextColorPicker.color
        scheme.playlist.indexDurationTextColor = indexDurationTextColorPicker.color
        
        scheme.playlist.trackNameSelectedTextColor = trackNameSelectedTextColorPicker.color
        scheme.playlist.groupNameSelectedTextColor = groupNameSelectedTextColorPicker.color
        scheme.playlist.indexDurationSelectedTextColor = indexDurationSelectedTextColorPicker.color
        
        scheme.playlist.summaryInfoColor = summaryInfoColorPicker.color
        
        scheme.playlist.groupIconColor = groupIconColorPicker.color
        scheme.playlist.groupDisclosureTriangleColor = groupDisclosureTriangleColorPicker.color
        
        scheme.playlist.selectionBoxColor = selectionBoxColorPicker.color
        scheme.playlist.playingTrackIconColor = playingTrackIconColorPicker.color
    }
    
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
    
    @IBAction func trackNameTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.trackNameTextColor = trackNameTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistTrackNameTextColor, trackNameTextColorPicker.color))
    }
    
    @IBAction func groupNameTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupNameTextColor = groupNameTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistGroupNameTextColor, groupNameTextColorPicker.color))
    }
    
    @IBAction func indexDurationTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.indexDurationTextColor = indexDurationTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistIndexDurationTextColor, indexDurationTextColorPicker.color))
    }
    
    @IBAction func trackNameSelectedTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.trackNameSelectedTextColor = trackNameSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistTrackNameSelectedTextColor, trackNameSelectedTextColorPicker.color))
    }
    
    @IBAction func groupNameSelectedTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupNameSelectedTextColor = groupNameSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistGroupNameSelectedTextColor, groupNameSelectedTextColorPicker.color))
    }
    
    @IBAction func indexDurationSelectedTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.indexDurationSelectedTextColor = indexDurationSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistIndexDurationSelectedTextColor, indexDurationSelectedTextColorPicker.color))
    }
    
    @IBAction func groupIconColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupIconColor = groupIconColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistGroupIconColor, groupIconColorPicker.color))
    }
    
    @IBAction func groupDisclosureTriangleColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.groupDisclosureTriangleColor = groupDisclosureTriangleColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistGroupDisclosureTriangleColor, groupDisclosureTriangleColorPicker.color))
    }
    
    @IBAction func selectionBoxColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.selectionBoxColor = selectionBoxColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistSelectionBoxColor, selectionBoxColorPicker.color))
    }
    
    @IBAction func playingTrackIconColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.playingTrackIconColor = playingTrackIconColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistPlayingTrackIconColor, playingTrackIconColorPicker.color))
    }
    
    @IBAction func summaryInfoColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.playlist.summaryInfoColor = summaryInfoColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistSummaryInfoColor, summaryInfoColorPicker.color))
    }
}
