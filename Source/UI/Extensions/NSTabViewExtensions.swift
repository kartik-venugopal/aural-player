import Cocoa

extension NSTabView {
    
    var selectedIndex: Int {
        return indexOfTabViewItem(selectedTabViewItem!)
    }
    
    func previousTab(_ sender: Any) {
        
        let selIndex = selectedIndex
        
        if selIndex >= 1 {
            selectPreviousTabViewItem(sender)
        } else {
            selectLastTabViewItem(sender)
        }
    }
    
    func nextTab(_ sender: Any) {
        
        let selIndex = selectedIndex
        
        if selIndex < tabViewItems.count - 1 {
            selectNextTabViewItem(sender)
        } else {
            selectFirstTabViewItem(sender)
        }
    }
}
