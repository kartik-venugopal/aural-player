import Cocoa
import AVFoundation

/*
    View controller for the Audio Units view.
 */
class AudioUnitsViewController: NSViewController, NSMenuDelegate, NotificationSubscriber {
    
    @IBOutlet weak var tableView: NSTableView!
    
    private let audioUnitEditorDialog: AudioUnitEditorDialogController = WindowFactory.audioUnitEditorDialog
    
    override var nibName: String? {return "AudioUnits"}
    
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    private let audioUnitsManager: AudioUnitsManager = ObjectGraph.audioUnitsManager
    
    @IBOutlet weak var btnAudioUnitsMenu: NSPopUpButton!

    @IBAction func addAudioUnitAction(_ sender: Any) {
        
        if let audioUnit = btnAudioUnitsMenu.selectedItem?.representedObject as? AVAudioUnitComponent,
           let result = audioGraph.addAudioUnit(ofType: audioUnit.audioComponentDescription.componentSubType) {
            
            // Refresh the table view with the new row.
            tableView.noteNumberOfRowsChanged()
            
            // Open the audio unit editor window with the new audio unit's custom view.
            DispatchQueue.main.async {
                self.audioUnitEditorDialog.showDialog(for: result.0)
            }
        }
    }
    
    @IBAction func editAudioUnitAction(_ sender: Any) {
        
        let selectedRow = tableView.selectedRow
        
        if selectedRow >= 0 {
            
            let audioUnit = audioGraph.audioUnits[selectedRow]
            
            // Open the audio unit editor window with the new audio unit's custom view.
//            DispatchQueue.main.async {
                self.audioUnitEditorDialog.showDialog(for: audioUnit)
//            }
        }
    }
    
    @IBAction func removeAudioUnitsAction(_ sender: Any) {
        
        let selRows = tableView.selectedRowIndexes
        
        if !selRows.isEmpty {
            
            audioGraph.removeAudioUnits(at: selRows)
            tableView.reloadData()
        }
    }
    
    // MARK: Menu Delegate functions
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets (all items before the first separator)
        while menu.items.count > 1 {
            menu.removeItem(at: 1)
        }
        
        for unit in audioUnitsManager.audioUnits {

            let item = NSMenuItem(title: unit.name, action: nil, keyEquivalent: "")
            item.target = self
            item.representedObject = unit
            
            menu.addItem(item)
        }
    }
}
