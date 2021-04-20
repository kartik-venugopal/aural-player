import Cocoa

/*
 View controller for the editor that allows the user to manage user-defined themes.
 */
class ThemesEditorViewController: NSViewController, NSTableViewDataSource,  NSTableViewDelegate, NSTextFieldDelegate {
    
    // The table listing all user-defined themes.
    @IBOutlet weak var editorView: NSTableView!
    
    // Buttons for operations that can be performed on the themes.
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnApply: NSButton!
    @IBOutlet weak var btnRename: NSButton!
    
    // A cache that prevents redundant fetch operations when populating the table view.
    private var themesCache: [Theme] = []
    
    // A view that gives the user a visual preview of what each theme looks like.
    @IBOutlet weak var previewView: ThemePreviewView!
    
    // Used to temporarily store the original name of a theme that is being renamed.
    private var oldThemeName: String = ""
    
    override var nibName: String? {"ThemesEditor"}
    
    override func viewDidAppear() {
        
        // Populate the cache with all user-defined themes.
        themesCache = Themes.userDefinedThemes
        
        // Refresh the table view.
        editorView.reloadData()
        editorView.deselectAll(self)
        
        // Set button states.
        [btnDelete, btnRename, btnApply].forEach {$0.disable()}
        
        // Clear the preview view (no theme is selected).
        previewView.clear()
    }
    
    // Deletes all themes selected in the table view.
    @IBAction func deleteSelectedThemesAction(_ sender: AnyObject) {
        
        // Descending order
        selectedThemeNames.forEach {Themes.deleteTheme($0)}
        
        // Update the cache
        themesCache = Themes.userDefinedThemes
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        updateButtonStates()
        updatePreview()
    }
    
    // Returns the names of all themes selected in the table view.
    private var selectedThemeNames: [String] {
        return editorView.selectedRowIndexes.map {themesCache[$0].name}
    }
    
    // Updates button states depending on how many rows are selected in the table view.
    private func updateButtonStates() {
        
        let selRows: Int = editorView.numberOfSelectedRows
        
        btnDelete.enableIf(selRows > 0)
        btnApply.enableIf(selRows == 1)
        btnRename.enableIf(selRows == 1)
    }
    
    // Renames a single theme.
    @IBAction func renameThemeAction(_ sender: AnyObject) {
        
        let selectedRowView = editorView.rowView(atRow: editorView.selectedRow, makeIfNecessary: true)
        
        if let editedTextField = (selectedRowView?.view(atColumn: 0) as? NSTableCellView)?.textField {
            
            // Shift focus to the text field for the theme being renamed.
            self.view.window?.makeFirstResponder(editedTextField)
        }
    }
    
    // Applies the selected theme to the system.
    @IBAction func applySelectedThemeAction(_ sender: AnyObject) {
        
        if Themes.applyTheme(named: selectedThemeNames[0]) {
            Messenger.publish(.applyTheme)
        }
    }
    
    // Dismisses the editor dialog.
    @IBAction func doneAction(_ sender: AnyObject) {
        UIUtils.dismissDialog(self.view.window!)
    }
    
    // Updates the visual preview.
    private func updatePreview() {
        
        if editorView.numberOfSelectedRows == 1 {
            
            previewView.theme = themesCache[editorView.selectedRow]
            
        } else {
            
            previewView.clear()
        }
    }
    
    // MARK: View delegate and data source functions
    
    // Returns the total number of themes
    func numberOfRows(in tableView: NSTableView) -> Int {
        return themesCache.count
    }
    
    // When the table selection changes, the button states and preview might need to change.
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        updateButtonStates()
        updatePreview()
        
        if editorView.numberOfSelectedRows == 1 {
            oldThemeName = themesCache[editorView.selectedRow].name
        }
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return GenericTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let theme = themesCache[row]
        return createTextCell(tableView, tableColumn!, row, theme.name)
    }
    
    // Creates a cell view containing text
    private func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ text: String) -> EditorTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? EditorTableCellView {
            
            cell.isSelectedFunction = {[weak self] (row: Int) -> Bool in
                self?.editorView.selectedRowIndexes.contains(row) ?? false
            }
            
            cell.row = row
            
            cell.textField?.stringValue = text
            cell.textField!.delegate = self
            
            return cell
        }
        
        return nil
    }
    
    // MARK: Text field delegate functions
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        let editedTextField = obj.object as! NSTextField
        
        if let theme = Themes.userDefinedThemeByName(oldThemeName) {
            
            let newThemeName = editedTextField.stringValue
            
            editedTextField.textColor = Colors.playlistSelectedTextColor
            
            // TODO: What if the string is too long ?
            
            // Empty string is invalid, revert to old value
            if StringUtils.isStringEmpty(newThemeName) {
                
                editedTextField.stringValue = theme.name
                
            } else if Themes.themeWithNameExists(newThemeName) {
                
                // Another theme with that name exists, can't rename
                editedTextField.stringValue = theme.name
                
                _ = UIUtils.showAlert(DialogsAndAlerts.genericErrorAlert("Can't rename theme", "Another theme with that name already exists.", "Please type a unique name."))
                
            } else {
                
                // Update the theme name
                Themes.renameTheme(theme.name, newThemeName)
                
                // Update the cache
                themesCache = Themes.userDefinedThemes
            }
        }
    }
}
