import Cocoa

extension NSView {
    
    var width: CGFloat {
        return self.frame.width
    }
    
    var height: CGFloat {
        return self.frame.height
    }
    
    var isShown: Bool {
        return !isHidden
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func hideIfShown() {
        
        if !isHidden {
            self.isHidden = true
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    // NOTE - Should not simply set the flag here because show() and hide() may be overriden and need to be called somewhere in a subview.
    func hideIf(_ condition: Bool) {
        condition ? hide() : show()
    }
    
    // NOTE - Should not simply set the flag here because show() and hide() may be overriden and need to be called somewhere in a subview.
    func showIf(_ condition: Bool) {
        condition ? show() : hide()
    }
    
    var isVisible: Bool {
        
        var curView: NSView? = self
        while curView != nil {
            
            if curView!.isHidden {return false}
            curView = curView!.superview
        }
        
        return true
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
    
    func bringToFront() {
        
        let superView = self.superview
        self.removeFromSuperview()
        superView?.addSubview(self, positioned: .above, relativeTo: nil)
    }
    
    func removeAllTrackingAreas() {
        
        for area in self.trackingAreas {
            self.removeTrackingArea(area)
        }
    }
    
    func anchorToSuperview() {
        
        if let superView = self.superview {
            anchorToView(superView)
        }
    }
    
    func anchorToView(_ otherView: NSView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        self.leadingAnchor.constraint(equalTo: otherView.leadingAnchor),
        self.trailingAnchor.constraint(equalTo: otherView.trailingAnchor),
        self.topAnchor.constraint(equalTo: otherView.topAnchor),
        self.bottomAnchor.constraint(equalTo: otherView.bottomAnchor)])
    }
    
    // MARK - Static functions
    
    static func showViews(_ views: NSView...) {
        views.forEach({$0.show()})
    }

    static func hideViews(_ views: NSView...) {
        views.forEach({$0.hide()})
    }
}

extension NSBox {
    
    func makeTransparent() {
        self.isTransparent = true
    }
    
    func makeOpaque() {
        self.isTransparent = false
    }
    
    static func makeTransparent(_ boxes: NSBox...) {
        boxes.forEach({$0.isTransparent = true})
    }

    fileprivate func makeOpaque(_ boxes: NSBox...) {
        boxes.forEach({$0.isTransparent = false})
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
    
    // Creates a menu item that serves only to describe other items in the menu. The item will have no action.
    static func createDescriptor(title: String) -> NSMenuItem {
        
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.disable()  // Descriptor items cannot be clicked
        return item
    }
}

extension NSControl {
    
    var isDisabled: Bool {
        return !isEnabled
    }
    
    // TODO: Why not just set the flag to true/false here ???
    // Is there an overriden function somewhere in a subview ?
    @objc func enable() {
        self.enableIf(true)
    }
    
    // TODO: Why not just set the flag to true/false here ???
    // Is there an overriden function somewhere in a subview ?
    @objc func disable() {
        self.enableIf(false)
    }
    
    @objc func enableIf(_ condition: Bool) {
        self.isEnabled = condition
    }
    
    @objc func disableIf(_ condition: Bool) {
        self.isEnabled = !condition
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
    
    func resizeTo(newWidth: CGFloat, newHeight: CGFloat) {
        
        var newFrame = self.frame
        newFrame.size = NSSize(width: newWidth, height: newHeight)
        setFrame(newFrame, display: true)
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
                
            @unknown default:
                NSLog("Encountered unknown CGPath element type:" + String(describing: type))
            }
        }
        return path
    }
}

extension NSImage {
    
    func writeToFile(fileType: NSBitmapImageRep.FileType, file: URL) throws {
        
        if let bits = self.representations.first as? NSBitmapImageRep,
           let data = bits.representation(using: fileType, properties: [:]) {
            
            try data.write(to: file)
        }
    }
    
    // Returns a copy of this image tinted with a given color. Used by several UI components for system color scheme conformance.
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
    
    // Returns whether or not this color is opaque (i.e. alpha == 1)
    var isOpaque: Bool {
        return self.alphaComponent == 1
    }
    
    // Computes a shadow color that would be visible in contrast to this color.
    // eg. if this color is white, black would be a visible shadow color. However, if this color is black, we would need a bit of brightness in the shadow.
    var visibleShadowColor: NSColor {
        
        // Convert to RGB color space to be able to determine the brightness.
        let rgb = toRGB()
        
        let myBrightness = rgb.brightnessComponent
        
        // If the brightness is under a threshold, it is too dark for black to be visible as its shadow. In that case, return a shadow color that has a bit of brightness to it.
        if myBrightness < 0.15 {
            return NSColor(white: min(0.2, myBrightness + 0.15), alpha: 1)
        }
        
        // For reasonably bright colors, black is the best shadow color.
        return NSColor.black
    }
    
    // Clones this color, but with the alpha component set to a specified value.
    func clonedWithTransparency(_ alpha: CGFloat) -> NSColor {
        
        switch self.colorSpace.colorSpaceModel {
            
        case .gray: return NSColor(white: self.whiteComponent, alpha: alpha)
            
        case .rgb:  return NSColor(red: self.redComponent, green: self.greenComponent, blue: self.blueComponent, alpha: alpha)
            
        case .cmyk: return NSColor(deviceCyan: self.cyanComponent, magenta: self.magentaComponent, yellow: self.yellowComponent, black: self.blackComponent, alpha: alpha)
            
        default: return self
            
        }
    }
    
    // If necessary, converts this color to the RGB color space.
    func toRGB() -> NSColor {
        
        // Not in RGB color space, need to convert.
        if self.colorSpace.colorSpaceModel != .rgb, let rgb = self.usingColorSpace(.deviceRGB) {
            return rgb
        }
        
        // Already in RGB color space, no need to convert.
        return self
    }
    
    // Returns a color that is darker than this color by a certain percentage.
    // NOTE - The percentage parameter represents a percentage within the range of possible values.
    // eg. For black, the range would be zero, so this function would have no effect. For white, the range would be the entire [0.0, 1.0]
    // For a color in between black and white, the range would be [0, B] where B represents the brightness component of this color.
    func darkened(_ percentage: CGFloat) -> NSColor {
        
        let rgbSelf = self.toRGB()
        
        let curBrightness = rgbSelf.brightnessComponent
        let newBrightness = curBrightness - (percentage * curBrightness / 100)
        
        return NSColor(hue: rgbSelf.hueComponent, saturation: rgbSelf.saturationComponent, brightness: min(max(0, newBrightness), 1), alpha: rgbSelf.alphaComponent)
    }
    
    // Returns a color that is brighter than this color by a certain percentage.
    // NOTE - The percentage parameter represents a percentage within the range of possible values.
    // eg. For white, the range would be zero, so this function would have no effect. For black, the range would be the entire [0.0, 1.0]
    // For a color in between black and white, the range would be [B, 1.0] where B represents the brightness component of this color.
    func brightened(_ percentage: CGFloat) -> NSColor {
        
        let rgbSelf = self.toRGB()
        
        let curBrightness = rgbSelf.brightnessComponent
        let range: CGFloat = 1 - curBrightness
        let newBrightness = curBrightness + (percentage * range / 100)
        
        return NSColor(hue: rgbSelf.hueComponent, saturation: rgbSelf.saturationComponent, brightness: min(max(0, newBrightness), 1), alpha: rgbSelf.alphaComponent)
    }
}

extension NSImageView {

    // Experimental code. Not currently in use.
//    var cornerRadius: CGFloat {
//
//        get {
//            return self.layer?.cornerRadius ?? 0
//        }
//
//        set(newValue) {
//
//            if !self.wantsLayer {
//
//                self.wantsLayer = true
//                self.layer?.masksToBounds = true;
//            }
//
//            self.layer?.cornerRadius = newValue;
//        }
//    }
}

extension NSGradient {
    
    // Returns an NSGradient with the start/end colors of this NSGradient reversed.
    func reversed() -> NSGradient {
        
        var start: NSColor = NSColor.white
        self.getColor(&start, location: nil, at: 0)
        
        var end: NSColor = NSColor.black
        self.getColor(&end, location: nil, at: 1)
        
        return NSGradient(starting: end, ending: start)!
    }
}
