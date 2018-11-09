import Foundation

let graph = ObjectGraph.getAudioGraphDelegate()

let eqStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.eqUnit.state}
let pitchStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.pitchUnit.state}
