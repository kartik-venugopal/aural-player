import Foundation

class TuneBrowserState {
    
    static var windowSize: NSSize = AppDefaults.tuneBrowserWindowSize
    static var displayedColumns: [DisplayedTableColumn] = []
    
    private static var sidebarUserFoldersByURL: [URL: TuneBrowserSidebarItem] = [:]
    
    private(set) static var sidebarUserFolders: [TuneBrowserSidebarItem] = []
    
    static func userFolder(forURL url: URL) -> TuneBrowserSidebarItem? {
        sidebarUserFoldersByURL[url]
    }
    
    static func addUserFolder(forURL url: URL) {
        
        if sidebarUserFoldersByURL[url] == nil {
            
            let newItem = TuneBrowserSidebarItem(url: url)
            sidebarUserFolders.append(newItem)
            sidebarUserFoldersByURL[url] = newItem
        }
    }
    
    static func removeUserFolder(item: TuneBrowserSidebarItem) -> Int? {
        
        sidebarUserFoldersByURL.removeValue(forKey: item.url)
        return sidebarUserFolders.removeItem(item)
    }
}

class DisplayedTableColumn: PersistentStateProtocol {
    
    let id: String
    let width: CGFloat
    
    init(id: String, width: CGFloat) {
        
        self.id = id
        self.width = width
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let id = map.nonEmptyStringValue(forKey: "id") else {return nil}
        self.id = id
        
        self.width = map.cgFloatValue(forKey: "width") ?? 50
    }
}
