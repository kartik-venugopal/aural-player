import Cocoa

protocol ModalComponentProtocol {
    
    var isModal: Bool {get}
}

/*
 Protocol to be implemented by all NSWindowController classes that control modal dialogs. This is intended to provide abstraction, so that NSWindowController classes are not entirely exposed to callers unnecessarily.
 */
protocol ModalDialogDelegate: ModalComponentProtocol {
    
    // Initialize and present the dialog modally
    func showDialog() -> ModalDialogResponse
    
    func setDataForKey(_ key: String, _ value: Any?)
}

enum ModalDialogResponse {
    
    case ok
    case cancel
}

extension ModalDialogDelegate {
    
    func setDataForKey(_ key: String, _ value: Any?) {
        // Dummy implementation
    }
}
