//
//  LibraryTracksViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryTracksViewController: TrackListTableViewController {
    
    override var nibName: NSNib.Name? {"LibraryTracks"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Spinner that shows progress when tracks are being added to the play queue.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    override var rowHeight: CGFloat {30}
    
    override var trackList: TrackListProtocol! {
        libraryDelegate
    }
    
    private lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        updateSummary()
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainer)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceivers: [lblTracksSummary, lblDurationSummary])
        
        messenger.subscribeAsync(to: .Library.tracksAdded, handler: tracksAdded(_:))
        messenger.subscribeAsync(to: .Library.tracksRemoved, handler: tracksRemoved(_:))
        messenger.subscribe(to: .Library.updateSummary, handler: updateSummary)
        messenger.subscribe(to: .Library.reloadTable, handler: reloadTable)
        
        messenger.subscribeAsync(to: .Library.doneAddingTracks, handler: doneAddingTracks)
        
//        messenger.subscribe(to: .Library.addChosenFiles, handler: addChosenTracks(_:))
//
//        messenger.subscribe(to: .Library.copyTracks, handler: copyTracks(_:))
    }
    
    override func view(forColumn column: NSUserInterfaceItemIdentifier, row: Int, track: Track) -> TableCellBuilder {
        
        let builder = TableCellBuilder()
        
        switch column {
            
        case .cid_index:
            
            return builder.withText(text: "\(row + 1)",
                                                   inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                                   selectedTextColor: systemColorScheme.tertiarySelectedTextColor)

        case .cid_trackName:
            
            let titleAndArtist = track.titleAndArtist
            
            if let artist = titleAndArtist.artist {
                
                return builder.withAttributedText(strings: [(text: artist + "  ", font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor),
                                                                       (text: titleAndArtist.title, font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor)],
                                                             selectedTextColors: [systemColorScheme.secondarySelectedTextColor, systemColorScheme.primarySelectedTextColor])
            } else {
                
                return builder.withAttributedText(strings: [(text: titleAndArtist.title,
                                                                        font: systemFontScheme.normalFont,
                                                                        color: systemColorScheme.primaryTextColor)], selectedTextColors: [systemColorScheme.primarySelectedTextColor])
            }
            
        case .cid_duration:
            
            return builder.withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                               inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                               selectedTextColor: systemColorScheme.tertiarySelectedTextColor)
            
        default:
            
            return builder
        }
    }
    
    override func notifyReloadTable() {
        messenger.publish(.Library.reloadTable)
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Actions (context menu)
    
    @IBAction func playNowAction(_ sender: AnyObject) {
        playQueueDelegate.enqueueToPlayNow(tracks: selectedTracks, clearQueue: false)
    }
    
    @IBAction func playNowClearingPlayQueueAction(_ sender: NSMenuItem) {
        playQueueDelegate.enqueueToPlayNow(tracks: selectedTracks, clearQueue: true)
    }
    
    @IBAction func playNextAction(_ sender: NSMenuItem) {
        playQueueDelegate.enqueueToPlayNext(tracks: selectedTracks)
    }
    
    @IBAction func playLaterAction(_ sender: NSMenuItem) {
        playQueueDelegate.enqueueToPlayLater(tracks: selectedTracks)
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Notification handling
    
    private func tracksAdded(_ notif: LibraryTracksAddedNotification) {
        
//        tracksAdded(at: notif.trackIndices)
//        updateSummary()
    }
    
    private func tracksRemoved(_ notif: LibraryTracksRemovedNotification) {
        
        tracksRemoved(at: notif.trackIndices)
        updateSummary()
    }
    
    func doneAddingTracks() {
        
        tableView.reloadData()
        updateSummary()
    }
    
    override func updateSummary() {
        
        let numTracks = library.size
        lblTracksSummary.stringValue = "\(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(library.duration)
    }
    
    private func copyTracks(_ notif: CopyTracksToPlaylistCommand) {
        
        guard let destinationPlaylist = playlistsManager.userDefinedObject(named: notif.destinationPlaylistName) else {return}
        
        destinationPlaylist.addTracks(notif.tracks)
        
        // If tracks were added to the displayed playlist, update the table view.
//        if destinationPlaylist == playlist {
//            tableView.noteNumberOfRowsChanged()
//        }
    }

    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        
        lblCaption.font = systemFontScheme.captionFont
        [lblTracksSummary, lblDurationSummary].forEach {
            $0.font = systemFontScheme.smallFont
        }
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        rootContainer.fillColor = systemColorScheme.backgroundColor
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        [lblTracksSummary, lblDurationSummary].forEach {
            $0?.textColor = systemColorScheme.secondaryTextColor
        }
    }
}
