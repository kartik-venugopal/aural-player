import Foundation

/*
    A collection that behaves like an array and a map, enabling fast lookups both by index and a String key.
 */
class StringKeyedCollection<T: StringKeyedItem> {
    
    private var array: [T] = [T]()
    private var map: [String: T] = [String: T]()
    
    func addItem(_ item: T) {
        
        array.append(item)
        map[item.key] = item
    }
    
    func removeItemWithKey(_ key: String) {
        
        if let index = array.firstIndex(where: {$0.key == key}) {
            array.remove(at: index)
            map.removeValue(forKey: key)
        }
    }
    
    func reMapForKey(_ oldKey: String, _ newKey: String) {
        
        if let index = array.firstIndex(where: {$0.key == oldKey}) {

            // Modify the key within the item
            array[index].key = newKey
            
            // Re-map the item to the new key
            map.removeValue(forKey: oldKey)
            map[newKey] = array[index]
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

// A contract for items in a StringKeyedCollection
protocol StringKeyedItem {
    
    var key: String {get set}
}
