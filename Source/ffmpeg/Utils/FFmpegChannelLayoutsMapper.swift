import AVFoundation

///
/// Helps map ffmpeg channel layout identifiers to their corresponding AVFoundation channel layout tags.
///
/// This is required when setting the format for an audio buffer that is to be scheduled for playback, so that
/// upmixing / downmixing can be performed correctly.
///
struct FFmpegChannelLayoutsMapper {
    
    ///
    /// A comprehensive mapping of ffmpeg layout identifiers to their corresponding AVFoundation channel layout tags.
    ///
    /// # Notes #
    ///
    /// Mappings for some less common channel layouts are not exact, but the closest possible matches. In such cases,
    /// some channels may be re-mapped to different channels or dropped from the output entirely.
    ///
    private static let layoutsMap: [Int: AudioChannelLayoutTag] = [
        
        // C
        CH_LAYOUT_MONO: kAudioChannelLayoutTag_Mono,
        
        // L R
        CH_LAYOUT_STEREO: kAudioChannelLayoutTag_Stereo,
        
        // L R
        CH_LAYOUT_STEREO_DOWNMIX: kAudioChannelLayoutTag_Stereo,
        
        // L R LFE
        CH_LAYOUT_2POINT1: kAudioChannelLayoutTag_WAVE_2_1,
        
        // L R Cs
        CH_LAYOUT_2_1: kAudioChannelLayoutTag_DVD_2,
        
        // L R C
        CH_LAYOUT_SURROUND: kAudioChannelLayoutTag_WAVE_3_0,
        
        // L R C LFE
        CH_LAYOUT_3POINT1: kAudioChannelLayoutTag_DVD_10,
        
        // L R C Cs
        CH_LAYOUT_4POINT0: kAudioChannelLayoutTag_DVD_8,
        
        // L R C LFE Cs
        CH_LAYOUT_4POINT1: kAudioChannelLayoutTag_DVD_11,
        
        // L R Ls Rs
        CH_LAYOUT_2_2: kAudioChannelLayoutTag_Quadraphonic,
        
        // L R Rls Rrs
        CH_LAYOUT_QUAD: kAudioChannelLayoutTag_WAVE_4_0_B,
        
        // L R C Ls Rs
        CH_LAYOUT_5POINT0: kAudioChannelLayoutTag_WAVE_5_0_A,
        
        // L R C LFE Ls Rs
        CH_LAYOUT_5POINT1: kAudioChannelLayoutTag_WAVE_5_1_A,
        
        // L R C Rls Rrs
        CH_LAYOUT_5POINT0_BACK: kAudioChannelLayoutTag_WAVE_5_0_B,
        
        // L R C LFE Rls Rrs
        CH_LAYOUT_5POINT1_BACK: kAudioChannelLayoutTag_WAVE_5_1_B,
        
        // L R C LFE Cs Ls Rs
        CH_LAYOUT_6POINT1: kAudioChannelLayoutTag_WAVE_6_1,
        
        // L R C LFE Rls Rrs Ls Rs
        CH_LAYOUT_7POINT1: kAudioChannelLayoutTag_WAVE_7_1,
        
        // MARK: The following mappings are not exact, but the closest possible matches.
        // NOTE - Some channels may be dropped entirely.
        
        // TODO: Create custom AudioChannelLayouts and AVAudioChannelLayouts with exact channel mappings
        
        // L R C Cs Ls Rs -> L R C Cs
        CH_LAYOUT_6POINT0: kAudioChannelLayoutTag_DVD_8,
        
        // L R Lc Rc Ls Rs -> Lc Rc L R Ls Rs
        CH_LAYOUT_6POINT0_FRONT: kAudioChannelLayoutTag_DTS_6_0_A,
        
        // L R C Rls Rrs Cs -> L R C Ls Rs
        CH_LAYOUT_HEXAGONAL: kAudioChannelLayoutTag_WAVE_5_0_A,
        
        // L R C LFE Rls Rrs Cs -> L R C LFE Ls Rs Cs
        CH_LAYOUT_6POINT1_BACK: kAudioChannelLayoutTag_AudioUnit_6_1,
        
        // L R LFE Lc Rc Ls Rs -> L R LFE Ls Rs
        CH_LAYOUT_6POINT1_FRONT: kAudioChannelLayoutTag_DVD_6,
        
        // L R C Rls Rrs Ls Rs -> L R C Rls Rrs
        CH_LAYOUT_7POINT0: kAudioChannelLayoutTag_WAVE_5_0_B,
        
        // L R C Lc Rc Ls Rs -> L R C Ls Rs
        CH_LAYOUT_7POINT0_FRONT: kAudioChannelLayoutTag_WAVE_5_0_A,
        
        // L R C LFE Lc Rc Ls Rs -> L R C LFE Rls Rrs Ls Rs
        CH_LAYOUT_7POINT1_WIDE: kAudioChannelLayoutTag_WAVE_7_1,
        
        // L R C LFE Rls Rrs Lc Rc -> L R C LFE Rls Rrs Ls Rs
        CH_LAYOUT_7POINT1_WIDE_BACK: kAudioChannelLayoutTag_WAVE_7_1,
        
        // L R C Rls Rrs Cs Ls Rs -> L R C Rls Rrs
        CH_LAYOUT_OCTAGONAL: kAudioChannelLayoutTag_WAVE_5_0_B,
        
        // L R C Rls Rrs Cs Ls Rs TL TC TR TRls TCs TRrs WL WR -> L R C Rls Rrs
        CH_LAYOUT_HEXADECAGONAL: kAudioChannelLayoutTag_WAVE_5_0_B]
    
    ///
    /// Given an ffmpeg channel layout identifier, maps it to a corresponding AVFoundation channel layout.
    ///
    /// This is required when setting the format for an audio buffer that is to be scheduled for playback, so that
    /// upmixing / downmixing can be performed correctly.
    ///
    /// - Parameter ffmpegLayout: An integer representation of an ffmpeg channel layout.
    ///
    /// - returns: A corresponding AVFoundation channel layout, if there exists a mapping for the given
    ///            ffmpeg channel layout. Nil otherwise.
    ///
    static func mapLayout(ffmpegLayout: Int) -> AVAudioChannelLayout? {
        
        if let layoutTag = layoutsMap[ffmpegLayout] {
         
            // NOTE - It's safe to force unwrap the optional AVAudioChannelLayout
            // because we are using only valid pre-defined channel layout tags.
            return AVAudioChannelLayout(layoutTag: layoutTag)!
        }
        
        return nil
    }
    
    ///
    /// Provides a human-readable string for a given channel layout.
    ///
    /// - Parameter channelLayout: The identifier for an ffmpeg channel layout.
    ///
    /// - Parameter channelCount:  The number of channels in **channelLayout**.
    ///
    /// - returns:                 A human-readable string describing the given channel layout.
    ///
    static func readableString(for channelLayout: Int64, channelCount: Int32) -> String {
        
        if channelLayout == 0 {return AVAudioChannelLayout.defaultDescription(channelCount: channelCount)}
        
        let avfLayout = mapLayout(ffmpegLayout: Int(channelLayout))
        return avfLayout?.layout.pointee.description ?? readableFFmpegString(for: channelLayout, channelCount: channelCount)
    }
    
    private static func readableFFmpegString(for channelLayout: Int64, channelCount: Int32) -> String {
        
        let layoutStringPointer = UnsafeMutablePointer<Int8>.allocate(capacity: 100)
        av_get_channel_layout_string(layoutStringPointer, 100, channelCount, UInt64(channelLayout))
        
        defer {layoutStringPointer.deallocate()}
        
        return String(cString: layoutStringPointer).replacingOccurrences(of: "(", with: " (").capitalized
    }
    
    // MARK: Debugging functions ------------------------------------------------------
    
    static func printLayouts() {
        
        for layout in layoutsMap.keys.sorted(by: {$0 < $1}).map({UInt64($0)}) {
            printLayout(layout, av_get_channel_layout_nb_channels(layout))
        }
    }
    
    static func printLayout(_ layout: UInt64, _ channelCount: Int32) {
        
        let layoutString = UnsafeMutablePointer<Int8>.allocate(capacity: 100)
        av_get_channel_layout_string(layoutString, 100, channelCount, layout)
        
        var channelNames: [String] = []
        for index in 0..<channelCount {
            channelNames.append(String(cString: av_get_channel_name(av_channel_layout_extract_channel(UInt64(layout), index))))
        }
        
        let ls = String(cString: layoutString)
        let ffLay = channelNames.joined(separator: " ")
        let avfLay = AVFLayout(ffLay)
        
        print("\nLayout:", layout, ls, ffLay)
        print("AVF Layout:", avfLay)
    }
    
    static func AVFLayout(_ lyt: String) -> String {
        
        return lyt
            .replacingOccurrences(of: "BL", with: "Rls")
            .replacingOccurrences(of: "BR", with: "Rrs")
            .replacingOccurrences(of: "BC", with: "Cs")
            .replacingOccurrences(of: "SL", with: "Ls")
            .replacingOccurrences(of: "SR", with: "Rs")
            .replacingOccurrences(of: "FLC", with: "Lc")
            .replacingOccurrences(of: "FRC", with: "Rc")
            .replacingOccurrences(of: "FL", with: "L")
            .replacingOccurrences(of: "FR", with: "R")
            .replacingOccurrences(of: "FC", with: "C")
        
    }
}
