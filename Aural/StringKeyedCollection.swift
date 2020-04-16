import Foundation

class StringKeyedCollection<T: StringKeyedItem> {
    
    private var array: [T] = [T]()
    private var map: [String: T] = [String: T]()
    
    func addItem(_ item: T) {
        
        array.append(item)
        map[item.key] = item
    }
    
    func removeItemWithKey(_ key: String) {
        
        if let index = array.index(where: {$0.key == key}) {
            array.remove(at: index)
            map.removeValue(forKey: key)
        }
    }
    
    func removeItemAtIndex(_ index: Int) {
        
        let item = array[index]
        map.removeValue(forKey: item.key)
        array.remove(at: index)
    }
    
    func itemAtIndex(_ index: Int) -> T {
        return array[index]
    }
    
    func itemWithKey(_ key: String) -> T? {
        return map[key]
    }
    
    func itemWithKeyExists(_ key: String) -> Bool {
        return map[key] != nil
    }
    
    var count: Int {
        return array.count
    }
    
    var allItems: [T] {
        
        let copy = array
        return copy
    }
    
    func removeAllItems() {
        array.removeAll()
        map.removeAll()
    }
}

protocol StringKeyedItem {
    
    var key: String {get}
}
