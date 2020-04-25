import Cocoa

/*
    Window controller for the Chapters list window.
    Contains the Chapters list view and performs window snapping.
 */
class ChaptersListWindowController: NSWindowController, ActionMessageSubscriber {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    
    override var windowNibName: String? {return "ChaptersList"}
    
    private lazy var windowManager: WindowManagerProtocol = ObjectGraph.windowManager
    
    override func windowDidLoad() {
        
        self.window?.delegate = ObjectGraph.windowManager
        
        changeBackgroundColor(ColorSchemes.systemScheme.general.backgroundColor)
        
        SyncMessenger.subscribe(actionTypes: [.changeBackgroundColor], subscriber: self)
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        windowManager.hideChaptersList()
    }
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeMessage(_ message: ActionMessage) {
    
        if let colorSchemeMsg = message as? ColorSchemeActionMessage {

            switch colorSchemeMsg.actionType {

            case .changeBackgroundColor:

                changeBackgroundColor(colorSchemeMsg.color)

            default: return

            }
            
            return
        }
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        rootContainerBox.fillColor = color
    }
}
