import Foundation

/*
    Exposes high-level operations performed on the popover view
 */
protocol PopoverViewDelegateProtocol {
    
    // Show the popover view
    func show()
    
    // Checks if the popover view is shown
    func isShown() -> Bool
    
    // Close the popover view
    func close()
    
    // Toggles the popover view
    func toggle()
    
    // Refreshes the track info in the popover view
    func refresh()
}
