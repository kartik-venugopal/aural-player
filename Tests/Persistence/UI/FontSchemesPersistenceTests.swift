//
//  FontSchemesPersistenceTests.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class FontSchemesPersistenceTests: PersistenceTestCase {
    
    func testPersistence() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            let systemScheme = randomFontScheme(named: "_system_")
            let userSchemes = randomFontSchemes()
            
            let state = FontSchemesPersistentState(systemScheme: systemScheme, userSchemes: userSchemes)
            doTestPersistence(serializedState: state)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension FontSchemesPersistentState: Equatable {
    
    static func == (lhs: FontSchemesPersistentState, rhs: FontSchemesPersistentState) -> Bool {
        lhs.systemScheme == rhs.systemScheme && lhs.userSchemes == rhs.userSchemes
    }
}

extension FontSchemePersistentState: Equatable {
    
    internal init(name: String?, textFontName: String?, headingFontName: String?, player: PlayerFontSchemePersistentState?, playlist: PlaylistFontSchemePersistentState?, effects: EffectsFontSchemePersistentState?) {
        
        self.name = name
        self.textFontName = textFontName
        self.headingFontName = headingFontName
        self.player = player
        self.playlist = playlist
        self.effects = effects
    }
    
    static func == (lhs: FontSchemePersistentState, rhs: FontSchemePersistentState) -> Bool {
        
        lhs.name == rhs.name &&
            lhs.headingFontName == rhs.headingFontName &&
            lhs.textFontName == rhs.textFontName &&
            lhs.player == rhs.player &&
            lhs.playlist == rhs.playlist &&
            lhs.effects == rhs.effects
    }
}

extension PlayerFontSchemePersistentState: Equatable {
   
    internal init(titleSize: CGFloat?, artistAlbumSize: CGFloat?, chapterTitleSize: CGFloat?, trackTimesSize: CGFloat?, feedbackTextSize: CGFloat?) {
        
        self.titleSize = titleSize
        self.artistAlbumSize = artistAlbumSize
        self.chapterTitleSize = chapterTitleSize
        self.trackTimesSize = trackTimesSize
        self.feedbackTextSize = feedbackTextSize
    }
    
    static func == (lhs: PlayerFontSchemePersistentState, rhs: PlayerFontSchemePersistentState) -> Bool {
        
        CGFloat.approxEquals(lhs.artistAlbumSize, rhs.artistAlbumSize, accuracy: 0.001) &&
        CGFloat.approxEquals(lhs.chapterTitleSize, rhs.chapterTitleSize, accuracy: 0.001) &&
        CGFloat.approxEquals(lhs.feedbackTextSize, rhs.feedbackTextSize, accuracy: 0.001) &&
        CGFloat.approxEquals(lhs.titleSize, rhs.titleSize, accuracy: 0.001) &&
        CGFloat.approxEquals(lhs.trackTimesSize, rhs.trackTimesSize, accuracy: 0.001)
    }
}

extension PlaylistFontSchemePersistentState: Equatable {
    
    internal init(trackTextSize: CGFloat?, trackTextYOffset: CGFloat?, groupTextSize: CGFloat?, groupTextYOffset: CGFloat?, summarySize: CGFloat?, tabButtonTextSize: CGFloat?, chaptersListHeaderSize: CGFloat?, chaptersListSearchSize: CGFloat?, chaptersListCaptionSize: CGFloat?) {
        
        self.trackTextSize = trackTextSize
        self.trackTextYOffset = trackTextYOffset
        self.groupTextSize = groupTextSize
        self.groupTextYOffset = groupTextYOffset
        self.summarySize = summarySize
        self.tabButtonTextSize = tabButtonTextSize
        self.chaptersListHeaderSize = chaptersListHeaderSize
        self.chaptersListSearchSize = chaptersListSearchSize
        self.chaptersListCaptionSize = chaptersListCaptionSize
    }
    
    static func == (lhs: PlaylistFontSchemePersistentState, rhs: PlaylistFontSchemePersistentState) -> Bool {
        
        CGFloat.approxEquals(lhs.chaptersListCaptionSize, rhs.chaptersListCaptionSize, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.chaptersListHeaderSize, rhs.chaptersListHeaderSize, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.chaptersListSearchSize, rhs.chaptersListSearchSize, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.groupTextSize, rhs.groupTextSize, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.summarySize, rhs.summarySize, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.tabButtonTextSize, rhs.tabButtonTextSize, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.trackTextSize, rhs.trackTextSize, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.groupTextYOffset, rhs.groupTextYOffset, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.trackTextYOffset, rhs.trackTextYOffset, accuracy: 0.001)
    }
}

extension EffectsFontSchemePersistentState: Equatable {
    
    internal init(unitCaptionSize: CGFloat?, unitFunctionSize: CGFloat?, masterUnitFunctionSize: CGFloat?, filterChartSize: CGFloat?, auRowTextYOffset: CGFloat?) {
        
        self.unitCaptionSize = unitCaptionSize
        self.unitFunctionSize = unitFunctionSize
        self.masterUnitFunctionSize = masterUnitFunctionSize
        self.filterChartSize = filterChartSize
        self.auRowTextYOffset = auRowTextYOffset
    }
    
    static func == (lhs: EffectsFontSchemePersistentState, rhs: EffectsFontSchemePersistentState) -> Bool {
        
        CGFloat.approxEquals(lhs.filterChartSize, rhs.filterChartSize, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.masterUnitFunctionSize, rhs.masterUnitFunctionSize, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.unitCaptionSize, rhs.unitCaptionSize, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.unitFunctionSize, rhs.unitFunctionSize, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.auRowTextYOffset, rhs.auRowTextYOffset, accuracy: 0.001)
    }
}
