import Cocoa

class ChaptersWindowController: NSWindowController {
    
    override var windowNibName: String? {return "Chapters"}
    
    override func windowDidLoad() {
        print("Chapters window loaded")
    }
}

class ChaptersViewController: NSViewController {
    
    @IBOutlet weak var chaptersView: NSTableView!
    
    override var nibName: String? {return "Chapters"}
    
    override func viewDidLoad() {
        print("Chapters view loaded")
        chaptersView.reloadData()
    }
}
