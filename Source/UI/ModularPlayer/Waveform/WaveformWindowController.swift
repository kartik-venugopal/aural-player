//
//  WaveformWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class WaveformWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"WaveformWindow"}
    
    @IBOutlet weak var btnClose: TintedImageButton!
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var waveformContainer: NSBox!
    private let viewController: WaveformViewController = .init()
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        waveformContainer.addSubview(viewController.view)
        viewController.view.anchorToSuperview()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceivers: [rootContainer, waveformContainer])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
    }
    
    override func destroy() {
        
        close()
        viewController.destroy()
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
        
        [rootContainer, waveformContainer].forEach {$0.fillColor = systemColorScheme.backgroundColor}
        btnClose.colorChanged(systemColorScheme.buttonColor)
        lblCaption.textColor = systemColorScheme.captionTextColor
    }
}
