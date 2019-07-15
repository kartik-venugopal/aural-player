import Cocoa

class ColorSensitiveImageButton: NSButton {
    
    var imageMappings: [ColorScheme: NSImage] = [:]
    
    func schemeChanged() {
        self.image = imageMappings[Colors.scheme]
    }
}

class ColorSensitiveMenuItem: NSMenuItem {
    
    var imageMappings: [ColorScheme: NSImage] = [:]
    
    func schemeChanged() {
        self.image = imageMappings[Colors.scheme]
    }
}
