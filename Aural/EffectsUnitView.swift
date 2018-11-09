//import Cocoa
//
//class EffectsUnitView: NSView, NSMenuDelegate, StringInputClient {
//    
//    @IBOutlet weak var btnBypass: EffectsUnitTriStateBypassButton!
//    
//    // Presets menu
//    @IBOutlet weak var presetsMenu: NSPopUpButton!
//    @IBOutlet weak var btnSavePreset: NSButton!
//    
//    private let eqPresets: EQPresets = ObjectGraph.getAudioGraphDelegate().eqPresets
//    
//    private lazy var userPresetsPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
//    
//    func initialize(_ stateFunction: @escaping () -> EffectsUnitState) {
//        
//        btnBypass.stateFunction = stateFunction
//        stateChanged()
//    }
//    
//    func stateChanged() {
//        btnBypass.updateState()
//    }
//    
//    func menuNeedsUpdate(_ menu: NSMenu) {
//        
//        if !presetsMenu.itemArray.isEmpty {
//            
//            // Remove all custom presets
//            while !presetsMenu.itemArray[0].isSeparatorItem {
//                presetsMenu.removeItem(at: 0)
//            }
//        }
//        
//        // Re-initialize the menu with user-defined presets
//        // TODO
//        eqPresets.userDefinedPresets.forEach({presetsMenu.insertItem(withTitle: $0.name, at: 0)})
//        
//        // Don't select any items from the EQ presets menu
//        presetsMenu.selectItem(at: -1)
//    }
// 
//    // MARK - StringInputClient functions
//    
//    func getInputPrompt() -> String {
//        return "Enter a new preset name:"
//    }
//    
//    func getDefaultValue() -> String? {
//        return "<New preset>"
//    }
//    
//    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
//        
//        // TODO
//        let valid = !eqPresets.presetWithNameExists(string)
//        
//        if (!valid) {
//            return (false, "Preset with this name already exists !")
//        } else {
//            return (true, nil)
//        }
//    }
//    
//    // Receives a new EQ preset name and saves the new preset
//    func acceptInput(_ string: String) {
//        
//        // Add a menu item for the new preset, at the top of the menu
//        presetsMenu.insertItem(withTitle: string, at: 0)
//    }
//}
