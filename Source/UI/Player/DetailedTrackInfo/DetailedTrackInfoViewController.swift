//
//  DetailedTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    View controller for the "Detailed Track Info" popover
*/
import Cocoa

class DetailedTrackInfoViewController: NSViewController, NSMenuDelegate, PopoverViewDelegate, Destroyable {
    
    private static var _instance: DetailedTrackInfoViewController?
    static var instance: DetailedTrackInfoViewController {
        
        if _instance == nil {
            _instance = create()
        }
        
        return _instance!
    }
    
    private static func create() -> DetailedTrackInfoViewController {
        
        let controller = DetailedTrackInfoViewController()
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller
        
        controller.popover = popover
        
        return controller
    }
    
    static func destroy() {
        
        _instance?.destroy()
        _instance = nil
    }
    
    // The actual popover that is shown
    private var popover: NSPopover!
    
    @IBOutlet weak var tabView: AuralTabView!
    
    @IBOutlet weak var lblNoArt: NSTextField!
    
    // Displays track artwork
    @IBOutlet weak var artView: NSImageView!
    
    @IBOutlet weak var exportArtMenuItem: NSMenuItem!
    @IBOutlet weak var exportHTMLWithArtMenuItem: NSMenuItem!
    
    @IBOutlet weak var lyricsView: NSTextView! {
        
        didSet {
            
            lyricsView.font = FontConstants.Standard.mainFont_13
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
    // TODO: Replace this static var with messaging: trackShown(track)
    static var shownTrack: Track?
    
    // Whether or not this popover is currently displayed attached to the player (false if attached to playlist).
    var attachedToPlayer: Bool = true
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    
    private lazy var dateFormatter: DateFormatter = {
    
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm:ss a"
        return formatter
    }()
    
    private let noLyricsText: String = "< No lyrics available for this track >"
    
    override var nibName: String? {"DetailedTrackInfo"}
    
    private let horizHTMLTablePadding: Int = 20
    private let vertHTMLTablePadding: Int = 5
    
    private lazy var messenger = Messenger(for: self)
    
    override func awakeFromNib() {
        
        // Only respond to these notifications when the popover is shown, the updated track matches the displayed track,
        // and the album art field of the track was updated.
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: trackInfoUpdated(_:),
                                 filter: {[weak self] msg in (self?.popover.isShown ?? false) && msg.updatedTrack == DetailedTrackInfoViewController.shownTrack && msg.updatedFields.contains(.art)})
    }
    
    func destroy() {
        
        messenger.unsubscribeFromAll()
        
        close()
        
        popover.contentViewController = nil
        self.popover = nil
        
        TrackInfoViewHolder.destroy()
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
        
        artView?.image = track.art?.image
        lblNoArt.showIf(artView?.image == nil)
        
        lyricsView?.string = track.lyrics ?? noLyricsText
    }
    
    func show(_ track: Track, _ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        refresh(track)
        
        if !popover.isShown {
            
            popover.show(relativeTo: positioningRect, of: relativeToView, preferredEdge: preferredEdge)
            tabView.selectTabViewItem(at: 0)
        }
    }
    
    var isShown: Bool {
        return popover.isShown
    }
    
    func close() {
        
        if popover.isShown {
            popover.performClose(self)
        }
    }
    
    func toggle(_ track: Track, _ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        popover.isShown ? close() : show(track, relativeToView, preferredEdge)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        let hasImage: Bool = DetailedTrackInfoViewController.shownTrack?.art?.image != nil
        
        exportArtMenuItem.showIf(hasImage)
        exportHTMLWithArtMenuItem.showIf(hasImage)
    }
    
    @IBAction func exportJPEGAction(_ sender: AnyObject) {
        doExportArt(.jpeg, "jpg")
    }
    
    @IBAction func exportPNGAction(_ sender: AnyObject) {
        doExportArt(.png, "png")
    }
    
    private func doExportArt(_ type: NSBitmapImageRep.FileType, _ fileExtension: String) {
        
        if let track = DetailedTrackInfoViewController.shownTrack, let image = track.art?.image {
            
            let dialog = DialogsAndAlerts.exportMetadataDialog(fileName: track.displayName + "-coverArt", fileExtension: fileExtension)
            
            if dialog.runModal() == NSApplication.ModalResponse.OK, let outFile = dialog.url {
                    
                do {
                    try image.writeToFile(fileType: type, file: outFile)
                    
                } catch {
                    
                    _ = DialogsAndAlerts.genericErrorAlert("Image file not written", "Unable to export image", error.localizedDescription).showModal()
                }
            }
        }
    }
    
    @IBAction func exportJSONAction(_ sender: AnyObject) {
        
        if let track = DetailedTrackInfoViewController.shownTrack {
            
            let metadataDict = tableToJSON(metadataTable)
            let audioDict = tableToJSON(audioTable)
            let fileSystemDict = tableToJSON(fileSystemTable)
            
            var dict = [NSString: AnyObject]()
            
            var appDict = [NSString: AnyObject]()
            
            appDict["version"] = NSApp.appVersion as AnyObject
            appDict["exportDate"] = dateFormatter.string(from: Date()) as AnyObject
            
            dict["appInfo"] = appDict as NSDictionary
            dict["metadata"] = metadataDict
            dict["lyrics"] = lyricsView.string as AnyObject
            dict["audio"] = audioDict
            dict["fileSystem"] = fileSystemDict
            
            let dialog = DialogsAndAlerts.exportMetadataDialog(fileName: track.displayName + "-metadata", fileExtension: "json")
            
            if dialog.runModal() == NSApplication.ModalResponse.OK, let outFile = dialog.url {
                
                do {
                    
                    try JSONSerialization.writeObject(dict as NSDictionary, toFile: outFile)
                    
                } catch {
                    
                    if let error = error as? JSONWriteError {
                        _ = DialogsAndAlerts.genericErrorAlert("JSON file not written", error.message, error.description).showModal()
                    }
                }
            }
        }
    }
    
    private func tableToJSON(_ table: NSTableView) -> NSDictionary {
        
        var dict: [NSString: AnyObject] = [:]
        
        for index in 0..<table.numberOfRows {
            
            if let keyCell = table.view(atColumn: 0, row: index, makeIfNecessary: true) as? NSTableCellView,
               let key = keyCell.textField?.stringValue,
               let valueCell = table.view(atColumn: 1, row: index, makeIfNecessary: true) as? NSTableCellView,
               let value = valueCell.textField?.stringValue {
                
                dict[key.prefix(key.count - 1) as NSString] = value as AnyObject
            }
        }
        
        return dict as NSDictionary
    }
    
    @IBAction func exportHTMLWithArtAction(_ sender: AnyObject) {
        doExportHTML(true)
    }
    
    @IBAction func exportHTMLAction(_ sender: AnyObject) {
        doExportHTML(false)
    }
        
    private func doExportHTML(_ withArt: Bool) {
        
        if let track = DetailedTrackInfoViewController.shownTrack {
            
            let metadataHTML = tableToHTML(metadataTable)
            let audioHTML = tableToHTML(audioTable)
            let fileSystemHTML = tableToHTML(fileSystemTable)
            
            let dialog = DialogsAndAlerts.exportMetadataDialog(fileName: track.displayName + "-metadata", fileExtension: "html")
            
            if dialog.runModal() == NSApplication.ModalResponse.OK, let outFile = dialog.url {
                
                do {
                    
                    let html = HTMLWriter()
                    
                    html.addTitle(track.displayName)
                    html.addHeading(track.displayName, 2, false)
                    
                    let text = String(format: "Metadata exported by Aural Player v%@ on: %@", NSApp.appVersion, dateFormatter.string(from: Date()))
                    let exportDate = HTMLText(text: text, underlined: true, bold: false, italic: false, width: nil)
                    html.addParagraph(exportDate)
                    
                    // Embed art in HTML
                    if withArt, let image = track.art?.image, let bits = image.representations.first as? NSBitmapImageRep, let data = bits.representation(using: .jpeg, properties: [:]) {
                        
                        let imgFile = outFile.deletingLastPathComponent().appendingPathComponent(track.displayName + "-coverArt.jpg", isDirectory: false)
                        
                        do {
                            
                            try data.write(to: imgFile)
                        } catch {}
                        
                        html.addImage(imgFile.lastPathComponent, "(Cover Art)")
                    }
                    
                    html.addTable("Metadata:", 3, nil, metadataHTML, horizHTMLTablePadding, vertHTMLTablePadding)
                    
                    html.addHeading("Lyrics:", 3, true)
                    
                    let lyrics = HTMLText(text: lyricsView.string, underlined: false, bold: false, italic: false, width: nil)
                    html.addParagraph(lyrics)
                    
                    html.addTable("Audio:", 3, nil, audioHTML, horizHTMLTablePadding, vertHTMLTablePadding)
                    html.addTable("File System:", 3, nil, fileSystemHTML, horizHTMLTablePadding, vertHTMLTablePadding)
                    
                    try html.writeToFile(outFile)
                    
                } catch {
                    
                    if let error = error as? HTMLWriteError {
                        _ = DialogsAndAlerts.genericErrorAlert("HTML file not written", error.message, error.description).showModal()
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
                    
                    let keyCol = HTMLText(text: String(key.prefix(key.count - 1)), underlined: true, bold: false, italic: false, width: 300)
                    let valueCol = HTMLText(text: value, underlined: false, bold: false, italic: false, width: nil)
                    grid.append([keyCol, valueCol])
                }
            }
        }
        
        return grid
    }
    
    @IBAction func previousTabAction(_ sender: Any) {
        tabView.previousTab()
    }
    
    @IBAction func nextTabAction(_ sender: Any) {
        tabView.nextTab()
    }
    
    @IBAction func closePopoverAction(_ sender: Any) {
        close()
    }
    
    func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
    
        artView?.image = notification.updatedTrack.art?.image
        lblNoArt.showIf(artView?.image == nil)
        coverArtTable?.reloadData()
    }
}
