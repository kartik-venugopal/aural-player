import Foundation

enum TuneBrowserSidebarCategory: String, CaseIterable, CustomStringConvertible {
    
    case volumes = "Volumes"
    case folders = "Folders"
    
    var description: String {rawValue}
}

class TuneBrowserSidebarItem: Equatable {
    
    var displayName: String
    var url: URL
    
    init(displayName: String, url: URL) {
        
        self.displayName = displayName
        self.url = url
    }
    
    static func == (lhs: TuneBrowserSidebarItem, rhs: TuneBrowserSidebarItem) -> Bool {
        lhs.url == rhs.url
    }
}
