//
//  GenericPresetPopupMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the popup menu that lists the available color schemes and opens the color scheme editor panel.
 */
class GenericPresetPopupMenuController: NSObject, NSMenuDelegate, StringInputReceiver {
    
    @IBOutlet weak var theMenu: NSMenu!
    private lazy var presetNamePopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    var descriptionOfPreset: String {"preset"}
    var descriptionOfPreset_plural: String {"presets"}
    
    var userDefinedPresets: [MappedPreset] {[]}
    var numberOfUserDefinedPresets: Int {0}
    
    func presetExists(named name: String) -> Bool {
        false
    }
    
    override func awakeFromNib() {
        
        theMenu.insertItem(NSMenuItem.createDescriptor(title: "Built-in \(descriptionOfPreset_plural)"), at: 0)
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
        
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
        theMenu.insertItem(NSMenuItem.createDescriptor(title: "Custom \(descriptionOfPreset_plural)"), at: 0)
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all user-defined scheme items (i.e. all items before the first separator)
        while let item = menu.item(at: 3), !item.isSeparatorItem {
            menu.removeItem(at: 3)
        }
        
        // Recreate the user-defined color scheme items
        userDefinedPresets.forEach {

            let item: NSMenuItem = NSMenuItem(title: $0.key, action: #selector(self.applyPresetAction(_:)), keyEquivalent: "")
            item.target = self
            item.indentationLevel = 1

            menu.insertItem(item, at: 3)
        }

        for index in 0...2 {
            menu.item(at: index)?.showIf_elseHide(numberOfUserDefinedPresets > 0)
        }
    }
    
    // Must be overriden by subclasses
    @IBAction func applyPresetAction(_ sender: NSMenuItem) {
        applyPreset(named: sender.title)
    }
    
    @IBAction func savePresetAction(_ sender: NSMenuItem) {
        presetNamePopover.show(WindowManager.instance.mainWindow.contentView!, NSRectEdge.maxX)
    }
    
    // MARK - StringInputReceiver functions (to receive the name of a new user-defined color scheme)
    
    var inputPrompt: String {
        return "Enter a new \(descriptionOfPreset) name:"
    }
    
    var defaultValue: String? {
        return "<New \(descriptionOfPreset)>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        if presetExists(named: string) {
            return (false, "\(descriptionOfPreset.capitalizingFirstLetter()) with this name already exists !")
        } else if string.trim().isEmpty {
            return (false, "Name must have at least 1 character.")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new preset name and saves the new scheme (must be overriden).
    func acceptInput(_ string: String) {
        addPreset(named: string)
    }

    // Must be overriden by subclasses.
    func addPreset(named name: String) {
    }
    
    // Must be overriden by subclasses.
    func applyPreset(named name: String) {
    }
}
