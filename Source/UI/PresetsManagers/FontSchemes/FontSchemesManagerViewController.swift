import Cocoa

/*
 View controller for the manager that allows the user to manage user-defined font schemes.
 */
class FontSchemesManagerViewController: GenericPresetsManagerViewController {
    
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    
    // A view that gives the user a visual preview of what each font scheme looks like.
    @IBOutlet weak var previewView: FontSchemePreviewView!
    
    override var nibName: String? {"FontSchemesManager"}
    
    override var numberOfPresets: Int {fontSchemesManager.numberOfUserDefinedPresets}
    
    override func nameOfPreset(atIndex index: Int) -> String {fontSchemesManager.userDefinedPresets[index].name}
    
    override func presetExists(named name: String) -> Bool {
        fontSchemesManager.presetExists(named: name)
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        // Clear the preview view (no theme is selected).
        previewView.clear()
    }
    
    override func deletePresets(atIndices indices: IndexSet) {
        
        fontSchemesManager.deletePresets(atIndices: indices)
        previewView.clear()
    }
    
    // Applies the selected font scheme to the system.
    override func applyPreset(atIndex index: Int) {
        
        let selScheme = fontSchemesManager.userDefinedPresets[index]
        let updatedScheme = fontSchemesManager.applyScheme(selScheme)
        
        // TODO: This should really be in FontSchemesManager, not here. Same for other preset managers.
        Messenger.publish(.applyFontScheme, payload: updatedScheme)
    }
    
    override func renamePreset(named name: String, to newName: String) {
        fontSchemesManager.renamePreset(named: name, to: newName)
    }

    // Updates the visual preview.
    private func updatePreview() {
        
        if tableView.numberOfSelectedRows == 1 {
            previewView.scheme = fontSchemesManager.userDefinedPresets[tableView.selectedRow]
            
        } else {
            previewView.clear()
        }
    }
    
    // MARK: Table view delegate and data source functions
    
    // When the table selection changes, the button states and preview might need to change.
    override func tableViewSelectionDidChange(_ notification: Notification) {
        
        super.tableViewSelectionDidChange(notification)
        updatePreview()
    }
    
    // Returns a view for a single column
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let scheme = fontSchemesManager.userDefinedPresets[row]
        return createTextCell(tableView, tableColumn!, row, scheme.name, true)
    }
}
