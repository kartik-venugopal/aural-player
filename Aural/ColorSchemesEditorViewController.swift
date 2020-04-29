import Cocoa

class ColorSchemesEditorViewController: NSViewController, NSTableViewDataSource,  NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var editorView: NSTableView!
    
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnApply: NSButton!
    @IBOutlet weak var btnRename: NSButton!
    
    private var schemesCache: [ColorScheme] = []
    
    @IBOutlet weak var previewView: ColorSchemePreviewView!
    
    private var oldSchemeName: String = ""
    
    override var nibName: String? {return "ColorSchemesEditor"}
    
    override func viewDidAppear() {
        
        schemesCache = ColorSchemes.userDefinedSchemes
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        [btnDelete, btnRename, btnApply].forEach({$0.disable()})
        
        previewView.clear()
    }
    
    @IBAction func deleteSelectedSchemesAction(_ sender: AnyObject) {
        
        // Descending order
        selectedSchemeNames.forEach({ColorSchemes.deleteScheme($0)})
        
        // Update the cache
        schemesCache = ColorSchemes.userDefinedSchemes
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        updateButtonStates()
        updatePreview()
    }
    
    private var selectedSchemeNames: [String] {
        
        var names = [String]()
        
        let selection = editorView.selectedRowIndexes
        
        selection.forEach({
            
            if let cell = editorView.view(atColumn: 0, row: $0, makeIfNecessary: true) as? NSTableCellView, let name = cell.textField?.stringValue {
            
                names.append(name)
            }
        })
        
        return names
    }
    
    private func updateButtonStates() {
        
        let selRows: Int = editorView.numberOfSelectedRows
        
        btnDelete.enableIf(selRows > 0)
        btnApply.enableIf(selRows == 1)
        btnRename.enableIf(selRows == 1)
    }
    
    @IBAction func renameSchemeAction(_ sender: AnyObject) {
        
        let rowIndex = editorView.selectedRow
        let rowView = editorView.rowView(atRow: rowIndex, makeIfNecessary: true)
        let editedTextField = (rowView?.view(atColumn: 0) as! NSTableCellView).textField!
        
        self.view.window?.makeFirstResponder(editedTextField)
    }
    
    @IBAction func applySelectedSchemeAction(_ sender: AnyObject) {
        
        if let scheme = ColorSchemes.applyScheme(selectedSchemeNames[0]) {
            SyncMessenger.publishActionMessage(ColorSchemeActionMessage(scheme))
        }
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        UIUtils.dismissDialog(self.view.window!)
    }
    
    private func updatePreview() {
        
        if editorView.numberOfSelectedRows == 1 {
            
            previewView.scheme = schemesCache[editorView.selectedRow]
            
        } else {
            
            previewView.clear()
        }
    }
    
    // MARK: View delegate and data source functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return schemesCache.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        updateButtonStates()
        updatePreview()
        
        if editorView.numberOfSelectedRows == 1,
            let cell = editorView.view(atColumn: 0, row: editorView.selectedRow, makeIfNecessary: true) as? NSTableCellView,
            let textField = cell.textField {
                
            oldSchemeName = textField.stringValue
        }
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return GenericTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let scheme = schemesCache[row]
        return createTextCell(tableView, tableColumn!, row, scheme.name)
    }
    
    // Creates a cell view containing text
    private func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ text: String) -> EditorTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? EditorTableCellView {
            
            cell.isSelectedFunction = {(row: Int) -> Bool in
                return self.editorView.selectedRowIndexes.contains(row)
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
        
        if let scheme = ColorSchemes.schemeByName(oldSchemeName, false) {
            
            let newSchemeName = editedTextField.stringValue
            
            editedTextField.textColor = Colors.playlistSelectedTextColor
            
            // TODO: What if the string is too long ?
            
            // Empty string is invalid, revert to old value
            if StringUtils.isStringEmpty(newSchemeName) {
                
                editedTextField.stringValue = scheme.name
                
            } else if ColorSchemes.schemeWithNameExists(newSchemeName) {
                
                // Another sccheme with that name exists, can't rename
                editedTextField.stringValue = scheme.name
                
            } else {
                
                // Update the scheme name
                ColorSchemes.renameScheme(scheme.name, newSchemeName)
                
                // Update the cache
                schemesCache = ColorSchemes.userDefinedSchemes
            }
        }
    }
}
