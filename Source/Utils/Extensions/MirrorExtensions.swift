import Foundation

extension Mirror {
    
    var allChildren: [Mirror.Child] {
        self.children + (self.superclassMirror?.allChildren ?? [])
    }
}
