import Foundation

class Stack<T: Any> {
 
    private var arr: [T] = []
    
    func push(_ elm: T) {
        arr.append(elm)
    }
    
    func pop() -> T? {
        return arr.popLast()
    }
    
    func peek() -> T? {
        return arr.last
    }
    
    func clear() {
        arr.removeAll()
    }
    
    var size: Int {
        return arr.count
    }
    
    var isEmpty: Bool {
        return arr.count == 0
    }
}
