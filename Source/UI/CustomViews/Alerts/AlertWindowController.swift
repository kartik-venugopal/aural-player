import Cocoa

class AlertWindowController: NSWindowController, ModalComponentProtocol, Destroyable {
    
    private static var _instance: AlertWindowController?
    static var instance: AlertWindowController {
        
        if _instance == nil {
            _instance = AlertWindowController()
        }
        
        return _instance!
    }
    
    static func destroy() {
        
        _instance?.destroy()
        _instance = nil
    }
    
    override var windowNibName: String? {"Alerts"}
    
    @IBOutlet weak var icon: NSImageView!
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var lblInfo: NSTextField!
    
    @IBOutlet weak var btnOK: NSButton!
    
    override func windowDidLoad() {
        WindowManager.instance?.registerModalComponent(self)
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    func showAlert(_ alertType: AlertType, _ title: String, _ message: String, _ info: String) {
        
        if !self.isWindowLoaded {
            _ = self.window!
        }
        
        switch alertType {
            
        case .error:    icon.image = Images.imgError
            
        case .warning:  icon.image = Images.imgWarning

        default:    icon.image = Images.imgWarning
            
        }
        
        lblTitle.stringValue = title
        lblMessage.stringValue = message
        lblInfo.stringValue = info
        
        UIUtils.centerDialogWRTScreen(self.window!)
        self.window!.makeKeyAndOrderFront(self)
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        self.window!.close()
    }
}

enum AlertType {
    
    case error
    case warning
    case info
}
