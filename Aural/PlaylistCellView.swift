/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and color.
*/

import Cocoa

class PlaylistCellView: NSTableCellView {
    
    // When the background changes (as a result of selection/deselection) switch appropriate colours
    override var backgroundStyle: NSBackgroundStyle {
        
        didSet {
            
            let field = self.textField
            
            if (field != nil) {
                
                if (backgroundStyle == NSBackgroundStyle.dark) {
                    // Selected
                    field!.font = UIConstants.playlistBoldFont
                    field!.textColor = Colors.playlistSelectedTextColor
                } else {
                    // Not selected
                    field!.font = UIConstants.playlistBoldFont
                    field!.textColor = Colors.playlistTextColor
                }
            }
        }
    }
}
