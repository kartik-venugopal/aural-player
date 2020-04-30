import Cocoa

class PlaylistColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var containerView: NSView!

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
    
    private var controlsMap: [Int: NSControl] = [:]
    private var actionsMap: [Int: ColorChangeAction] = [:]
    private var history: ColorSchemeHistory!
    
    override var nibName: NSNib.Name? {return "PlaylistColorScheme"}
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    override func viewDidLoad() {
        
        for aView in containerView.subviews {
            
            if let control = aView as? NSColorWell {
                controlsMap[control.tag] = control
            }
        }
        
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
    
    func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory) {
        
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
        
        // Only do this when the window is opening
        if !(self.view.window?.isVisible ?? true) {
            scrollToTop()
        }
    }
    
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
    
    func undoLastChange() -> Bool {
        
        if let lastChange = history.changeToUndo, let colPicker = controlsMap[lastChange.tag] as? NSColorWell,
            let undoColor = lastChange.undoValue as? NSColor, let undoAction = actionsMap[lastChange.tag] {
            
            _ = history.undoLastChange()
            
            print("Found change:", lastChange.tag)
            
            colPicker.color = undoColor
            undoAction()
            
            return true
        }
        
        return false
    }
    
    func redoLastChange() -> Bool {
        
        if let lastChange = history.changeToRedo, let colPicker = controlsMap[lastChange.tag] as? NSColorWell,
            let redoColor = lastChange.redoValue as? NSColor, let redoAction = actionsMap[lastChange.tag] {
            
            print("Found REDO change:", lastChange.tag)
            
            _ = history.redoLastChange()
            
            colPicker.color = redoColor
            redoAction()
            
            return true
        }
        
        return false
    }
    
    @IBAction func trackNameTextColorAction(_ sender: Any) {
        
        history.noteChange(trackNameTextColorPicker.tag, ColorSchemes.systemScheme.playlist.trackNameTextColor, trackNameTextColorPicker.color, .changeColor)
        changeTrackNameTextColor()
    }
    
    private func changeTrackNameTextColor() {
        
        ColorSchemes.systemScheme.playlist.trackNameTextColor = trackNameTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistTrackNameTextColor, trackNameTextColorPicker.color))
    }
    
    @IBAction func groupNameTextColorAction(_ sender: Any) {
        
        history.noteChange(groupNameTextColorPicker.tag, ColorSchemes.systemScheme.playlist.groupNameTextColor, groupNameTextColorPicker.color, .changeColor)
        changeGroupNameTextColor()
    }
    
    private func changeGroupNameTextColor() {
        
        ColorSchemes.systemScheme.playlist.groupNameTextColor = groupNameTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistGroupNameTextColor, groupNameTextColorPicker.color))
    }
    
    @IBAction func indexDurationTextColorAction(_ sender: Any) {
        
        history.noteChange(indexDurationTextColorPicker.tag, ColorSchemes.systemScheme.playlist.indexDurationTextColor, indexDurationTextColorPicker.color, .changeColor)
        changeIndexDurationTextColor()
    }
    
    private func changeIndexDurationTextColor() {
        
        ColorSchemes.systemScheme.playlist.indexDurationTextColor = indexDurationTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistIndexDurationTextColor, indexDurationTextColorPicker.color))
    }
    
    @IBAction func trackNameSelectedTextColorAction(_ sender: Any) {
        
        history.noteChange(trackNameSelectedTextColorPicker.tag, ColorSchemes.systemScheme.playlist.trackNameSelectedTextColor, trackNameSelectedTextColorPicker.color, .changeColor)
        changeTrackNameSelectedTextColor()
    }
    
    private func changeTrackNameSelectedTextColor() {
        
        ColorSchemes.systemScheme.playlist.trackNameSelectedTextColor = trackNameSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistTrackNameSelectedTextColor, trackNameSelectedTextColorPicker.color))
    }
    
    @IBAction func groupNameSelectedTextColorAction(_ sender: Any) {
        
        history.noteChange(groupNameSelectedTextColorPicker.tag, ColorSchemes.systemScheme.playlist.groupNameSelectedTextColor, groupNameSelectedTextColorPicker.color, .changeColor)
        changeGroupNameSelectedTextColor()
    }
    
    private func changeGroupNameSelectedTextColor() {
        
        ColorSchemes.systemScheme.playlist.groupNameSelectedTextColor = groupNameSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistGroupNameSelectedTextColor, groupNameSelectedTextColorPicker.color))
    }
    
    @IBAction func indexDurationSelectedTextColorAction(_ sender: Any) {
        
        history.noteChange(indexDurationSelectedTextColorPicker.tag, ColorSchemes.systemScheme.playlist.indexDurationSelectedTextColor, indexDurationSelectedTextColorPicker.color, .changeColor)
        changeIndexDurationSelectedTextColor()
    }
    
    private func changeIndexDurationSelectedTextColor() {
        
        ColorSchemes.systemScheme.playlist.indexDurationSelectedTextColor = indexDurationSelectedTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistIndexDurationSelectedTextColor, indexDurationSelectedTextColorPicker.color))
    }
    
    @IBAction func groupIconColorAction(_ sender: Any) {
        
        history.noteChange(groupIconColorPicker.tag, ColorSchemes.systemScheme.playlist.groupIconColor, groupIconColorPicker.color, .changeColor)
        changeGroupIconColor()
    }
    
    private func changeGroupIconColor() {
        
        ColorSchemes.systemScheme.playlist.groupIconColor = groupIconColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistGroupIconColor, groupIconColorPicker.color))
    }
    
    @IBAction func groupDisclosureTriangleColorAction(_ sender: Any) {
        
        history.noteChange(groupDisclosureTriangleColorPicker.tag, ColorSchemes.systemScheme.playlist.groupDisclosureTriangleColor, groupDisclosureTriangleColorPicker.color, .changeColor)
        changeGroupDisclosureTriangleColor()
    }
    
    private func changeGroupDisclosureTriangleColor() {
        
        ColorSchemes.systemScheme.playlist.groupDisclosureTriangleColor = groupDisclosureTriangleColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistGroupDisclosureTriangleColor, groupDisclosureTriangleColorPicker.color))
    }
    
    @IBAction func selectionBoxColorAction(_ sender: Any) {
        
        history.noteChange(selectionBoxColorPicker.tag, ColorSchemes.systemScheme.playlist.selectionBoxColor, selectionBoxColorPicker.color, .changeColor)
        changeSelectionBoxColor()
    }
    
    private func changeSelectionBoxColor() {
        
        ColorSchemes.systemScheme.playlist.selectionBoxColor = selectionBoxColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistSelectionBoxColor, selectionBoxColorPicker.color))
    }
    
    @IBAction func playingTrackIconColorAction(_ sender: Any) {
        
        history.noteChange(playingTrackIconColorPicker.tag, ColorSchemes.systemScheme.playlist.playingTrackIconColor, playingTrackIconColorPicker.color, .changeColor)
        changePlayingTrackIconColor()
    }
    
    private func changePlayingTrackIconColor() {
        
        ColorSchemes.systemScheme.playlist.playingTrackIconColor = playingTrackIconColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistPlayingTrackIconColor, playingTrackIconColorPicker.color))
    }
    
    @IBAction func summaryInfoColorAction(_ sender: Any) {
        
        history.noteChange(summaryInfoColorPicker.tag, ColorSchemes.systemScheme.playlist.summaryInfoColor, summaryInfoColorPicker.color, .changeColor)
        changeSummaryInfoColor()
    }
    
    private func changeSummaryInfoColor() {
        
        ColorSchemes.systemScheme.playlist.summaryInfoColor = summaryInfoColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlaylistSummaryInfoColor, summaryInfoColorPicker.color))
    }
}
