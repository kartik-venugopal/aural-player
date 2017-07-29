import Cocoa

class ColoredCursorSearchField: NSTextField {
    
    override func awakeFromNib()
    {
        // Change the cursor color
        let fieldEditor = self.window?.fieldEditor(true, for: self) as! NSTextView
        fieldEditor.insertionPointColor = Colors.searchFieldCursorColor
    }
    
    override func textDidChange(_ notification: Notification) {
        let app = NSApplication.shared().delegate as! AppDelegate
        app.searchQueryChanged()
    }
}
