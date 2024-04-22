//
//  FilterBandWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class FilterBandEditorDialogController: NSWindowController {
    
    override var windowNibName: String? {"FilterBandEditorDialog"}
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var btnClose: NSButton!
    @IBOutlet weak var btnDone: NSButton!
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var bandView: FilterBandView!
    
    private var filterUnit: FilterUnitDelegateProtocol = audioGraphDelegate.filterUnit
    
    var bandIndex: Int! {
        
        didSet {
            bandView?.bandIndex = self.bandIndex
            lblCaption?.stringValue = "Filter Band# \(bandIndex + 1)"
        }
    }
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        window?.isMovableByWindowBackground = true
        
        lblCaption.stringValue = "Filter Band# \(bandIndex + 1)"
        bandView.initialize(band: filterUnit[bandIndex], at: bandIndex)
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainerBox)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, handler: buttonColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primaryTextColor, handler: primaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: bandView.secondaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
    }
    
    @IBAction func doneAction(_ sender: NSButton) {
        close()
    }
}

extension FilterBandEditorDialogController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        btnDone.redraw()
        bandView.fontSchemeChanged()
    }
}

extension FilterBandEditorDialogController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        btnClose.contentTintColor = systemColorScheme.buttonColor
        btnDone.redraw()
        lblCaption.textColor = systemColorScheme.captionTextColor
    }
    
    private func buttonColorChanged(_ newColor: PlatformColor) {
        
        btnClose.contentTintColor = newColor
        btnDone.redraw()
        bandView.buttonColorChanged(newColor)
    }
    
    private func primaryTextColorChanged(_ newColor: PlatformColor) {
        
        btnDone.redraw()
        bandView.primaryTextColorChanged(newColor)
    }
}
