//
//  ChaptersListWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Window controller for the Chapters list window.
    Contains the Chapters list view and performs window snapping.
 */
class ChaptersListWindowController: NSWindowController, ModalComponentProtocol {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var viewController: ChaptersListViewController!
    
    override var windowNibName: NSNib.Name? {"ChaptersList"}
    
    private lazy var messenger = Messenger(for: self)
    
    // The chapters list window is only considered modal when it is the key window AND
    // the search bar has focus (i.e. a search is being performed).
    var isModal: Bool {
        theWindow.isKeyWindow && viewController.isPerformingSearch
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainerBox)
        
        rootContainerBox.cornerRadius = playerUIState.cornerRadius
        
        messenger.subscribe(to: .Player.UI.changeCornerRadius, handler: changeWindowCornerRadius(_:))
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        windowLayoutsManager.hideWindow(withId: .chaptersList)
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
    
    override func destroy() {
        
        viewController.destroy()
        
        close()
        messenger.unsubscribeFromAll()
    }
}

extension ChaptersListWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
    }
}
