
import Cocoa
import AVFoundation

/*
    Provides convenient helper methods to work with AVAudioEngine
*/
class AudioEngineHelper {
    
    fileprivate let audioEngine: AVAudioEngine
    fileprivate var nodes: [AVAudioNode]
    
    init(engine: AVAudioEngine) {
        self.audioEngine = engine
        nodes = [AVAudioNode]()
    }
    
    // Attach a single node to the engine
    func addNode(_ node: AVAudioNode) {
        nodes.append(node)
        audioEngine.attach(node)
    }
    
    // Attach multiple nodes to the engine
    func addNodes(_ nodes: [AVAudioNode]) {
        self.nodes.append(contentsOf: nodes)
        for node in nodes {
            audioEngine.attach(node)
        }
    }
    
    // Connects all nodes in sequence
    func connectNodes() {
        
        var input: AVAudioNode, output: AVAudioNode
        
        // At least 2 nodes required for this to work
        if (nodes.count >= 2) {
            for i in 0...nodes.count - 2 {
                
                input = nodes[i]
                output = nodes[i + 1]
                
                audioEngine.connect(input, to: output, format: nil)
            }
        }
        
        audioEngine.connect(nodes[nodes.count - 1], to: audioEngine.mainMixerNode, format: nil)
    }
    
    // Reconnects two nodes with the given audio format (required when a track change occurs)
    func reconnectNodes(_ inputNode: AVAudioNode, outputNode: AVAudioNode, format: AVAudioFormat) {
        
        audioEngine.disconnectNodeOutput(inputNode)
        audioEngine.connect(inputNode, to: outputNode, format: format)
    }
    
    func prepareAndStart() {
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch let error as NSError {
            NSLog("Error starting audio engine: %@", error.description)
        }
    }
}
