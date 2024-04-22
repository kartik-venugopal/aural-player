//
//  FontSchemeFontsViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FontSchemeFontsViewController: NSViewController, FontSchemesViewProtocol {
    
    @IBOutlet weak var textFontMenuButton: NSPopUpButton!
    @IBOutlet weak var captionFontMenuButton: NSPopUpButton!
    
    private var textFontMenu: NSMenu {
        textFontMenuButton.menu!
    }
    
    private var captionFontMenu: NSMenu {
        captionFontMenuButton.menu!
    }
    
    @IBOutlet weak var lblTextPreview: NSTextField!
    @IBOutlet weak var lblCaptionPreview: NSTextField!
    
    override var nibName: NSNib.Name? {"FontSchemeFonts"}
    
    var textFontName: String {
        (textFontMenuButton.selectedItem as! FontMenuItem).fontName
    }
    
    var captionFontName: String {
        (captionFontMenuButton.selectedItem as! FontMenuItem).fontName
    }
    
    var fontNameToDisplayNameMap: [String: String] = [:]
    
    func resetFields(_ fontScheme: FontScheme) {
        
        textFontMenu.removeAllItems()
        captionFontMenu.removeAllItems()
        
        fontNameToDisplayNameMap.removeAll()
        
        for family in NSFontManager.shared.availableFontFamilies {
            
            if let members = NSFontManager.shared.availableMembers(ofFontFamily: family) {
                
                for member in members {
                    
                    if member.count >= 2, let fontName = member[0] as? String, let weight = member[1] as? String {
                        
                        let displayName = String(format: "%@ %@", family, weight)
                        fontNameToDisplayNameMap[fontName] = displayName
                        
                        let newItem1 = FontMenuItem(title: displayName)
                        newItem1.fontName = fontName
                        textFontMenu.addItem(newItem1)
                        
                        let newItem2 = FontMenuItem(title: displayName)
                        newItem2.fontName = fontName
                        captionFontMenu.addItem(newItem2)
                    }
                }
            }
        }
        
        loadFontScheme(fontScheme)
    }
    
    func loadFontScheme(_ fontScheme: FontScheme) {
        
        if let displayNameOfTextFont = fontNameToDisplayNameMap[fontScheme.prominentFont.fontName] {
            
            textFontMenuButton.selectItem(withTitle: displayNameOfTextFont)
            lblTextPreview.font = NSFont(name: fontScheme.prominentFont.fontName, size: 14)
        }
        
        let captionFontName = fontScheme.captionFont.fontName
        
        if let displayNameOfCaptionFont = fontNameToDisplayNameMap[captionFontName] {
            
            captionFontMenuButton.selectItem(withTitle: displayNameOfCaptionFont)
            lblCaptionPreview.font = NSFont(name: captionFontName, size: 18)
        }
    }
    
    @IBAction func chooseTextFontAction(_ sender: Any) {
        
        if let selItem = textFontMenuButton.selectedItem as? FontMenuItem, let font = NSFont(name: selItem.fontName, size: 14) {
            lblTextPreview.font = font
        }
    }
    
    @IBAction func chooseCaptionFontAction(_ sender: Any) {
        
        if let selItem = captionFontMenuButton.selectedItem as? FontMenuItem, let font = NSFont(name: selItem.fontName, size: 18) {
            lblCaptionPreview.font = font
        }
    }
    
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme) {
        
        context.textFontName = textFontName
        context.captionFontName = captionFontName
    }
}

class FontMenuItem: NSMenuItem {
    
    var fontName: String = ""
}
