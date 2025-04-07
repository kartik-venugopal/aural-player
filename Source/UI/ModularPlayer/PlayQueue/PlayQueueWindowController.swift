//
//  PlayQueueWindowController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueWindowController: NSWindowController, ColorSchemeObserver {

    override var windowNibName: NSNib.Name? {"PlayQueueWindow"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var containerView: NSView!
    private lazy var btnCloseConstraints: LayoutConstraintsManager = LayoutConstraintsManager(for: btnClose)
    
    private lazy var containerViewController: PlayQueueContainerViewController = .init()
    
    var eventMonitor: EventMonitor! = EventMonitor()
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        theWindow.isMovableByWindowBackground = true
        
        containerView.addSubview(containerViewController.view)
        
        containerViewController.view.anchorToSuperview()
        
        // Bring the 'X' (Close) button to the front and constrain it.
        btnClose.bringToFront()

        btnCloseConstraints.setWidth(10)
        btnCloseConstraints.setHeight(10)
        btnCloseConstraints.setLeading(relatedToLeadingOf: btnClose.superview!, offset: 10)
        btnCloseConstraints.setTop(relatedToTopOf: btnClose.superview!, offset: 15)
        
        // Offset the caption to the right of the 'X' (Close) button.
        containerViewController.lblCaption.moveRight(distance: 20)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainer)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
        
        changeWindowCornerRadius(playerUIState.cornerRadius)
        messenger.subscribe(to: .View.changeWindowCornerRadius, handler: changeWindowCornerRadius(_:))
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        
        setUpEventHandling()
    }
    
    func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        // New track has no chapters, or there is no new track
        if playbackInfoDelegate.chapterCount == 0 {
            windowLayoutsManager.hideWindow(withId: .chaptersList)
            
        } // Only show chapters list if preferred by user
        else if preferences.playQueuePreferences.showChaptersList {
            windowLayoutsManager.showWindow(withId: .chaptersList)
        }
    }
    
    func colorSchemeChanged() {
        
        rootContainer.fillColor = systemColorScheme.backgroundColor
        btnClose.contentTintColor = systemColorScheme.buttonColor
    }
    
    // MARK: Actions ----------------------------------------------------------------------------------
    
    @IBAction func closeAction(_ sender: NSButton) {
        
        windowLayoutsManager.toggleWindow(withId: .playQueue)
        appDelegate.playQueueMenuRootItem.disable()
    }
    
    // MARK: Notification handling ----------------------------------------------------------------------------------
    
    private func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainer.cornerRadius = radius
    }
    
    override func destroy() {
        
        close()
        
        containerViewController.destroy()
        messenger.unsubscribeFromAll()
        
        eventMonitor.stopMonitoring()
        eventMonitor = nil
    }
}
