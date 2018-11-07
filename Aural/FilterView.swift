import Cocoa

class FilterView: NSView {
    
    @IBOutlet weak var bandsTable: NSTableView!
    @IBOutlet weak var tableViewDelegate: FilterBandsViewDelegate!
    
    @IBOutlet weak var chart: FilterChart!
    
    func initialize(_ stateFunction: @escaping () -> EffectsUnitState, _ bandsDataFunction: @escaping () -> [FilterBand], _ tableDataSource: FilterBandsDataSource, _ allowTableRowSelection: Bool = true) {
        
        chart.filterUnitStateFunction = stateFunction
        chart.bandsDataFunction = bandsDataFunction
        tableViewDelegate.dataSource = tableDataSource
        tableViewDelegate.allowSelection = allowTableRowSelection
    }
    
    func refresh() {
        
        chart.redraw()
        bandsTable.reloadData()
    }
    
    func redrawChart() {
        chart.redraw()
    }
    
    func tableRowsAddedOrRemoved() {
        bandsTable.noteNumberOfRowsChanged()
        redrawChart()
    }
    
    var numberOfSelectedRows: Int {
        return bandsTable.numberOfSelectedRows
    }
    
    var selectedRow: Int {
        return bandsTable.selectedRow
    }
    
    func refreshSelectedRow() {
        bandsTable.reloadData(forRowIndexes: IndexSet([selectedRow]), columnIndexes: [0, 1])
    }
    
    var selectedRows: IndexSet {
        return bandsTable.selectedRowIndexes
    }
    
    func deselectAllRows() {
        bandsTable.selectRowIndexes(IndexSet([]), byExtendingSelection: false)
    }
    
    func bandsRemoved() {
        
        bandsTable.reloadData()
        deselectAllRows()
        redrawChart()
    }
    
    func bandEdited() {
        
        refreshSelectedRow()
        redrawChart()
    }
}
