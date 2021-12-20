//
//  AudioUnitsViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

/*
    View controller for the Audio Units view.
 */
class AudioUnitsViewController: NSViewController, Destroyable {
    
    override var nibName: String? {"AudioUnits"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
//    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tableScrollView: NSScrollView!
    @IBOutlet weak var tableClipView: NSClipView!

    // Audio Unit ID -> Dialog
    private var editorDialogs: [String: AudioUnitEditorDialogController] = [:]
    
    @IBOutlet weak var btnAudioUnitsMenu: NSPopUpButton!
    @IBOutlet weak var audioUnitsMenuIconItem: TintedIconMenuItem!
    @IBOutlet weak var btnRemove: TintedImageButton!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    let audioGraph: AudioGraphDelegateProtocol = objectGraph.audioGraphDelegate
    
    private let audioUnitsManager: AudioUnitsManager = objectGraph.audioUnitsManager
    
    let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    private lazy var windowLayoutsManager: WindowLayoutsManager = objectGraph.windowLayoutsManager
    
    private(set) lazy var messenger = Messenger(for: self)
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func viewDidLoad() {
        
        audioUnitsMenuIconItem.tintFunction = {Colors.functionButtonColor}
        btnRemove.tintFunction = {Colors.functionButtonColor}
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
        
        // Subscribe to notifications
        messenger.subscribe(to: .effects_unitStateChanged, handler: stateChanged)
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
        
        messenger.subscribe(to: .changeBackgroundColor, handler: changeBackgroundColor(_:))
        
        messenger.subscribe(to: .changeMainCaptionTextColor, handler: changeMainCaptionTextColor(_:))
        messenger.subscribe(to: .changeFunctionButtonColor, handler: changeFunctionButtonColor(_:))
        
        messenger.subscribe(to: .effects_changeActiveUnitStateColor, handler: changeActiveUnitStateColor(_:))
        messenger.subscribe(to: .effects_changeBypassedUnitStateColor, handler: changeBypassedUnitStateColor(_:))
        messenger.subscribe(to: .effects_changeSuppressedUnitStateColor, handler: changeSuppressedUnitStateColor(_:))
        
        messenger.subscribe(to: .playlist_changeSelectionBoxColor, handler: changeSelectionBoxColor(_:))
        messenger.subscribe(to: .playlist_changeTrackNameTextColor, handler: changeAURowTextColor(_:))
        messenger.subscribe(to: .playlist_changeTrackNameSelectedTextColor, handler: changeAURowSelectedTextColor(_:))
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions

    @IBAction func addAudioUnitAction(_ sender: Any) {
        
        if let audioUnitComponent = btnAudioUnitsMenu.selectedItem?.representedObject as? AVAudioUnitComponent,
           let result = audioGraph.addAudioUnit(ofType: audioUnitComponent.audioComponentDescription.componentType,
                                                andSubType: audioUnitComponent.audioComponentDescription.componentSubType) {
            
            let audioUnit = result.0
            
            // Refresh the table view with the new row.
            tableView.noteNumberOfRowsChanged()
            
            // Create an editor dialog for the new audio unit.
            editorDialogs[audioUnit.id] = AudioUnitEditorDialogController(for: audioUnit)
            
            // Open the audio unit editor window with the new audio unit's custom view.
            DispatchQueue.main.async {

                self.doEditAudioUnit(audioUnit)
                self.messenger.publish(.auEffectsUnit_audioUnitsAddedOrRemoved)
                self.messenger.publish(.effects_unitStateChanged)
            }
        }
    }
    
    @IBAction func editAudioUnitAction(_ sender: Any) {
        
        let selectedRow = tableView.selectedRow
        
        if selectedRow >= 0 {

            // Open the audio unit editor window with the new audio unit's custom view.
            doEditAudioUnit(audioGraph.audioUnits[selectedRow])
        }
    }
    
    func doEditAudioUnit(_ audioUnit: HostedAudioUnitDelegateProtocol) {
        
        if editorDialogs[audioUnit.id] == nil {
            editorDialogs[audioUnit.id] = AudioUnitEditorDialogController(for: audioUnit)
        }
        
        if let dialog = editorDialogs[audioUnit.id], let dialogWindow = dialog.window {
            
            windowLayoutsManager.addChildWindow(dialogWindow)
            dialog.showWindow(self)
        }
    }
    
    @IBAction func removeAudioUnitsAction(_ sender: Any) {
        
        let selRows = tableView.selectedRowIndexes
        
        if !selRows.isEmpty {
            
            for unit in audioGraph.removeAudioUnits(at: selRows) {
                
                editorDialogs[unit.id]?.close()
                editorDialogs.removeValue(forKey: unit.id)
            }
            
            tableView.reloadData()
            messenger.publish(.auEffectsUnit_audioUnitsAddedOrRemoved)
            messenger.publish(.effects_unitStateChanged)
        }
    }
    
    private func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
//        lblCaption.font = fontSchemesManager.systemScheme.effects.unitCaptionFont
        tableView.reloadAllRows(columns: [1])
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeMainCaptionTextColor(scheme.general.mainCaptionTextColor)
        
        audioUnitsMenuIconItem.reTint()
        btnRemove.reTint()
        
        tableView.reloadDataMaintainingSelection()
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        tableScrollView.backgroundColor = color
        tableClipView.backgroundColor = color
        tableView.backgroundColor = color
    }
    
    func changeMainCaptionTextColor(_ color: NSColor) {
//        lblCaption.textColor = color
    }
    
    func changeAURowTextColor(_ color: NSColor) {
        tableView.reloadAllRows(columns: [1])
    }
    
    func changeAURowSelectedTextColor(_ color: NSColor) {
        tableView.reloadRows(tableView.selectedRowIndexes, columns: [1])
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        
        let rowsForActiveUnits: [Int] = tableView.allRowIndices.filter {audioGraph.audioUnits[$0].state == .active}
        tableView.reloadRows(rowsForActiveUnits, columns: [0])
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        
        let rowsForBypassedUnits: [Int] = tableView.allRowIndices.filter {audioGraph.audioUnits[$0].state == .bypassed}
        tableView.reloadRows(rowsForBypassedUnits, columns: [0])
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        let rowsForSuppressedUnits: [Int] = tableView.allRowIndices.filter {audioGraph.audioUnits[$0].state == .suppressed}
        tableView.reloadRows(rowsForSuppressedUnits, columns: [0])
    }
    
    func stateChanged() {
        tableView.reloadAllRows(columns: [0])
    }
    
    func changeFunctionButtonColor(_ color: NSColor) {
        
        audioUnitsMenuIconItem.reTint()
        btnRemove.reTint()
        
        tableView.reloadAllRows(columns: [2])
    }
    
    private func changeSelectionBoxColor(_ color: NSColor) {
        tableView.redoRowSelection()
    }
}

// ------------------------------------------------------------------------

// MARK: NSMenuDelegate

extension AudioUnitsViewController: NSMenuDelegate {
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all dynamic items (all items after the first icon item).
        while menu.items.count > 1 {
            menu.removeItem(at: 1)
        }
        
        for unit in audioUnitsManager.audioUnits {

            let itemTitle = "\(unit.name) v\(unit.versionString) by \(unit.manufacturerName)"
            let item = NSMenuItem(title: itemTitle)
            item.target = self
            item.representedObject = unit
            
            menu.addItem(item)
        }
    }
}
