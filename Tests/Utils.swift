//
//  Utils.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

func executionTimeFor(_ task: () -> Void) -> Double {
    
    let startTime = CFAbsoluteTimeGetCurrent()
    task()
    return CFAbsoluteTimeGetCurrent() - startTime
}

func randomString(length: Int) -> String {
    
    let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -"
    let len = UInt32(letters.length)

    var randomString: String = ""

    for _ in 0 ..< length {
        
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }

    return randomString
}

extension CaseIterable where Self: RawRepresentable, AllCases == [Self] {
    
    static func randomCase() -> Self {
        return allCases[Int.random(in: allCases.indices)]
    }
}

func randomUnitState() -> EffectsUnitState {EffectsUnitState.randomCase()}

func randomNillableUnitState() -> EffectsUnitState? {
    randomNillableValue {randomUnitState()}
}

func randomNillableValue<T>(_ producer: @escaping () -> T) -> T? where T: Any {
    
    if Float.random(in: 0...1) < 0.5 {
        return producer()
    } else {
        return nil
    }
}

func randomNillableBool() -> Bool? {
    randomNillableValue {.random()}
}

extension Float {
    
    static func approxEquals(_ op1: Float?, _ op2: Float?, accuracy: Float) -> Bool {
        
        if op1 == nil {return op2 == nil}
        if op2 == nil {return false}
        
        guard let theOp1 = op1, let theOp2 = op2 else {return false}
        
        return theOp1.approxEquals(theOp2, accuracy: accuracy)
    }
    
    func approxEquals(_ other: Float, accuracy: Float) -> Bool {
        fabsf(self - other) <= accuracy
    }
}

extension Array where Element == Float {
    
    static func approxEquals(_ array: [Float]?, _ other: [Float]?, accuracy: Float) -> Bool {
        
        if array == nil {return other == nil}
        if other == nil {return false}
        
        guard let array1 = array, let array2 = other else {return false}
        
        if array1.count != array2.count {return false}
        
        if array1.count == 0 {return true}
        
        for index in array1.indices {
            
            if !array1[index].approxEquals(array2[index], accuracy: accuracy) {
                return false
            }
        }
        
        return true
    }
    
    func approxEquals(_ other: [Float]?, accuracy: Float) -> Bool {
        
        guard let other = other else {return false}
        
        if count != other.count {return false}
        
        if count == 0 {return true}
        
        for index in indices {
            
            if !self[index].approxEquals(other[index], accuracy: accuracy) {
                return false
            }
        }
        
        return true
    }
}

extension Double {
    
    func approxEquals(_ other: Double, accuracy: Double) -> Bool {
        fabs(self - other) <= accuracy
    }
    
    static func approxEquals(_ op1: Double?, _ op2: Double?, accuracy: Double) -> Bool {
        
        if op1 == nil {return op2 == nil}
        if op2 == nil {return false}
        
        guard let theOp1 = op1, let theOp2 = op2 else {return false}
        
        return theOp1.approxEquals(theOp2, accuracy: accuracy)
    }
}

extension CGFloat {
    
    static func approxEquals(_ op1: CGFloat?, _ op2: CGFloat?, accuracy: CGFloat) -> Bool {
        
        if op1 == nil {return op2 == nil}
        if op2 == nil {return false}
        
        guard let theOp1 = op1, let theOp2 = op2 else {return false}
        
        return theOp1.approxEquals(theOp2, accuracy: accuracy)
    }
    
    func approxEquals(_ other: CGFloat, accuracy: CGFloat) -> Bool {
        abs(self - other) <= accuracy
    }
}

func randomColor() -> ColorPersistentState {
    
    let randomNum = Int.random(in: 1...3)
    
    switch randomNum {
    
    case 1:     return randomGrayscaleColor()
        
    case 2:     return randomRGBColor()
        
    case 3:     return randomCMYKColor()
        
    default:    return randomRGBColor()
    
    }
}

func randomColorComponent() -> CGFloat {
    CGFloat.random(in: 0...1)
}

func randomGrayscaleColor() -> ColorPersistentState {
    ColorPersistentState(color: NSColor(white: randomColorComponent(), alpha: randomColorComponent()))
}

func randomRGBColor() -> ColorPersistentState {
    
    ColorPersistentState(color: NSColor(red: randomColorComponent(),
                                        green: randomColorComponent(),
                                        blue: randomColorComponent(),
                                        alpha: randomColorComponent()))
}

func randomCMYKColor() -> ColorPersistentState {
    
    ColorPersistentState(color: NSColor(deviceCyan: randomColorComponent(),
                                        magenta: randomColorComponent(),
                                        yellow: randomColorComponent(),
                                        black: randomColorComponent(),
                                        alpha: randomColorComponent()))
}

func randomFontSchemes(count: Int? = nil) -> [FontSchemePersistentState] {
    
    let numSchemes = count ?? Int.random(in: 0...10)
    
    return numSchemes == 0 ? [] : (1...numSchemes).map {index in
        randomFontScheme(named: "FontScheme-\(index)")
    }
}

func randomFontScheme(named name: String) -> FontSchemePersistentState {
    
    let player = PlayerFontSchemePersistentState(titleSize: randomFontSize(),
                                                 artistAlbumSize: randomFontSize(),
                                                 chapterTitleSize: randomFontSize(),
                                                 trackTimesSize: randomFontSize(),
                                                 feedbackTextSize: randomFontSize())
    
    let playlist = PlaylistFontSchemePersistentState(trackTextSize: randomFontSize(),
                                                     trackTextYOffset: randomTextYOffset(),
                                                     groupTextSize: randomFontSize(),
                                                     groupTextYOffset: randomTextYOffset(),
                                                     summarySize: randomFontSize(),
                                                     tabButtonTextSize: randomFontSize(),
                                                     chaptersListHeaderSize: randomFontSize(),
                                                     chaptersListSearchSize: randomFontSize(),
                                                     chaptersListCaptionSize: randomFontSize())
    
    let effects = EffectsFontSchemePersistentState(unitCaptionSize: randomFontSize(),
                                                   unitFunctionSize: randomFontSize(),
                                                   masterUnitFunctionSize: randomFontSize(),
                                                   filterChartSize: randomFontSize(),
                                                   auRowTextYOffset: randomTextYOffset())
    
    return FontSchemePersistentState(name: name,
                                     textFontName: randomFontName(),
                                     headingFontName: randomFontName(),
                                     player: player,
                                     playlist: playlist,
                                     effects: effects)
}

let allFonts: [String] = {
    
    var fontNames: [String] = []
    
    for family in NSFontManager.shared.availableFontFamilies {
        
        if let members = NSFontManager.shared.availableMembers(ofFontFamily: family) {
            
            for member in members {
                
                if member.count >= 2, let fontName = member[0] as? String, let weight = member[1] as? String {
                    fontNames.append(String(format: "%@ %@", family, weight))
                }
            }
        }
    }
    
    return fontNames
}()

func randomFontName() -> String {
    
    let randomIndex = Int.random(in: allFonts.indices)
    return allFonts[randomIndex]
}

func randomFontSize() -> CGFloat {
    CGFloat.random(in: 10...20)
}

func randomTextYOffset() -> CGFloat {
    CGFloat.random(in: -3...3)
}

func randomColorSchemes(count: Int? = nil) -> [ColorSchemePersistentState] {
    
    let numSchemes = count ?? Int.random(in: 0...10)
    
    return numSchemes == 0 ? [] : (1...numSchemes).map {index in
        randomColorScheme(named: "ColorScheme-\(index)")
    }
}

func randomColorScheme(named name: String) -> ColorSchemePersistentState {
    
    let general = GeneralColorSchemePersistentState(appLogoColor: randomColor(),
                                                    backgroundColor: randomColor(),
                                                    viewControlButtonColor: randomColor(),
                                                    functionButtonColor: randomColor(),
                                                    textButtonMenuColor: randomColor(),
                                                    toggleButtonOffStateColor: randomColor(),
                                                    selectedTabButtonColor: randomColor(),
                                                    mainCaptionTextColor: randomColor(),
                                                    tabButtonTextColor: randomColor(),
                                                    selectedTabButtonTextColor: randomColor(),
                                                    buttonMenuTextColor: randomColor())
    
    let player = PlayerColorSchemePersistentState(trackInfoPrimaryTextColor: randomColor(),
                                                  trackInfoSecondaryTextColor: randomColor(),
                                                  trackInfoTertiaryTextColor: randomColor(),
                                                  sliderValueTextColor: randomColor(),
                                                  sliderBackgroundColor: randomColor(),
                                                  sliderBackgroundGradientType: .randomCase(),
                                                  sliderBackgroundGradientAmount: Int.random(in: 1...100),
                                                  sliderForegroundColor: randomColor(),
                                                  sliderForegroundGradientType: .randomCase(),
                                                  sliderForegroundGradientAmount: Int.random(in: 1...100),
                                                  sliderKnobColor: randomColor(),
                                                  sliderKnobColorSameAsForeground: .random(),
                                                  sliderLoopSegmentColor: randomColor())
    
    let playlist = PlaylistColorSchemePersistentState(trackNameTextColor: randomColor(),
                                                      groupNameTextColor: randomColor(),
                                                      indexDurationTextColor: randomColor(),
                                                      trackNameSelectedTextColor: randomColor(),
                                                      groupNameSelectedTextColor: randomColor(),
                                                      indexDurationSelectedTextColor: randomColor(),
                                                      summaryInfoColor: randomColor(),
                                                      playingTrackIconColor: randomColor(),
                                                      selectionBoxColor: randomColor(),
                                                      groupIconColor: randomColor(),
                                                      groupDisclosureTriangleColor: randomColor())
    
    let effects = EffectsColorSchemePersistentState(functionCaptionTextColor: randomColor(),
                                                    functionValueTextColor: randomColor(),
                                                    sliderBackgroundColor: randomColor(),
                                                    sliderBackgroundGradientType: .randomCase(),
                                                    sliderBackgroundGradientAmount: .random(in: 1...100),
                                                    sliderForegroundGradientType: .randomCase(),
                                                    sliderForegroundGradientAmount: .random(in: 1...100),
                                                    sliderKnobColor: randomColor(),
                                                    sliderKnobColorSameAsForeground: .random(),
                                                    sliderTickColor: randomColor(),
                                                    activeUnitStateColor: randomColor(),
                                                    bypassedUnitStateColor: randomColor(),
                                                    suppressedUnitStateColor: randomColor())
    
    return ColorSchemePersistentState(name: name,
                                      general: general,
                                      player: player,
                                      playlist: playlist,
                                      effects: effects)
}

func randomTheme(named name: String) -> ThemePersistentState {
    
    let windowCornerRadius = CGFloat.random(in: 0...25)
    let fontScheme = randomFontScheme(named: "Font scheme for theme '\(name)'")
    let colorScheme = randomColorScheme(named: "Color scheme for theme '\(name)'")
    
    return ThemePersistentState(name: name,
                                fontScheme: fontScheme,
                                colorScheme: colorScheme,
                                windowAppearance: WindowAppearancePersistentState(cornerRadius: windowCornerRadius))
                                
}

func randomThemes(count: Int? = nil) -> [ThemePersistentState] {
    
    let numThemes = count ?? Int.random(in: 0...10)
    
    return numThemes == 0 ? [] : (1...numThemes).map {index in
        randomTheme(named: "Theme-\(index)")
    }
}

func randomUserLayouts(count: Int? = nil) -> [UserWindowLayoutPersistentState] {
    
    let numLayouts = count ?? Int.random(in: 0...10)
    
    return numLayouts == 0 ? [] : (1...numLayouts).map {index in
        
        let layout = randomLayout(name: "Layout-\(index)", systemDefined: false)
        return UserWindowLayoutPersistentState(layout: layout)
    }
}

func randomLayout(name: String, systemDefined: Bool,
                          showPlaylist: Bool? = nil, showEffects: Bool? = nil) -> WindowLayout {
    
    let visibleFrame = visibleFrameRect
    
    let randomNum = Int.random(in: 1...100)
    
    // 70% probability that the playlist window is shown.
    let showPlaylist: Bool = showPlaylist ?? (randomNum > 30)
    
    // 50% probability that the effects window is shown.
    let showEffects: Bool = showEffects ?? (randomNum > 50)
    
    var effectsWindowOrigin: NSPoint? = nil
    var playlistWindowFrame: NSRect? = nil
    
    let mainWindowOrigin = visibleFrame.randomContainedRect(width: WindowLayoutPresets.mainWindowWidth,
                                                            height: WindowLayoutPresets.mainWindowHeight).origin
    
    if showEffects {
        
        let effectsWindowFrame = visibleFrame.randomContainedRect(width: WindowLayoutPresets.effectsWindowWidth,
                                                                  height: WindowLayoutPresets.effectsWindowHeight)
        
        effectsWindowOrigin = effectsWindowFrame.origin
    }
    
    if showPlaylist {
        
        let playlistWidth = CGFloat.random(in: WindowLayoutPresets.mainWindowWidth...visibleFrame.width)
        let playlistHeight = CGFloat.random(in: WindowLayoutPresets.mainWindowHeight...visibleFrame.height)
        
        playlistWindowFrame = visibleFrame.randomContainedRect(width: playlistWidth,
                                                               height: playlistHeight)
    }
    
    return WindowLayout(name, showEffects, showPlaylist,
                        mainWindowOrigin, effectsWindowOrigin, playlistWindowFrame,
                        systemDefined)
}

var visibleFrameRect: NSRect {
    return NSScreen.main!.visibleFrame
}

func moveLayoutToRandomLocation(layout: WindowLayout) -> WindowLayout {
    
    let visibleFrame = visibleFrameRect
    
    let layoutBoundingBox = layout.boundingBox
    let movedBoundingBox = visibleFrame.randomContainedRect(width: layoutBoundingBox.width,
                                                            height: layoutBoundingBox.height)
    
    let distanceMovedX = movedBoundingBox.minX - layoutBoundingBox.minX
    let distanceMovedY = movedBoundingBox.minY - layoutBoundingBox.minY
    
    let movedMainWindowOrigin = layout.mainWindowOrigin.translating(distanceMovedX, distanceMovedY)
    let movedEffectsWindowOrigin = layout.effectsWindowOrigin?.translating(distanceMovedX, distanceMovedY)
    let movedPlaylistWindowFrame = layout.playlistWindowFrame?.offsetBy(dx: distanceMovedX, dy: distanceMovedY)
    
    return WindowLayout(layout.name, layout.showEffects, layout.showPlaylist, movedMainWindowOrigin, movedEffectsWindowOrigin, movedPlaylistWindowFrame, layout.systemDefined)
}

func randomControlBarPlayerWindowFrame() -> NSRect {
    
    let visibleFrame = visibleFrameRect
    return visibleFrame.randomContainedRect(width: CGFloat.random(in: 600...visibleFrame.width),
                                            height: 40)
}

func randomRecentlyPlayedItems() -> [HistoryItemPersistentState] {
    
    let numItems = Int.random(in: 10...100)
    
    return (1...numItems).map {_ in
        
        let file = randomAudioFile()
        let name = randomString(length: Int.random(in: 10...50))
        let time = Date.init(timeIntervalSinceNow: -randomTimeBeforeNow())
        
        return HistoryItemPersistentState(file: file, name: name, time: time.serializableString())
    }
}

func randomRecentlyAddedItems() -> [HistoryItemPersistentState] {
    
    let numItems = Int.random(in: 10...100)
    
    return (1...numItems).map {_ in
        
        let file = randomRecentlyAddedItemFilePath()
        let name = randomString(length: Int.random(in: 10...50))
        let time = Date.init(timeIntervalSinceNow: -randomTimeBeforeNow())
        
        return HistoryItemPersistentState(file: file, name: name, time: time.serializableString())
    }
}

func randomTimeBeforeNow() -> Double {
    
    // 1 minute to 60 days.
    Double.random(in: 65...5184000)
}

func randomRecentlyAddedItemFilePath() -> URLPath {
    
    let randomNum = Int.random(in: 1...3)
    
    switch randomNum {
    
    case 1:     // Audio file
                return randomAudioFile()
    
    case 2:     // Playlist file
                return randomPlaylistFile()
    
    case 3:     // Folder
                return randomFolder()
        
    default:    return randomAudioFile()
        
    }
}

func fileMetadata(_ title: String?, _ artist: String?, _ album: String?, _ genre: String?, _ duration: Double) -> FileMetadata {
    
    var fileMetadata: FileMetadata = FileMetadata()
    var playlistMetadata: PlaylistMetadata = PlaylistMetadata()
    
    playlistMetadata.title = title
    playlistMetadata.artist = artist
    playlistMetadata.album = album
    playlistMetadata.genre = genre
    playlistMetadata.duration = duration
    
    fileMetadata.playlist = playlistMetadata
    
    return fileMetadata
}

let allAudioExtensions: [String] = Array(SupportedTypes.allAudioExtensions)

func randomAudioFileExtension() -> URLPath {
    
    let randomIndex = Int.random(in: 0..<SupportedTypes.allAudioExtensions.count)
    return allAudioExtensions[randomIndex]
}

private let imageFileExtensions: [String] = ["jpg", "png", "tiff", "bmp"]

func randomImageFileExtension() -> URLPath {
    
    let randomIndex = Int.random(in: 0..<imageFileExtensions.count)
    return imageFileExtensions[randomIndex]
}

func randomAudioFile() -> URLPath {
    
    let pathComponents: [String] = (0..<Int.random(in: 2...10)).map {_ in randomString(length: Int.random(in: 5...20))}
    return "/\(pathComponents.joined(separator: "/")).\(randomAudioFileExtension())"
}

func randomPlaylistFile() -> URLPath {
    
    let pathComponents: [String] = (0..<Int.random(in: 2...10)).map {_ in randomString(length: Int.random(in: 5...20))}
    return "/\(pathComponents.joined(separator: "/")).m3u"
}

func randomImageFile() -> URLPath {
    
    let pathComponents: [String] = (0..<Int.random(in: 2...10)).map {_ in randomString(length: Int.random(in: 5...20))}
    return "/\(pathComponents.joined(separator: "/")).\(randomImageFileExtension())"
}

func randomFolder() -> URLPath {
    
    let pathComponents: [String] = (0..<Int.random(in: 2...10)).map {_ in randomString(length: Int.random(in: 5...20))}
    return "/\(pathComponents.joined(separator: "/"))"
}

func randomPlaybackPosition() -> Double {
    Double.random(in: 0...36000)
}

extension Array {
    
    func randomElement() -> Element {
        
        let randomIndex: Int = Int.random(in: self.indices)
        return self[randomIndex]
    }
}

extension Array where Element: FloatingPoint {
    
    func sum() -> Element {
        self.reduce(Element.init(0), {$0 + $1})
    }
}
