import Cocoa

class GeneralFontSetViewController: NSViewController, FontSetsViewProtocol {
    
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
    
    override var nibName: NSNib.Name? {return "GeneralFontSet"}
    
    var fontSetsView: NSView {
        self.view
    }
    
    var textFontName: String {
        (textFontMenuButton.selectedItem as! FontMenuItem).fontName
    }
    
    var headingFontName: String {
        (headingFontMenuButton.selectedItem as! FontMenuItem).fontName
    }
    
    func resetFields(_ fontSet: FontSet) {
        
//        print("Current font:", fontSet.player.infoBoxTitleFont_normal.familyName, fontSet.player.infoBoxTitleFont_normal.displayName, fontSet.player.infoBoxTitleFont_normal.fontName)
        
        textFontMenu.removeAllItems()
        headingFontMenu.removeAllItems()
        
        var fontNameToDisplayNameMap: [String: String] = [:]
        
        for family in NSFontManager.shared.availableFontFamilies {
            
            if let members = NSFontManager.shared.availableMembers(ofFontFamily: family) {
                
                for member in members {
                    
                    if member.count >= 2, let fontName = member[0] as? String, let weight = member[1] as? String {
                        
                        let displayName = String(format: "%@ %@", family, weight)
                        fontNameToDisplayNameMap[fontName] = displayName
                        
                        let newItem1 = FontMenuItem(title: displayName, action: nil, keyEquivalent: "")
                        newItem1.fontName = fontName
                        textFontMenu.addItem(newItem1)
                        
                        let newItem2 = FontMenuItem(title: displayName, action: nil, keyEquivalent: "")
                        newItem2.fontName = fontName
                        headingFontMenu.addItem(newItem2)
                    }
                }
            }
        }
        
        if let displayNameOfTextFont = fontNameToDisplayNameMap[fontSet.player.infoBoxTitleFont.fontName] {
            
            textFontMenuButton.selectItem(withTitle: displayNameOfTextFont)
            lblTextPreview.font = NSFont(name: fontSet.player.infoBoxTitleFont.fontName, size: 14)
        }
        
        if let displayNameOfHeadingFont = fontNameToDisplayNameMap[fontSet.playlist.tabButtonTextFont.fontName] {
            
            headingFontMenuButton.selectItem(withTitle: displayNameOfHeadingFont)
            lblHeadingPreview.font = NSFont(name: fontSet.playlist.tabButtonTextFont.fontName, size: 18)
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
    
    func applyFontSet(_ context: FontSetChangeContext, to fontSet: FontSet) {
        
        context.textFontName = textFontName
        context.headingFontName = headingFontName
    }
}

class FontMenuItem: NSMenuItem {
    
    var fontName: String = ""
}
