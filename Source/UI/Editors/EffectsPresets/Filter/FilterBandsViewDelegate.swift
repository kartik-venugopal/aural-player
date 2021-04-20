import Cocoa

protocol FilterBandsDataSource {
    
    func countFilterBands() -> Int
    
    func getFilterBand(_ index: Int) -> FilterBand
}

class AudioGraphFilterBandsDataSource: FilterBandsDataSource {
    
    private var filterUnit: FilterUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.filterUnit
    
    init(_ filterUnit: FilterUnitDelegateProtocol) {
        self.filterUnit = filterUnit
    }
    
    func countFilterBands() -> Int {filterUnit.bands.count}
    
    func getFilterBand(_ index: Int) -> FilterBand {filterUnit.bands[index]}
}

class FilterBandsViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    var dataSource: FilterBandsDataSource?
    
    var allowSelection: Bool = true
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        dataSource?.countFilterBands() ?? 0
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return GenericTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let band = dataSource?.getFilterBand(row) else {return nil}
        
        let colID = tableColumn!.identifier.rawValue
        var cellText: String
        
        switch colID {
            
        case UIConstants.filterBandsFreqColumnID:
            
            switch band.type {
                
            case .bandPass, .bandStop:
                
                cellText = String(format: "[ %@ - %@ ]", formatFreqNumber(band.minFreq!), formatFreqNumber(band.maxFreq!))
                
            case .lowPass:
                
                cellText = String(format: "< %@", formatFreqNumber(band.maxFreq!))
                
            case .highPass:
                
                cellText = String(format: "> %@", formatFreqNumber(band.minFreq!))
            }
            
        case UIConstants.filterBandsTypeColumnID:
            
            cellText = band.type.description
            
        default: return nil
            
        }
        
        return createCell(tableView, colID, row, cellText)
    }
    
    private func formatFreqNumber(_ freq: Float) -> String {
        
        let num = roundedInt(freq)
        if num % 1000 == 0 {
            return String(format: "%d KHz", num / 1000)
        } else {
            return String(format: "%d Hz", num)
        }
    }
    
    private func createCell(_ tableView: NSTableView, _ id: String, _ row: Int, _ text: String) -> BasicTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? BasicTableCellView else {return nil}
        
        cell.textField?.stringValue = text
        cell.textFont = Fonts.Standard.mainFont_10
        cell.selectedTextFont = Fonts.Standard.mainFont_10
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        return cell
    }
    
    // Row selection
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return allowSelection
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
    return NSUserInterfaceItemIdentifier(rawValue: input)
}
