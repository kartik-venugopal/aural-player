import Cocoa

class EQViewController: NSViewController, ActionMessageSubscriber {
    
    // Parametric equalizer controls
    @IBOutlet weak var eqGlobalGainSlider: NSSlider!
    @IBOutlet weak var eqSlider1k: NSSlider!
    @IBOutlet weak var eqSlider64: NSSlider!
    @IBOutlet weak var eqSlider16k: NSSlider!
    @IBOutlet weak var eqSlider8k: NSSlider!
    @IBOutlet weak var eqSlider4k: NSSlider!
    @IBOutlet weak var eqSlider2k: NSSlider!
    @IBOutlet weak var eqSlider32: NSSlider!
    @IBOutlet weak var eqSlider512: NSSlider!
    @IBOutlet weak var eqSlider256: NSSlider!
    @IBOutlet weak var eqSlider128: NSSlider!
    @IBOutlet weak var eqPresets: NSPopUpButton!
    
    private var eqSliders: [NSSlider] = []
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
 
    convenience init() {
        self.init(nibName: "EQ", bundle: Bundle.main)!
    }
    
    override func viewDidLoad() {
        initEQ(ObjectGraph.getUIAppState())
        SyncMessenger.subscribe(actionTypes: [.increaseBass, .decreaseBass, .increaseMids, .decreaseMids, .increaseTreble, .decreaseTreble], subscriber: self)
    }
    
    private func initEQ(_ appState: UIAppState) {
        
        eqSliders = [eqSlider32, eqSlider64, eqSlider128, eqSlider256, eqSlider512, eqSlider1k, eqSlider2k, eqSlider4k, eqSlider8k, eqSlider16k]
        
        eqGlobalGainSlider.floatValue = appState.eqGlobalGain
        updateAllEQSliders(appState.eqBands)
        
        // Don't select any items from the EQ presets menu
        eqPresets.selectItem(at: -1)
    }
    
    // Updates the global gain value of the Equalizer
    @IBAction func eqGlobalGainAction(_ sender: AnyObject) {
        graph.setEQGlobalGain(eqGlobalGainSlider.floatValue)
    }
    
    // Updates the gain value of a single frequency band (specified by the slider parameter) of the Equalizer
    @IBAction func eqSliderAction(_ sender: NSSlider) {
        // Slider tags match the corresponding EQ band indexes
        graph.setEQBand(sender.tag, gain: sender.floatValue)
    }
    
    // Applies a built-in preset to the Equalizer
    @IBAction func eqPresetsAction(_ sender: AnyObject) {
        
        let preset = EQPresets.fromDescription((eqPresets.selectedItem?.title)!)
        
        let eqBands: [Int: Float] = preset.bands
        graph.setEQBands(eqBands)
        updateAllEQSliders(eqBands)
        
        // Don't select any of the items
        eqPresets.selectItem(at: -1)
    }
    
    private func updateAllEQSliders(_ eqBands: [Int: Float]) {
        // Slider tag = index. Default gain value, if bands array doesn't contain gain for index, is 0
        eqSliders.forEach({
            $0.floatValue = eqBands[$0.tag] ?? 0
        })
    }
    
    private func updateEQSliders(_ eqBands: [Int: Float]) {
        // Slider tag = index. Default gain value, if bands array doesn't contain gain for index, is 0
        for (index, gain) in eqBands {
            eqSliders[index].floatValue = gain
        }
    }
    
    private func showEQTab() {
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.showEffectsUnitTab, .eq))
    }
    
    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    private func increaseBass() {
        updateEQSliders(graph.increaseBass())
        showEQTab()
    }
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    private func decreaseBass() {
        updateEQSliders(graph.decreaseBass())
        showEQTab()
    }
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    private func increaseMids() {
        updateEQSliders(graph.increaseMids())
        showEQTab()
    }
    
    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    private func decreaseMids() {
        updateEQSliders(graph.decreaseMids())
        showEQTab()
    }
    
    // Decreases each of the EQ treble bands by a certain preset increment
    private func increaseTreble() {
        updateEQSliders(graph.increaseTreble())
        showEQTab()
    }
    
    // Decreases each of the EQ treble bands by a certain preset decrement
    private func decreaseTreble() {
        updateEQSliders(graph.decreaseTreble())
        showEQTab()
    }
    
    // MARK: Message handling
    
    func consumeMessage(_ message: ActionMessage) {
        
        let message = message as! AudioGraphActionMessage
        
        switch message.actionType {
            
        case .increaseBass: increaseBass()
            
        case .decreaseBass: decreaseBass()
            
        case .increaseMids: increaseMids()
            
        case .decreaseMids: decreaseMids()
            
        case .increaseTreble: increaseTreble()
            
        case .decreaseTreble: decreaseTreble()
            
        default: return
            
        }
    }
}
