/*
    View controller for the Help menu
 */

import Cocoa

class HelpViewController: NSViewController {
    
    private let workspace: NSWorkspace = NSWorkspace.shared
    
    // Opens the online (HTML) user guide
    @IBAction func onlineUserGuideAction(_ sender: Any) {
        workspace.open(AppConstants.onlineUserGuideURL)
    }
    
    // Opens the bundled (PDF) user guide
    @IBAction func pdfUserGuideAction(_ sender: Any) {
        workspace.openFile(AppConstants.pdfUserGuidePath)
    }
}
