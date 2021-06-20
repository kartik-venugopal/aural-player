import Foundation

class FileSystemInfo {
    
    // The filesystem file that contains the audio track represented by this object
    let file: URL
    let fileName: String
    
    init(_ file: URL) {
        
        self.file = file
        self.fileName = file.deletingPathExtension().lastPathComponent
    }
    
    // Filesystem size
    var size: Size?
    var lastModified: Date?
    var creationDate: Date?
    var kindOfFile: String?
    var lastOpened: Date?
}
