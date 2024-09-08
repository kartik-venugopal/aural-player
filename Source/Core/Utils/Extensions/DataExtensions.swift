//
// DataExtensions.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import CryptoKit

extension Data {
    
    var md5String: String {
        Insecure.MD5.hash(data: self).map {String(format: "%02hhx", $0)}.joined()
    }
}
