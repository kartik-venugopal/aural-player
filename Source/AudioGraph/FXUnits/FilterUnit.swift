import AVFoundation

class FilterUnit: FXUnit, FilterUnitProtocol {
    
    private let node: FlexibleFilterNode = FlexibleFilterNode()
    let presets: FilterPresets = FilterPresets()
    
    override var avNodes: [AVAudioNode] {return [node]}
    
    init(_ persistentState: AudioGraphState) {
        
        let filterState = persistentState.filterUnit
        
        super.init(.filter, filterState.state)
        
        node.addBands(filterState.bands)
        presets.addPresets(filterState.userPresets)
    }
    
    var bands: [FilterBand] {
        
        get {node.allBands()}
        set {node.setBands(newValue)}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    func getBand(_ index: Int) -> FilterBand {
        return node.getBand(index)
    }
    
    func addBand(_ band: FilterBand) -> Int {
        return node.addBand(band)
    }
    
    func updateBand(_ index: Int, _ band: FilterBand) {
        node.updateBand(index, band)
    }
    
    func removeBands(_ indexSet: IndexSet) {
        node.removeBands(indexSet)
    }
    
    func removeAllBands() {
        node.removeAllBands()
    }
    
    override func savePreset(_ presetName: String) {
        
        // Need to clone the filter's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        var presetBands: [FilterBand] = []
        bands.forEach({presetBands.append($0.clone())})
        
        presets.addPreset(FilterPreset(presetName, .active, presetBands, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.presetByName(presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: FilterPreset) {
        
        // Need to clone the filter's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        var filterBands: [FilterBand] = []
        preset.bands.forEach({filterBands.append($0.clone())})
        
        bands = filterBands
    }
    
    var settingsAsPreset: FilterPreset {
        return FilterPreset("filterSettings", state, bands, false)
    }
    
    var persistentState: FilterUnitState {
        
        let filterState = FilterUnitState()
        
        filterState.state = state
        filterState.bands = bands
        filterState.userPresets = presets.userDefinedPresets
        
        return filterState
    }
}
