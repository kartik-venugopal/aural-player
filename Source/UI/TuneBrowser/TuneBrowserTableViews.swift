import Cocoa

class TuneBrowserOutlineView: NSOutlineView {
    
    override func menu(for event: NSEvent) -> NSMenu? {
        
        let clickedRow: Int = self.row(at: self.convert(event.locationInWindow, from: nil))

        // If the click occurred outside of any of the playlist rows (i.e. empty space), don't show the menu
        if clickedRow == -1 {return nil}
        
        if !self.isRowSelected(clickedRow) {
            self.selectRow(clickedRow)
        }
        
        return self.menu
    }
}

class TuneBrowserItemNameCell: NSTableCellView {
 
    @IBInspectable @IBOutlet weak var icon: NSImageView!
    @IBInspectable @IBOutlet weak var lblName: NSTextField!
    
    func initializeForFile(_ file: FileSystemItem) {
        
        lblName.stringValue = file.url.lastPathComponent
        
        if file.isDirectory {
            icon.image = Images.imgGroup
            
        } else if file.isTrack {
            icon.image = Images.imgPlayingArt
            
        } else if file.isPlaylist {
            icon.image = Images.imgPlaylistPreview
        }
    }
}

class TuneBrowserItemTypeCell: NSTableCellView {
 
    func initializeForFile(_ file: FileSystemItem) {
        
        if file.isDirectory {
            textField?.stringValue = "Folder"
            
        } else if file.isTrack {
            textField?.stringValue = "Track"
            
        } else if file.isPlaylist {
            textField?.stringValue = "Playlist"
        }
    }
}
