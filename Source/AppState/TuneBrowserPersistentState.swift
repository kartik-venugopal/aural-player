import Foundation

class TuneBrowserPersistentState: PersistentStateProtocol {
    
    var windowSize: NSSize = AppDefaults.tuneBrowserWindowSize
    var displayedColumns: [DisplayedTableColumn] = []
    var sidebar: TuneBrowserSidebarPersistentState = TuneBrowserSidebarPersistentState()
    
    required init?(_ map: NSDictionary) -> TuneBrowserPersistentState {
        
        let state = TuneBrowserPersistentState()
        
        if let windowSizeDict = map["windowSize"] as? NSDictionary, let windowSize = mapNSSize(windowSizeDict) {
            state.windowSize = windowSize
        }
        
        if let displayedColumnsArr = map["displayedColumns"] as? [NSDictionary] {
            state.displayedColumns = displayedColumnsArr.map {DisplayedTableColumn.deserialize($0)}
        }
        
        if let sidebarDict = map["sidebar"] as? NSDictionary {
            state.sidebar = TuneBrowserSidebarPersistentState.deserialize(sidebarDict)
        }
        
        return state
    }
}

class TuneBrowserSidebarPersistentState: PersistentStateProtocol {
    
    var userFolders: [TuneBrowserSidebarItemPersistentState] = []
    
    required init?(_ map: NSDictionary) -> TuneBrowserSidebarPersistentState {
        
        let state = TuneBrowserSidebarPersistentState()
        
        if let userFoldersArr = map["userFolders"] as? [NSDictionary] {
            state.userFolders = userFoldersArr.map {TuneBrowserSidebarItemPersistentState.deserialize($0)}
        }
        
        return state
    }
}

class TuneBrowserSidebarItemPersistentState: PersistentStateProtocol {
    
    var url: URL = URL(fileURLWithPath: "/")
    
    init() {}
    
    init(_ url: URL) {
        self.url = url
    }
    
    required init?(_ map: NSDictionary) -> TuneBrowserSidebarItemPersistentState {
        
        let state = TuneBrowserSidebarItemPersistentState()
        
        if let urlPath = map["url"] as? String {
            state.url = URL(fileURLWithPath: urlPath)
        }
        
        return state
    }
}

extension TuneBrowserState {
    
    static func initialize(fromPersistentState state: TuneBrowserPersistentState) {
        
        Self.windowSize = state.windowSize
        Self.displayedColumns = state.displayedColumns
        
        for item in state.sidebar.userFolders {
            Self.addUserFolder(forURL: item.url)
        }
    }
    
    static var persistentState: TuneBrowserPersistentState {
        
        let state = TuneBrowserPersistentState()
        
        state.windowSize = windowSize
        state.displayedColumns = displayedColumns
        state.sidebar = TuneBrowserSidebarPersistentState()
        state.sidebar.userFolders = sidebarUserFolders.map {TuneBrowserSidebarItemPersistentState($0.url)}
        
        return state
    }
}

extension DisplayedTableColumn: PersistentStateProtocol {
    
    required init?(_ map: NSDictionary) -> DisplayedTableColumn {
        
        let id: String = map["id"] as? String ?? ""
        var width: CGFloat = 50
        
        if let widthNum = map["width"] as? NSNumber {
            width = CGFloat(widthNum.floatValue)
        }
        
        return DisplayedTableColumn(id: id, width: width)
    }
}
