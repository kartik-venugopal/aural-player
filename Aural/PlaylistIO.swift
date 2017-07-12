
import Foundation

/*
    Performs I/O of playlists in the JSON format
*/
class PlaylistIO {
    
    // Save current playlist to an output file
    static func savePlaylist(file: NSURL) {
        
        let currentPlaylist: Playlist = Playlist.instance()
        let savedPlaylist: SavedPlaylist = SavedPlaylist(outputFile: file, sourcePlaylist: currentPlaylist)
        
        let outputStream = NSOutputStream(URL: file, append: false)
        outputStream?.open()
        
        NSJSONSerialization.writeJSONObject(savedPlaylist.forWritingAsJSON(), toStream: outputStream!, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        outputStream?.close()
    }
    
    // Load playlist from file into current playlist
    static func loadPlaylist(file: NSURL) {
        
        let inputStream = NSInputStream(URL: file)
        inputStream?.open()
        
        do {
            let data = try NSJSONSerialization.JSONObjectWithStream(inputStream!, options: NSJSONReadingOptions())
            
            inputStream?.close()
            
            let playlist: SavedPlaylist = SavedPlaylist(inputFile: file, jsonObject: data as! NSArray)
            
            let currentPlaylist: Playlist = Playlist.instance()
            currentPlaylist.addPlaylist(playlist)
            
        } catch let error as NSError {
            NSLog("Error reading playlist file '%@': %@", file.path!, error.description)
        }
    }
}