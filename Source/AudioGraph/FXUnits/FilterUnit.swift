import AVFoundation

class FilterUnit: FXUnit, FilterUnitProtocol {
    
    private let node: FlexibleFilterNode = FlexibleFilterNode()
    let presets: FilterPresets = FilterPresets()
    
    override var avNodes: [AVAudioNode] {return [node]}
    
    init(persistentState: FilterUnitPersistentState?) {
        
        super.init(.filter, persistentState?.state ?? AudioGraphDefaults.filterState)
        
        node.addBands((persistentState?.bands ?? []).map {FilterBand(persistentState: $0)})
        presets.addPresets((persistentState?.userPresets ?? []).map {FilterPreset(persistentState: $0)})
    }
    
    var bands: [FilterBand] {
        
        get {return node.allBands()}
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
    
    var persistentState: FilterUnitPersistentState {
        
        let filterState = FilterUnitPersistentState()
        
        filterState.state = state
        filterState.bands = bands.map {FilterBandPersistentState(band: $0)}
        filterState.userPresets = presets.userDefinedPresets.map {FilterPresetState(preset: $0)}
        
        return filterState
    }
}
