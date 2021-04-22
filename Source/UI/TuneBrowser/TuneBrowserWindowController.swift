import Cocoa

class TuneBrowserWindowController: NSWindowController, Destroyable {
    
    override var windowNibName: String? {"TuneBrowser"}
    
    @IBAction func closeAction(_ sender: Any) {
        self.window?.close()
    }
}
