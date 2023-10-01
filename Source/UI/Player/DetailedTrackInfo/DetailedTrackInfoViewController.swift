//
//  DetailedTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the "Detailed Track Info" popover
*/
class DetailedTrackInfoViewController: SingletonPopoverViewController, NSMenuDelegate {
    
    @IBOutlet weak var tabView: AuralTabView!
    
    @IBOutlet weak var exportArtMenuItem: NSMenuItem!
    @IBOutlet weak var exportHTMLWithArtMenuItem: NSMenuItem!
    
    private let metadataViewController: MetadataTrackInfoViewController = MetadataTrackInfoViewController()
    private let lyricsViewController: LyricsTrackInfoViewController = LyricsTrackInfoViewController()
    private let coverArtViewController: CoverArtTrackInfoViewController = CoverArtTrackInfoViewController()
    private let audioViewController: AudioTrackInfoViewController = AudioTrackInfoViewController()
    private let fileSystemViewController: FileSystemTrackInfoViewController = FileSystemTrackInfoViewController()
    
    private var viewControllers: [TrackInfoViewProtocol] = []
    
    // Temporary holder for the currently shown track
    var displayedTrack: Track?
    
    // Whether or not this popover is currently displayed attached to the player (false if attached to playlist).
    var attachedToPlayer: Bool = true
    
    private lazy var dateFormatter: DateFormatter = DateFormatter(format: "MMMM dd, yyyy 'at' hh:mm:ss a")
    
    override var nibName: String? {"DetailedTrackInfo"}
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        viewControllers = [metadataViewController, lyricsViewController, coverArtViewController,
                           audioViewController, fileSystemViewController]
        
        tabView.addViewsForTabs(viewControllers.map {$0.view})
        tabView.selectTabViewItem(at: 0)
        
        // Only respond to these notifications when the popover is shown, the updated track matches the displayed track,
        // and the album art field of the track was updated.
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: coverArtViewController.trackInfoUpdated(_:),
                                 filter: {[weak self] msg in (self?.popover.isShown ?? false) &&
                                    msg.updatedTrack == self?.displayedTrack &&
                                    msg.updatedFields.contains(.art)})
    }
    
    override func destroy() {

        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh(_ track: Track) {
        
        // Force the view to load
        if !self.isViewLoaded {
            _ = self.view
        }
        
        displayedTrack = track
        viewControllers.forEach {$0.refresh(forTrack: track)}
    }
    
    func show(_ track: Track, _ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        refresh(track)
        
        if !isShown {
            
            popover.show(relativeTo: positioningRect, of: relativeToView, preferredEdge: preferredEdge)
            tabView.selectTabViewItem(at: 0)
        }
    }

    func toggle(_ track: Track, _ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        popover.isShown ? close() : show(track, relativeToView, preferredEdge)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        let hasImage: Bool = displayedTrack?.art?.image != nil
        
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
        
        if let track = displayedTrack {
            coverArtViewController.exportArt(forTrack: track, type: type, fileExtension: fileExtension)
        }
    }
    
    @IBAction func exportJSONAction(_ sender: AnyObject) {
        
        guard let track = displayedTrack else {return}
        
        let dialog = DialogsAndAlerts.exportMetadataDialog(fileName: track.displayName + "-metadata", fileExtension: "json")
        guard dialog.runModal() == .OK, let outFile = dialog.url else {return}
        
        var appDict = [NSString: AnyObject]()
        appDict["version"] = NSApp.appVersion as AnyObject
        appDict["exportDate"] = dateFormatter.string(from: Date()) as AnyObject

        let dict: [NSString: AnyObject?] = ["appInfo": appDict as NSDictionary,
                                           "metadata": metadataViewController.jsonObject,
                                           "coverArt": coverArtViewController.jsonObject,
                                           "lyrics": lyricsViewController.jsonObject,
                                           "audio": audioViewController.jsonObject,
                                           "fileSystem": fileSystemViewController.jsonObject]
        
        do {
            try JSONSerialization.writeObject(dict as NSDictionary, toFile: outFile)
            
        } catch {
            
            if let error = error as? JSONWriteError {
                _ = DialogsAndAlerts.genericErrorAlert("JSON file not written", error.message, error.description).showModal()
            }
        }
    }
    
    @IBAction func exportHTMLWithArtAction(_ sender: AnyObject) {
        doExportHTML(withArt: true)
    }
    
    @IBAction func exportHTMLAction(_ sender: AnyObject) {
        doExportHTML(withArt: false)
    }
        
    private func doExportHTML(withArt includeArt: Bool) {
        
        guard let track = displayedTrack else {return}
        
        let dialog = DialogsAndAlerts.exportMetadataDialog(fileName: track.displayName + "-metadata", fileExtension: "html")
        guard dialog.runModal() == .OK, let outFile = dialog.url else {return}
            
        do {
            let writer = HTMLWriter(outputFile: outFile)
            
            writer.addTitle(track.displayName)
            writer.addHeading(track.displayName, 2, false)
            
            let text = String(format: "Metadata exported by Aural Player v%@ on: %@", NSApp.appVersion, dateFormatter.string(from: Date()))
            let exportDate = HTMLText(text: text, underlined: true, bold: false, italic: false, width: nil)
            writer.addParagraph(exportDate)
            
            if includeArt {
                coverArtViewController.writeHTML(forTrack: track, to: writer)
            }
            
            ([metadataViewController, lyricsViewController, audioViewController, fileSystemViewController] as? [TrackInfoViewProtocol])?.forEach {
                $0.writeHTML(forTrack: track, to: writer)
            }
            
            try writer.writeToFile()
            
        } catch {
            
            if let error = error as? HTMLWriteError {
                _ = DialogsAndAlerts.genericErrorAlert("HTML file not written", error.message, error.description).showModal()
            }
        }
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
}

protocol TrackInfoViewProtocol {
    
    func refresh(forTrack track: Track)
    
    var view: NSView {get}
    
    var jsonObject: AnyObject? {get}
    
    func writeHTML(forTrack track: Track, to writer: HTMLWriter)
}
