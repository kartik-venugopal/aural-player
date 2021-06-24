//
//  FXPresets.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

protocol FXPresetsProtocol {
    
    associatedtype T: EffectsUnitPreset
    
    var userDefinedPresets: [T] {get}
    var systemDefinedPresets: [T] {get}
    
    func preset(named name: String) -> T?
    
    func deletePresets(named presetNames: [String])
    
    func renamePreset(named oldName: String, to newName: String)
    
    func addPreset(_ preset: T)
    
    func presetExists(named name: String) -> Bool
}

class FXPresets<T: EffectsUnitPreset>: MappedPresets<T>, FXPresetsProtocol {
}
