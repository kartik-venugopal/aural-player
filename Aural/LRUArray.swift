import Cocoa

struct LRUArray<T: EquatableHistoryItem> {
    
    private var array: [T] = [T]()
    private let size: Int
    
    init(_ size: Int) {
        self.size = size
    }
    
    mutating func add(_ newElement: T) {
        
        if let index = array.index(where: { $0.equals(newElement) }) {
            
            // Item already exists in array, remove it from the previous location (so it may be added at the top)
            array.remove(at: index)
        }
        
        // Add the new element at the top
        array.append(newElement)
        
        // Max size has been reached, remove the oldest item
        if (array.count > size) {
            array.removeFirst()
        }
    }
    
    mutating func addAll(_ newElements: [T]) {
        newElements.forEach({add($0)})
    }
    
    mutating func remove(_ element: T) {
       
        if let index = array.index(where: { $0.equals(element) }) {
            array.remove(at: index)
        }
    }
    
    func itemAt(_ index: Int) -> T? {
        return array.isEmpty || index < 0 || index >= array.count ? nil : array[index]
    }
    
    func toArray() -> [T] {
        let arrayCopy = array
        return arrayCopy
    }
    
    func contains(_ element: T) -> Bool {
        return array.contains(where: { $0.equals(element) })
    }
}
