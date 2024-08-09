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
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    private let viewController: WaveformViewController = .init()
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        window?.contentView?.addSubview(viewController.view)
        viewController.view.anchorToSuperview()
        
        // Bring the 'X' (Close) button to the front and constrain it.
        btnClose.bringToFront()

        btnCloseConstraints.setWidth(11.5)
        btnCloseConstraints.setHeight(10)
        btnCloseConstraints.setLeading(relatedToLeadingOf: btnClose.superview!, offset: 10)
        btnCloseConstraints.setTop(relatedToTopOf: btnClose.superview!, offset: 15)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
    }
    
    @IBAction func closeAction(_ sender: NSButton) {
        windowLayoutsManager.toggleWindow(withId: .waveform)
    }
}

extension WaveformWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        btnClose.colorChanged(systemColorScheme.buttonColor)
    }
}
