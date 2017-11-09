import Cocoa

/*
    Protocol to be implemented by all NSWindowController classes that control modal dialogs
 */
protocol ModalDialogDelegate {
    
    // Initialize and present the dialog modally
    func showDialog()
}
