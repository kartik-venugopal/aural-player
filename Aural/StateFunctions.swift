import Foundation

let graph = ObjectGraph.getAudioGraphDelegate()

let pitchStateFunction: EffectsUnitStateFunction = {() -> EffectsUnitState in return graph.pitchUnit.state}
