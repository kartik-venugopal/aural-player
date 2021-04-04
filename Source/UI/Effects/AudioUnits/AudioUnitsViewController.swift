import Cocoa

/*
    View controller for the Audio Units view.
 */
class AudioUnitsViewController: NSViewController, NotificationSubscriber {
    
    @IBOutlet weak var tableView: NSTableView!
    
    private let audioUnitAddDialog: ModalDialogDelegate = WindowFactory.audioUnitAddDialog
    
    override var nibName: String? {return "AudioUnits"}
    
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    override func viewDidLoad() {
        Messenger.subscribe(self, .auFXUnit_addAudioUnit, self.addAudioUnit(_:))
    }
    
    @IBAction func addAudioUnitAction(_ sender: Any) {
        _ = audioUnitAddDialog.showDialog()
    }
    
    private func addAudioUnit(_ notif: AddAudioUnitCommandNotification) {
        
        if let _ = audioGraph.addAudioUnit(ofType: notif.componentSubType) {
            tableView.reloadData()
        }
    }
}
