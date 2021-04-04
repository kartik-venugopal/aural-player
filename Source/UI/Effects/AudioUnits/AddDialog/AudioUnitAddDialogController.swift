import Cocoa

class AudioUnitAddDialogController: NSWindowController, NotificationSubscriber, ModalDialogDelegate {
    
    override var windowNibName: String? {return "AudioUnitAddDialog"}
    
    @IBOutlet weak var lblDescription: NSTextField!
   
    @IBOutlet weak var tableView: NSTableView!
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
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
    
    }
    
    @IBAction func okAction(_ sender: Any) {
        
//        Messenger.publish(.player_jumpToTime, payload: jumpToTime)
        
        modalDialogResponse = .ok
        UIUtils.dismissDialog(self.window!)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        UIUtils.dismissDialog(self.window!)
    }
}
