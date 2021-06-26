//
//  ControlBarModeSeekSliderView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class ControlBarModeSeekSliderView: SeekSliderView {
 
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        seekSlider.redraw()
    }
}
