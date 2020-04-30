import Foundation

class Stack<T: Any> {
 
    private var arr: [T] = []
    
    func push(_ elm: T) {
        arr.append(elm)
    }
    
    func pop() -> T? {
        
        if arr.count > 0 {
            return arr.removeLast()
        }
        
        return nil
    }
    
    func peek() -> T? {
        return arr.last
    }
    
    func clear() {
        arr.removeAll()
    }
}
