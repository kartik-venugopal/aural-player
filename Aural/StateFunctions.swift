import Foundation

typealias EffectsUnitStateFunction = () -> EffectsUnitState

let graph = ObjectGraph.getAudioGraphDelegate()
let recorder = ObjectGraph.getRecorderDelegate()

let masterStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.masterUnit.state}
let eqStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.eqUnit.state}
let pitchStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.pitchUnit.state}
let timeStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.timeUnit.state}
let reverbStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.reverbUnit.state}
let delayStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.delayUnit.state}
let filterStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.filterUnit.state}

let recorderStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return recorder.isRecording() ? .active : .bypassed}
