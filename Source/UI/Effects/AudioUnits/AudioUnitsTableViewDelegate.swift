import Cocoa
import AVFoundation

class AudioUnitsTableViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
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
            
            return createNameCell(tableView, tableColumn!.identifier.rawValue, row, "\(row)")
            
        case .uid_audioUnitName:
            
            return createNameCell(tableView, tableColumn!.identifier.rawValue, row, audioGraph.audioUnits[row].name)
            
        case .uid_audioUnitEdit:
            
            return createNameCell(tableView, tableColumn!.identifier.rawValue, row, "\(row)")
            
        default: return nil
            
        }
    }
    
//    private func createSwitchCell(_ tableView: NSTableView, _ id: String, _ row: Int, _ state: EffectsUnitState) -> AudioUnitSwitchCellView? {
//        
//        
//    }
    
    private func createNameCell(_ tableView: NSTableView, _ id: String, _ row: Int, _ text: String) -> BasicTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(id), owner: nil) as? BasicTableCellView {
            
            cell.textField?.stringValue = text
            cell.textFont = FontSchemes.systemScheme.effects.unitFunctionFont
            cell.selectedTextFont = FontSchemes.systemScheme.effects.unitFunctionFont
            cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
            
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
