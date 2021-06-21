import Foundation

extension MutableCollection where Indices.Iterator.Element == Index {

    // Shuffles a collection using the Fisher-Yates algorithm
    mutating func shuffle() {
        
        guard count > 1 else {return}
        
        let theCount = count
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: theCount, to: 1, by: -1)) {
            
            let offset: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard offset != 0 else {continue}
            
            let swapIndex = index(firstUnshuffled, offsetBy: offset)
            self.swapAt(firstUnshuffled, swapIndex)
        }
    }
    
    var lastIndex: Int {count - 1}
}
