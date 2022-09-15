//
//  MarkLastPlaybackPositionAction.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class MarkLastPlaybackPositionAction: PlaybackChainAction {
    
    // TODO: Find a way to pass this in without a circular dependency problem (PlaybackDelegate <-> HistoryDelegate).
    lazy var history: HistoryDelegateProtocol = objectGraph.historyDelegate
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        history.markLastPlaybackPosition(context.currentSeekPosition)
        chain.proceed(context)
    }
}
