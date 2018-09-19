//import Foundation
//
//
//let date = Date()
//let calendar = Calendar.current
//
//let hour = calendar.component(.year, from: date)
//let minutes = calendar.component(.minute, from: date)
//let seconds = calendar.component(.second, from: date)
//print("hours = \(hour):\(minutes):\(seconds)")
//

// ------------- Context-sensitive information tool tip -----------------

//let mgr = NSHelpManager.shared()
//mgr.setContextHelp(NSAttributedString.init(string: self.toolTip ?? "ToolTip"), for: self)
//
//let win = self.window!
//let winLoc = event.locationInWindow.applying(CGAffineTransform.init(translationX: win.x, y: win.y))
//
//mgr.showContextHelp(for: self, locationHint: winLoc)
//mgr.removeContextHelp(for: self)

// --------------- Force tool tip to show --------


//invalidateOldToolTip()
//
//let win = self.window!
////        let winLoc = event.locationInWindow
//let winLoc = self.convert(event.locationInWindow, from: nil)
////        let winLoc = event.locationInWindow.applying(CGAffineTransform.init(translationX: win.x, y: win.y))
//self.addToolTip(NSRect(x: winLoc.x, y: winLoc.y, width: 100, height: 30), owner: self.toolTip!, userData: nil)
//}
//
//private func invalidateOldToolTip() {
//    
//    // self.removeAllToolTips()
//}
