import Foundation

class TuneBrowserPersistentState: PersistentStateProtocol {
    
    var sidebar: TuneBrowserSidebarPersistentState = TuneBrowserSidebarPersistentState()
    
    static func deserialize(_ map: NSDictionary) -> TuneBrowserPersistentState {
        
        let state = TuneBrowserPersistentState()
        
        if let sidebarDict = map["sidebar"] as? NSDictionary {
            state.sidebar = TuneBrowserSidebarPersistentState.deserialize(sidebarDict)
        }
        
        return state
    }
}

class TuneBrowserSidebarPersistentState: PersistentStateProtocol {
    
    var userFolders: [TuneBrowserSidebarItemPersistentState] = []
    
    static func deserialize(_ map: NSDictionary) -> TuneBrowserSidebarPersistentState {
        
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
    
    static func deserialize(_ map: NSDictionary) -> TuneBrowserSidebarItemPersistentState {
        
        let state = TuneBrowserSidebarItemPersistentState()
        
        if let urlPath = map["url"] as? String {
            state.url = URL(fileURLWithPath: urlPath)
        }
        
        return state
    }
}

extension TuneBrowserState {
    
    static func initialize(fromPersistentState state: TuneBrowserPersistentState) {
        
        for item in state.sidebar.userFolders {
            Self.addUserFolder(forURL: item.url)
        }
    }
    
    static var persistentState: TuneBrowserPersistentState {
        
        let state = TuneBrowserPersistentState()
        
        state.sidebar = TuneBrowserSidebarPersistentState()
        state.sidebar.userFolders = sidebarUserFolders.map {TuneBrowserSidebarItemPersistentState($0.url)}
        
        return state
    }
}
