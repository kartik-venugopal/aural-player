import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterViewController: FXUnitViewController {
    
    @IBOutlet weak var filterView: FilterView!
    private lazy var editor: FilterBandEditorController = FilterBandEditorController()
    
    override var nibName: String? {return "Filter"}
    
    var filterUnit: FilterUnitDelegate {return graph.filterUnit}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .filter
        fxUnit = filterUnit
        unitStateFunction = filterStateFunction
        presetsWrapper = PresetsWrapper<FilterPreset, FilterPresets>(filterUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()

        let bandsDataFunction = {() -> [FilterBand] in return self.filterUnit.bands}
        filterView.initialize(filterStateFunction, bandsDataFunction, AudioGraphFilterBandsDataSource(filterUnit))
    }
 
    override func initControls() {

        super.initControls()
        filterView.refresh()
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction override func bypassAction(_ sender: AnyObject) {
        
        super.bypassAction(sender)
        filterView.refresh()
    }
    
    @IBAction func editBandAction(_ sender: AnyObject) {
        
        if filterView.numberOfSelectedRows == 1 {
            
            let index = filterView.selectedRow
            editor.editBand(index, filterUnit.getBand(index))
            filterView.bandEdited()
        }
    }
    
    @IBAction func addBandAction(_ sender: AnyObject) {
        
        if editor.showDialog() == .ok {
            filterView.tableRowsAddedOrRemoved()
        }
    }
    
    @IBAction func removeBandsAction(_ sender: AnyObject) {
        
        if filterView.numberOfSelectedRows > 0 {
            
            filterUnit.removeBands(filterView.selectedRows)
            filterView.bandsRemoved()
        }
    }
    
    @IBAction func removeAllBandsAction(_ sender: AnyObject) {
        
        filterUnit.removeAllBands()
        filterView.tableRowsAddedOrRemoved()
    }
}
