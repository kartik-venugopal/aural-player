import Cocoa

protocol LayoutManagerProtocol {
    
    func isShowingEffects() -> Bool
    
    func isShowingPlaylist() -> Bool
    
    func layout(_ layout: WindowLayout)
    
    func layout(_ name: String)
}
