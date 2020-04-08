import Cocoa

class ChaptersWindowController: NSWindowController {
    
    override var windowNibName: String? {return "Chapters"}
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.toggleChaptersList))
    }
}
