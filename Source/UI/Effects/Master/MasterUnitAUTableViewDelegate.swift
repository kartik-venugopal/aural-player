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
    
    private let audioGraph: AudioGraphDelegateProtocol = objectGraph.audioGraphDelegate
    
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    private lazy var messenger = Messenger(for: self)
    
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
                self.messenger.publish(.effects_unitStateChanged)
            }
            
            return cell
        }
        
        return nil
    }
    
    private func createNameCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ row: Int) -> MasterUnitAUTableNameCellView? {
        
        if let cell = tableView.makeView(withIdentifier: id, owner: nil) as? MasterUnitAUTableNameCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.text = audioUnit.name
            cell.textFont = fontSchemesManager.systemScheme.effects.unitFunctionFont
            cell.realignText(yOffset: fontSchemesManager.systemScheme.effects.auRowTextYOffset)

            switch audioUnit.state {
            
            case .active:
                
                cell.textColor = colorSchemesManager.systemScheme.effects.activeUnitStateColor
                
            case .bypassed:
                
                cell.textColor = colorSchemesManager.systemScheme.effects.bypassedUnitStateColor
                
            case .suppressed:
                
                cell.textColor = colorSchemesManager.systemScheme.effects.suppressedUnitStateColor
            }
            
            return cell
        }
        
        return nil
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
