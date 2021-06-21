import Cocoa

class LayoutsEditorViewController: NSViewController, NSTableViewDataSource,  NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var editorView: NSTableView!
    
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnApply: NSButton!
    @IBOutlet weak var btnRename: NSButton!
    
    @IBOutlet weak var previewView: LayoutPreviewView!
    
    // Delegate that performs CRUD on user preferences
    private lazy var preferences: Preferences = ObjectGraph.preferences
    
    private var oldLayoutName: String = ""
    
    override var nibName: String? {"LayoutsEditor"}
    
    override func viewDidAppear() {
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        [btnDelete, btnRename, btnApply].forEach({$0.disable()})
        
        previewView.clear()
    }
    
    @IBAction func deleteSelectedLayoutsAction(_ sender: AnyObject) {
        
        // Descending order
        let selection = selectedLayoutNames
        let prefLayout = preferences.viewPreferences.layoutOnStartup.layoutName
        
        // The preferred layout (in the view preferences) was deleted. Set the preference to the default
        if (selection.contains(prefLayout)) {
            
            let defaultLayout = WindowLayouts.defaultLayout.name
            
            preferences.viewPreferences.layoutOnStartup.layoutName = defaultLayout
        }

        selection.forEach({WindowLayouts.deleteLayout($0)})
        
        editorView.reloadData()
        editorView.deselectAll(self)
        updateButtonStates()
        updatePreview()
    }
    
    private var selectedLayoutNames: [String] {
        
        var names = [String]()
        
        let selection = editorView.selectedRowIndexes
        
        selection.forEach({
            
            let cell = editorView.view(atColumn: 0, row: $0, makeIfNecessary: true) as! NSTableCellView
            
            let name = cell.textField!.stringValue
            names.append(name)
        })
        
        return names
    }
    
    private func updateButtonStates() {
        
        let selRows: Int = editorView.numberOfSelectedRows
        
        btnDelete.enableIf(selRows > 0)
        btnApply.enableIf(selRows == 1)
        btnRename.enableIf(selRows == 1)
    }
    
    @IBAction func renameLayoutAction(_ sender: AnyObject) {
        
        let rowIndex = editorView.selectedRow
        let rowView = editorView.rowView(atRow: rowIndex, makeIfNecessary: true)
        let editedTextField = (rowView?.view(atColumn: 0) as! NSTableCellView).textField!
        
        self.view.window?.makeFirstResponder(editedTextField)
    }
    
    @IBAction func applySelectedLayoutAction(_ sender: AnyObject) {
        WindowManager.instance.layout(selectedLayoutNames[0])
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        UIUtils.dismissDialog(self.view.window!)
    }
    
    private func updatePreview() {
        
        if editorView.numberOfSelectedRows == 1 {
            
            let layout = WindowLayouts.layoutByName(selectedLayoutNames[0])!
            previewView.drawPreviewForLayout(layout)
            
        } else {
            
            previewView.clear()
        }
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return WindowLayouts.userDefinedLayouts.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        updateButtonStates()
        updatePreview()
        
        if editorView.numberOfSelectedRows == 1 {
        
            let cell = editorView.view(atColumn: 0, row: editorView.selectedRow, makeIfNecessary: true) as! NSTableCellView
            oldLayoutName = cell.textField!.stringValue
        }
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return GenericTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let layout = WindowLayouts.userDefinedLayouts[row]
        return createTextCell(tableView, tableColumn!, row, layout.name)
    }
    
    // Creates a cell view containing text
    private func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ text: String) -> EditorTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? EditorTableCellView {
            
            cell.isSelectedFunction = {[weak self] (row: Int) -> Bool in
                self?.editorView.selectedRowIndexes.contains(row) ?? false
            }
            
            cell.row = row
            
            cell.textField?.stringValue = text
            cell.textField?.delegate = self
            
            return cell
        }
        
        return nil
    }
    
    // MARK: Text field delegate functions
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        let editedTextField = obj.object as! NSTextField
        
        if let layout = WindowLayouts.layoutByName(oldLayoutName, false) {
            
            let newLayoutName = editedTextField.stringValue
            
            editedTextField.textColor = Colors.playlistSelectedTextColor
            
            // TODO: What if the string is too long ?
            
            // Empty string is invalid, revert to old value
            if (StringUtils.isStringEmpty(newLayoutName)) {
                editedTextField.stringValue = layout.name
                
            } else if WindowLayouts.layoutWithNameExists(newLayoutName) {
                
                // Another layout with that name exists, can't rename
                editedTextField.stringValue = layout.name
                
            } else {
            
                // Update the layout name
                WindowLayouts.renameLayout(layout.name, newLayoutName)
                
                // Also update the view preference, if the chosen layout was this edited one
                let prefLayout = preferences.viewPreferences.layoutOnStartup.layoutName
                if prefLayout == oldLayoutName {
                    
                    preferences.viewPreferences.layoutOnStartup.layoutName = newLayoutName
                    preferences.persist()
                }
            }
        }
    }
}
