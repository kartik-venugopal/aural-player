//
//  FontSet.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

///
/// A utility that provides convenient functions for creating fonts belonging to a certain font scheme.
///
class FontSet {
    
    let mainFontName: String
    let captionFontName: String
    
    init(mainFontName: String, captionFontName: String) {
        
        self.mainFontName = mainFontName
        self.captionFontName = captionFontName
    }
    
    func mainFont(size: CGFloat) -> NSFont {
        NSFont(name: mainFontName, size: size)!
    }
    
    func captionFont(size: CGFloat) -> NSFont {
        NSFont(name: captionFontName, size: size)!
    }
}
