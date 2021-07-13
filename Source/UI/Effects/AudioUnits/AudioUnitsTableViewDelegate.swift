//
//  AudioUnitsTableViewDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

class AudioUnitsTableViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    private lazy var messenger = Messenger(for: self)
    
    func numberOfRows(in tableView: NSTableView) -> Int {audioGraph.audioUnits.count}
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {24}
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {AudioUnitsTableRowView()}
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let colID = tableColumn?.identifier else {return nil}
        
        switch colID {
        
        case .uid_audioUnitSwitch:
            
            return createSwitchCell(tableView, colID, row)
            
        case .uid_audioUnitName:
            
            return createNameCell(tableView, colID, row)
            
        case .uid_audioUnitEdit:
            
            return createEditCell(tableView, colID, row)
            
        default: return nil
            
        }
    }
    
    private func createSwitchCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ row: Int) -> AudioUnitSwitchCellView? {
     
        if let cell = tableView.makeView(withIdentifier: id, owner: nil) as? AudioUnitSwitchCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.btnSwitch.stateFunction = audioUnit.stateFunction
            
            cell.btnSwitch.offStateTooltip = "Activate this Audio Unit"
            cell.btnSwitch.onStateTooltip = "Deactivate this Audio Unit"
            
            cell.btnSwitch.updateState()
            
            cell.action = {
                
                _ = audioUnit.toggleState()
                self.messenger.publish(.effects_unitStateChanged)
            }
            
            return cell
        }
        
        return nil
    }
    
    private func createNameCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ row: Int) -> AudioUnitNameCellView? {
        
        if let cell = tableView.makeView(withIdentifier: id, owner: nil) as? AudioUnitNameCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.textField?.stringValue = "\(audioUnit.name) v\(audioUnit.version) by \(audioUnit.manufacturerName)"
            cell.textField?.font = fontSchemesManager.systemScheme.effects.unitFunctionFont
            cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
            cell.realignText(yOffset: fontSchemesManager.systemScheme.effects.auRowTextYOffset)
            
            return cell
        }
        
        return nil
    }
    
    private func createEditCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ row: Int) -> AudioUnitEditCellView? {
     
        if let cell = tableView.makeView(withIdentifier: id, owner: nil) as? AudioUnitEditCellView {
            
            let audioUnit = audioGraph.audioUnits[row]
            
            cell.btnEdit.tintFunction = {self.colorSchemesManager.systemScheme.general.functionButtonColor}
            cell.btnEdit.reTint()
            
            cell.action = {
                self.messenger.publish(ShowAudioUnitEditorCommandNotification(audioUnit: audioUnit))
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
            
            Colors.Playlist.selectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
}

class AudioUnitNameCellView: NSTableCellView {
    
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var textColor: NSColor {Colors.Playlist.trackNameTextColor}
    var selectedTextColor: NSColor {Colors.Playlist.trackNameSelectedTextColor}
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    private lazy var textFieldConstraintsManager = LayoutConstraintsManager(for: textField!)
    
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
        
        textFieldConstraintsManager.removeAll(withAttributes: [.bottom])
        textFieldConstraintsManager.setBottom(relatedToBottomOf: self, offset: yOffset)
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
    
    static let uid_audioUnitSwitch: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_AudioUnitSwitch")
    static let uid_audioUnitName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_AudioUnitName")
    static let uid_audioUnitEdit: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_AudioUnitEdit")
}
