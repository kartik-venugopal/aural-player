import Cocoa

class ReverbViewController: NSViewController {
    
    // Reverb controls
    @IBOutlet weak var btnReverbBypass: NSButton!
    @IBOutlet weak var reverbMenu: NSPopUpButton!
    @IBOutlet weak var reverbSlider: NSSlider!
    @IBOutlet weak var lblReverbAmountValue: NSTextField!
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    convenience init() {
        self.init(nibName: "Reverb", bundle: Bundle.main)!
    }
    
    override func viewDidLoad() {
        initReverb(ObjectGraph.getUIAppState())
    }
    
    private func initReverb(_ appState: UIAppState) {
        
        btnReverbBypass.image = appState.reverbBypass ? Images.imgSwitchOff : Images.imgSwitchOn
        reverbMenu.select(reverbMenu.item(withTitle: appState.reverbPreset))
        
        reverbSlider.floatValue = appState.reverbAmount
        lblReverbAmountValue.stringValue = appState.formattedReverbAmount
    }

    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleReverbBypass()
        btnReverbBypass.image = newBypassState ? Images.imgSwitchOff : Images.imgSwitchOn
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.reverb, !newBypassState))
    }

    // Updates the Reverb preset
    @IBAction func reverbAction(_ sender: AnyObject) {
        graph.setReverb(ReverbPresets.fromDescription((reverbMenu.selectedItem?.title)!))
    }

    // Updates the Reverb amount parameter
    @IBAction func reverbAmountAction(_ sender: AnyObject) {
        lblReverbAmountValue.stringValue = graph.setReverbAmount(reverbSlider.floatValue)
    }
}
