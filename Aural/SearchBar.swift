/*
    Custom NSSearchField subclass that notifies the app everytime its text changes
 */

import Cocoa

class SearchBar: NSSearchField, NSTextFieldDelegate {
    
    override func textDidChange(_ notification: Notification) {
        let app = (NSApplication.shared().delegate as! AppDelegate)
        app.searchQueryChanged()
    }
}
