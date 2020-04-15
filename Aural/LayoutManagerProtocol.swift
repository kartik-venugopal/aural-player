import Cocoa

protocol LayoutManagerProtocol {
    
    func isShowingEffects() -> Bool
    
    func isShowingPlaylist() -> Bool
    
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
