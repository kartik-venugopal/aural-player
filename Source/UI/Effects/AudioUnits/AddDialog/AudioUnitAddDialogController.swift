import Cocoa

class AudioUnitAddDialogController: NSWindowController, NotificationSubscriber, ModalDialogDelegate {
    
    override var windowNibName: String? {return "AudioUnitAddDialog"}
    
    @IBOutlet weak var lblDescription: NSTextField!
   
    @IBOutlet weak var tableView: NSTableView!
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    private let audioUnitsManager: AudioUnitsManager = ObjectGraph.audioUnitsManager
    
    override func windowDidLoad() {
        WindowManager.registerModalComponent(self)
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = self.window!
        }
        
        resetFields()
        UIUtils.showDialog(self.window!)
        modalDialogResponse = .ok
        
        return modalDialogResponse
    }
    
    func resetFields() {
        tableView.selectRowIndexes(IndexSet([0]), byExtendingSelection: false)
    }
    
    @IBAction func okAction(_ sender: Any) {

        if tableView.selectedRow >= 0 {
            
            let componentSubType = audioUnitsManager.audioUnits[tableView.selectedRow].audioComponentDescription.componentSubType
            Messenger.publish(AddAudioUnitCommandNotification(componentSubType: componentSubType))
        }
        
        modalDialogResponse = .ok
        UIUtils.dismissDialog(self.window!)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        UIUtils.dismissDialog(self.window!)
    }
}
