//
//  PlayQueueContainerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Cocoa

class PlayQueueContainerViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"PlayQueueContainer"}
    
    @IBOutlet weak var containerTabGroup: NSTabView!
    @IBOutlet weak var containerView: NSView!
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Spinner that shows progress when tracks are being added to the play queue.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    @IBOutlet weak var tabButtonsContainer: NSBox!
    
    // The tab group that switches between the PQ views
    @IBOutlet weak var playQueueTabGroup: NSTabView!
    
    @IBOutlet weak var btnSimpleView: TrackListTabButton!
    @IBOutlet weak var btnExpandedView: TrackListTabButton!
    
    var buttonColorChangeReceivers: [ColorSchemePropertyChangeReceiver] = []
    
    lazy var tabButtons: [TrackListTabButton] = [btnSimpleView, btnExpandedView]
    
    @IBOutlet weak var sortOrderMenuItemView: SortOrderMenuItemView!
    
    @IBOutlet weak var simpleViewController: PlayQueueSimpleViewController!
    @IBOutlet weak var expandedViewController: PlayQueueExpandedViewController!
    lazy var searchViewController: PlayQueueSearchViewController = PlayQueueSearchViewController()
    
    lazy var controllers: [PlayQueueViewController] = [simpleViewController, expandedViewController]
    
    lazy var fileOpenDialog = DialogsAndAlerts.openFilesAndFoldersDialog
    
    lazy var saveDialog = DialogsAndAlerts.savePlaylistDialog
    
    var currentViewController: PlayQueueViewController {
        playQueueUIState.currentView == .simple ? simpleViewController : expandedViewController
    }
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        initializeView()
        setUpTheming()
        initSubscriptions()
        
        updateSummary()
    }
    
    func initializeView() {
        
        // Offset the caption label a bit to the right.
        if appModeManager.currentMode == .modular,
            let lblCaptionLeadingConstraint = lblCaption.superview?.constraints.first(where: {$0.firstAttribute == .leading}) {
            
            lblCaptionLeadingConstraint.constant = 23
        }
        
        let simpleView = simpleViewController.view
        let prettyView = expandedViewController.view
        let searchView = searchViewController.view
        
        for (index, view) in [simpleView, prettyView].enumerated() {
            
            playQueueTabGroup.tabViewItem(at: index).view?.addSubview(view)
            view.anchorToSuperview()
        }
        
        for (index, view) in [containerView, searchView].compactMap({$0}).enumerated() {
            
            containerTabGroup.tabViewItem(at: index).view?.addSubview(view)
            view.anchorToSuperview()
        }
        
        doSelectTab(at: playQueueUIState.currentView.rawValue)
        
        if playQueueDelegate.isBeingModified {
            startedAddingTracks()
        }
    }
    
    func setUpTheming() {
        
        buttonColorChangeReceivers = [btnSimpleView, btnExpandedView]
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.buttonColor, \.inactiveControlColor], changeReceivers: buttonColorChangeReceivers)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: tabButtonsContainer)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: secondaryTextColorChanged(_:))
    }
    
    func initSubscriptions() {
        
        messenger.subscribe(to: .PlayQueue.addTracks, handler: importFilesAndFolders)
        
        messenger.subscribe(to: .PlayQueue.removeTracks, handler: removeTracks)
        messenger.subscribe(to: .PlayQueue.cropSelection, handler: cropSelection)
        messenger.subscribe(to: .PlayQueue.removeAllTracks, handler: removeAllTracks)
        
//        messenger.subscribe(to: .PlayQueue.enqueueAndPlayNow, handler: enqueueAndPlayNow(_:))
        messenger.subscribe(to: .PlayQueue.enqueueAndPlayNext, handler: enqueueAndPlayNext(_:))
        messenger.subscribe(to: .PlayQueue.enqueueAndPlayLater, handler: enqueueAndPlayLater(_:))
        
        messenger.subscribe(to: .PlayQueue.loadAndPlayNow, handler: loadAndPlayNow(_:))
        
        messenger.subscribe(to: .PlayQueue.playNext, handler: playNext)
        
        messenger.subscribe(to: .PlayQueue.playSelectedTrack, handler: playSelectedTrack)
        
        messenger.subscribe(to: .PlayQueue.selectAllTracks, handler: selectAllTracks)
        messenger.subscribe(to: .PlayQueue.clearSelection, handler: clearSelection)
        messenger.subscribe(to: .PlayQueue.invertSelection, handler: invertSelection)
        
        messenger.subscribe(to: .PlayQueue.pageUp, handler: pageUp)
        messenger.subscribe(to: .PlayQueue.pageDown, handler: pageDown)
        messenger.subscribe(to: .PlayQueue.scrollToTop, handler: scrollToTop)
        messenger.subscribe(to: .PlayQueue.scrollToBottom, handler: scrollToBottom)
        
        messenger.subscribe(to: .PlayQueue.showPlayingTrack, handler: showPlayingTrack)
        
        messenger.subscribe(to: .PlayQueue.moveTracksUp, handler: moveTracksUp)
        messenger.subscribe(to: .PlayQueue.moveTracksDown, handler: moveTracksDown)
        messenger.subscribe(to: .PlayQueue.moveTracksToTop, handler: moveTracksToTop)
        messenger.subscribe(to: .PlayQueue.moveTracksToBottom, handler: moveTracksToBottom)
        
        messenger.subscribe(to: .PlayQueue.search, handler: search)
        messenger.subscribe(to: .Search.done, handler: searchDone)
        
        messenger.subscribe(to: .PlayQueue.exportAsPlaylistFile, handler: exportToPlaylistFile)
        
        messenger.subscribeAsync(to: .PlayQueue.startedAddingTracks, handler: startedAddingTracks)
        messenger.subscribeAsync(to: .PlayQueue.doneAddingTracks, handler: doneAddingTracks)
        
        messenger.subscribeAsync(to: .PlayQueue.tracksAdded, handler: updateSummary)
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        
        messenger.subscribe(to: .PlayQueue.updateSummary, handler: updateSummary)
        messenger.subscribe(to: .PlayQueue.shuffleModeUpdated, handler: updateSummary)
    }
    
    func playSelectedTrack() {
        currentViewController.playSelectedTrack()
    }
    
    func selectAllTracks() {
        currentViewController.selectAll()
    }
    
    func clearSelection() {
        currentViewController.clearSelection()
    }
    
    func invertSelection() {
        currentViewController.invertSelection()
    }
    
    // Removes all items from the playlist
    func removeAllTracks() {
        
        guard playQueueDelegate.size > 0, !checkIfPlayQueueIsBeingModified() else {return}
        
        playQueueDelegate.removeAllTracks()
        
        // Tell the play queue UI to refresh its views.
        controllers.forEach {
            $0.tableView.reloadData()
        }
        
        updateSummary()
    }
    
    func showPlayingTrack() {
        currentViewController.showPlayingTrack()
    }
    
    func pageUp() {
        currentViewController.pageUp()
    }
    
    func pageDown() {
        currentViewController.pageDown()
    }
    
    func scrollToTop() {
        currentViewController.scrollToTop()
    }
    
    func scrollToBottom() {
        currentViewController.scrollToBottom()
    }
    
    private func checkIfPlayQueueIsBeingModified() -> Bool {
        
        let playQueueBeingModified = playQueueDelegate.isBeingModified
        
        if playQueueBeingModified {
            
            NSAlert.showError(withTitle: "Play Queue not modified",
                              andText: "The Play Queue cannot be modified while tracks are being added. Please wait till the Play Queue is done adding tracks ...")
        }
        
        return playQueueBeingModified
    }
    
    // MARK: Notification handling ----------------------------------------------------------------------------------
    
    func startedAddingTracks() {
        progressSpinner.animate()
    }
    
    func doneAddingTracks() {
        progressSpinner.dismiss()
    }
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        if preferences.playQueuePreferences.showNewTrackInPlayQueue.value, notification.endTrack != nil {
            showPlayingTrack()
        }
        
        updateSummary()
    }
    
    func updateSummary() {
        
        let tracksCardinalString = playQueueDelegate.size == 1 ? "track" : "tracks"
        
        if let playingTrackIndex = playQueueDelegate.currentTrackIndex {
            
            if playQueueDelegate.shuffleMode == .on {
                updateShuffleSequenceProgress()
                
            } else {
                
                let playIconAttStr = "▶".attributed(font: futuristicFontSet.mainFont(size: 12), color: systemColorScheme.secondaryTextColor)
                let tracksSummaryAttStr = "  \(playingTrackIndex + 1) / \(playQueueDelegate.size) \(tracksCardinalString)".attributed(font: systemFontScheme.smallFont,
                                                                                                                                      color: systemColorScheme.secondaryTextColor)
                
                lblTracksSummary.attributedStringValue = playIconAttStr + tracksSummaryAttStr
            }
            
        } else {
            
            lblTracksSummary.stringValue = "\(playQueueDelegate.size) \(tracksCardinalString)"
            lblTracksSummary.font = systemFontScheme.smallFont
            lblTracksSummary.textColor = systemColorScheme.secondaryTextColor
        }
        
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(playQueueDelegate.duration)
        lblDurationSummary.font = systemFontScheme.smallFont
        lblDurationSummary.textColor = systemColorScheme.secondaryTextColor
    }
    
    private func updateShuffleSequenceProgress() {
        
        let imgAttachment = NSTextAttachment()
        imgAttachment.image = .imgShuffle
        let imgAttrString = NSMutableAttributedString(attachment: imgAttachment)
        
        let sequenceProgress = playQueueDelegate.shuffleSequence.progress
        let tracksSummaryAttStr = "  \(sequenceProgress.tracksPlayed) / \(playQueueDelegate.size) tracks".attributed(font: systemFontScheme.smallFont,
                                                                                                                    color: systemColorScheme.secondaryTextColor)
        lblTracksSummary.attributedStringValue = imgAttrString + tracksSummaryAttStr
    }
    
    func search() {

        containerTabGroup.selectTabViewItem(at: 1)
        playQueueUIState.isShowingSearch = true
    }
    
    private func searchDone() {
        
        containerTabGroup.selectTabViewItem(at: 0)
        playQueueUIState.isShowingSearch = false
    }
    
    override func destroy() {
        
        controllers.forEach {$0.destroy()}
        messenger.unsubscribeFromAll()
    }
}

extension PlayQueueContainerViewController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        
        // Ignore this when searching the PQ
        if playQueueTabGroup.selectedIndex == 2 {return}
        
         playQueueUIState.currentView = playQueueTabGroup.selectedIndex == 0 ? .simple : .expanded
    }
}

extension PlayQueueContainerViewController: ThemeInitialization {
    
    func initTheme() {
        
        lblCaption.font = systemFontScheme.captionFont
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        updateSummary()
        
        [btnSimpleView, btnExpandedView].forEach {
            $0.redraw()
        }
        
        tabButtonsContainer.fillColor = systemColorScheme.backgroundColor
    }
}

extension PlayQueueContainerViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        updateSummary()
    }
}

extension PlayQueueContainerViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        [btnSimpleView, btnExpandedView].forEach {
            $0.redraw()
        }
        
        tabButtonsContainer.fillColor = systemColorScheme.backgroundColor
        
        lblCaption.textColor = systemColorScheme.captionTextColor
        updateSummary()
    }
    
    func secondaryTextColorChanged(_ newColor: NSColor) {
        updateSummary()
    }
}
