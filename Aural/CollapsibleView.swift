
import Cocoa

/*
    Helper class that groups NSView objects together as a unit for hiding/showing
*/
class CollapsibleView {
    
    private let views: [NSView]
    var hidden: Bool {
        return views[0].hidden
    }
    
    // Difference between minY and maxY of all views
    let height: CGFloat
    
    // Minimum and maximum Y co-ordinate of all views
    let minY: CGFloat
    let maxY: CGFloat
    
    init(views: [NSView]) {
        self.views = views
        
        var minY = CGFloat.max
        var maxY = CGFloat.min
        
        // Computer minY, maxY, and height
        for view in views {
            
            if (view.frame.minY < minY) {
                minY = view.frame.minY
            }
            
            if (view.frame.maxY > maxY) {
                maxY = view.frame.maxY
            }
        }
        
        self.minY = minY
        self.maxY = maxY
        self.height = maxY - minY
    }
    
    // Hide all constituent views
    func hide() {
        for view in views {
            view.hidden = true
        }
    }
    
    // Show all constituent views
    func show() {
        for view in views {
            view.hidden = false
        }
    }
    
    // Toggles the hidden state of the constituent views. Returns whether or not the views are visble after the toggle
    func toggle() -> Bool {
        
        let hidden = views[0].hidden
        
        for view in views {
            view.hidden = !hidden
        }
        
        return hidden
    }
}