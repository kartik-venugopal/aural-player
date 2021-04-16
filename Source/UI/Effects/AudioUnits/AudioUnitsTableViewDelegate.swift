import Cocoa
import AVFoundation

class AudioUnitsTableViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return audioGraph.audioUnits.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 24
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AudioUnitsTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableColumn!.identifier {
        
        case .uid_audioUnitSwitch:
            
            return createSwitchCell(tableView, tableColumn!.identifier.rawValue, row)
            
        case .uid_audioUnitName:
            
            return createNameCell(tableView, tableColumn!.identifier.rawValue, row)
            
        case .uid_audioUnitEdit:
            
            return createEditCell(tableView, tableColumn!.identifier.rawValue, row)
            
        default: return nil
            
        }
    }
    
    private func createSwitchCell(_ tableView: NSTableView, _ id: String, _ row: Int) -> AudioUnitSwitchCellView? {
     
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(id), owner: nil) as? AudioUnitSwitchCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.btnSwitch.stateFunction = audioUnit.stateFunction
            
            cell.btnSwitch.offStateTooltip = "Activate this Audio Unit"
            cell.btnSwitch.onStateTooltip = "Deactivate this Audio Unit"
            
            cell.btnSwitch.updateState()
            
            cell.action = {
                
                _ = audioUnit.toggleState()
                Messenger.publish(.fx_unitStateChanged)
            }
            
            return cell
        }
        
        return nil
    }
    
    private func createNameCell(_ tableView: NSTableView, _ id: String, _ row: Int) -> AudioUnitNameCellView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(id), owner: nil) as? AudioUnitNameCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.textField?.stringValue = "\(audioUnit.name) v\(audioUnit.version) by \(audioUnit.manufacturerName)"
            cell.textField?.font = FontSchemes.systemScheme.effects.unitFunctionFont
            cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
            cell.realignText(yOffset: FontSchemes.systemScheme.effects.auRowTextYOffset)
            
            return cell
        }
        
        return nil
    }
    
    private func createEditCell(_ tableView: NSTableView, _ id: String, _ row: Int) -> AudioUnitEditCellView? {
     
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(id), owner: nil) as? AudioUnitEditCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.btnEdit.tintFunction = {ColorSchemes.systemScheme.general.functionButtonColor}
            cell.btnEdit.reTint()
            
            cell.action = {
                Messenger.publish(ShowAudioUnitEditorCommandNotification(audioUnit: audioUnit))
            }
            
            return cell
        }
        
        return nil
    }
}

/*
    Custom view for a NSTableView row that displays a single Audio Unit. Customizes the selection look and feel.
 */
class AudioUnitsTableRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != NSTableView.SelectionHighlightStyle.none {
            
            let selectionRect = self.bounds.insetBy(dx: 30, dy: 0).offsetBy(dx: -5, dy: 0)
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 2, yRadius: 2)
            
            ColorSchemes.systemScheme.playlist.selectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
}

class AudioUnitNameCellView: NSTableCellView {
    
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var textColor: NSColor {Colors.Playlist.trackNameTextColor}
    var selectedTextColor: NSColor {Colors.Playlist.trackNameSelectedTextColor}
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            backgroundStyleChanged()
        }
    }
    
    func backgroundStyleChanged() {
        
        // Check if this row is selected, change color accordingly.
        textField?.textColor = rowIsSelected ?  selectedTextColor : textColor
    }
    
    // Constraints
    func realignText(yOffset: CGFloat) {
        
        guard let textField = self.textField else {return}
        
        // Remove any existing constraints on the text field's 'bottom' attribute
        self.constraints.filter {$0.firstItem === textField && $0.firstAttribute == .bottom}.forEach {self.deactivateAndRemoveConstraint($0)}

        let textFieldBottomConstraint = NSLayoutConstraint(item: textField, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: yOffset)
        
        self.activateAndAddConstraint(textFieldBottomConstraint)
    }
}

@IBDesignable
class AudioUnitSwitchCellView: NSTableCellView {
    
    @IBOutlet weak var btnSwitch: EffectsUnitTriStateBypassButton!
    
    var action: (() -> ())! {
        
        didSet {
            btnSwitch.action = #selector(self.toggleAudioUnitStateAction(_:))
            btnSwitch.target = self
        }
    }
    
    @objc func toggleAudioUnitStateAction(_ sender: Any) {
        self.action()
    }
}

@IBDesignable
class AudioUnitEditCellView: NSTableCellView {
    
    @IBOutlet weak var btnEdit: TintedImageButton!
    
    var action: (() -> ())! {
        
        didSet {
            
            btnEdit.action = #selector(self.editAudioUnitAction(_:))
            btnEdit.target = self
        }
    }
    
    @objc func editAudioUnitAction(_ sender: Any) {
        self.action()
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let uid_audioUnitSwitch: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.audioUnitSwitchColumnID)
    static let uid_audioUnitName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.audioUnitNameColumnID)
    static let uid_audioUnitEdit: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(UIConstants.audioUnitEditColumnID)
}
