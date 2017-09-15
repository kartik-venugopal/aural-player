//////
//////  main.swift
//////  Aural
//////
//////  Created by Kay Ven on 9/13/17.
//////  Copyright © 2017 Anonymous. All rights reserved.
//////
////
//import Foundation
//import AVFoundation
////
//let mapFP = "/Users/kven/Documents/itunes.txt"
////
//let mapStr = try String(contentsOfFile: mapFP)
//let mapLines = mapStr.components(separatedBy: .newlines)
//
////for line in mapLines {
////
////    let tokens = line.components(separatedBy: " ")
////
////    if (tokens.count > 2) {
////        
////        let key = tokens[2].replacingOccurrences(of: ":", with: "", options: .literal, range: nil)
////        var desc = key.replacingOccurrences(of: "AVMetadataiTunesMetadataKey", with: "", options: .literal, range: nil)
////        desc = Utils.splitCamelCaseWord(desc, true)
////        
////        print(String(format: "arr.append((\"%@\", %@, \"%@\"))", key, key, desc))
////    }
////}
//
//var arr: [(k: String, v: String, d: String)] = [(String, String, String)]()
//
//arr.append(("AVMetadataiTunesMetadataKeyAlbum", AVMetadataiTunesMetadataKeyAlbum, "Album"))
//arr.append(("AVMetadataiTunesMetadataKeyArtist", AVMetadataiTunesMetadataKeyArtist, "Artist"))
//arr.append(("AVMetadataiTunesMetadataKeyUserComment", AVMetadataiTunesMetadataKeyUserComment, "User Comment"))
//arr.append(("AVMetadataiTunesMetadataKeyCoverArt", AVMetadataiTunesMetadataKeyCoverArt, "Cover Art"))
//arr.append(("AVMetadataiTunesMetadataKeyCopyright", AVMetadataiTunesMetadataKeyCopyright, "Copyright"))
//arr.append(("AVMetadataiTunesMetadataKeyReleaseDate", AVMetadataiTunesMetadataKeyReleaseDate, "Release Date"))
//arr.append(("AVMetadataiTunesMetadataKeyEncodedBy", AVMetadataiTunesMetadataKeyEncodedBy, "Encoded By"))
//arr.append(("AVMetadataiTunesMetadataKeyPredefinedGenre", AVMetadataiTunesMetadataKeyPredefinedGenre, "Predefined Genre"))
//arr.append(("AVMetadataiTunesMetadataKeyUserGenre", AVMetadataiTunesMetadataKeyUserGenre, "User Genre"))
//arr.append(("AVMetadataiTunesMetadataKeySongName", AVMetadataiTunesMetadataKeySongName, "Song Name"))
//arr.append(("AVMetadataiTunesMetadataKeyTrackSubTitle", AVMetadataiTunesMetadataKeyTrackSubTitle, "Track Sub Title"))
//arr.append(("AVMetadataiTunesMetadataKeyEncodingTool", AVMetadataiTunesMetadataKeyEncodingTool, "Encoding Tool"))
//arr.append(("AVMetadataiTunesMetadataKeyComposer", AVMetadataiTunesMetadataKeyComposer, "Composer"))
//arr.append(("AVMetadataiTunesMetadataKeyAlbumArtist", AVMetadataiTunesMetadataKeyAlbumArtist, "Album Artist"))
//arr.append(("AVMetadataiTunesMetadataKeyAccountKind", AVMetadataiTunesMetadataKeyAccountKind, "Account Kind"))
//arr.append(("AVMetadataiTunesMetadataKeyAppleID", AVMetadataiTunesMetadataKeyAppleID, "Apple I D"))
//arr.append(("AVMetadataiTunesMetadataKeyArtistID", AVMetadataiTunesMetadataKeyArtistID, "Artist I D"))
//arr.append(("AVMetadataiTunesMetadataKeySongID", AVMetadataiTunesMetadataKeySongID, "Song I D"))
//arr.append(("AVMetadataiTunesMetadataKeyDiscCompilation", AVMetadataiTunesMetadataKeyDiscCompilation, "Disc Compilation"))
//arr.append(("AVMetadataiTunesMetadataKeyDiscNumber", AVMetadataiTunesMetadataKeyDiscNumber, "Disc Number"))
//arr.append(("AVMetadataiTunesMetadataKeyGenreID", AVMetadataiTunesMetadataKeyGenreID, "Genre I D"))
//arr.append(("AVMetadataiTunesMetadataKeyGrouping", AVMetadataiTunesMetadataKeyGrouping, "Grouping"))
//arr.append(("AVMetadataiTunesMetadataKeyPlaylistID", AVMetadataiTunesMetadataKeyPlaylistID, "Playlist I D"))
//arr.append(("AVMetadataiTunesMetadataKeyContentRating", AVMetadataiTunesMetadataKeyContentRating, "Content Rating"))
//arr.append(("AVMetadataiTunesMetadataKeyBeatsPerMin", AVMetadataiTunesMetadataKeyBeatsPerMin, "Beats Per Min"))
//arr.append(("AVMetadataiTunesMetadataKeyTrackNumber", AVMetadataiTunesMetadataKeyTrackNumber, "Track Number"))
//arr.append(("AVMetadataiTunesMetadataKeyArtDirector", AVMetadataiTunesMetadataKeyArtDirector, "Art Director"))
//arr.append(("AVMetadataiTunesMetadataKeyArranger", AVMetadataiTunesMetadataKeyArranger, "Arranger"))
//arr.append(("AVMetadataiTunesMetadataKeyAuthor", AVMetadataiTunesMetadataKeyAuthor, "Author"))
//arr.append(("AVMetadataiTunesMetadataKeyLyrics", AVMetadataiTunesMetadataKeyLyrics, "Lyrics"))
//arr.append(("AVMetadataiTunesMetadataKeyAcknowledgement", AVMetadataiTunesMetadataKeyAcknowledgement, "Acknowledgement"))
//arr.append(("AVMetadataiTunesMetadataKeyConductor", AVMetadataiTunesMetadataKeyConductor, "Conductor"))
//arr.append(("AVMetadataiTunesMetadataKeyDescription", AVMetadataiTunesMetadataKeyDescription, "Description"))
//arr.append(("AVMetadataiTunesMetadataKeyDirector", AVMetadataiTunesMetadataKeyDirector, "Director"))
//arr.append(("AVMetadataiTunesMetadataKeyEQ", AVMetadataiTunesMetadataKeyEQ, "E Q"))
//arr.append(("AVMetadataiTunesMetadataKeyLinerNotes", AVMetadataiTunesMetadataKeyLinerNotes, "Liner Notes"))
//arr.append(("AVMetadataiTunesMetadataKeyRecordCompany", AVMetadataiTunesMetadataKeyRecordCompany, "Record Company"))
//arr.append(("AVMetadataiTunesMetadataKeyOriginalArtist", AVMetadataiTunesMetadataKeyOriginalArtist, "Original Artist"))
//arr.append(("AVMetadataiTunesMetadataKeyPhonogramRights", AVMetadataiTunesMetadataKeyPhonogramRights, "Phonogram Rights"))
//arr.append(("AVMetadataiTunesMetadataKeyProducer", AVMetadataiTunesMetadataKeyProducer, "Producer"))
//arr.append(("AVMetadataiTunesMetadataKeyPerformer", AVMetadataiTunesMetadataKeyPerformer, "Performer"))
//arr.append(("AVMetadataiTunesMetadataKeyPublisher", AVMetadataiTunesMetadataKeyPublisher, "Publisher"))
//arr.append(("AVMetadataiTunesMetadataKeySoundEngineer", AVMetadataiTunesMetadataKeySoundEngineer, "Sound Engineer"))
//arr.append(("AVMetadataiTunesMetadataKeySoloist", AVMetadataiTunesMetadataKeySoloist, "Soloist"))
//arr.append(("AVMetadataiTunesMetadataKeyCredits", AVMetadataiTunesMetadataKeyCredits, "Credits"))
//arr.append(("AVMetadataiTunesMetadataKeyThanks", AVMetadataiTunesMetadataKeyThanks, "Thanks"))
//arr.append(("AVMetadataiTunesMetadataKeyOnlineExtras", AVMetadataiTunesMetadataKeyOnlineExtras, "Online Extras"))
//arr.append(("AVMetadataiTunesMetadataKeyExecProducer", AVMetadataiTunesMetadataKeyExecProducer, "Exec Producer"))
//
//for item in arr {
//    
//    print("//", item.v)
//    print(String(format: "map[%@] = \"%@\"\n", item.k, item.d))
//}
