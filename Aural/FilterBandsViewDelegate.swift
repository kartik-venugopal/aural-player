import Cocoa

protocol FilterBandsDataSource {
    
    func countFilterBands() -> Int
    
    func getFilterBand(_ index: Int) -> FilterBand
}

class AudioGraphFilterBandsDataSource: FilterBandsDataSource {
    
    private var filterUnit: FilterUnitDelegate = ObjectGraph.getAudioGraphDelegate().filterUnit
    
    init(_ filterUnit: FilterUnitDelegate) {
        self.filterUnit = filterUnit
    }
    
    func countFilterBands() -> Int {
        return filterUnit.bands.count
    }
    
    func getFilterBand(_ index: Int) -> FilterBand {
        return filterUnit.bands[index]
    }
}

class FilterBandsViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    var dataSource: FilterBandsDataSource?
    
    var allowSelection: Bool = true
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSource?.countFilterBands() ?? 0
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AuralTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let band = dataSource!.getFilterBand(row)
        
        switch tableColumn!.identifier.rawValue {
            
        case UIConstants.filterBandsFreqColumnID:
            
            switch band.type {
                
            case .bandPass, .bandStop:
                
                let rangeText = String(format: "[ %@ - %@ ]", formatFreqNumber(band.minFreq!), formatFreqNumber(band.maxFreq!))
                return createCell(tableView, tableColumn!.identifier.rawValue, row, rangeText)
                
            case .lowPass:
                
                let cutoffText = String(format: "< %@", formatFreqNumber(band.maxFreq!))
                return createCell(tableView, tableColumn!.identifier.rawValue, row, cutoffText)
                
            case .highPass:
                
                let cutoffText = String(format: "> %@", formatFreqNumber(band.minFreq!))
                return createCell(tableView, tableColumn!.identifier.rawValue, row, cutoffText)
            }
            
            
            
        case UIConstants.filterBandsTypeColumnID:
            
            let typeText = band.type.rawValue
            return createCell(tableView, tableColumn!.identifier.rawValue, row, typeText)
            
        default: return nil
            
        }
    }
    
    private func formatFreqNumber(_ freq: Float) -> String {
        
        let num = roundedInt(freq)
        if num % 1000 == 0 {
            return String(format: "%dKHz", num / 1000)
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
    
    // Completely disable row selection
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return allowSelection
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
