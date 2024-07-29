//
//  FFmpegChannelLayout.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

struct FFmpegChannelLayout {
    
    let avChannelLayout: AVChannelLayout
    let numberOfChannels: Int32
    let mask: UInt64
    let avfLayout: AVAudioChannelLayout?
    
    lazy var description: String = {
       
        let layoutStringBuffer = UnsafeBuffer<Int8>(ofCapacity: 100)
        
        withUnsafePointer(to: avChannelLayout) {ptr -> Void in
            av_channel_layout_describe(ptr, layoutStringBuffer.pointer, layoutStringBuffer.capacity)
        }
        
        return String(cString: layoutStringBuffer.pointer).replacingOccurrences(of: "(", with: " (").capitalized
    }()
    
    init(avChannelLayout: AVChannelLayout) {
        
        self.avChannelLayout = avChannelLayout
        self.numberOfChannels = avChannelLayout.nb_channels
        self.mask = avChannelLayout.u.mask
        
        if let layoutTag = Self.layoutsMap[avChannelLayout] {
            self.avfLayout = AVAudioChannelLayout(layoutTag: layoutTag)
        } else {
            self.avfLayout = nil
        }
    }
    
    private static let layoutsMap: [AVChannelLayout: AudioChannelLayoutTag] = [
        
        // C
        AVChannelLayout_Mono: kAudioChannelLayoutTag_Mono,
        
        // L R
        AVChannelLayout_Stereo: kAudioChannelLayoutTag_Stereo,
        
        // L R
        AVChannelLayout_StereoDownmix: kAudioChannelLayoutTag_Stereo,
        
        // L R LFE
        AVChannelLayout_2Point1: kAudioChannelLayoutTag_WAVE_2_1,
        
        // L R Cs
        AVChannelLayout_2_1: kAudioChannelLayoutTag_DVD_2,
        
        // L R C
        AVChannelLayout_Surround: kAudioChannelLayoutTag_WAVE_3_0,
        
        // L R C LFE
        AVChannelLayout_3Point1: kAudioChannelLayoutTag_DVD_10,
        
        // L R C Cs
        AVChannelLayout_4Point0: kAudioChannelLayoutTag_DVD_8,
        
        // L R C LFE Cs
        AVChannelLayout_4Point1: kAudioChannelLayoutTag_DVD_11,
        
        // L R Ls Rs
        AVChannelLayout_2_2: kAudioChannelLayoutTag_Quadraphonic,
        
        // L R Rls Rrs
        AVChannelLayout_Quad: kAudioChannelLayoutTag_WAVE_4_0_B,
        
        // L R C Ls Rs
        AVChannelLayout_5Point0: kAudioChannelLayoutTag_WAVE_5_0_A,
        
        // L R C LFE Ls Rs
        AVChannelLayout_5Point1: kAudioChannelLayoutTag_WAVE_5_1_A,
        
        // L R C Rls Rrs
        AVChannelLayout_5Point0Back: kAudioChannelLayoutTag_WAVE_5_0_B,
        
        // L R C LFE Rls Rrs
        AVChannelLayout_5Point1Back: kAudioChannelLayoutTag_WAVE_5_1_B,
        
        // L R C LFE Cs Ls Rs
        AVChannelLayout_6Point1: kAudioChannelLayoutTag_WAVE_6_1,
        
        // L R C LFE Rls Rrs Ls Rs
        AVChannelLayout_7Point1: kAudioChannelLayoutTag_WAVE_7_1,
        
        // MARK: The following mappings are not exact, but the closest possible matches.
        // NOTE - Some channels may be dropped entirely.
        
        // L R C Cs Ls Rs -> L R C Cs
        AVChannelLayout_6Point0: kAudioChannelLayoutTag_DVD_6,
        
        // L R Lc Rc Ls Rs -> Lc Rc L R Ls Rs
        AVChannelLayout_6Point0Front: kAudioChannelLayoutTag_DTS_6_0_A,
        
        // L R C Rls Rrs Cs -> L R C Ls Rs
        AVChannelLayout_Hexagonal: kAudioChannelLayoutTag_WAVE_5_0_A,
        
        // L R C LFE Rls Rrs Cs -> L R C LFE Ls Rs Cs
        AVChannelLayout_6Point1Back: kAudioChannelLayoutTag_AudioUnit_6_1,
        
        // L R LFE Lc Rc Ls Rs -> L R LFE Ls Rs
        AVChannelLayout_6Point1Front: kAudioChannelLayoutTag_DVD_6,
        
        // L R C Rls Rrs Ls Rs -> L R C Rls Rrs
        AVChannelLayout_7Point0: kAudioChannelLayoutTag_WAVE_5_0_B,
        
        // L R C Lc Rc Ls Rs -> L R C Ls Rs
        AVChannelLayout_7Point0Front: kAudioChannelLayoutTag_WAVE_5_0_A,
        
        // L R C LFE Lc Rc Ls Rs -> L R C LFE Rls Rrs Ls Rs
        AVChannelLayout_7Point1Wide: kAudioChannelLayoutTag_WAVE_7_1,
        
        // L R C LFE Rls Rrs Lc Rc -> L R C LFE Rls Rrs Ls Rs
        AVChannelLayout_7Point1WideBack: kAudioChannelLayoutTag_WAVE_7_1,
        
        // L R C Rls Rrs Cs Ls Rs -> L R C Rls Rrs
        AVChannelLayout_Octagonal: kAudioChannelLayoutTag_WAVE_5_0_B,
        
        // L R C Rls Rrs Cs Ls Rs TL TC TR TRls TCs TRrs WL WR -> L R C Rls Rrs
        AVChannelLayout_Hexadecagonal: kAudioChannelLayoutTag_WAVE_5_0_B]
}

extension AVChannelLayout: Hashable {
    
    public static func == (lhs: AVChannelLayout, rhs: AVChannelLayout) -> Bool {
        lhs.u.mask == rhs.u.mask
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.u.mask)
    }
}

