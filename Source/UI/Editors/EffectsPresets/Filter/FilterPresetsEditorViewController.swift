import Cocoa

class FilterPresetsEditorViewController: FXPresetsEditorGenericViewController {
    
    @IBOutlet weak var filterView: FilterView!
    private var bandsDataSource: PresetFilterBandsDataSource = PresetFilterBandsDataSource()
    
    @IBOutlet weak var bandsTable: NSTableView!
    @IBOutlet weak var tableViewDelegate: FilterBandsViewDelegate!
    
    override var nibName: String? {"FilterPresetsEditor"}
    
    var filterUnit: FilterUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.filterUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .filter
        fxUnit = filterUnit
        presetsWrapper = PresetsWrapper<FilterPreset, FilterPresets>(filterUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let bandsDataFunction = {[weak self] () -> [FilterBand] in self?.filterChartBands ?? []}
        
        filterView.initialize({() -> EffectsUnitState in .active}, bandsDataFunction, bandsDataSource, false)
        
        tableViewDelegate.dataSource = bandsDataSource
        tableViewDelegate.allowSelection = false
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = filterUnit.presets.preset(named: presetName) {
            
            bandsDataSource.preset = preset
            filterView.refresh()
            bandsTable.reloadData()
        }
    }
    
    private var filterChartBands: [FilterBand] {
        
        let selection = selectedPresetNames
        return selection.isNonEmpty ? filterUnit.presets.preset(named: selection[0])?.bands ?? [] : []
    }
}

class PresetFilterBandsDataSource: FilterBandsDataSource {
    
    var preset: FilterPreset?
    
    func countFilterBands() -> Int {
        preset?.bands.count ?? 0
    }
    
    func getFilterBand(_ index: Int) -> FilterBand {
        preset!.bands[index]
    }
}
