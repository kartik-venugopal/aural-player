import Cocoa
import AVFoundation

/*
    Provides convenient helper methods to work with AVAudioEngine
*/
class AudioEngineHelper {
    
    private let audioEngine: AVAudioEngine
    private var permanentNodes: [AVAudioNode]
    private var removableNodes: [AVAudioNode]
    
    init(engine: AVAudioEngine, permanentNodes: [AVAudioNode], removableNodes: [AVAudioNode]) {
        
        self.audioEngine = engine
        self.permanentNodes = permanentNodes
        self.removableNodes = removableNodes
        
        (permanentNodes + removableNodes).forEach {audioEngine.attach($0)}
    }
    
    // Connects all nodes in sequence
    func connectNodes() {
        
        let allNodes = permanentNodes + removableNodes
        
        var input: AVAudioNode, output: AVAudioNode
        
        // At least 2 nodes required for this to work
        if allNodes.count >= 2 {
            
            for i in 0...allNodes.count - 2 {
                
                input = allNodes[i]
                output = allNodes[i + 1]
                
                audioEngine.connect(input, to: output, format: nil)
            }
        }
        
        // Connect last node to main mixer
        audioEngine.connect(allNodes.last!, to: audioEngine.mainMixerNode, format: nil)
    }
    
    func insertNode(_ node: AVAudioNode) {
        
        let allNodes = permanentNodes + removableNodes
        
        if let lastNode = allNodes.last {
            
            audioEngine.disconnectNodeOutput(lastNode)
            
            removableNodes.append(node)
            audioEngine.attach(node)
            
            audioEngine.connect(lastNode, to: node, format: nil)
            audioEngine.connect(node, to: audioEngine.mainMixerNode, format: nil)
        }
    }
    
    // Assume indices are valid and sorted in descending order.
    // NOTE - Indices are relative to the number of audio units, not actual node indices.
    func removeNodes(_ descendingIndices: [Int]) {
        
        for index in descendingIndices {
        
            var previousNode: AVAudioNode = permanentNodes.last!
            var nextNode: AVAudioNode = audioEngine.mainMixerNode
            
            // Find the node previous to the node to be removed.
            if index > 0 {
                
                for previousIndex in stride(from: index - 1, to: -1, by: -1) {
                    
                    if !descendingIndices.contains(previousIndex) {
                        
                        previousNode = removableNodes[previousIndex]
                        break
                    }
                }
            }
            
            // Find the node next to the node to be removed.
            if index < removableNodes.lastIndex {
                
                for nextIndex in (index + 1)...removableNodes.lastIndex {
                    
                    if !descendingIndices.contains(nextIndex) {
                        
                        nextNode = removableNodes[nextIndex]
                        break
                    }
                }
            }
            
            // Sever the connections with the node to be removed.
            audioEngine.disconnectNodeOutput(previousNode)
            audioEngine.disconnectNodeInput(nextNode)
            
            // Connect the previous / next node together.
            audioEngine.connect(previousNode, to: nextNode, format: nil)
        }
        
        for index in descendingIndices {
            audioEngine.detach(removableNodes.remove(at: index))
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
        
        let allNodes = permanentNodes + removableNodes
        
        // Disconnect and detach nodes (in this order)
        allNodes.forEach {
            
            audioEngine.disconnectNodeOutput($0)
            audioEngine.disconnectNodeInput($0)
            audioEngine.detach($0)
        }
        
        // Attach them back and reconnect them
        allNodes.forEach {audioEngine.attach($0)}
        connectNodes()
        start()
    }
}
