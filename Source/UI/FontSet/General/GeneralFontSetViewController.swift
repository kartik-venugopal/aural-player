import Cocoa

class GeneralFontSetViewController: NSViewController, NSMenuDelegate {

    @IBOutlet weak var textFontMenu: NSPopUpButton!
    @IBOutlet weak var lblTextPreview: NSTextField!
    
    override var nibName: NSNib.Name? {return "GeneralFontSet"}
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        menu.removeAllItems()
        
        for family in NSFontManager.shared.availableFontFamilies {
            
            if let members = NSFontManager.shared.availableMembers(ofFontFamily: family) {
                
                for member in members {
                    
                    if member.count >= 2, let fontName = member[0] as? String, let weight = member[1] as? String {
                        
                        let displayName = String(format: "%@ %@", family, weight)
                        
                        let newItem = FontMenuItem(title: displayName, action: nil, keyEquivalent: "")
                        newItem.fontName = fontName
                        
                        menu.addItem(newItem)
                        
                    }
                }
            }
        }
    }
    
    @IBAction func chooseTextFontAction(_ sender: Any) {
        
        if let selItem = textFontMenu.selectedItem as? FontMenuItem, let font = NSFont(name: selItem.fontName, size: 14) {
            
            print("Chose font:", font)
            lblTextPreview.font = font
        }
    }
}

class FontMenuItem: NSMenuItem {
    
    var fontName: String = ""
}
