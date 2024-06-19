//
//  AVFExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

extension AVAudioUnitComponent {
    
    var componentType: OSType {
        audioComponentDescription.componentType
    }
    
    var componentSubType: OSType {
        audioComponentDescription.componentSubType
    }
}

extension AVAudioMixerNode {
    
    convenience init(muted: Bool) {
        
        self.init()
        self.volume = muted ? 0 : 1
    }
    
    var muted: Bool {
        
        get {volume == 0}
        set {volume = newValue ? 0 : 1}
    }
}

extension AVAudioChannelLayout {
    
    static let stereo: AVAudioChannelLayout = AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_Stereo)!

    static func defaultDescription(channelCount: Int32) -> String {
        
        switch channelCount {
            
        case 1: return "Mono"
            
        case 2: return "Stereo (L R)"
            
        case 3: return "2.1"
            
        case 6: return "5.1"
            
        case 8: return "7.1"
            
        case 10: return "9.1"
            
        default: return "\(channelCount) channels"
            
        }
    }
}

extension AudioChannelLayout {
    
    static let sizeOfLayout: UInt32 = UInt32(MemoryLayout<AudioChannelLayout>.size)
    
    var description: String? {
        
        var layout: AudioChannelLayout = self
        
        var nameSize : UInt32 = 0
        var status = AudioFormatGetPropertyInfo(kAudioFormatProperty_ChannelLayoutName,
                                                Self.sizeOfLayout, &layout, &nameSize)
        
        if status != noErr {return nil}
        
        var formatName: CFString = String() as CFString
        status = AudioFormatGetProperty(kAudioFormatProperty_ChannelLayoutName,
                                        Self.sizeOfLayout, &layout, &nameSize, &formatName)
        
        if status != noErr {return nil}
        
        return String(formatName as NSString)
    }
}

extension AVAssetTrack {
    
    var formatDescription: CMFormatDescription {
        self.formatDescriptions.first as! CMFormatDescription
    }
    
    var format: FourCharCode {
        CMFormatDescriptionGetMediaSubType(formatDescription)
    }
    
    var format4CharString: String {
        format.toString()
    }
}

extension FourCharCode {
    
    // Create a String representation of a FourCC
    func toString() -> String {
        
        let bytes: [CChar] = [
            CChar((self >> 24) & 0xff),
            CChar((self >> 16) & 0xff),
            CChar((self >> 8) & 0xff),
            CChar(self & 0xff),
            0
        ]
        let result = String(cString: bytes)
        let characterSet = CharacterSet.whitespaces
        return result.trimmingCharacters(in: characterSet)
    }
}

infix operator <> : DefaultPrecedence
extension AudioFormatFlags {
    
    static func <> (left: AudioFormatFlags, right: AudioFormatFlags) -> Bool {
        (left & right) != 0
    }
}

extension AVMetadataItem {
    
    var commonKeyAsString: String? {
        return commonKey?.rawValue
    }
    
    var keyAsString: String? {
        
        if let key = self.key as? String {
            return key
        }
        
        if let id = self.identifier {
            
            // This is required for .iTunes keyspace items ("itsk").
            
            let tokens = id.rawValue.split(separator: "/")
            if tokens.count == 2 {
                
                let key = (tokens[1].replacingOccurrences(of: "%A9", with: "@").trim())
                return key.removingPercentEncoding ?? key
            }
        }
        
        return nil
    }
    
    var valueAsString: String? {

        if !String.isEmpty(self.stringValue) {
            return self.stringValue
        }
        
        if let number = self.numberValue {
            return String(describing: number)
        }
        
        if let data = self.dataValue {
            return String(data: data, encoding: .utf8)
        }
        
        if let date = self.dateValue {
            return String(describing: date)
        }
        
        return nil
    }
    
    var valueAsNumericalString: String {
        
        if !String.isEmpty(self.stringValue), let num = Int(self.stringValue!) {
            return String(describing: num)
        }
        
        if let number = self.numberValue {
            return String(describing: number)
        }
        
        if let data = self.dataValue, let num = Int(data.hexEncodedString(), radix: 16) {
            return String(describing: num)
        }
        
        return "0"
    }
}

extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
