//
//  MasterUnitViewController+AUTableViewDelegate.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

fileprivate let auTableRowHeight: CGFloat = 24

// ------------------------------------------------------------------------

// MARK: NSTableViewDataSource

extension MasterUnitViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        graph.audioUnits.count
    }
}

// ------------------------------------------------------------------------

// MARK: NSTableViewDelegate

extension MasterUnitViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {auTableRowHeight}
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {false}
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AudioUnitsTableRowView()
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let colID = tableColumn?.identifier else {return nil}
        
        switch colID {
        
        case .cid_audioUnitSwitch:
            
            return createSwitchCell(tableView, colID, row)
            
        case .cid_audioUnitName:
            
            return createNameCell(tableView, colID, row)
            
        default:
            
            return nil
        }
    }

    private func createSwitchCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ row: Int) -> AudioUnitSwitchCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? AudioUnitSwitchCellView else {return nil}
        
        let audioUnit = graph.audioUnits[row]
        
        cell.btnSwitch.stateFunction = audioUnit.stateFunction
        
        cell.btnSwitch.offStateTooltip = "Activate this Audio Unit"
        cell.btnSwitch.onStateTooltip = "Deactivate this Audio Unit"
        
        cell.btnSwitch.updateState()
        
        cell.action = {[weak self] in
            
            _ = audioUnit.toggleState()
            self?.messenger.publish(.effects_unitStateChanged)
        }
        
        return cell
    }
    
    private var systemFontScheme: EffectsFontScheme {fontSchemesManager.systemScheme.effects}
    private var systemColorScheme: EffectsColorScheme {colorSchemesManager.systemScheme.effects}
    
    private func createNameCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ row: Int) -> MasterUnitAUTableNameCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? MasterUnitAUTableNameCellView else {return nil}
        
        let audioUnit = graph.audioUnits[row]
        
        cell.text = audioUnit.name
        cell.textFont = systemFontScheme.unitFunctionFont
        cell.realignText(yOffset: systemFontScheme.auRowTextYOffset)
        
        switch audioUnit.state {
        
        case .active:
            
            cell.textColor = systemColorScheme.activeUnitStateColor
            
        case .bypassed:
            
            cell.textColor = systemColorScheme.bypassedUnitStateColor
            
        case .suppressed:
            
            cell.textColor = systemColorScheme.suppressedUnitStateColor
        }
        
        return cell
    }
}

class MasterUnitAUTableNameCellView: NSTableCellView {
    
    private lazy var textFieldConstraintsManager = LayoutConstraintsManager(for: textField!)
    
    // Constraints
    func realignText(yOffset: CGFloat) {
        
        textFieldConstraintsManager.removeAll(withAttributes: [.bottom])
        textFieldConstraintsManager.setBottom(relatedToBottomOf: self, offset: yOffset)
    }
}
