import Cocoa

/*
    View controller for the Recorder unit
 */
class AUViewController: NSViewController, NotificationSubscriber {
    
    private let audioUnitAddDialog: ModalDialogDelegate = WindowFactory.audioUnitAddDialog
    
    override var nibName: String? {return "AudioUnits"}
    
    override func viewDidLoad() {
        print("AU View did load !!!")
    }
    
    @IBAction func addAudioUnitAction(_ sender: Any) {
        _ = audioUnitAddDialog.showDialog()
    }
}
