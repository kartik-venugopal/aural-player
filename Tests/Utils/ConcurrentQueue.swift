import Foundation

// FIFO
class ConcurrentQueue<T> {
    
    private let syncQueue: DispatchQueue
    
    init(_ id: String) {
        syncQueue = DispatchQueue(label: id, attributes: .concurrent)
    }
    
    private(set) var array: [T] = []
    
    func enqueue(_ item: T) {
        
        syncQueue.sync(flags: .barrier) {
            array.append(item)
        }
    }
    
    func dequeue() -> T? {
        
        var returnVal: T? = nil
        
        syncQueue.sync(flags: .barrier) {
            returnVal = array.isEmpty ? nil : array.remove(at: 0)
        }
        
        return returnVal
    }
    
    func clear() {
        
        syncQueue.sync(flags: .barrier) {
            array.removeAll()
        }
    }
    
    var size: Int {
        return array.count
    }
}
