import Cocoa

/*
    Controller for the view that allows the user to edit color scheme elements that apply to the playlist UI.
 */
class PlaylistColorSchemeViewController: ColorSchemeViewController {
    
    @IBOutlet weak var trackNameTextColorPicker: AuralColorPicker!
    @IBOutlet weak var groupNameTextColorPicker: AuralColorPicker!
    @IBOutlet weak var indexDurationTextColorPicker: AuralColorPicker!

    @IBOutlet weak var trackNameSelectedTextColorPicker: AuralColorPicker!
    @IBOutlet weak var groupNameSelectedTextColorPicker: AuralColorPicker!
    @IBOutlet weak var indexDurationSelectedTextColorPicker: AuralColorPicker!
    
    @IBOutlet weak var summaryInfoColorPicker: AuralColorPicker!

    @IBOutlet weak var groupIconColorPicker: AuralColorPicker!
    @IBOutlet weak var groupDisclosureTriangleColorPicker: AuralColorPicker!
    
    @IBOutlet weak var selectionBoxColorPicker: AuralColorPicker!
    @IBOutlet weak var playingTrackIconColorPicker: AuralColorPicker!
    
    override var nibName: NSNib.Name? {return "PlaylistColorScheme"}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Map control tags to their corresponding undo/redo actions
        
        actionsMap[trackNameTextColorPicker.tag] = self.changeTrackNameTextColor
        actionsMap[groupNameTextColorPicker.tag] = self.changeGroupNameTextColor
        actionsMap[indexDurationTextColorPicker.tag] = self.changeIndexDurationTextColor
        
        actionsMap[trackNameSelectedTextColorPicker.tag] = self.changeTrackNameSelectedTextColor
        actionsMap[groupNameSelectedTextColorPicker.tag] = self.changeGroupNameSelectedTextColor
        actionsMap[indexDurationSelectedTextColorPicker.tag] = self.changeIndexDurationSelectedTextColor
        
        actionsMap[summaryInfoColorPicker.tag] = self.changeSummaryInfoColor
        
        actionsMap[groupIconColorPicker.tag] = self.changeGroupIconColor
        actionsMap[groupDisclosureTriangleColorPicker.tag] = self.changeGroupDisclosureTriangleColor
        
        actionsMap[playingTrackIconColorPicker.tag] = self.changePlayingTrackIconColor
        actionsMap[selectionBoxColorPicker.tag] = self.changeSelectionBoxColor
    }
    
    override func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard!) {
        
        super.resetFields(scheme, history, clipboard)
        
        // Update the UI to reflect the current system color scheme
        
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
    }
    
    @IBAction func trackNameTextColorAction(_ sender: Any) {
        
        history.noteChange(trackNameTextColorPicker.tag, ColorSchemes.systemScheme.playlist.trackNameTextColor, trackNameTextColorPicker.color, .changeColor)
        changeTrackNameTextColor()
    }
    
    private func changeTrackNameTextColor() {
        
        ColorSchemes.systemScheme.playlist.trackNameTextColor = trackNameTextColorPicker.color
        Messenger.publish(.playlist_changeTrackNameTextColor, payload: trackNameTextColorPicker.color)
    }
    
    @IBAction func groupNameTextColorAction(_ sender: Any) {
        
        history.noteChange(groupNameTextColorPicker.tag, ColorSchemes.systemScheme.playlist.groupNameTextColor, groupNameTextColorPicker.color, .changeColor)
        changeGroupNameTextColor()
    }
    
    private func changeGroupNameTextColor() {
        
        ColorSchemes.systemScheme.playlist.groupNameTextColor = groupNameTextColorPicker.color
        Messenger.publish(.playlist_changeGroupNameTextColor, payload: groupNameTextColorPicker.color)
    }
    
    @IBAction func indexDurationTextColorAction(_ sender: Any) {
        
        history.noteChange(indexDurationTextColorPicker.tag, ColorSchemes.systemScheme.playlist.indexDurationTextColor, indexDurationTextColorPicker.color, .changeColor)
        changeIndexDurationTextColor()
    }
    
    private func changeIndexDurationTextColor() {
        
        ColorSchemes.systemScheme.playlist.indexDurationTextColor = indexDurationTextColorPicker.color
        Messenger.publish(.playlist_changeIndexDurationTextColor, payload: indexDurationTextColorPicker.color)
    }
    
    @IBAction func trackNameSelectedTextColorAction(_ sender: Any) {
        
        history.noteChange(trackNameSelectedTextColorPicker.tag, ColorSchemes.systemScheme.playlist.trackNameSelectedTextColor, trackNameSelectedTextColorPicker.color, .changeColor)
        changeTrackNameSelectedTextColor()
    }
    
    private func changeTrackNameSelectedTextColor() {
        
        ColorSchemes.systemScheme.playlist.trackNameSelectedTextColor = trackNameSelectedTextColorPicker.color
        Messenger.publish(.playlist_changeTrackNameSelectedTextColor, payload: trackNameSelectedTextColorPicker.color)
    }
    
    @IBAction func groupNameSelectedTextColorAction(_ sender: Any) {
        
        history.noteChange(groupNameSelectedTextColorPicker.tag, ColorSchemes.systemScheme.playlist.groupNameSelectedTextColor, groupNameSelectedTextColorPicker.color, .changeColor)
        changeGroupNameSelectedTextColor()
    }
    
    private func changeGroupNameSelectedTextColor() {
        
        ColorSchemes.systemScheme.playlist.groupNameSelectedTextColor = groupNameSelectedTextColorPicker.color
        Messenger.publish(.playlist_changeGroupNameSelectedTextColor, payload: groupNameSelectedTextColorPicker.color)
    }
    
    @IBAction func indexDurationSelectedTextColorAction(_ sender: Any) {
        
        history.noteChange(indexDurationSelectedTextColorPicker.tag, ColorSchemes.systemScheme.playlist.indexDurationSelectedTextColor, indexDurationSelectedTextColorPicker.color, .changeColor)
        changeIndexDurationSelectedTextColor()
    }
    
    private func changeIndexDurationSelectedTextColor() {
        
        ColorSchemes.systemScheme.playlist.indexDurationSelectedTextColor = indexDurationSelectedTextColorPicker.color
        Messenger.publish(.playlist_changeIndexDurationSelectedTextColor, payload: indexDurationSelectedTextColorPicker.color)
    }
    
    @IBAction func groupIconColorAction(_ sender: Any) {
        
        history.noteChange(groupIconColorPicker.tag, ColorSchemes.systemScheme.playlist.groupIconColor, groupIconColorPicker.color, .changeColor)
        changeGroupIconColor()
    }
    
    private func changeGroupIconColor() {
        
        ColorSchemes.systemScheme.playlist.groupIconColor = groupIconColorPicker.color
        AuralPlaylistOutlineView.changeGroupIconColor(groupIconColorPicker.color)
        
        Messenger.publish(.playlist_changeGroupIconColor, payload: groupIconColorPicker.color)
    }
    
    @IBAction func groupDisclosureTriangleColorAction(_ sender: Any) {
        
        history.noteChange(groupDisclosureTriangleColorPicker.tag, ColorSchemes.systemScheme.playlist.groupDisclosureTriangleColor, groupDisclosureTriangleColorPicker.color, .changeColor)
        changeGroupDisclosureTriangleColor()
    }
    
    private func changeGroupDisclosureTriangleColor() {
        
        ColorSchemes.systemScheme.playlist.groupDisclosureTriangleColor = groupDisclosureTriangleColorPicker.color
        AuralPlaylistOutlineView.changeDisclosureTriangleColor(groupDisclosureTriangleColorPicker.color)
        
        Messenger.publish(.playlist_changeGroupDisclosureTriangleColor, payload: groupDisclosureTriangleColorPicker.color)
    }
    
    @IBAction func selectionBoxColorAction(_ sender: Any) {
        
        history.noteChange(selectionBoxColorPicker.tag, ColorSchemes.systemScheme.playlist.selectionBoxColor, selectionBoxColorPicker.color, .changeColor)
        changeSelectionBoxColor()
    }
    
    private func changeSelectionBoxColor() {
        
        ColorSchemes.systemScheme.playlist.selectionBoxColor = selectionBoxColorPicker.color
        Messenger.publish(.playlist_changeSelectionBoxColor, payload: selectionBoxColorPicker.color)
    }
    
    @IBAction func playingTrackIconColorAction(_ sender: Any) {
        
        history.noteChange(playingTrackIconColorPicker.tag, ColorSchemes.systemScheme.playlist.playingTrackIconColor, playingTrackIconColorPicker.color, .changeColor)
        changePlayingTrackIconColor()
    }
    
    private func changePlayingTrackIconColor() {
        
        ColorSchemes.systemScheme.playlist.playingTrackIconColor = playingTrackIconColorPicker.color
        Messenger.publish(.playlist_changePlayingTrackIconColor, payload: playingTrackIconColorPicker.color)
    }
    
    @IBAction func summaryInfoColorAction(_ sender: Any) {
        
        history.noteChange(summaryInfoColorPicker.tag, ColorSchemes.systemScheme.playlist.summaryInfoColor, summaryInfoColorPicker.color, .changeColor)
        changeSummaryInfoColor()
    }
    
    private func changeSummaryInfoColor() {
        
        ColorSchemes.systemScheme.playlist.summaryInfoColor = summaryInfoColorPicker.color
        Messenger.publish(.playlist_changeSummaryInfoColor, payload: summaryInfoColorPicker.color)
    }
}
