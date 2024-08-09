import Foundation

///
/// An array that can safely be updated concurrently by multiple threads.
///
class ConcurrentArray<T>: CustomStringConvertible {
    
    ///
    /// The underlying / backing array.
    ///
    var array: [T] = []

    ///
    /// Allows safe shared access to the underlying array.
    ///
    /// # Note #
    ///
    /// The semaphore grants array access to only one thread at a time.
    ///
    private var semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)

    ///
    /// The size of this (the underlying) array.
    ///
    var count: Int {array.count}
    
    ///
    /// Allows access to elements through a subscript, similar to a Swift array.
    ///
    /// - Parameter index: The index of the element being accessed.
    ///
    ///```
    /// Example
    ///
    /// let threadSafeArr = ConcurrentArray<Int>()
    /// threadSafeArr.append(24)
    /// threadSafeArr.append(50)
    /// threadSafeArr.append(75)
    ///
    /// threadSafeArr[0] = 25
    /// print(threadSafeArr[0])     // prints "25"
    ///```
    ///
    subscript(index: Int) -> T {
        
        get {
            
            semaphore.wait()
            defer {semaphore.signal()}
            
            return array[index]
        }
        
        set {
            
            semaphore.wait()
            defer {semaphore.signal()}
            
            array[index] = newValue
        }
    }
    
    ///
    /// Appends a new element to the end of the underlying array.
    ///
    /// - Parameter index: The index of the element being accessed.
    ///
    ///```
    /// Example
    ///
    /// let threadSafeArr = ConcurrentArray<Int>()
    ///
    /// threadSafeArr.append(25)
    /// print(threadSafeArr)        // prints "[25]"
    ///
    /// threadSafeArr.append(50)
    /// print(threadSafeArr)        // prints "[25, 50]"
    ///
    /// threadSafeArr.append(75)
    /// print(threadSafeArr)        // prints "[25, 50, 75]"
    ///```
    ///
    func append(_ element: T) {
        
        semaphore.wait()
        defer {semaphore.signal()}
        
        array.append(element)
    }
    
    ///
    /// Sorts the underlying array using the given comparator for element comparison.
    ///
    /// - Parameter comparator: The comparator to use for element comparison when sorting.
    ///
    ///```
    /// Example
    ///
    /// let threadSafeArr = ConcurrentArray<Int>()
    ///
    /// threadSafeArr.append(25)
    /// threadSafeArr.append(50)
    /// threadSafeArr.append(75)
    /// print(threadSafeArr)        // prints "[25, 50, 75]"
    ///
    /// threadSafeArr.sort(by {$0 > $1})    // Sort in descending order.
    /// print(threadSafeArr)        // prints "[75, 50, 25]"
    ///```
    ///
    func sort(by comparator: (T, T) -> Bool) {
        
        semaphore.wait()
        defer {semaphore.signal()}
        
        array.sort(by: comparator)
    }

    ///
    /// Provides a printable description of this array (like that of a Swift array), that can aid in debugging.
    ///
    var description: String {array.description}
}
