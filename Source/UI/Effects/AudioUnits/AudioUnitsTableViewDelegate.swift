import Cocoa
import AVFoundation

class AudioUnitsTableViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    private let audioUnitEditorDialog: AudioUnitEditorDialogController = WindowFactory.audioUnitEditorDialog
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return audioGraph.audioUnits.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 24
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return GenericTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableColumn!.identifier {
        
        case .uid_audioUnitSwitch:
            
            return createSwitchCell(tableView, tableColumn!.identifier.rawValue, row)
            
        case .uid_audioUnitName:
            
            return createNameCell(tableView, tableColumn!.identifier.rawValue, row)
            
        case .uid_audioUnitEdit:
            
            return createEditCell(tableView, tableColumn!.identifier.rawValue, row)
            
        default: return nil
            
        }
    }
    
    private func createSwitchCell(_ tableView: NSTableView, _ id: String, _ row: Int) -> AudioUnitSwitchCellView? {
     
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(id), owner: nil) as? AudioUnitSwitchCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.btnSwitch.stateFunction = audioUnit.stateFunction
            
            cell.btnSwitch.offStateTooltip = "Activate this Audio Unit"
            cell.btnSwitch.onStateTooltip = "Deactivate this Audio Unit"
            
            cell.btnSwitch.updateState()
            
            cell.action = {
                
                _ = audioUnit.toggleState()
                cell.btnSwitch.updateState()
            }
            
            return cell
        }
        
        return nil
    }
    
    private func createNameCell(_ tableView: NSTableView, _ id: String, _ row: Int) -> BasicTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(id), owner: nil) as? BasicTableCellView {
            
            cell.textField?.stringValue = audioGraph.audioUnits[row].name
            cell.textFont = FontSchemes.systemScheme.effects.unitFunctionFont
            cell.selectedTextFont = FontSchemes.systemScheme.effects.unitFunctionFont
            cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
            
            return cell
        }
        
        return nil
    }
    
    private func createEditCell(_ tableView: NSTableView, _ id: String, _ row: Int) -> AudioUnitEditCellView? {
     
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(id), owner: nil) as? AudioUnitEditCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.action = {
                self.audioUnitEditorDialog.showDialog(for: audioUnit)
            }
            
            return cell
        }
        
        return nil
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let uid_audioUnitSwitch: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.audioUnitSwitchColumnID)
    static let uid_audioUnitName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.audioUnitNameColumnID)
    static let uid_audioUnitEdit: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.audioUnitEditColumnID)
}
