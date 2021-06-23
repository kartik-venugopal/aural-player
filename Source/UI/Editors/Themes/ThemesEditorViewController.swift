import Cocoa

/*
 View controller for the editor that allows the user to manage user-defined themes.
 */
class ThemesEditorViewController: GenericPresetsManagerViewController {
    
    // A view that gives the user a visual preview of what each theme looks like.
    @IBOutlet weak var previewView: ThemePreviewView!
    
    private lazy var themesManager: ThemesManager = ObjectGraph.themesManager
    
    override var nibName: String? {"ThemesEditor"}
    
    override var numberOfPresets: Int {themesManager.numberOfUserDefinedPresets}
    
    override func nameOfPreset(atIndex index: Int) -> String {themesManager.userDefinedPresets[index].name}
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        // Clear the preview view (no theme is selected).
        previewView.clear()
    }
    
    override func deletePresets(atIndices indices: IndexSet) {
        
        themesManager.deletePresets(atIndices: indices)
        previewView.clear()
    }
    
    override func applyPreset(atIndex index: Int) {
        
        let selTheme = themesManager.userDefinedPresets[index]
        themesManager.applyTheme(selTheme)
        
        // TODO: This should really be in ThemesManager, not here. Same for other preset managers.
        Messenger.publish(.applyTheme)
    }
    
    override func renamePreset(named name: String, to newName: String) {
        themesManager.renamePreset(named: name, to: newName)
    }
    
    // Updates the visual preview.
    private func updatePreview() {
        
        if presetsTableView.numberOfSelectedRows == 1 {
            
            previewView.theme = themesManager.userDefinedPresets[presetsTableView.selectedRow]
            
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
        
        let theme = themesManager.userDefinedPresets[row]
        return createTextCell(tableView, tableColumn!, row, theme.name, true)
    }
}
