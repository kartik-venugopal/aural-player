import Foundation

extension IndexSet {

    // Convenience function to convert an IndexSet to an array
    func toArray() -> [Int] {self.filter {$0 >= 0}}
}
