import Cocoa

extension NSView {
    
    var width: CGFloat {
        return self.frame.width
    }
    
    var height: CGFloat {
        return self.frame.height
    }
}

extension NSButton {
    
    @objc func off() {
        self.state = UIConstants.offState
    }
    
    @objc func on() {
        self.state = UIConstants.onState
    }
    
    @objc func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    @objc var isOn: Bool {
        return self.state == UIConstants.onState
    }
    
    @objc var isOff: Bool {
        return self.state == UIConstants.offState
    }
    
    @objc func toggle() {
        isOn ? off() : on()
    }
    
    @objc func displaceLeft(_ amount: CGFloat) {
        self.frame.origin.x -= amount
    }

    @objc func displaceRight(_ amount: CGFloat) {
        self.frame.origin.x += amount
    }
}

extension NSButtonCell {

    @objc func off() {
        self.state = UIConstants.offState
    }

    @objc func on() {
        self.state = UIConstants.onState
    }

    @objc func onIf(_ condition: Bool) {
        condition ? on() : off()
    }

    @objc var isOn: Bool {
        return self.state == UIConstants.onState
    }

    @objc var isOff: Bool {
        return self.state == UIConstants.offState
    }

    @objc func toggle() {
        isOn ? off() : on()
    }
}

extension NSMenuItem {
    
    @objc func off() {
        self.state = UIConstants.offState
    }
    
    @objc func on() {
        self.state = UIConstants.onState
    }
    
    @objc func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    @objc var isOn: Bool {
        return self.state == UIConstants.onState
    }
    
    @objc var isOff: Bool {
        return self.state == UIConstants.offState
    }
    
    @objc func toggle() {
        isOn ? off() : on()
    }
    
    var isShown: Bool {
        return !isHidden
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hideIf_elseShow(_ condition: Bool) {
        self.isHidden = condition
    }
    
    func showIf_elseHide(_ condition: Bool) {
        self.isHidden = !condition
    }
    
    var isDisabled: Bool {
        return !isEnabled
    }
    
    func enable() {
        self.enableIf(true)
    }
    
    func disable() {
        self.enableIf(false)
    }
    
    func enableIf(_ condition: Bool) {
        self.isEnabled = condition
    }
    
    func disableIf(_ condition: Bool) {
        self.isEnabled = !condition
    }
}

extension NSView {
    
    var isShown: Bool {
        return !isHidden
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hideIf_elseShow(_ condition: Bool) {
        self.isHidden = condition
    }
    
    func showIf_elseHide(_ condition: Bool) {
        self.isHidden = !condition
    }
    
    func hideIf(_ condition: Bool) {
        if condition {hide()}
    }

    func showIf(_ condition: Bool) {
        if condition {show()}
    }
    
    var isVisible: Bool {
        
        var curView: NSView? = self
        while curView != nil {
            
            if curView!.isHidden {return false}
            curView = curView!.superview
        }
        
        return true
    }
    
    func coLocate(_ other: NSView) {
        self.frame.origin = other.frame.origin
    }
    
    func redraw() {
        self.setNeedsDisplay(self.bounds)
    }
    
    func addSubviews(_ subViews: NSView...) {
        subViews.forEach({self.addSubview($0)})
    }
    
    func positionAtZeroPoint() {
        self.setFrameOrigin(NSPoint.zero)
    }
}

extension NSControl {
    
    var isDisabled: Bool {
        return !isEnabled
    }
    
    func enable() {
        self.enableIf(true)
    }
    
    func disable() {
        self.enableIf(false)
    }
    
    func enableIf(_ condition: Bool) {
        self.isEnabled = condition
    }
    
    func disableIf(_ condition: Bool) {
        self.isEnabled = !condition
    }
}

extension NSPopUpButton {
    
    var separatorCount: Int {
        
        var count: Int = 0
        
        for item in self.menu!.items {
            if item.isSeparatorItem {count += 1}
        }
        
        return count
    }
}

class NoTitleBarWindow: NSWindow {
    
    override func awakeFromNib() {
        self.titlebarAppearsTransparent = true
    }
    
    override var canBecomeKey: Bool {
        get {return true}
    }
}

class NoTitleBarPanel: NSPanel {
    
    override func awakeFromNib() {
        self.titlebarAppearsTransparent = true
    }
}

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

extension String {
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + (self.count > 1 ? self.substring(range: 1..<self.count) : "")
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension NSWindow {
    
    var origin: NSPoint {
        return self.frame.origin
    }
    
    var width: CGFloat {
        return self.frame.width
    }
    
    var height: CGFloat {
        return self.frame.height
    }
    
    // X co-ordinate of location
    var x: CGFloat {
        return self.frame.origin.x
    }
    
    // Y co-ordinate of location
    var y: CGFloat {
        return self.frame.origin.y
    }
    
    var maxX: CGFloat {
        return self.frame.maxX
    }
    
    var maxY: CGFloat {
        return self.frame.maxY
    }
    
    // Screen (visible) width - this window's width
    var remainingWidth: CGFloat {
        return (NSScreen.main!.visibleFrame.width - self.width)
    }
    
    // Screen (visible) height - this window's height
    var remainingHeight: CGFloat {
        return (NSScreen.main!.visibleFrame.height - self.height)
    }
}

public extension NSBezierPath {

    var CGPath: CGPath {

        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)

            switch type {
            case .moveTo: path.move(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .lineTo: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .curveTo: path.addCurve(      to: CGPoint(x: points[2].x, y: points[2].y),
                                               control1: CGPoint(x: points[0].x, y: points[0].y),
                                               control2: CGPoint(x: points[1].x, y: points[1].y) )
            case .closePath: path.closeSubpath()
            }
        }
        return path
    }
}

extension NSColor {
    
    var isOpaque: Bool {
        return self.alphaComponent == 1
    }
}

extension NSImage {
    
    func applyingTint(_ color: NSColor) -> NSImage {
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        color.set()
        
        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)
        
        image.unlockFocus()
        
        return image
    }
}

extension NSColor {
    
//    func brightened(_ amount : CGFloat = 0.25) -> NSColor {
//        return hueColorWithBrightnessAmount(min(1, 1 + amount))
//    }
    
    func darkened(_ amount : CGFloat = 0.25) -> NSColor {
        
        switch self.colorSpace.colorSpaceModel {
            
        case .gray:
            
            return NSColor(calibratedWhite: self.whiteComponent * 0.3, alpha: self.alphaComponent)
            
        case .rgb:
            
            return NSColor(calibratedRed: self.redComponent * 0.3, green: self.greenComponent * 0.3, blue: self.blueComponent * 0.3, alpha: self.alphaComponent)
            
        case .cmyk:
            
            return NSColor(deviceCyan: self.cyanComponent * 0.3, magenta: self.magentaComponent * 0.3, yellow: self.yellowComponent * 0.3, black: self.blackComponent, alpha: self.alphaComponent)
            
        default: return self
            
        }
    }
    
    func clonedWithTransparency(_ alpha: CGFloat) -> NSColor {
        
        switch self.colorSpace.colorSpaceModel {
            
        case .gray:
            
            return NSColor(calibratedWhite: self.whiteComponent, alpha: alpha)
            
        case .rgb:
            
            return NSColor(calibratedRed: self.redComponent, green: self.greenComponent, blue: self.blueComponent, alpha: alpha)
            
        case .cmyk:
            
            return NSColor(deviceCyan: self.cyanComponent, magenta: self.magentaComponent, yellow: self.yellowComponent, black: self.blackComponent, alpha: alpha)
            
        default: return self
            
        }
    }
}

extension NSImageView {
    
    var cornerRadius: CGFloat {
        
        get {
            return self.layer?.cornerRadius ?? 0
        }
        
        set(newValue) {
            
            if !self.wantsLayer {
                
                self.wantsLayer = true
                self.layer?.masksToBounds = true;
            }
            
            self.layer?.cornerRadius = newValue;
        }
    }
}
