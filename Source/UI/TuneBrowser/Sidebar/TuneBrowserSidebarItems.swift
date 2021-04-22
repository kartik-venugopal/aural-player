import Foundation

enum SidebarCategory: String, CaseIterable, CustomStringConvertible {
    
    case volumes = "Volumes"
    case folders = "Folders"
    
    var description: String {rawValue}
}

struct SidebarItem {
    
    let displayName: String
}
