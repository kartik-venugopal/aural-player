//
//  FontSchemeSizesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FontSchemeSizesViewController: NSViewController, FontSchemesViewProtocol {
    
    @IBOutlet weak var captionSizeStepper: FontSizeStepper!
    @IBOutlet weak var prominentSizeStepper: FontSizeStepper!
    @IBOutlet weak var normalSizeStepper: FontSizeStepper!
    @IBOutlet weak var smallSizeStepper: FontSizeStepper!
    @IBOutlet weak var xtraSmallSizeStepper: FontSizeStepper!
    @IBOutlet weak var tableTextOffsetStepper: FontSizeStepper!
    
    override var nibName: NSNib.Name? {"FontSchemeSizes"}
    
    func resetFields(_ fontScheme: FontScheme) {
        loadFontScheme(fontScheme)
    }
    
    func loadFontScheme(_ fontScheme: FontScheme) {
        
        captionSizeStepper.fontSize = fontScheme.captionFont.pointSize
        prominentSizeStepper.fontSize = fontScheme.prominentFont.pointSize
        normalSizeStepper.fontSize = fontScheme.normalFont.pointSize
        smallSizeStepper.fontSize = fontScheme.smallFont.pointSize
        xtraSmallSizeStepper.fontSize = fontScheme.extraSmallFont.pointSize
        tableTextOffsetStepper.fontSize = fontScheme.tableYOffset
    }
    
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme) {
        
        let textFontName = context.textFontName
        let captionFontName = context.captionFontName
        
        fontScheme.captionFont = NSFont(name: captionFontName, size: captionSizeStepper.fontSize)!
        fontScheme.prominentFont = NSFont(name: textFontName, size: prominentSizeStepper.fontSize)!
        fontScheme.normalFont = NSFont(name: textFontName, size: normalSizeStepper.fontSize)!
        fontScheme.smallFont = NSFont(name: textFontName, size: smallSizeStepper.fontSize)!
        fontScheme.extraSmallFont = NSFont(name: textFontName, size: xtraSmallSizeStepper.fontSize)!
        fontScheme.tableYOffset = tableTextOffsetStepper.fontSize
    }
}
