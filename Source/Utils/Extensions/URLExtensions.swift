import Foundation

extension URL {
    
    var lowerCasedExtension: String {
        pathExtension.lowercased()
    }
    
    var isNativelySupported: Bool {
        AppConstants.SupportedTypes.nativeAudioExtensions.contains(lowerCasedExtension)
    }
}
