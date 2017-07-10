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
        let duration = Utils.formatDuration(Int(round((playlist.getTrackAt(row)?.duration)!)))
        
        let view = PlaylistSongView()
        view.trackName = trackName
        view.duration = duration
        view.tableView = tableView
        
        return view
    }
}