/*
    View controller for the "Detailed Track Info" popover
*/
import Cocoa

class DetailedTrackInfoViewController: NSViewController, PopoverViewDelegate, AsyncMessageSubscriber {
    
    // The actual popover that is shown
    private var popover: NSPopover!
    
    @IBOutlet weak var tabView: AuralTabView!
    
    // Displays track artwork
    @IBOutlet weak var artView: NSImageView!
    
    @IBOutlet weak var lyricsView: NSTextView! {
        
        didSet {
            lyricsView.font = Fonts.gillSans13Font
            lyricsView.alignment = .center
            lyricsView.backgroundColor = Colors.popoverBackgroundColor
            lyricsView.textColor = Colors.boxTextColor
            lyricsView.enclosingScrollView?.contentInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            lyricsView.enclosingScrollView?.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: -9)
        }
    }
    
    // The table view that displays the track info
    @IBOutlet weak var metadataTable: NSTableView! {
        
        didSet {
            metadataTable.enclosingScrollView?.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 1)
        }
    }
    
    @IBOutlet weak var coverArtTable: NSTableView!
    
    // The table view that displays the track info
    @IBOutlet weak var audioTable: NSTableView!
    
    // The table view that displays the track info
    @IBOutlet weak var fileSystemTable: NSTableView!
    
    // Temporary holder for the currently shown track
    static var shownTrack: Track?
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    
    private lazy var dateFormatter: DateFormatter = {
    
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy  'at'  hh:mm:ss a"
        return formatter
    }()
    
    let subscriberId: String = "DetailedTrackInfoViewController"
    
    private let noLyricsText: String = "< No lyrics available for this track >"
    
    override var nibName: String? {return "DetailedTrackInfo"}
    
    override func awakeFromNib() {
        AsyncMessenger.subscribe([.trackInfoUpdated], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    static func create() -> DetailedTrackInfoViewController {
        
        let controller = DetailedTrackInfoViewController()
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller
        
        controller.popover = popover
        
        return controller
    }
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh(_ track: Track) {
        
        // Force the view to load
        if !self.isViewLoaded {
            _ = self.view
        }
        
        DetailedTrackInfoViewController.shownTrack = track
        
        [metadataTable, coverArtTable, audioTable, fileSystemTable].forEach({
            $0?.reloadData()
            $0?.scrollRowToVisible(0)
        })
        
        artView?.image = track.displayInfo.art?.image
        lyricsView?.string = track.lyrics ?? noLyricsText
    }
    
    func show(_ track: Track, _ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        refresh(track)
        
        if (!popover.isShown) {
            popover.show(relativeTo: positioningRect, of: relativeToView, preferredEdge: preferredEdge)
            tabView.selectTabViewItem(at: 0)
        }
    }
    
    func isShown() -> Bool {
        return popover.isShown
    }
    
    func close() {
        
        if (popover.isShown) {
            popover.performClose(self)
        }
    }
    
    func toggle(_ track: Track, _ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        if (popover.isShown) {
            close()
        } else {
            show(track, relativeToView, preferredEdge)
        }
    }
    
    @IBAction func exportJSONAction(_ sender: AnyObject) {
        
        if let track = DetailedTrackInfoViewController.shownTrack {
            
            let metadataDict = tableToJSON(metadataTable)
            let audioDict = tableToJSON(audioTable)
            let fileSystemDict = tableToJSON(fileSystemTable)
            
            var dict = [NSString: AnyObject]()
            
            var appDict = [NSString: AnyObject]()
            appDict["version"] = AppConstants.appVersion  as AnyObject
            appDict["exportDate"] = dateFormatter.string(from: Date()) as AnyObject
            
            dict["appInfo"] = appDict as NSDictionary
            dict["metadata"] = metadataDict
            dict["lyrics"] = lyricsView.string as AnyObject
            dict["audio"] = audioDict
            dict["fileSystem"] = fileSystemDict
            
            let dialog = DialogsAndAlerts.exportMetadataPanel(track.conciseDisplayName + "-metadata", "json")
            
            if dialog.runModal() == NSApplication.ModalResponse.OK, let outFile = dialog.url {
                
                do {
                    
                    try JSONWriter.writeObject(dict as NSDictionary, outFile)
                    
                } catch let error {
                    
                    if let error = error as? JSONWriteError {
                        _ = UIUtils.showAlert(DialogsAndAlerts.genericErrorAlert("JSON file not written", error.message, error.description))
                    }
                }
            }
        }
    }
    
    private func tableToJSON(_ table: NSTableView) -> NSDictionary {
        
        var dict: [NSString: AnyObject] = [:]
        
        for index in 0..<table.numberOfRows {
            
            let keyCell = table.view(atColumn: 0, row: index, makeIfNecessary: true) as! NSTableCellView
            if let key = keyCell.textField?.stringValue {
                
                let valueCell = table.view(atColumn: 1, row: index, makeIfNecessary: true) as! NSTableCellView
                if let value = valueCell.textField?.stringValue {
                    dict[key.prefix(key.count - 1) as NSString] = value as AnyObject
                }
            }
        }
        
        return dict as NSDictionary
    }
    
    @IBAction func exportHTMLAction(_ sender: AnyObject) {
        
        if let track = DetailedTrackInfoViewController.shownTrack {
            
            let html = HTMLWriter()
            
            html.addTitle(track.conciseDisplayName)
            html.addHeading(track.conciseDisplayName, 2, false)
            
            let text = String(format: "Metadata exported by Aural Player v%@ on: %@", AppConstants.appVersion, dateFormatter.string(from: Date()))
            let exportDate = HTMLText(text, true, false, false, nil)
            html.addParagraph(exportDate)
            
            let horizPadding: Int = 20
            let vertPadding: Int = 5
            
            html.addTable("Metadata:", 3, nil, tableToHTML(metadataTable), horizPadding, vertPadding)
            
            html.addHeading("Lyrics:", 3, true)
            
            let lyrics = HTMLText(lyricsView.string, false, false, false, nil)
            html.addParagraph(lyrics)
            
            html.addTable("Audio:", 3, nil, tableToHTML(audioTable), horizPadding, vertPadding)
            html.addTable("File System:", 3, nil, tableToHTML(fileSystemTable), horizPadding, vertPadding)
            
            let dialog = DialogsAndAlerts.exportMetadataPanel(track.conciseDisplayName + "-metadata", "html")
            
            if dialog.runModal() == NSApplication.ModalResponse.OK, let outFile = dialog.url {
                
                do {
                    
                    try html.writeToFile(outFile)
                    
                } catch let error {
                    
                    if let error = error as? HTMLWriteError {
                        _ = UIUtils.showAlert(DialogsAndAlerts.genericErrorAlert("HTML file not written", error.message, error.description))
                    }
                }
            }
        }
    }
    
    private func tableToHTML(_ table: NSTableView) -> [[HTMLText]] {
        
        var grid: [[HTMLText]] = [[]]
        
        for index in 0..<table.numberOfRows {
            
            let keyCell = table.view(atColumn: 0, row: index, makeIfNecessary: true) as! NSTableCellView
            if let key = keyCell.textField?.stringValue {
                
                let valueCell = table.view(atColumn: 1, row: index, makeIfNecessary: true) as! NSTableCellView
                if let value = valueCell.textField?.stringValue {
                    
                    let keyCol = HTMLText(String(key.prefix(key.count - 1)), true, false, false, 300)
                    let valueCol = HTMLText(value, false, false, false, nil)
                    grid.append([keyCol, valueCol])
                }
            }
        }
        
        return grid
    }
    
    @IBAction func closePopoverAction(_ sender: Any) {
        close()
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
    
        if popover.isShown && message.messageType == .trackInfoUpdated {
            
            let msg = message as! TrackUpdatedAsyncMessage
                
            if msg.track == DetailedTrackInfoViewController.shownTrack {
                
                artView?.image = msg.track.displayInfo.art?.image
                print("UPDATED cover art for", msg.track.conciseDisplayName)
                coverArtTable.reloadData()
            }
        }
    }
}
