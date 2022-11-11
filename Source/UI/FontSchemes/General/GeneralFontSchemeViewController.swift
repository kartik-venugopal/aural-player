//
//  GeneralFontSchemeViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class GeneralFontSchemeViewController: NSViewController, FontSchemesViewProtocol {
    
    @IBOutlet weak var textFontMenuButton: NSPopUpButton!
    @IBOutlet weak var headingFontMenuButton: NSPopUpButton!
    
    private var textFontMenu: NSMenu {
        textFontMenuButton.menu!
    }
    
    private var headingFontMenu: NSMenu {
        headingFontMenuButton.menu!
    }
    
    @IBOutlet weak var lblTextPreview: NSTextField!
    @IBOutlet weak var lblHeadingPreview: NSTextField!
    
    override var nibName: NSNib.Name? {"GeneralFontScheme"}
    
    var textFontName: String {
        (textFontMenuButton.selectedItem as! FontMenuItem).fontName
    }
    
    var headingFontName: String {
        (headingFontMenuButton.selectedItem as! FontMenuItem).fontName
    }
    
    var fontNameToDisplayNameMap: [String: String] = [:]
    
    func resetFields(_ fontScheme: FontScheme) {
        
        textFontMenu.removeAllItems()
        headingFontMenu.removeAllItems()
        
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
                        headingFontMenu.addItem(newItem2)
                    }
                }
            }
        }
        
        loadFontScheme(fontScheme)
    }
    
    func loadFontScheme(_ fontScheme: FontScheme) {
        
        if let displayNameOfTextFont = fontNameToDisplayNameMap[fontScheme.player.infoBoxTitleFont.fontName] {
            
            textFontMenuButton.selectItem(withTitle: displayNameOfTextFont)
            lblTextPreview.font = NSFont(name: fontScheme.player.infoBoxTitleFont.fontName, size: 14)
        }
        
        if let displayNameOfHeadingFont = fontNameToDisplayNameMap[fontScheme.playlist.tabButtonTextFont.fontName] {
            
            headingFontMenuButton.selectItem(withTitle: displayNameOfHeadingFont)
            lblHeadingPreview.font = NSFont(name: fontScheme.playlist.tabButtonTextFont.fontName, size: 18)
        }
    }
    
    @IBAction func chooseTextFontAction(_ sender: Any) {
        
        if let selItem = textFontMenuButton.selectedItem as? FontMenuItem, let font = NSFont(name: selItem.fontName, size: 14) {
            lblTextPreview.font = font
        }
    }
    
    @IBAction func chooseHeadingFontAction(_ sender: Any) {
        
        if let selItem = headingFontMenuButton.selectedItem as? FontMenuItem, let font = NSFont(name: selItem.fontName, size: 18) {
            lblHeadingPreview.font = font
        }
    }
    
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme) {
        
        context.textFontName = textFontName
        context.headingFontName = headingFontName
    }
}

class FontMenuItem: NSMenuItem {
    
    var fontName: String = ""
}
