import Foundation

let graph = ObjectGraph.getAudioGraphDelegate()

let eqStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.eqUnit.state}
let pitchStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.pitchUnit.state}
let timeStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.timeUnit.state}
let reverbStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.reverbUnit.state}
