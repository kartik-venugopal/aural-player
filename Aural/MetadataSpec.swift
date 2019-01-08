import Foundation

/*
    Contract for a metadata specification
 */
protocol MetadataSpec {
    
    // For a format-specific key, return a descriptive user-friendly key
    static func readableKey(_ key: String) -> String
}
