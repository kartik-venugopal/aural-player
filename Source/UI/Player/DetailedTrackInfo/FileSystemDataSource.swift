import Cocoa

/*
 Data source and delegate for the Detailed Track Info popover view
 */
class FileSystemDataSource: TrackInfoDataSource {
    
    override var tableId: TrackInfoTab {return .fileSystem}
    
    private let dateFormatter: DateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        
        // Store a reference to trackInfoView that is easily accessible
        dateFormatter.dateFormat = "MMMM dd, yyyy  'at'  hh:mm:ss a"
    }
    
    override func infoForTrack(_ track: Track) -> [(key: String, value: String)] {
        
        var trackInfo: [(key: String, value: String)] = []
        
        trackInfo.append((key: "Location", value: track.file.path))
        
//        if let kindOfFile = track.fileSystemInfo.kindOfFile {
//            trackInfo.append((key: "Kind", value: kindOfFile))
//        }
//        
//        trackInfo.append((key: "Size", value: track.fileSystemInfo.size!.toString()))
//        trackInfo.append((key: "Created", value: dateFormatter.string(from: track.fileSystemInfo.creationDate!)))
//        trackInfo.append((key: "Last Modified", value: dateFormatter.string(from: track.fileSystemInfo.lastModified!)))
//        
//        if let openDate = track.fileSystemInfo.lastOpened {
//            trackInfo.append((key: "Last Opened", value: dateFormatter.string(from: openDate)))
//        }
        
        return trackInfo
    }
}
