import Foundation

class FileSystemItem {
    
    let url: URL
    let path: String
    let name: String
    let fileExtension: String
    
    lazy var children: [FileSystemItem] = loadChildren(url)
    
    var isDirectory: Bool {url.hasDirectoryPath}
    
    var isPlaylist: Bool {AppConstants.SupportedTypes.playlistExtensions.contains(fileExtension)}
    
    var isTrack: Bool {AppConstants.SupportedTypes.allAudioExtensions.contains(fileExtension)}
    
    init(url: URL, loadChildren: Bool = false) {
        
        self.url = url
        self.fileExtension = url.pathExtension.lowercased()
        self.path = url.path
        self.name = url.lastPathComponent
        
        if loadChildren {
            _ = self.children
        }
    }
    
    private func loadChildren(_ dir: URL) -> [FileSystemItem] {
        
        guard dir.hasDirectoryPath, let dirContents = FileSystemUtils.getContentsOfDirectory(dir) else {return []}
        
        return dirContents.map{FileSystemItem(url: $0)}
            .filter {$0.isTrack || $0.isDirectory || $0.isPlaylist}
            .sorted(by: {$0.name < $1.name})
    }
}
