import Cocoa

class FilterBandsViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    private var graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return graph.allFilterBands().count
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AuralTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let band = graph.getFilterBand(row)
        
        switch tableColumn!.identifier.rawValue {
            
        case UIConstants.filterBandsFreqColumnID:
            
            let rangeText = String(format: "[ %@ - %@ ]", formatFreqNumber(band.minFreq!), formatFreqNumber(band.maxFreq!))
            return createCell(tableView, tableColumn!.identifier.rawValue, row, rangeText)
            
        case UIConstants.filterBandsTypeColumnID:
            
            let typeText = band.type.rawValue
            return createCell(tableView, tableColumn!.identifier.rawValue, row, typeText)
            
        default: return nil
            
        }
    }
    
    private func formatFreqNumber(_ freq: Float) -> String {
        
        let num = Int(freq)
        if num % 1024 == 0 {
            return String(format: "%dKHz", num / 1024)
        } else {
            return String(format: "%dHz", num)
        }
    }
    
    private func createCell(_ tableView: NSTableView, _ id: String, _ row: Int, _ text: String) -> BasicTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? BasicTableCellView {
            
            cell.textField?.stringValue = text
            cell.row = row
            cell.textFont = Fonts.gillSans10Font
            cell.selectedTextFont = Fonts.gillSansSemiBold10Font
            cell.selectionFunction = {() -> Bool in
                return tableView.selectedRowIndexes.contains(row)
            }
            
            return cell
        }
        
        return nil
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSUserInterfaceItemIdentifier(_ input: NSUserInterfaceItemIdentifier) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
    return NSUserInterfaceItemIdentifier(rawValue: input)
}
