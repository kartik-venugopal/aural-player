import Foundation

/*
    Data structure that provides LIFO operations - push/pop/peek. Backed by an array.
 */
class Stack<T: Any> {
 
    // Backing array
    private var array: [T] = []
    
    func push(_ elm: T) {
        array.append(elm)
    }
    
    func pop() -> T? {
        return array.popLast()
    }
    
    func peek() -> T? {
        return array.last
    }
    
    func clear() {
        array.removeAll()
    }
    
    var size: Int {
        return array.count
    }
    
    var isEmpty: Bool {
        return array.count == 0
    }
}
