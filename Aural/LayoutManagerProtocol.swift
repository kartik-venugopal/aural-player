import Cocoa

protocol LayoutManagerProtocol {
    
    var isShowingEffects: Bool {get}
    
    var isShowingPlaylist: Bool {get}
    
    var isShowingChaptersList: Bool {get}
    
    var mainWindow: NSWindow {get}
    
    var chaptersListWindow: NSWindow {get}
    
    func layout(_ layout: WindowLayout)
    
    func layout(_ name: String)
    
    func getMainWindowFrame() -> NSRect
    
    func getEffectsWindowFrame() -> NSRect
    
    func getPlaylistWindowFrame() -> NSRect
    
    func addChildWindow(_ window: NSWindow)
    
    func showChaptersList()
    
    func hideChaptersList()
}
