import Cocoa

/*
    Window controller for the Chapters list window.
    Contains the Chapters list view and performs window snapping.
 */
class ChaptersListWindowController: NSWindowController, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    
    override var windowNibName: String? {return "ChaptersList"}
    
    override func windowDidLoad() {
        
        self.window?.delegate = WindowManager.windowDelegate
        
        changeBackgroundColor(ColorSchemes.systemScheme.general.backgroundColor)
        
        Messenger.subscribe(self, .colorScheme_applyColorScheme, self.applyColorScheme(_:))
        SyncMessenger.subscribe(actionTypes: [.changeBackgroundColor], subscriber: self)
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        WindowManager.hideChaptersList()
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        changeBackgroundColor(scheme.general.backgroundColor)
    }
    
    func consumeMessage(_ message: ActionMessage) {
    
        if let colorSchemeMsg = message as? ColorSchemeComponentActionMessage {

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
