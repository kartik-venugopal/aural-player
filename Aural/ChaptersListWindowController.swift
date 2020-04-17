import Cocoa

/*
    Window controller for the Chapters list window.
    Contains the Chapters list view and performs window snapping.
 */
class ChaptersListWindowController: NSWindowController {
    
    override var windowNibName: String? {return "ChaptersList"}
    
    private lazy var windowManager: WindowManagerProtocol = ObjectGraph.windowManager
    
    override func windowDidLoad() {
        self.window?.delegate = ObjectGraph.windowManager
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        windowManager.hideChaptersList()
    }
}
