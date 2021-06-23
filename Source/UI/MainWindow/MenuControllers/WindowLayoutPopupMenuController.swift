import Cocoa

class WindowLayoutPopupMenuController: GenericPresetPopupMenuController {

    private lazy var managerWindowController: PresetsManagerWindowController = PresetsManagerWindowController.instance
    private lazy var windowLayoutsManager: WindowLayoutsManager = ObjectGraph.windowLayoutsManager
    
    override var descriptionOfPreset: String {"layout"}
    override var descriptionOfPreset_plural: String {"layouts"}
    
    override var userDefinedPresets: [MappedPreset] {windowLayoutsManager.userDefinedPresets}
    override var numberOfUserDefinedPresets: Int {windowLayoutsManager.numberOfUserDefinedPresets}
    
    override func presetExists(named name: String) -> Bool {
        windowLayoutsManager.presetExists(named: name)
    }
    
    // Receives a new layout name and saves the new layout.
    override func addPreset(named name: String) {
        
        let newLayout = WindowManager.instance.currentWindowLayout
        newLayout.name = name
        windowLayoutsManager.addPreset(newLayout)
    }
    
    override func applyPreset(named name: String) {
        WindowManager.instance.layout(name)
    }
    
    @IBAction func manageLayoutsAction(_ sender: Any) {
        managerWindowController.showLayoutsManager()
    }
}
