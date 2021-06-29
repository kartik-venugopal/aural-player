//
//  MenuBarSeekSliderView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

class MenuBarSeekSliderView: SeekSliderView {
    
    func stopUpdatingSeekPosition() {
        setSeekTimerState(false)
    }
    
    func resumeUpdatingSeekPosition() {
        
        updateSeekPosition()
        setSeekTimerState(true)
    }
}
