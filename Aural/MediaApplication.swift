import Cocoa

class MediaApplication: NSApplication {
    
    private var now: Date?
    
//    enum KeyAction {
//        
//        case keyUp
//        c
//    }
    
    override func sendEvent(_ event: NSEvent) {
        
        if (event.type == .systemDefined && event.subtype.rawValue == 8) {
            
            let keyCode = ((event.data1 & 0xFFFF0000) >> 16)
            let keyFlags = (event.data1 & 0x0000FFFF)
            // Get the key state. 0xA is KeyDown, OxB is KeyUp
            let keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA
            let keyRepeat = (keyFlags & 0x1)
            
            mediaKeyEvent(key: Int32(keyCode), state: keyState, keyRepeat: keyRepeat == 0 ? false : true)
        }
        
        super.sendEvent(event)
    }
    
    func mediaKeyEvent(key: Int32, state: Bool, keyRepeat: Bool) {
        
//        print(key, state, keyRepeat)
        if let ts = now {
            
            let cur = Date()
            let elapsed = cur.timeIntervalSince(ts)
            print("\n", elapsed)
            
            now = cur
            
        } else {
            print("\nFirst event")
            now = Date()
        }
        
        // Only send events on KeyDown. Without this check, these events will happen twice
        if (state) {
            
            switch(key) {
                
            case NX_KEYTYPE_PLAY:
                print("Play")
                break
            case NX_KEYTYPE_FAST:
                print(keyRepeat ? "Seek Fwd" : "Next")
                break
            case NX_KEYTYPE_REWIND:
                print(keyRepeat ? "Seek Bkwd" : "Prev")
                break
            default:
                break
            }
        }
    }
}
