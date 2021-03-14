import Cocoa

/*
    A "smart" button that determines and sets its own tool tip dynamically based on logic (closure) that can be set externally. Useful when tool tips need to change based on app state, e.g. to display the previous/next track name in a tool tip for the previous/next track control buttons.
 */
@IBDesignable
class TrackPeekingButton: ColorSensitiveImageButton {
    
    @IBInspectable var defaultTooltip: String!
    
    // This function will be invoked, on the fly (when the user hovers over the button), to determine the button's tool tip
    var toolTipFunction: (() -> String?)?
    
    func updateTooltip() {
        self.toolTip = toolTipFunction?() ?? defaultTooltip
    }
}
