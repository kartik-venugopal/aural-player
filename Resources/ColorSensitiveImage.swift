import Cocoa

class ColorSensitiveImage: NSImageView {
    
    var imageMappings: [ColorScheme: NSImage] = [:]
    
    func colorSchemeChanged() {
        self.image = imageMappings[Colors.scheme]
    }
}

class ColorSensitiveImageButton: NSButton {
    
    var imageMappings: [ColorScheme: NSImage] = [:]
    
    func colorSchemeChanged() {
        self.image = imageMappings[Colors.scheme]
    }
}

class ColorSensitiveMenuItem: NSMenuItem {
    
    var imageMappings: [ColorScheme: NSImage] = [:]
    
    func colorSchemeChanged() {
        self.image = imageMappings[Colors.scheme]
    }
}
