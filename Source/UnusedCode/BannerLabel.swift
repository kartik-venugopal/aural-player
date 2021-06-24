//
//  BannerLabel.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
//import Cocoa
//
//@IBDesignable
//class BannerLabel: NSView {
//
//    private var allowAnimation: Bool = false
//
//    @IBInspectable var text: String! = "" {
//
//        didSet {
//
//            label?.stringValue = text
//            if (text != "" && allowAnimation) {
//                textChanged()
//            }
//        }
//    }
//
//    var textWidth: CGFloat! = 0
//
//    var font: NSFont! {
//
//        didSet {
//            label?.font = font
//        }
//    }
//
//    @IBInspectable var textColor: NSColor! {
//
//        didSet {
//            label?.textColor = textColor
//        }
//    }
//
//    @IBInspectable var backgroundColor: NSColor! {
//
//        didSet {
//            label?.backgroundColor = backgroundColor
//        }
//    }
//
//    var alignment: NSTextAlignment! {
//
//        didSet {
//            label?.alignment = alignment
//        }
//    }
//
//    private var label: NSTextField!
//
//    override func awakeFromNib() {
//
//        label = NSTextField.createLabel(self.text, self.font, self.alignment, self.textColor, self.backgroundColor)
//
//        self.addSubview(label)
//        label.setFrameSize(self.size)
//        label.setFrameOrigin(NSPoint.zero)
//
//        self.wantsLayer = true
//        allowAnimation = true
//    }
//
//    private func textChanged() {
//
//        NSAnimationContext.runAnimationGroup({_ in
//
//            // Kill any existing animation
//            NSAnimationContext.current.duration = 0.01
//            self.label.animator().setFrameOrigin(NSPoint(x: 0.1, y: 0))
//
//        }, completionHandler: {
//
//            // Begin a new animation
//            if self.font != nil {
//
//                let size: CGSize = (self.text as NSString).size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): self.label.font!]))
//                self.textWidth = size.width
//
//                self.label?.resize(max(self.textWidth + 10, self.width), self.label.height)
//
//                if self.textWidth >= self.width && self.allowAnimation {
//                    self.doBeginAnimation(self.text)
//                }
//            }
//        })
//    }
//
//    private func killAnimation() {
//
//        NSAnimationContext.beginGrouping()
//        NSAnimationContext.current.duration = 0.01
//        self.label.animator().setFrameOrigin(NSPoint(x: 0.1, y: 0))
//        NSAnimationContext.endGrouping()
//    }
//
//    private func doBeginAnimation(_ animatedText: String) {
//
//        let distanceToMove = self.width - label.width
//
//        NSAnimationContext.runAnimationGroup({_ in
//
//            // Duration at least 2 seconds
//            let dur = max(Double(abs(distanceToMove)) / 30, 2)
//
//            NSAnimationContext.current.duration = dur
//
//            NSAnimationContext.current.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//
//            // Move either left or right (alternate, creating a ping-pong effect)
//            let xDest = self.label.frame.origin.x == 0 ? distanceToMove: 0
//            self.label.animator().setFrameOrigin(NSPoint(x: xDest, y: 0))
//
//        }, completionHandler: {
//
//            // Ensure text is updated (and not the result of a stale recursive call with old text)
//            if animatedText == self.text && self.allowAnimation {
//
//                // Loop indefinitely
//                self.doBeginAnimation(animatedText)
//            }
//        })
//    }
//
//    func beginAnimation() {
//        allowAnimation = true
//    }
//
//    func endAnimation() {
//        allowAnimation = false
//        killAnimation()
//    }
//}
//
//extension NSTextField {
//
//    static func createLabel(_ string: String!, _ font: NSFont!, _ alignment: NSTextAlignment!, _ textColor: NSColor!, _ backgroundColor: NSColor!) -> NSTextField {
//
//        let label = NSTextField()
//
//        label.stringValue = string
//        label.isSelectable = false
//        label.isEditable = false
//
//        label.font = font
//        if (alignment != nil) {
//            label.alignment = alignment
//        }
//        label.textColor = textColor
//        label.backgroundColor = backgroundColor
//
//        label.drawsBackground = true
//        label.isBordered = false
//
//        return label
//    }
//}
//
//// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
//	guard let input = input else { return nil }
//	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
//}
//
//// Helper function inserted by Swift 4.2 migrator.
//fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
//	return input.rawValue
//}
