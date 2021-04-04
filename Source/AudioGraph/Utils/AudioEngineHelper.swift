import Cocoa
import AVFoundation

/*
    Provides convenient helper methods to work with AVAudioEngine
*/
class AudioEngineHelper {
    
    private let audioEngine: AVAudioEngine
    private var nodes: [AVAudioNode]
    
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
        if nodes.count >= 2 {
            
            for i in 0...nodes.count - 2 {
                
                input = nodes[i]
                output = nodes[i + 1]
                
                audioEngine.connect(input, to: output, format: nil)
            }
        }
        
        // Connect last node to main mixer
        audioEngine.connect(nodes.last!, to: audioEngine.mainMixerNode, format: nil)
    }
    
    func insertNode(_ node: AVAudioNode) {
        
        if let lastNode = nodes.last {
            
            let connectionFormat = lastNode.outputFormat(forBus: 0)
            audioEngine.disconnectNodeOutput(lastNode)
            
            addNode(node)
            
            audioEngine.connect(lastNode, to: node, format: connectionFormat)
            audioEngine.connect(node, to: audioEngine.mainMixerNode, format: nil)
        }
    }
    
    // Reconnects two nodes with the given audio format (required when a track change occurs)
    func reconnectNodes(_ inputNode: AVAudioNode, outputNode: AVAudioNode, format: AVAudioFormat) {
        
        audioEngine.disconnectNodeOutput(inputNode)
        audioEngine.connect(inputNode, to: outputNode, format: format)
    }
    
    func prepareAndStart() {
        
        audioEngine.prepare()
        start()
    }
    
    func start() {
        do {
            try audioEngine.start()
        } catch let error as NSError {
            NSLog("Error starting audio engine: %@", error.description)
        }
    }
    
    // TODO: AudioGraph should also respond to this notification and set its _outputDevice var to the new device
    func restart() {
        
        // Disconnect and detach nodes (in this order)
        nodes.forEach({
            audioEngine.disconnectNodeOutput($0)
            audioEngine.disconnectNodeInput($0)
            audioEngine.detach($0)
        })
        
        let nodesCopy = nodes
        nodes.removeAll()
        
        // Attach them back and reconnect them
        addNodes(nodesCopy)
        connectNodes()
        start()
    }
}
