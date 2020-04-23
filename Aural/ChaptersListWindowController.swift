import Cocoa

/*
    Window controller for the Chapters list window.
    Contains the Chapters list view and performs window snapping.
 */
class ChaptersListWindowController: NSWindowController, ActionMessageSubscriber {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var btnPreviousChapter: TintedImageButton!
    @IBOutlet weak var btnNextChapter: TintedImageButton!
    @IBOutlet weak var btnReplayChapter: TintedImageButton!
    
    @IBOutlet weak var btnLoopChapter: OnOffImageButton!
    @IBOutlet weak var btnCaseSensitive: OnOffImageButton!
    
    private var controlButtons: [Tintable] = []
    
    override var windowNibName: String? {return "ChaptersList"}
    
    private lazy var windowManager: WindowManagerProtocol = ObjectGraph.windowManager
    
    override func windowDidLoad() {
        
        self.window?.delegate = ObjectGraph.windowManager
        
        controlButtons = [btnClose, btnPreviousChapter, btnNextChapter, btnReplayChapter, btnLoopChapter, btnCaseSensitive]
        
        SyncMessenger.subscribe(actionTypes: [.changeBackgroundColor, .changeControlButtonColor, .changeControlButtonOffStateColor], subscriber: self)
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
                
            case .changeControlButtonColor:
                
                changeControlButtonColor(colorSchemeMsg.color)
                
            case .changeControlButtonOffStateColor:
                
                changeControlButtonOffStateColor(colorSchemeMsg.color)

            default: return

            }
            
            return
        }
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        rootContainerBox.fillColor = color
    }
    
    private func changeControlButtonColor(_ color: NSColor) {
        controlButtons.forEach({$0.reTint()})
    }
    
    private func changeControlButtonOffStateColor(_ color: NSColor) {
        [btnLoopChapter, btnCaseSensitive].forEach({$0.reTint()})
    }
}
