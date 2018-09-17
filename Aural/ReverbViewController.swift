import Cocoa

/*
    View controller for the Reverb effects unit
 */
class ReverbViewController: NSViewController {
    
    // Reverb controls
    @IBOutlet weak var btnReverbBypass: EffectsUnitBypassButton!
    @IBOutlet weak var reverbMenu: NSPopUpButton!
    @IBOutlet weak var reverbSlider: NSSlider!
    @IBOutlet weak var lblReverbAmountValue: NSTextField!
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "Reverb"}
    
    override func viewDidLoad() {
        initControls()
    }
    
    private func initControls() {
        
        btnReverbBypass.setBypassState(graph.isReverbBypass())
        reverbMenu.select(reverbMenu.item(withTitle: graph.getReverbPreset()))
        
        let amount = graph.getReverbAmount()
        reverbSlider.floatValue = amount.amount
        lblReverbAmountValue.stringValue = amount.amountString
    }

    // Activates/deactivates the Reverb effects unit
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        btnReverbBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.reverb, !graph.toggleReverbBypass()))
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
