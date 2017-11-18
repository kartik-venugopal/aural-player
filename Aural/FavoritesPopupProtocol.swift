import Cocoa

// Contract for displaying the Favorites notification popup
protocol FavoritesPopupProtocol {
    
    // Shows a message that a track has been added to Favorites
    func showAddedMessage(_ relativeToView: NSView, _ preferredEdge: NSRectEdge)
    
    // Shows a message that a track has been removed from Favorites
    func showRemovedMessage(_ relativeToView: NSView, _ preferredEdge: NSRectEdge)
}
