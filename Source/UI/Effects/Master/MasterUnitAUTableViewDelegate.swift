import Cocoa
import AVFoundation

class MasterUnitAUTableViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return audioGraph.audioUnits.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 22
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {false}
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AudioUnitsTableRowView()
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableColumn!.identifier {
        
        case .uid_audioUnitSwitch:
            
            return createSwitchCell(tableView, tableColumn!.identifier.rawValue, row)
            
        case .uid_audioUnitName:
            
            return createNameCell(tableView, tableColumn!.identifier.rawValue, row)
            
        case .uid_audioUnitIcon:
            
            return createIconCell(tableView, tableColumn!.identifier.rawValue, row)
            
        default: return nil
            
        }
    }

    private func createSwitchCell(_ tableView: NSTableView, _ id: String, _ row: Int) -> AudioUnitSwitchCellView? {
     
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(id), owner: nil) as? AudioUnitSwitchCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.btnSwitch.stateFunction = audioUnit.stateFunction
            cell.btnSwitch.updateState()
            
            cell.action = {
                
                _ = audioUnit.toggleState()
                cell.btnSwitch.updateState()
                Messenger.publish(.fx_unitStateChanged)
            }
            
            return cell
        }
        
        return nil
    }
    
    private func createNameCell(_ tableView: NSTableView, _ id: String, _ row: Int) -> AudioUnitNameCellView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(id), owner: nil) as? AudioUnitNameCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.textField?.stringValue = audioUnit.name
            cell.textField?.font = FontSchemes.systemScheme.effects.unitFunctionFont
            cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
            
            return cell
        }
        
        return nil
    }
    
    private func createIconCell(_ tableView: NSTableView, _ id: String, _ row: Int) -> AudioUnitIconCellView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(id), owner: nil) as? AudioUnitIconCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.imgIcon.stateFunction = audioUnit.stateFunction
            cell.imgIcon.updateState()
            
            return cell
        }
        
        return nil
    }
}

@IBDesignable
class AudioUnitIconCellView: NSTableCellView {
    
    @IBOutlet weak var imgIcon: EffectsUnitTriStateBypassImage!
}

extension NSUserInterfaceItemIdentifier {
    
    static let uid_audioUnitIcon: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.audioUnitEditColumnID)
}
