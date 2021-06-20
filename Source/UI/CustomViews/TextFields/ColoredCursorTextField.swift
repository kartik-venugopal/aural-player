/*
 Customizes the color of the cursor of a text field
 */
import Cocoa

class ColoredCursorTextField: NSTextField {
    
    override func viewDidMoveToWindow() {
        
        // Change the cursor color
        
        if let fieldEditor = self.window?.fieldEditor(true, for: self) as? NSTextView {
            fieldEditor.insertionPointColor = Colors.textFieldCursorColor
        }
    }
}

/*
 Customizes the color of the cursor of the search modal dialog's text field
 */

// TODO: Use an NSSearchField and remove this class/notification if changing its cursor/text colors is possible.
class ColoredCursorSearchField: ColoredCursorTextField {
    
    override func textDidChange(_ notification: Notification) {
        
        // Notify the search view that the query text has changed
        Messenger.publish(.playlist_searchTextChanged, payload: self.stringValue)
    }
}
