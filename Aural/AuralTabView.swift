import Cocoa

class AuralTabView: NSTabView {
    
    var items: [AuralTabViewItem] {
        return self.tabViewItems as! [AuralTabViewItem]
    }
    
    override func awakeFromNib() {
        self.delegate = AuralTabViewDelegate(self)
//        items.forEach({
//            $0.tabButton.action = #selector(selectTab($0))
//        })
    }
}

class AuralTabViewItem: NSTabViewItem {
 
    @IBOutlet weak var tabButton: NSButton!
    
    private var auralTabView: AuralTabView {
        print("TV:", self.tabView)
        return self.tabView as! AuralTabView
    }
    
    override func awakeFromNib() {
        
        tabButton.action = #selector(selectTab(_:))
        tabButton.target = self
    }
    
    func selectTab(_ sender: Any) {
        
        print("Tag:", tabButton.tag)

        auralTabView.selectTabViewItem(at: tabButton.tag)
        
        self.auralTabView.items.forEach({
            $0.tabButton.state = $0 === self ? 1 : 0
            $0.tabButton.setNeedsDisplay()
        })
    }
}

class AuralTabViewDelegate: NSObject, NSTabViewDelegate {
    
    private var tabView: AuralTabView
    
    init(_ tabView: AuralTabView) {
        self.tabView = tabView
    }
 
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        
        print("Did select")
        
        self.tabView.items.forEach({
            $0.tabButton.state = $0 === tabViewItem ? 1 : 0
        })
    }
}
