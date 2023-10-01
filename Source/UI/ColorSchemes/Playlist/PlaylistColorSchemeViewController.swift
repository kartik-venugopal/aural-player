//
//  PlaylistColorSchemeViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
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
    
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    private lazy var messenger = Messenger(for: self)
    
    override var nibName: NSNib.Name? {"PlaylistColorScheme"}
    
    private var playlistScheme: PlaylistColorScheme {
        colorSchemesManager.systemScheme.playlist
    }
    
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
    
    override func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard) {
        
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
        
        history.noteChange(ColorSchemeChange(tag: trackNameTextColorPicker.tag, undoValue: playlistScheme.trackNameTextColor,
                                             redoValue: trackNameTextColorPicker.color, changeType: .changeColor))
        changeTrackNameTextColor()
    }
    
    private func changeTrackNameTextColor() {
        
        playlistScheme.trackNameTextColor = trackNameTextColorPicker.color
        messenger.publish(.playlist_changeTrackNameTextColor, payload: trackNameTextColorPicker.color)
    }
    
    @IBAction func groupNameTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: groupNameTextColorPicker.tag, undoValue: playlistScheme.groupNameTextColor,
                                             redoValue: groupNameTextColorPicker.color, changeType: .changeColor))
        changeGroupNameTextColor()
    }
    
    private func changeGroupNameTextColor() {
        
        playlistScheme.groupNameTextColor = groupNameTextColorPicker.color
        messenger.publish(.playlist_changeGroupNameTextColor, payload: groupNameTextColorPicker.color)
    }
    
    @IBAction func indexDurationTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: indexDurationTextColorPicker.tag, undoValue: playlistScheme.indexDurationTextColor,
                                             redoValue: indexDurationTextColorPicker.color, changeType: .changeColor))
        changeIndexDurationTextColor()
    }
    
    private func changeIndexDurationTextColor() {
        
        playlistScheme.indexDurationTextColor = indexDurationTextColorPicker.color
        messenger.publish(.playlist_changeIndexDurationTextColor, payload: indexDurationTextColorPicker.color)
    }
    
    @IBAction func trackNameSelectedTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: trackNameSelectedTextColorPicker.tag, undoValue: playlistScheme.trackNameSelectedTextColor,
                                             redoValue: trackNameSelectedTextColorPicker.color, changeType: .changeColor))
        changeTrackNameSelectedTextColor()
    }
    
    private func changeTrackNameSelectedTextColor() {
        
        playlistScheme.trackNameSelectedTextColor = trackNameSelectedTextColorPicker.color
        messenger.publish(.playlist_changeTrackNameSelectedTextColor, payload: trackNameSelectedTextColorPicker.color)
    }
    
    @IBAction func groupNameSelectedTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: groupNameSelectedTextColorPicker.tag, undoValue: playlistScheme.groupNameSelectedTextColor,
                                             redoValue: groupNameSelectedTextColorPicker.color, changeType: .changeColor))
        changeGroupNameSelectedTextColor()
    }
    
    private func changeGroupNameSelectedTextColor() {
        
        playlistScheme.groupNameSelectedTextColor = groupNameSelectedTextColorPicker.color
        messenger.publish(.playlist_changeGroupNameSelectedTextColor, payload: groupNameSelectedTextColorPicker.color)
    }
    
    @IBAction func indexDurationSelectedTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: indexDurationSelectedTextColorPicker.tag, undoValue: playlistScheme.indexDurationSelectedTextColor,
                                             redoValue: indexDurationSelectedTextColorPicker.color, changeType: .changeColor))
        
        changeIndexDurationSelectedTextColor()
    }
    
    private func changeIndexDurationSelectedTextColor() {
        
        playlistScheme.indexDurationSelectedTextColor = indexDurationSelectedTextColorPicker.color
        messenger.publish(.playlist_changeIndexDurationSelectedTextColor, payload: indexDurationSelectedTextColorPicker.color)
    }
    
    @IBAction func groupIconColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: groupIconColorPicker.tag, undoValue: playlistScheme.groupIconColor,
                                             redoValue: groupIconColorPicker.color, changeType: .changeColor))
        changeGroupIconColor()
    }
    
    private func changeGroupIconColor() {
        
        playlistScheme.groupIconColor = groupIconColorPicker.color
        AuralPlaylistOutlineView.changeGroupIconColor(groupIconColorPicker.color)
        
        messenger.publish(.playlist_changeGroupIconColor, payload: groupIconColorPicker.color)
    }
    
    @IBAction func groupDisclosureTriangleColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: groupDisclosureTriangleColorPicker.tag, undoValue: playlistScheme.groupDisclosureTriangleColor,
                                             redoValue: groupDisclosureTriangleColorPicker.color, changeType: .changeColor))
        
        changeGroupDisclosureTriangleColor()
    }
    
    private func changeGroupDisclosureTriangleColor() {
        
        playlistScheme.groupDisclosureTriangleColor = groupDisclosureTriangleColorPicker.color
        AuralPlaylistOutlineView.changeDisclosureTriangleColor(groupDisclosureTriangleColorPicker.color)
        
        messenger.publish(.playlist_changeGroupDisclosureTriangleColor, payload: groupDisclosureTriangleColorPicker.color)
    }
    
    @IBAction func selectionBoxColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: selectionBoxColorPicker.tag, undoValue: playlistScheme.selectionBoxColor,
                                             redoValue: selectionBoxColorPicker.color, changeType: .changeColor))
        changeSelectionBoxColor()
    }
    
    private func changeSelectionBoxColor() {
        
        playlistScheme.selectionBoxColor = selectionBoxColorPicker.color
        messenger.publish(.playlist_changeSelectionBoxColor, payload: selectionBoxColorPicker.color)
    }
    
    @IBAction func playingTrackIconColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: playingTrackIconColorPicker.tag, undoValue: playlistScheme.playingTrackIconColor,
                                             redoValue: playingTrackIconColorPicker.color, changeType: .changeColor))
        changePlayingTrackIconColor()
    }
    
    private func changePlayingTrackIconColor() {
        
        playlistScheme.playingTrackIconColor = playingTrackIconColorPicker.color
        messenger.publish(.playlist_changePlayingTrackIconColor, payload: playingTrackIconColorPicker.color)
    }
    
    @IBAction func summaryInfoColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: summaryInfoColorPicker.tag, undoValue: playlistScheme.summaryInfoColor,
                                             redoValue: summaryInfoColorPicker.color, changeType: .changeColor))
        changeSummaryInfoColor()
    }
    
    private func changeSummaryInfoColor() {
        
        playlistScheme.summaryInfoColor = summaryInfoColorPicker.color
        messenger.publish(.playlist_changeSummaryInfoColor, payload: summaryInfoColorPicker.color)
    }
}
