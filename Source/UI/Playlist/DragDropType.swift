import Cocoa

// Indicates the type of drop operation being performed
enum DropType {
    
    // Drop on a destination row
    case on
    
    // Drop above a destination row
    case above
    
    // Converts an NSTableViewDropOperation to a DropType
    static func fromDropOperation(_ dropOp: NSTableView.DropOperation) -> DropType {
        return dropOp == .on ? .on : .above
    }
}
