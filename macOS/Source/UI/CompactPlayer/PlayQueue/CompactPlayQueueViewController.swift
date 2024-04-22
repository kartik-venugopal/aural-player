//
//  CompactPlayQueueViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class CompactPlayQueueViewController: PlayQueueViewController {
    
    override var nibName: NSNib.Name? {"CompactPlayQueue"}
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Spinner that shows progress when tracks are being added to the play queue.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    override var playQueueView: PlayQueueView {
        .expanded
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messenger.subscribeAsync(to: .PlayQueue.startedAddingTracks, handler: startedAddingTracks)
        messenger.subscribeAsync(to: .PlayQueue.doneAddingTracks, handler: doneAddingTracks)
        
        messenger.subscribeAsync(to: .PlayQueue.tracksAdded, handler: updateSummary)
        messenger.subscribeAsync(to: .PlayQueue.showPlayingTrack, handler: showPlayingTrack)
    }
    
    // MARK: Notification handling ----------------------------------------------------------------------------------
    
    func startedAddingTracks() {
        
        progressSpinner.startAnimation(nil)
        progressSpinner.show()
    }
    
    func doneAddingTracks() {
        
        progressSpinner.hide()
        progressSpinner.stopAnimation(nil)
    }
    
    // TODO: This is a hack ! Re-investigate the superClass method that calls this. eg. doSort()
    override func notifyReloadTable() {
        
        tableView.reloadData()
        updateSummary()
    }
    
    // MARK: Table view delegate / data source --------------------------------------------------------------------------------------------------------
    
    override var rowHeight: CGFloat {45}
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        getView(for: tableColumn, row: row)
    }
    
    override func updateSummary() {
        
        let tracksCardinalString = playQueueDelegate.size == 1 ? "track" : "tracks"
        
        if let playingTrackIndex = playQueueDelegate.currentTrackIndex {
            
            let playIconAttStr = "▶".attributed(font: futuristicFontSet.mainFont(size: 12), color: systemColorScheme.secondaryTextColor)
            let tracksSummaryAttStr = "  \(playingTrackIndex + 1) / \(playQueueDelegate.size) \(tracksCardinalString)".attributed(font: systemFontScheme.smallFont,
                                                                                                                                  color: systemColorScheme.secondaryTextColor)
            
            lblTracksSummary.attributedStringValue = playIconAttStr + tracksSummaryAttStr
            
        } else {
            
            lblTracksSummary.stringValue = "\(playQueueDelegate.size) \(tracksCardinalString)"
            lblTracksSummary.font = systemFontScheme.smallFont
            lblTracksSummary.textColor = systemColorScheme.secondaryTextColor
        }
        
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(playQueueDelegate.duration)
        lblDurationSummary.font = systemFontScheme.smallFont
        lblDurationSummary.textColor = systemColorScheme.secondaryTextColor
    }
    
    override func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        super.trackTransitioned(notification)
        updateSummary()
    }
    
    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        
        lblCaption.font = systemFontScheme.captionFont
        updateSummary()
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        lblCaption.textColor = systemColorScheme.captionTextColor
        updateSummary()
    }
}
