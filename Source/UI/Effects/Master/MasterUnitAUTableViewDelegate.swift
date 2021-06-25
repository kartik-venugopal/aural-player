//
//  MasterUnitAUTableViewDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

class MasterUnitAUTableViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return audioGraph.audioUnits.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {false}
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AudioUnitsTableRowView()
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let colID = tableColumn?.identifier else {return nil}
        
        switch colID {
        
        case .uid_audioUnitSwitch:
            
            return createSwitchCell(tableView, colID, row)
            
        case .uid_audioUnitName:
            
            return createNameCell(tableView, colID, row)
            
        default: return nil
            
        }
    }

    private func createSwitchCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ row: Int) -> AudioUnitSwitchCellView? {
     
        if let cell = tableView.makeView(withIdentifier: id, owner: nil) as? AudioUnitSwitchCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.btnSwitch.stateFunction = audioUnit.stateFunction
            
            cell.btnSwitch.offStateTooltip = "Activate this Audio Unit"
            cell.btnSwitch.onStateTooltip = "Deactivate this Audio Unit"
            
            cell.btnSwitch.updateState()
            
            cell.action = {
                
                _ = audioUnit.toggleState()
                Messenger.publish(.effects_unitStateChanged)
            }
            
            return cell
        }
        
        return nil
    }
    
    private func createNameCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ row: Int) -> MasterUnitAUTableNameCellView? {
        
        if let cell = tableView.makeView(withIdentifier: id, owner: nil) as? MasterUnitAUTableNameCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.textField?.stringValue = audioUnit.name
            cell.textField?.font = fontSchemesManager.systemScheme.effects.unitFunctionFont
            cell.realignText(yOffset: fontSchemesManager.systemScheme.effects.auRowTextYOffset)

            switch audioUnit.state {
            
            case .active:
                
                cell.textField?.textColor = colorSchemesManager.systemScheme.effects.activeUnitStateColor
                
            case .bypassed:
                
                cell.textField?.textColor = colorSchemesManager.systemScheme.effects.bypassedUnitStateColor
                
            case .suppressed:
                
                cell.textField?.textColor = colorSchemesManager.systemScheme.effects.suppressedUnitStateColor
            }
            
            return cell
        }
        
        return nil
    }
}

class MasterUnitAUTableNameCellView: NSTableCellView {
    
    // Constraints
    func realignText(yOffset: CGFloat) {
        
        guard let textField = self.textField else {return}
        
        // Remove any existing constraints on the text field's 'bottom' attribute
        self.constraints.filter {$0.firstItem === textField && $0.firstAttribute == .bottom}.forEach {self.deactivateAndRemoveConstraint($0)}

        let textFieldBottomConstraint = NSLayoutConstraint(item: textField, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: yOffset)
        
        self.activateAndAddConstraint(textFieldBottomConstraint)
    }
}
