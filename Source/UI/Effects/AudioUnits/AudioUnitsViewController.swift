import Cocoa

/*
    View controller for the Audio Units view.
 */
class AudioUnitsViewController: NSViewController, NotificationSubscriber {
    
    @IBOutlet weak var tableView: NSTableView!
    
    private let audioUnitEditorDialog: AudioUnitEditorDialogController = WindowFactory.audioUnitEditorDialog
    
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
        
        if let result = audioGraph.addAudioUnit(ofType: notif.componentSubType) {
            
            // Refresh the table view with the new row.
            tableView.noteNumberOfRowsChanged()
            
            // Open the audio unit editor window with the new audio unit's custom view.
            DispatchQueue.main.async {
                self.audioUnitEditorDialog.showDialog(for: result.0)
            }
        }
    }
    
    @IBAction func editAudioUnitAction(_ sender: Any) {
        
        let selectedRow = tableView.selectedRow
        
        if selectedRow >= 0 {
            
            let audioUnit = audioGraph.audioUnits[selectedRow]
            
            // Open the audio unit editor window with the new audio unit's custom view.
//            DispatchQueue.main.async {
                self.audioUnitEditorDialog.showDialog(for: audioUnit)
//            }
        }
    }
    
    @IBAction func removeAudioUnitsAction(_ sender: Any) {
        
        let selRows = tableView.selectedRowIndexes
        
        if !selRows.isEmpty {
            
            audioGraph.removeAudioUnits(at: selRows)
            tableView.reloadData()
        }
    }
}
