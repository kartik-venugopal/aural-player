//
//  FilterBandsTableViewDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension FilterUnitViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        filterUnit.bands.count
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let colID = tableColumn?.identifier else {return nil}
        
        let band = filterUnit[row]
        
        switch colID {
            
        case .cid_FilterBandIndex:
            
            return createTextCell(tableView, colID, row, "\(row + 1)", isPrimaryText: false)
            
        case .cid_FilterBandSwitch:
            
            return createSwitchCell(tableView, colID, row)
            
        case .cid_FilterBandType:
            
            return createTextCell(tableView, colID, row, band.type.description, isPrimaryText: false)
            
        case .cid_FilterBand:
            
            let cellText: String
            
            switch band.type {
                
            case .bandPass, .bandStop:
                
                cellText = String(format: "[ %@ - %@ ]", formatFreqNumber(band.minFreq!), formatFreqNumber(band.maxFreq!))
                
            case .lowPass:
                
                cellText = String(format: "< %@", formatFreqNumber(band.maxFreq!))
                
            case .highPass:
                
                cellText = String(format: "> %@", formatFreqNumber(band.minFreq!))
            }
            
            return createTextCell(tableView, colID, row, cellText, isPrimaryText: true)
            
        case .cid_FilterBandSettings:
            
            return createEditCell(tableView, colID, row)
            
        default:
            
            return nil
        }
    }
    
    private func formatFreqNumber(_ freq: Float) -> String {
        
        let num = freq.roundedInt
        if num % 1000 == 0 {
            return String(format: "%d KHz", num / 1000)
        } else {
            return String(format: "%d Hz", num)
        }
    }
    
    private func createSwitchCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ row: Int) -> FilterBandSwitchCellView? {
     
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? FilterBandSwitchCellView else {return nil}
        
        cell.bandIndex = row
        fxUnitStateObserverRegistry.registerObserver(cell.btnSwitch, forFXUnit: filterUnit)
        
        cell.action = {[weak self] in
            
            guard let strongSelf = self else {return}
            
            let band = strongSelf.filterUnit[row]
            
            band.bypass.toggle()
            strongSelf.filterUnit[row] = band
            cell.buttonStateUpdated(to: strongSelf.filterUnit.state)
            
            strongSelf.messenger.publish(.Effects.FilterUnit.bandBypassStateUpdated, payload: row)
        }
        
        return cell
    }
    
    private func createTextCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ row: Int, _ text: String, isPrimaryText: Bool) -> BasicTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? BasicTableCellView else {return nil}
        
        cell.text = text
        cell.textFont = systemFontScheme.smallFont
        cell.unselectedTextColor = isPrimaryText ? systemColorScheme.primaryTextColor : systemColorScheme.secondaryTextColor
        cell.selectedTextColor = isPrimaryText ? systemColorScheme.primarySelectedTextColor : systemColorScheme.secondarySelectedTextColor
        cell.rowSelectionStateFunction = {[weak tableView] in tableView?.isRowSelected(row) ?? false}
        
        return cell
    }
    
    private func createEditCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ row: Int) -> FilterBandEditCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? FilterBandEditCellView else {return nil}
        
        cell.btnEdit.contentTintColor = systemColorScheme.buttonColor
        
        cell.action = {[weak self] in
            
            guard let strongSelf = self else {return}
            
            let editor = strongSelf.bandEditors[row]
            editor.showWindow()
            strongSelf.initEditorWindowMagnetism(for: editor, showWindow: true)
        }
        
        return cell
    }
}

@IBDesignable
class FilterBandSwitchCellView: NSTableCellView {
    
    var bandIndex: Int! {
        
        didSet {
            btnSwitch.bandIndex = bandIndex
        }
    }
    
    @IBOutlet weak var btnSwitch: FilterBandTriStateBypassButton!
    
    var action: (() -> Void)! {
        
        didSet {
            
            btnSwitch.action = #selector(self.toggleStateAction(_:))
            btnSwitch.target = self
        }
    }
    
    @objc func toggleStateAction(_ sender: Any) {
        self.action()
    }
    
    func buttonStateUpdated(to newState: EffectsUnitState) {
        btnSwitch.unitStateChanged(to: newState)
    }
}

@IBDesignable
class FilterBandEditCellView: NSTableCellView {
    
    @IBOutlet weak var btnEdit: TintedImageButton!
    
    var action: (() -> Void)! {
        
        didSet {
            
            btnEdit.action = #selector(self.editBandAction(_:))
            btnEdit.target = self
        }
    }
    
    @objc func editBandAction(_ sender: Any) {
        self.action()
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    
    static let cid_FilterBandIndex: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_FilterBandIndex")
    static let cid_FilterBandSwitch: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_FilterBandSwitch")
    static let cid_FilterBandType: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_FilterBandType")
    static let cid_FilterBand: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_FilterBand")
    static let cid_FilterBandSettings: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_FilterBandSettings")
}
