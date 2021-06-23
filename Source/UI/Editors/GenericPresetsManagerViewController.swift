import Cocoa

class GenericPresetsManagerViewController: NSViewController, NSTableViewDataSource,  NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var presetsTableView: NSTableView!
    
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnApply: NSButton!
    @IBOutlet weak var btnRename: NSButton?
    
    // Needs to be overriden by subclasses.
    var numberOfPresets: Int {0}
    
    // Needs to be overriden by subclasses.
    func presetExists(named name: String) -> Bool {false}
    
    // Needs to be overriden by subclasses.
    func renamePreset(named name: String, to newName: String) {
    }
    
    // Needs to be overriden by subclasses.
    func nameOfPreset(atIndex index: Int) -> String {""}
    
    override func viewDidLoad() {
        
        if presetsTableView.headerView != nil {
            presetsTableView.customizeHeader(heightIncrease: 8, customCellType: AuralTableHeaderCell.self)
        }
    }
    
    override func viewDidAppear() {
        
        presetsTableView.reloadData()
        presetsTableView.deselectAll(self)
        
        [btnApply, btnRename, btnDelete].forEach {$0?.disable()}
    }
    
    @IBAction func deleteSelectedPresetsAction(_ sender: AnyObject) {
        
        deletePresets(atIndices: presetsTableView.selectedRowIndexes)
        
        presetsTableView.reloadData()
        presetsTableView.deselectAll(self)
        updateButtonStates()
    }

    // Needs to be overriden by subclasses.
    func deletePresets(atIndices indices: IndexSet) {
    }
    
    @IBAction func applySelectedPresetAction(_ sender: AnyObject) {
        applyPreset(atIndex: presetsTableView.selectedRow)
    }
    
    // Needs to be overriden by subclasses.
    func applyPreset(atIndex index: Int) {
    }
    
    @IBAction func renamePresetAction(_ sender: AnyObject) {
        
        let rowIndex = presetsTableView.selectedRow
        let rowView = presetsTableView.rowView(atRow: rowIndex, makeIfNecessary: true)
        
        if let editedTextField = (rowView?.view(atColumn: 0) as? NSTableCellView)?.textField {
            self.view.window?.makeFirstResponder(editedTextField)
        }
    }
    
    private func updateButtonStates() {
        
        let selRows: Int = presetsTableView.numberOfSelectedRows
        
        btnDelete.enableIf(selRows > 0)
        [btnApply, btnRename].forEach {$0?.enableIf(selRows == 1)}
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.view.window?.close()
    }
    
    // MARK: Table view delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {numberOfPresets}
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return GenericTableRowView()
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the name (first) column is used for type selection.
        if let column = tableColumn, (column.tableView?.column(withIdentifier: column.identifier) ?? -1) == 0 {
            return nameOfPreset(atIndex: row)
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateButtonStates()
    }
    
    // Needs to be overriden by subclasses.
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {nil}
    
    // Creates a cell view containing text
    func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ text: String, _ editable: Bool) -> EditorTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? EditorTableCellView,
              let textField = cell.textField else {return nil}
        
        cell.isSelectedFunction = {[weak self] (row: Int) -> Bool in
            self?.presetsTableView.selectedRowIndexes.contains(row) ?? false
        }
        
        textField.stringValue = text
        textField.textColor = Colors.defaultLightTextColor
        cell.row = row
        
        // Set tool tip on name/track only if text wider than column width
        updateTooltip(forCell: cell, inColumn: column)
        
        // Name column is editable
        if editable {
            textField.delegate = self
        }
        
        return cell
    }
    
    func tableViewColumnDidResize(_ notification: Notification) {
        
        // Update tool tips as some may no longer be needed or some new ones may be needed
        
        if let column = notification.userInfo?["NSTableColumn", NSTableColumn.self] {
            
            let rowCount = presetsTableView.numberOfRows
            
            if rowCount > 0 {
                
                for index in 0..<rowCount {
                    
                    if let cell = tableView(presetsTableView, viewFor: column, row: index) as? NSTableCellView {
                        updateTooltip(forCell: cell, inColumn: column)
                    }
                }
            }
        }
    }
    
    // Renames the selected preset.
    func controlTextDidEndEditing(_ obj: Notification) {
        
        let rowIndex = presetsTableView.selectedRow
        let rowView = presetsTableView.rowView(atRow: rowIndex, makeIfNecessary: true)

        guard let cell = rowView?.view(atColumn: 0) as? NSTableCellView,
              let editedTextField = cell.textField else {return}
        
        let oldPresetName = nameOfPreset(atIndex: rowIndex)
        let newPresetName = editedTextField.stringValue
        
        editedTextField.textColor = Colors.defaultSelectedLightTextColor
        
        // TODO: What if the string is too long ?
        
        // Empty string is invalid, revert to old value
        if newPresetName.isEmptyAfterTrimming {
            
            editedTextField.stringValue = oldPresetName
            
            _ = DialogsAndAlerts.genericErrorAlert("Can't rename preset", "Preset name must have at least one non-whitespace character.", "Please type a valid name.").showModal()
            
        } else if presetExists(named: newPresetName) {
            
            // Another theme with that name exists, can't rename
            editedTextField.stringValue = oldPresetName
            
            _ = DialogsAndAlerts.genericErrorAlert("Can't rename preset", "Another preset with that name already exists.", "Please type a unique name.").showModal()
            
        } else {
            
            // Update the preset name
            renamePreset(named: oldPresetName, to: newPresetName)
        }
        
        // Update the tool tip
        let nameColumn = presetsTableView.tableColumns[0]
        updateTooltip(forCell: cell, inColumn: nameColumn)
    }
    
    private func updateTooltip(forCell cell: NSTableCellView, inColumn column: NSTableColumn) {
        
        guard let textField = cell.textField else {return}
        
        if let font = textField.font, textField.stringValue.numberOfLines(font: font, lineWidth: column.width) > 1 {
            cell.toolTip = textField.stringValue
        } else {
            cell.toolTip = nil
        }
    }
}
