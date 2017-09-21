/*
    Customizes the color of the cursor of the search modal dialog's text field
 */
import Cocoa

class ColoredCursorSearchField: NSTextField {
    
    override func awakeFromNib()
    {
        // Change the cursor color
        let fieldEditor = self.window?.fieldEditor(true, for: self) as! NSTextView
        fieldEditor.insertionPointColor = Colors.searchFieldCursorColor
    }
    
    override func textDidChange(_ notification: Notification) {
        
        // Notify the search view that the query text has changed
        SyncMessenger.publishNotification(SearchTextChangedNotification.instance)
    }
}
