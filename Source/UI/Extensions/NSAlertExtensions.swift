import Cocoa

extension NSAlert {
    
    // Centers an alert with respect to the screen, and shows it. Returns the modal response from the alert.
    func showModal() -> NSApplication.ModalResponse {
        
        window.showCenteredOnScreen()
        return runModal()
    }
    
    func showNonModal() {
        
        showsHelp = false
        showsSuppressionButton = false
        window.showCenteredOnScreen()
    }
}
