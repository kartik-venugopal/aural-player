import Cocoa

protocol WindowManagerProtocol: NSWindowDelegate {
    
    var isShowingEffects: Bool {get}
    
    var isShowingPlaylist: Bool {get}
    
    var isShowingChaptersList: Bool {get}
    
    var isShowingModalComponent: Bool {get}
    
    var mainWindow: NSWindow {get}
    
    var playlistWindow: NSWindow {get}
    
    var effectsWindow: NSWindow {get}
    
    var chaptersListWindow: NSWindow {get}
    
    func registerModalComponent(_ component: ModalComponentProtocol)
    
    func initializeWindows()
    
    func layout(_ layout: WindowLayout)
    
    func layout(_ name: String)
    
    var mainWindowFrame: NSRect {get}
    
    var effectsWindowFrame: NSRect {get}
    
    var playlistWindowFrame: NSRect {get}
    
    func addChildWindow(_ window: NSWindow)
    
    func showChaptersList()
    
    func hideChaptersList()
}
