//
//  ChaptersListWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Window controller for the Chapters list window.
    Contains the Chapters list view and performs window snapping.
 */
class ChaptersListWindowController: NSWindowController, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var viewController: ChaptersListViewController!
    
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    override var windowNibName: String? {"ChaptersList"}
    
    override func windowDidLoad() {
        
        changeBackgroundColor(colorSchemesManager.systemScheme.general.backgroundColor)
        rootContainerBox.cornerRadius = WindowAppearanceState.cornerRadius
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeBackgroundColor, self.changeBackgroundColor(_:))
        Messenger.subscribe(self, .windowAppearance_changeCornerRadius, self.changeWindowCornerRadius(_:))
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        WindowManager.instance.hideChaptersList()
    }
    
    private func applyTheme() {
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        changeBackgroundColor(scheme.general.backgroundColor)
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        rootContainerBox.fillColor = color
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
    
    func destroy() {
        
        viewController.destroy()
        
        close()
        Messenger.unsubscribeAll(for: self)
    }
}
