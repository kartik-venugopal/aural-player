import Foundation

class TuneBrowserPersistentState: PersistentStateProtocol {
    
    var windowSize: NSSize?
    var displayedColumns: [DisplayedTableColumn]?
    var sidebar: TuneBrowserSidebarPersistentState?
    
    init() {}
    
    required init?(_ map: NSDictionary) {
        
        self.windowSize = map.nsSizeValue(forKey: "windowSize")
        self.displayedColumns = map.arrayValue(forKey: "displayedColumns", ofType: DisplayedTableColumn.self)
        self.sidebar = map.objectValue(forKey: "sidebar", ofType: TuneBrowserSidebarPersistentState.self)
    }
}

class TuneBrowserSidebarPersistentState: PersistentStateProtocol {
    
    let userFolders: [TuneBrowserSidebarItemPersistentState]?
    
    init(userFolders: [TuneBrowserSidebarItemPersistentState]?) {
        self.userFolders = userFolders
    }
    
    required init?(_ map: NSDictionary) {
        self.userFolders = map.arrayValue(forKey: "userFolders", ofType: TuneBrowserSidebarItemPersistentState.self)
    }
}

class TuneBrowserSidebarItemPersistentState: PersistentStateProtocol {
    
    var url: URL?
    
    init(url: URL) {
        self.url = url
    }
    
    required init?(_ map: NSDictionary) {
        self.url = map.urlValue(forKey: "url")
    }
}

extension TuneBrowserState {
    
    static func initialize(fromPersistentState state: TuneBrowserPersistentState?) {
        
        Self.windowSize = state?.windowSize ?? NSSize(width: 700, height: 500)
        Self.displayedColumns = state?.displayedColumns ?? []
        
        for url in (state?.sidebar?.userFolders ?? []).compactMap({$0.url}) {
            Self.addUserFolder(forURL: url)
        }
    }
    
    static var persistentState: TuneBrowserPersistentState {
        
        let state = TuneBrowserPersistentState()
        
        state.windowSize = windowSize
        state.displayedColumns = displayedColumns
        state.sidebar = TuneBrowserSidebarPersistentState(userFolders: sidebarUserFolders.map {TuneBrowserSidebarItemPersistentState(url: $0.url)})
        
        return state
    }
}
