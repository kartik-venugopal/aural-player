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
    
    @IBOutlet weak var btnClose: TintedImageButton!
    private lazy var btnCloseConstraints: LayoutConstraintsManager = LayoutConstraintsManager(for: btnClose)
    
    private let viewController: ChaptersListViewController = .init()
    
    override var windowNibName: NSNib.Name? {"ChaptersListWindow"}
    
    private lazy var messenger = Messenger(for: self)
    
    // The chapters list window is only considered modal when it is the key window AND
    // the search bar has focus (i.e. a search is being performed).
    var isModal: Bool {
        theWindow.isKeyWindow && viewController.isPerformingSearch
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        window?.contentView?.addSubview(viewController.view)
        viewController.view.anchorToSuperview()
        
        btnClose.bringToFront()
        
        btnCloseConstraints.setWidth(11.5)
        btnCloseConstraints.setHeight(10)
        btnCloseConstraints.setLeading(relatedToLeadingOf: btnClose.superview!, offset: 10)
        btnCloseConstraints.setTop(relatedToTopOf: btnClose.superview!, offset: 15)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        windowLayoutsManager.hideWindow(withId: .chaptersList)
    }
    
    override func destroy() {
        
        viewController.destroy()
        
        close()
        messenger.unsubscribeFromAll()
    }
}

extension ChaptersListWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        btnClose.colorChanged(systemColorScheme.buttonColor)
    }
}
