/*
    Custom view controller for the NSTableView that displays the playlist. Creates table cells with the necessary track information.
*/

import Cocoa
import AVFoundation

class PlaylistViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    var playlist: Playlist = Playlist.instance()
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return playlist.size()
    }
    
    // Each playlist view row contains one track, with name and duration
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        
        let trackName = playlist.getTrackAt(row)?.shortDisplayName
        let duration = Utils.formatDuration((playlist.getTrackAt(row)?.duration)!)
        
        let view = PlaylistSongView()
        view.trackName = trackName
        view.duration = duration
        view.tableView = tableView
        
        return view
    }
    
    // Drag n drop
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        
        // No validation required here
        return NSDragOperation.Copy;
    }
    
    // Drag n drop
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        let objects = info.draggingPasteboard().readObjectsForClasses([NSURL.classForArchiver()!], options: nil)
        
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.addTracks(objects! as! [NSURL])
        
        return true
    }
}