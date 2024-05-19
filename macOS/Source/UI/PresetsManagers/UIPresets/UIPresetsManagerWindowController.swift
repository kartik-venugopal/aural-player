//
//  UIPresetsManagerWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class UIPresetsManagerWindowController: SingletonWindowController, ModalComponentProtocol {
    
    override var windowNibName: NSNib.Name? {"UIPresetsManager"}
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var toolbar: NSToolbar!
    
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnApply: NSButton!
    @IBOutlet weak var btnRename: NSButton?
    
    private lazy var themesManagerViewController: NSViewController = ThemesManagerViewController()
    private lazy var fontSchemesManagerViewController: NSViewController = FontSchemesManagerViewController()
    private lazy var colorSchemesManagerViewController: NSViewController = ColorSchemesManagerViewController()
    private lazy var layoutsManagerViewController: NSViewController = LayoutsManagerViewController()
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        let viewControllers = [themesManagerViewController, fontSchemesManagerViewController, colorSchemesManagerViewController, layoutsManagerViewController]
        for (index, viewController) in viewControllers.enumerated() {
            
            tabView.tabViewItem(at: index).view?.addSubview(viewController.view)
            viewController.view.anchorToSuperview()
        }
        
        toolbar.selectedItemIdentifier = NSToolbarItem.Identifier("Themes")
        
        messenger.subscribe(to: .PresetsManager.selectionChanged, handler: updateButtonStates(numberOfSelectedRows:))
    }
    
    var isModal: Bool {self.window?.isVisible ?? false}
    
    private func disableButtons() {
        [btnApply, btnRename, btnDelete].forEach {$0?.disable()}
    }
    
    private func updateButtonStates(numberOfSelectedRows: Int) {
        
        btnDelete.enableIf(numberOfSelectedRows > 0)
        [btnApply, btnRename].forEach {$0?.enableIf(numberOfSelectedRows == 1)}
    }
    
    func showThemesManager() {
        
        forceLoadingOfWindow()
        window?.showCenteredOnScreen()
        toolbar.selectedItemIdentifier = NSToolbarItem.Identifier("Themes")
        
        doShowThemesManager()
    }
    
    private func doShowThemesManager() {
        
        tabView.selectTabViewItem(at: 0)
        disableButtons()
    }
    
    func showFontSchemesManager() {
        
        forceLoadingOfWindow()
        window?.showCenteredOnScreen()
        toolbar.selectedItemIdentifier = NSToolbarItem.Identifier("FontSchemes")
        
        doShowFontSchemesManager()
    }
    
    private func doShowFontSchemesManager() {
        
        tabView.selectTabViewItem(at: 1)
        disableButtons()
    }
    
    func showColorSchemesManager() {
        
        forceLoadingOfWindow()
        window?.showCenteredOnScreen()
        toolbar.selectedItemIdentifier = NSToolbarItem.Identifier("ColorSchemes")
        
        doShowColorSchemesManager()
    }
    
    private func doShowColorSchemesManager() {
        
        tabView.selectTabViewItem(at: 2)
        disableButtons()
    }
    
    func showLayoutsManager() {
        
        forceLoadingOfWindow()
        window?.showCenteredOnScreen()
        toolbar.selectedItemIdentifier = NSToolbarItem.Identifier("WindowLayouts")
        
        doShowLayoutsManager()
    }
    
    private func doShowLayoutsManager() {
        
        tabView.selectTabViewItem(at: 3)
        disableButtons()
    }
    
    @IBAction func toolbarItemAction(_ sender: NSToolbarItem) {
        
        switch sender.itemIdentifier.rawValue {
            
        case "Themes":
            doShowThemesManager()
            
        case "FontSchemes":
            doShowFontSchemesManager()
            
        case "ColorSchemes":
            doShowColorSchemesManager()
            
        case "WindowLayouts":
            doShowLayoutsManager()
            
        default:
            return
        }
    }
    
    @IBAction func deleteSelectedPresetsAction(_ sender: AnyObject) {
        
//        deletePresets(atIndices: tableView.selectedRowIndexes)
//        
//        tableView.reloadData()
//        tableView.deselectAll(self)
////        Messenger.publish(.PresetsManager.selectionChanged, payload: tableView.numberOfSelectedRows)
    }
    
    @IBAction func applySelectedPresetAction(_ sender: AnyObject) {
//        applyPreset(atIndex: tableView.selectedRow)
    }
    
    @IBAction func renamePresetAction(_ sender: AnyObject) {
        
//        let rowIndex = tableView.selectedRow
//        let rowView = tableView.rowView(atRow: rowIndex, makeIfNecessary: true)
//        
//        if let editedTextField = (rowView?.view(atColumn: 0) as? NSTableCellView)?.textField {
//            
//            tableView.window?.makeFirstResponder(editedTextField)
//        }
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        window?.close()
    }
}
