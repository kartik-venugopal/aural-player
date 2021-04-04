import Cocoa
import AVFoundation

class AudioUnitsListTableViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    var components: [AVAudioUnitComponent] = []
    let componentsBlackList: Set<String> = ["AUNewPitch", "AURoundTripAAC", "AUNetSend"]
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        let desc = AudioComponentDescription(componentType: kAudioUnitType_Effect,
                                             componentSubType: 0,
                                             componentManufacturer: 0,
                                             componentFlags: 0,
                                             componentFlagsMask: 0)

        self.components = AVAudioUnitComponentManager.shared().components(matching: desc)
            .filter {$0.hasCustomView && !componentsBlackList.contains($0.name)}
        
        return components.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 24
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return GenericTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if row < components.count {
            return createCell(tableView, tableColumn!.identifier.rawValue, row, components[row].name)
        }
        
        return nil
    }
    
    private func createCell(_ tableView: NSTableView, _ id: String, _ row: Int, _ text: String) -> BasicTableCellView? {
        
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
