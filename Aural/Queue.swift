import Foundation

// FIFO
class Queue<T> {
    
    private var array: [T] = []
    
    func enqueue(_ item: T) {
        array.append(item)
    }
    
    func dequeue() -> T? {
        
        if array.count > 0 {
            return array.first
        }
        
        return nil
    }
    
    func clear() {
        array.removeAll()
    }
    
    func size() -> Int {
        return array.count
    }
    
    func toArray() -> [T] {
        let copy = array
        return copy
    }
}
