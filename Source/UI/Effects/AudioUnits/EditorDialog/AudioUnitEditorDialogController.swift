import Cocoa

class AudioUnitEditorDialogController: NSWindowController, NotificationSubscriber {
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var viewContainer: NSBox!
    
    var currentlyDisplayedView: NSView?
    
    override var windowNibName: String? {return "AudioUnitEditorDialog"}
    
    private let audioUnitsManager: AudioUnitsManager = ObjectGraph.audioUnitsManager
    
    func showDialog(withAudioUnitView view: NSView, forComponentWithName name: String) {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = self.window!
        }
        
        viewContainer.addSubview(view)
        view.anchorToView(view.superview!)
        view.show()
        
        currentlyDisplayedView = view
        
        lblTitle.stringValue = "Editing Audio Unit:  \(name)"
            
        UIUtils.showDialog(self.window!)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        
        UIUtils.dismissDialog(self.window!)
        currentlyDisplayedView?.hide()
    }
}
