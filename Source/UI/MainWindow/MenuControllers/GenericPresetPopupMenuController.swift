//
//  GenericPresetPopupMenuController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the popup menu that lists the available color schemes and opens the color scheme editor panel.
 */
class GenericPresetPopupMenuController: NSObject {
    
    @IBOutlet weak var theMenu: NSMenu!
    private lazy var presetNamePopover: StringInputPopoverViewController = .create(self)
    
    var descriptionOfPreset: String {"preset"}
    var descriptionOfPreset_plural: String {"presets"}
    
    var userDefinedPresets: [UserManagedObject] {[]}
    var numberOfUserDefinedPresets: Int {0}
    
    func presetExists(named name: String) -> Bool {false}
    
    private lazy var windowLayoutsManager: WindowLayoutsManager = objectGraph.windowLayoutsManager
    
    // Must be overriden by subclasses
    @IBAction func applyPresetAction(_ sender: NSMenuItem) {
        applyPreset(named: sender.title)
    }
    
    @IBAction func savePresetAction(_ sender: NSMenuItem) {
        
        if let contentView = windowLayoutsManager.mainWindow.contentView {
            presetNamePopover.show(contentView, .maxX)
        }
    }
    
    // Must be overriden by subclasses.
    func addPreset(named name: String) {}
    
    // Must be overriden by subclasses.
    func applyPreset(named name: String) {}
}

extension GenericPresetPopupMenuController: NSMenuDelegate {
    
    override func awakeFromNib() {
        
        theMenu.insertItem(NSMenuItem.createDescriptor(title: "Built-in \(descriptionOfPreset_plural)"), at: 0)
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
        
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
        theMenu.insertItem(NSMenuItem.createDescriptor(title: "Custom \(descriptionOfPreset_plural)"), at: 0)
        theMenu.insertItem(NSMenuItem.separator(), at: 0)
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        menu.recreateMenu(insertingItemsAt: 3, withTitles: userDefinedPresets.map {$0.name},
                          action: #selector(self.applyPresetAction(_:)), target: self,
                          indentationLevel: 1)
        
        let showDescriptors: Bool = numberOfUserDefinedPresets > 0

        for index in 0...2 {
            menu.item(at: index)?.showIf(showDescriptors)
        }
    }
}

extension GenericPresetPopupMenuController: StringInputReceiver {
    
    // MARK - StringInputReceiver functions (to receive the name of a new user-defined color scheme)
    
    var inputPrompt: String {
        "Enter a new \(descriptionOfPreset) name:"
    }
    
    var defaultValue: String? {
        "<New \(descriptionOfPreset)>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        if presetExists(named: string) {
            return (false, "\(descriptionOfPreset.capitalizingFirstLetter()) with this name already exists !")
            
        } else if string.isEmptyAfterTrimming {
            return (false, "Name must have at least 1 character.")
            
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new preset name and saves the new scheme (must be overriden).
    func acceptInput(_ string: String) {
        addPreset(named: string)
    }
}
