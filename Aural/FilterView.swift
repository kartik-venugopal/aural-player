import Cocoa

class FilterView: NSView {
    
    @IBOutlet weak var chart: FilterChart!
    @IBOutlet weak var bandsView: NSTabView!
    
    func initialize(_ stateFunction: @escaping () -> EffectsUnitState, _ bandsDataFunction: @escaping () -> [FilterBand], _ tableDataSource: FilterBandsDataSource, _ allowTableRowSelection: Bool = true) {
        
        chart.filterUnitStateFunction = stateFunction
        chart.bandsDataFunction = bandsDataFunction
    }
    
    func refresh() {
        chart.redraw()
    }
    
    func redrawChart() {
        chart.redraw()
    }
    
    func bandsAddedOrRemoved() {
        redrawChart()
    }
    
    func bandsRemoved() {
        redrawChart()
    }
    
    func bandEdited() {
        redrawChart()
    }
    
    func addBandView(_ view: NSView) {
        
        let numItems = bandsView.numberOfTabViewItems
        let title = String(format: "Band %d", numItems)
        let newItem = NSTabViewItem(identifier: title)
        newItem.label = title
        bandsView.addTabViewItem(newItem)
        
        newItem.view?.addSubview(view)
    }
}
