/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - color.
*/

import Cocoa

class TrackInfoCellView: NSTableCellView {
    
    // When the background changes (as a result of selection/deselection) switch appropriate colours
    override var backgroundStyle: NSBackgroundStyle {
        
        didSet {
            
            let field = self.textField
            
            if (field != nil) {
                field!.textColor = UIConstants.colorScheme.playlistTextColor
            }
        }
    }
}
