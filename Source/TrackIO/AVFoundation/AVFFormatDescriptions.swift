//
//  AVFFormatDescriptions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// A map that contains user-friendly (human readable) descriptions for each of the
/// supported AVFoundation audio formats.
///

let avfFormatDescriptions: [FourCharCode: String] = [
    
    kAudioFormatLinearPCM: "Linear PCM",
    kAudioFormatAC3: "AC-3",
    kAudioFormatEnhancedAC3: "Enhanced AC-3",
    kAudioFormat60958AC3: "IEC 60958 compliant AC-3",
    
    kAudioFormatAppleIMA4: "Apple IMA 4:1 ADPCM",
    
    kAudioFormatMPEG4AAC: "MPEG-4 AAC",
    kAudioFormatMPEG4AAC_HE: "MPEG-4 HE AAC",
    kAudioFormatMPEG4AAC_HE_V2: "MPEG-4 HE AAC Version 2",
    kAudioFormatMPEG4AAC_LD: "MPEG-4 LD AAC",
    kAudioFormatMPEG4AAC_ELD: "MPEG-4 ELD AAC",
    kAudioFormatMPEG4AAC_ELD_SBR: "MPEG-4 ELD AAC w/ SBR extension",
    kAudioFormatMPEG4AAC_ELD_V2: "MPEG-4 ELD AAC Version 2",
    kAudioFormatMPEG4AAC_Spatial: "MPEG-4 Spatial AAC",
    
    kAudioFormatMPEG4CELP: "MPEG-4 CELP",
    kAudioFormatMPEG4HVXC: "MPEG-4 HVXC",
    kAudioFormatMPEG4TwinVQ: "MPEG-4 TwinVQ",
    
    kAudioFormatMACE3: "MACE 3:1",
    kAudioFormatMACE6: "MACE 6:1",
    
    kAudioFormatULaw: "µLaw 2:1",
    kAudioFormatALaw: "aLaw 2:1",
    
    kAudioFormatQDesign: "QDesign music",
    kAudioFormatQDesign2: "QDesign2 music",
    
    kAudioFormatQUALCOMM: "QUALCOMM PureVoice",
    
    kAudioFormatMPEGLayer1: "MP1 (MPEG-1/2 Layer 1)",
    kAudioFormatMPEGLayer2: "MP2 (MPEG-1/2 Layer 2)",
    kAudioFormatMPEGLayer3: "MP3 (MPEG-1/2 Layer 3)",

    kAudioFormatTimeCode: "IO Audio",
    
    kAudioFormatMIDIStream: "MIDI",
    
    kAudioFormatParameterValueStream: "Audio Unit Parameter Value Stream",
    
    kAudioFormatAppleLossless: "Apple Lossless",
    
    kAudioFormatMPEGD_USAC: "MPEG-D USAC",
    
    kAudioFormatAMR: "AMR Narrow Band",
    kAudioFormatAMR_WB: "AMR Wide Band",
    
    kAudioFormatAudible: "Audible",
    
    kAudioFormatiLBC: "iLBC",
    
    kAudioFormatDVIIntelIMA: "DVI/Intel IMA ADPCM",
    
    kAudioFormatMicrosoftGSM: "Microsoft GSM 6.10",
    
    kAudioFormatAES3: "AES3-2003",
    
    kAudioFormatFLAC: "FLAC",
    
    kAudioFormatOpus: "Opus"
]
