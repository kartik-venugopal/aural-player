import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterViewController: NSViewController {
    
    // Filter controls
    @IBOutlet weak var btnFilterBypass: EffectsUnitBypassButton!
    @IBOutlet weak var filterBassSlider: RangeSlider!
    @IBOutlet weak var filterMidSlider: RangeSlider!
    @IBOutlet weak var filterTrebleSlider: RangeSlider!
    
    @IBOutlet weak var lblFilterBassRange: NSTextField!
    @IBOutlet weak var lblFilterMidRange: NSTextField!
    @IBOutlet weak var lblFilterTrebleRange: NSTextField!
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "Filter"}
    
    override func viewDidLoad() {
        initControls(ObjectGraph.getUIAppState())
    }
 
    private func initControls(_ appState: UIAppState) {
        
        btnFilterBypass.setBypassState(appState.filterBypass)
        
        filterBassSlider.initialize(AppConstants.bass_min, AppConstants.bass_max, appState.filterBassMin, appState.filterBassMax, {
            (slider: RangeSlider) -> Void in
            self.filterBassChanged()
        })
        
        filterMidSlider.initialize(AppConstants.mid_min, AppConstants.mid_max, appState.filterMidMin, appState.filterMidMax, {
            (slider: RangeSlider) -> Void in
            self.filterMidChanged()
        })
        
        filterTrebleSlider.initialize(AppConstants.treble_min, AppConstants.treble_max, appState.filterTrebleMin, appState.filterTrebleMax, {
            (slider: RangeSlider) -> Void in
            self.filterTrebleChanged()
        })
        
        lblFilterBassRange.stringValue = appState.formattedFilterBassRange
        lblFilterMidRange.stringValue = appState.formattedFilterMidRange
        lblFilterTrebleRange.stringValue = appState.formattedFilterTrebleRange
    }
    
    // Activates/deactivates the Filter effects unit
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        btnFilterBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.filter, !graph.toggleFilterBypass()))
    }
    
    // Action function for the Filter unit's bass slider. Updates the Filter bass band.
    private func filterBassChanged() {
        lblFilterBassRange.stringValue = graph.setFilterBassBand(Float(filterBassSlider.start), Float(filterBassSlider.end))
    }
    
    // Action function for the Filter unit's mid-frequency slider. Updates the Filter mid-frequency band.
    private func filterMidChanged() {
        lblFilterMidRange.stringValue = graph.setFilterMidBand(Float(filterMidSlider.start), Float(filterMidSlider.end))
    }
    
    // Action function for the Filter unit's treble slider. Updates the Filter treble band.
    private func filterTrebleChanged() {
        lblFilterTrebleRange.stringValue = graph.setFilterTrebleBand(Float(filterTrebleSlider.start), Float(filterTrebleSlider.end))
    }
}
