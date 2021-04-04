import Cocoa

/*
    View controller for the Audio Units view.
 */
class AudioUnitsViewController: NSViewController, NotificationSubscriber {
    
    @IBOutlet weak var tableView: NSTableView!
    
    private let audioUnitEditorDialog: AudioUnitEditorDialogController = AudioUnitEditorDialogController()
    
    private let audioUnitAddDialog: ModalDialogDelegate = WindowFactory.audioUnitAddDialog
    
    override var nibName: String? {return "AudioUnits"}
    
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    override func viewDidLoad() {
        Messenger.subscribe(self, .auFXUnit_addAudioUnit, self.addAudioUnit(_:))
    }
    
    @IBAction func addAudioUnitAction(_ sender: Any) {
        _ = audioUnitAddDialog.showDialog()
    }
    
    @IBAction func removeAudioUnitsAction(_ sender: Any) {
        
        for row in tableView.selectedRowIndexes {
            audioGraph.removeAudioUnit(at: row)
        }
        
        
    }
    
    private func addAudioUnit(_ notif: AddAudioUnitCommandNotification) {
        
        if let result = audioGraph.addAudioUnit(ofType: notif.componentSubType) {
            
            // Refresh the table view with the new row.
            tableView.noteNumberOfRowsChanged()
            
            // Open the audio unit editor window with the new audio unit's custom view.
            DispatchQueue.main.async {
                
                let componentName = result.0.name
                result.0.presentView {view in
                    self.audioUnitEditorDialog.showDialog(withAudioUnitView: view, forComponentWithName: componentName)
                }
            }
        }
    }
    
    @IBAction func editAudioUnitAction(_ sender: Any) {
        
        let selectedRow = tableView.selectedRow
        
        if selectedRow >= 0 {
            
            let audioUnit = audioGraph.audioUnits[selectedRow]
            
            // Open the audio unit editor window with the new audio unit's custom view.
            DispatchQueue.main.async {
                
                audioUnit.presentView {view in
                    self.audioUnitEditorDialog.showDialog(withAudioUnitView: view, forComponentWithName: audioUnit.name)
                }
            }
        }
    }
}
