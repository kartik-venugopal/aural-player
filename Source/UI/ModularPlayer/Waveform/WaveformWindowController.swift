//
//  WaveformWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class WaveformWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"WaveformWindow"}
    
    @IBOutlet weak var btnClose: TintedImageButton!
    private lazy var btnCloseConstraints: LayoutConstraintsManager = LayoutConstraintsManager(for: btnClose)
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var waveformContainer: NSView!
    private let viewController: WaveformViewController = .init()
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        waveformContainer.addSubview(viewController.view)
        viewController.view.anchorToSuperview()
        
        // Bring the 'X' (Close) button to the front and constrain it.
        btnClose.bringToFront()

        btnCloseConstraints.setWidth(11.5)
        btnCloseConstraints.setHeight(10)
        btnCloseConstraints.setLeading(relatedToLeadingOf: btnClose.superview!, offset: 10)
        btnCloseConstraints.setTop(relatedToTopOf: btnClose.superview!, offset: 15)
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainer)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        windowLayoutsManager.toggleWindow(withId: .waveform)
    }
}

extension WaveformWindowController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        lblCaption.font = systemFontScheme.captionFont
    }
}

extension WaveformWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainer.fillColor = systemColorScheme.backgroundColor
        btnClose.colorChanged(systemColorScheme.buttonColor)
        lblCaption.textColor = systemColorScheme.captionTextColor
    }
}
