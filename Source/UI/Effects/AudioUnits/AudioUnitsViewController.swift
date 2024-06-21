//
//  AudioUnitsViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

/*
    View controller for the Audio Units view.
 */
class AudioUnitsViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"AudioUnits"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var lblSummary: NSTextField!

    // Audio Unit ID -> Dialog
    private var editorDialogs: [String: AudioUnitEditorDialogController] = [:]
    
    @IBOutlet weak var btnAudioUnitsMenu: NSPopUpButton!
    @IBOutlet weak var btnRemove: TintedImageButton!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    let audioGraph: AudioGraphDelegateProtocol = audioGraphDelegate
    
    private(set) lazy var messenger = Messenger(for: self)
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        updateSummary()
        
        fontSchemesManager.registerObserver(self)

        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: backgroundColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primaryTextColor, handler: primaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceiver: lblSummary)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primarySelectedTextColor, handler: primarySelectedTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.textSelectionColor, handler: textSelectionColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: [btnRemove, btnAudioUnitsMenu])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, handler: buttonColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, handler: activeControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.inactiveControlColor, handler: inactiveControlColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.suppressedControlColor, handler: suppressedControlColorChanged(_:))
        
        messenger.subscribeAsync(to: .Effects.auStateChanged, handler: {[weak self] in
            
            self?.tableView.reloadData()
            self?.updateSummary()
        })
    }
    
    override func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions

    @IBAction func addAudioUnitAction(_ sender: Any) {
        
        guard let audioUnitComponent = btnAudioUnitsMenu.selectedItem?.representedObject as? AVAudioUnitComponent,
              let result = audioGraph.addAudioUnit(ofType: audioUnitComponent.audioComponentDescription.componentType,
                                                   andSubType: audioUnitComponent.audioComponentDescription.componentSubType) else {return}
        
        let audioUnit = result.audioUnit
        
        // Refresh the table view with the new row.
        tableView.noteNumberOfRowsChanged()
        updateSummary()
        
        // Create an editor dialog for the new audio unit.
        editorDialogs[audioUnit.id] = AudioUnitEditorDialogController(for: audioUnit)
        
        // Open the audio unit editor window with the new audio unit's custom view.
        DispatchQueue.main.async {
            
            self.doEditAudioUnit(audioUnit)
            self.messenger.publish(.Effects.audioUnitAdded, payload: audioUnit)
            self.messenger.publish(.Effects.unitStateChanged)
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
        
        guard let dialog = editorDialogs[audioUnit.id], let dialogWindow = dialog.window else {return}
        
        switch appModeManager.currentMode {
            
        case .modular:
            windowLayoutsManager.addChildWindow(dialogWindow)
            
        case .unified:
            
            if let window = NSApp.windows.first(where: {$0.identifier?.rawValue == "unifiedPlayer"}) {
                window.addChildWindow(dialogWindow, ordered: .above)
            }
            
        case .compact:
            
            if let window = NSApp.windows.first(where: {$0.identifier?.rawValue == "compactPlayer"}) {
                window.addChildWindow(dialogWindow, ordered: .above)
            }
            
        default:
            return
            
        }
        
        dialog.showWindow(self)
    }
    
    func toggleAudioUnitState(audioUnit: HostedAudioUnitDelegateProtocol) {
        
        _ = audioUnit.toggleState()
        messenger.publish(.Effects.unitStateChanged)
        updateSummary()
    }
    
    @IBAction func removeAudioUnitsAction(_ sender: Any) {
        
        let selRows = tableView.selectedRowIndexes
        guard !selRows.isEmpty else {return}
        
        for unit in audioGraph.removeAudioUnits(at: selRows) {
            
            editorDialogs[unit.id]?.close()
            editorDialogs.removeValue(forKey: unit.id)
        }
        
        tableView.reloadData()
        updateSummary()
        
        messenger.publish(.Effects.audioUnitsRemoved, payload: selRows)
        messenger.publish(.Effects.unitStateChanged)
    }
    
    private func updateSummary() {
        
        let audioUnits = audioGraph.audioUnits
        let numberOfAUs = audioUnits.count
        
        if numberOfAUs > 0 {
            
            let numberOfActiveAUs = audioUnits.filter {$0.state != .bypassed}.count
            let unitOrUnitsString = numberOfAUs == 1 ? "Unit" : "Units"
            
            lblSummary.stringValue = "\(numberOfAUs) Audio \(unitOrUnitsString) (\(numberOfActiveAUs) active)"
            
        } else {
            lblSummary.stringValue = "0 Audio Units"
        }
    }
}

extension AudioUnitsViewController: ThemeInitialization {
    
    func initTheme() {
        
        tableView.colorSchemeChanged()
        
        lblSummary.font = systemFontScheme.smallFont
        lblSummary.textColor = systemColorScheme.secondaryTextColor
        
        btnRemove.contentTintColor = systemColorScheme.buttonColor
        btnAudioUnitsMenu.colorChanged(systemColorScheme.buttonColor)
    }
}

extension AudioUnitsViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        tableView.reloadAllRows(columns: [1])
        lblSummary.font = systemFontScheme.smallFont
    }
}

extension AudioUnitsViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        tableView.colorSchemeChanged()
        
        btnRemove.contentTintColor = systemColorScheme.buttonColor
        btnAudioUnitsMenu.colorChanged(systemColorScheme.buttonColor)
        
        lblSummary.textColor = systemColorScheme.secondaryTextColor
    }
    
    private func backgroundColorChanged(_ newColor: NSColor) {
        tableView.setBackgroundColor(newColor)
    }
    
    func primaryTextColorChanged(_ newColor: NSColor) {
        tableView.reloadAllRows(columns: [1])
    }
    
    func primarySelectedTextColorChanged(_ newColor: NSColor) {
        tableView.reloadRows(tableView.selectedRowIndexes, columns: [1])
    }
    
    func activeControlColorChanged(_ newColor: NSColor) {
        
        let rowsForActiveUnits: [Int] = tableView.allRowIndices.filter {audioGraph.audioUnits[$0].state == .active}
        tableView.reloadRows(rowsForActiveUnits, columns: [0])
    }
    
    func inactiveControlColorChanged(_ newColor: NSColor) {
        
        let rowsForBypassedUnits: [Int] = tableView.allRowIndices.filter {audioGraph.audioUnits[$0].state == .bypassed}
        tableView.reloadRows(rowsForBypassedUnits, columns: [0])
    }
    
    func suppressedControlColorChanged(_ newColor: NSColor) {
        
        let rowsForSuppressedUnits: [Int] = tableView.allRowIndices.filter {audioGraph.audioUnits[$0].state == .suppressed}
        tableView.reloadRows(rowsForSuppressedUnits, columns: [0])
    }
    
    func buttonColorChanged(_ newColor: NSColor) {
        tableView.reloadAllRows(columns: [2])
    }
    
    private func textSelectionColorChanged(_ newColor: NSColor) {
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
