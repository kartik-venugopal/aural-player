//
//  PresetsManagerWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PresetsManagerWindowController: SingletonWindowController, ModalComponentProtocol {
    
    private lazy var layoutsManagerViewController: NSViewController = LayoutsManagerViewController()
    private lazy var layoutsManagerView: NSView = layoutsManagerViewController.view
    
    private lazy var themesManagerViewController: NSViewController = ThemesManagerViewController()
    private lazy var themesManagerView: NSView = themesManagerViewController.view
    
    private lazy var fontSchemesManagerViewController: NSViewController = FontSchemesManagerViewController()
    private lazy var fontSchemesManagerView: NSView = fontSchemesManagerViewController.view
    
    private lazy var colorSchemesManagerViewController: NSViewController = ColorSchemesManagerViewController()
    private lazy var colorSchemesManagerView: NSView = colorSchemesManagerViewController.view
    
    private lazy var effectsPresetsManagerViewLoader: LazyViewLoader<EffectsPresetsManagerViewController> = LazyViewLoader()
    private lazy var effectsPresetsManagerView: NSView = effectsPresetsManagerViewLoader.view
    
    override var windowNibName: String? {"PresetsManagerWindow"}
    
    private var addedViews: Set<NSView> = Set()
    
    override func windowDidLoad() {
        theWindow.isMovableByWindowBackground = true
    }
    
    override func destroy() {
        
        addedViews.removeAll()
        effectsPresetsManagerViewLoader.destroy()
    }
    
    var isModal: Bool {self.window?.isVisible ?? false}
    
    func showManager(_ tableView: NSView) {
        
        if !addedViews.contains(tableView) {
            
            theWindow.contentView?.addSubview(tableView)
            addedViews.insert(tableView)
        }
        
        addedViews.forEach {$0.hide()}
        tableView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, tableView.height)
        theWindow.setFrame(frame, display: true)
        
        theWindow.showCenteredOnScreen()
    }
    
    func showLayoutsManager() {
        showManager(layoutsManagerView)
    }
    
    func showEffectsPresetsManager() {
        showManager(effectsPresetsManagerView)
    }
    
    func showThemesManager() {
        showManager(themesManagerView)
    }
    
    func showFontSchemesManager() {
        showManager(fontSchemesManagerView)
    }
    
    func showColorSchemesManager() {
        showManager(colorSchemesManagerView)
    }
}
