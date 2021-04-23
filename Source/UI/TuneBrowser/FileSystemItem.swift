import Foundation

class FileSystemItem {
    
    // TODO: This needs to be a ConcurrentMap.
    // To prevent redundant items being created for the same URL.
    private static var itemCache: [URL: FileSystemItem] = [:]
    
    static func create(forURL url: URL, loadChildren: Bool = false) -> FileSystemItem {
        
        if let item = itemCache[url] {
            return item
        }
        
        let item = FileSystemItem(url: url, loadChildren: loadChildren)
        itemCache[url] = item
        
        return item
    }
    
    let url: URL
    let path: String
    let name: String
    let fileExtension: String
    
    lazy var children: [FileSystemItem] = loadChildren(url)
    var metadataLoadedForChildren: Bool = false
    
    var isDirectory: Bool {url.hasDirectoryPath}
    
    var isPlaylist: Bool {AppConstants.SupportedTypes.playlistExtensions.contains(fileExtension)}
    
    var isTrack: Bool {AppConstants.SupportedTypes.allAudioExtensions.contains(fileExtension)}
    
    var metadata: FileMetadata?
    
    private init(url: URL, loadChildren: Bool = false) {
        
        self.url = url
        self.fileExtension = url.lowerCasedExtension
        self.path = url.path
        self.name = url.lastPathComponent
        
        if loadChildren {
            _ = self.children
        }
    }
    
    private func loadChildren(_ dir: URL) -> [FileSystemItem] {
        
        guard dir.hasDirectoryPath, let dirContents = FileSystemUtils.getContentsOfDirectory(dir) else {return []}
        
        return dirContents.map{FileSystemItem.create(forURL: $0)}
            .filter {$0.isTrack || $0.isDirectory || $0.isPlaylist}
            .sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
    }
}
