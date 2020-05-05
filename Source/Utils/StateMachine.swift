import Cocoa

class StateMachine<T: AnyObject> {
    
    private var array: [T]
    private var cursor: Int
    
    init(_ array: [T]) {
        self.array = array
        self.cursor = 0
    }
 
    func next() -> T {
        cursor = cursor == array.count - 1 ? 0 : cursor + 1
        return array[cursor]
    }
    
    func previous() -> T {
        cursor = cursor == 0 ? array.count - 1 : cursor - 1
        return array[cursor]
    }
    
    func setState(_ state: T) {
        
        for i in 0..<array.count {
            
            if array[i] === state {
                cursor = i
                return
            }
        }
    }
}
