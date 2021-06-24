//
//  EffectsFontSchemeViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EffectsFontSchemeViewController: NSViewController, FontSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var unitCaptionStepper: NSStepper!
    @IBOutlet weak var txtUnitCaption: NSTextField!
    
    @IBOutlet weak var unitFunctionStepper: NSStepper!
    @IBOutlet weak var txtUnitFunction: NSTextField!
    
    @IBOutlet weak var masterUnitFunctionStepper: NSStepper!
    @IBOutlet weak var txtMasterUnitFunction: NSTextField!
    
    @IBOutlet weak var filterChartStepper: NSStepper!
    @IBOutlet weak var txtFilterChart: NSTextField!
    
    @IBOutlet weak var auTableRowYOffsetStepper: NSStepper!
    @IBOutlet weak var txtAUTableRowYOffset: NSTextField!
    
    override var nibName: NSNib.Name? {return "EffectsFontScheme"}
    
    var fontSchemesView: NSView {
        self.view
    }
    
    // Scrolls the scroll view to the top
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.height))
    }
    
    func resetFields(_ fontScheme: FontScheme) {
        
        scrollToTop()
        loadFontScheme(fontScheme)
    }
        
    func loadFontScheme(_ fontScheme: FontScheme) {
        
        unitCaptionStepper.floatValue = Float(fontScheme.effects.unitCaptionFont.pointSize * 10)
        txtUnitCaption.stringValue = String(format: "%.1f", unitCaptionStepper.floatValue / 10.0)
        
        unitFunctionStepper.floatValue = Float(fontScheme.effects.unitFunctionFont.pointSize * 10)
        txtUnitFunction.stringValue = String(format: "%.1f", unitFunctionStepper.floatValue / 10.0)
        
        masterUnitFunctionStepper.floatValue = Float(fontScheme.effects.masterUnitFunctionFont.pointSize * 10)
        txtMasterUnitFunction.stringValue = String(format: "%.1f", masterUnitFunctionStepper.floatValue / 10.0)
        
        filterChartStepper.floatValue = Float(fontScheme.effects.filterChartFont.pointSize * 10)
        txtFilterChart.stringValue = String(format: "%.1f", filterChartStepper.floatValue / 10.0)
        
        auTableRowYOffsetStepper.integerValue = fontScheme.effects.auRowTextYOffset.roundedInt
        txtAUTableRowYOffset.stringValue = String(format: "%d px", auTableRowYOffsetStepper.integerValue)
    }
    
    @IBAction func unitCaptionStepperAction(_ sender: NSStepper) {
        txtUnitCaption.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func unitFunctionStepperAction(_ sender: NSStepper) {
        txtUnitFunction.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func masterUnitFunctionStepperAction(_ sender: NSStepper) {
        txtMasterUnitFunction.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func filterChartStepperAction(_ sender: NSStepper) {
        txtFilterChart.stringValue = String(format: "%.1f", sender.floatValue / 10.0)
    }
    
    @IBAction func auTableRowYOffsetStepperAction(_ sender: NSStepper) {
        txtAUTableRowYOffset.stringValue = String(format: "%d px", auTableRowYOffsetStepper.integerValue)
    }
    
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme) {
        
        let textFontName = context.textFontName
        let headingFontName = context.headingFontName
        
        fontScheme.effects.unitCaptionFont = NSFont(name: headingFontName, size: CGFloat(unitCaptionStepper.floatValue / 10.0))!
        fontScheme.effects.unitFunctionFont = NSFont(name: textFontName, size: CGFloat(unitFunctionStepper.floatValue / 10.0))!
        fontScheme.effects.masterUnitFunctionFont = NSFont(name: headingFontName, size: CGFloat(masterUnitFunctionStepper.floatValue / 10.0))!
        fontScheme.effects.filterChartFont = NSFont(name: textFontName, size: CGFloat(filterChartStepper.floatValue / 10.0))!
        fontScheme.effects.auRowTextYOffset = CGFloat(auTableRowYOffsetStepper.integerValue)
    }
}
