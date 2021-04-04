import Cocoa

/*
    View controller for the Recorder unit
 */
class AUViewController: NSViewController, NotificationSubscriber {
    
    override var nibName: String? {return "AudioUnits"}
    
    override func viewDidLoad() {
        print("AU View did load !!!")
    }
}
