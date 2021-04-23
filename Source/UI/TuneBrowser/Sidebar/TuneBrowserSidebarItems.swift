import Foundation

enum TuneBrowserSidebarCategory: String, CaseIterable, CustomStringConvertible {
    
    case volumes = "Volumes"
    case folders = "Folders"
    
    var description: String {rawValue}
}

class TuneBrowserSidebarItem {
    
    var displayName: String
    var url: URL
    
    init(displayName: String, url: URL) {
        
        self.displayName = displayName
        self.url = url
    }
}
