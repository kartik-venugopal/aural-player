//import AVFoundation
//
//let file = URL(fileURLWithPath: "/Users/kven/Music/03_Oolaa.mp3")
//
//ObjectGraph.initialize()
//let player = ObjectGraph.getAG().playerNode
//
//var avFile: AVAudioFile? = nil
//do {
//    try avFile = AVAudioFile(forReading: file)
//} catch let error as NSError {
//}
//
//let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: avFile!.processingFormat, frameCapacity: AVAudioFrameCount(Double(10) * avFile!.processingFormat.sampleRate))
//
//do {
//    try avFile!.read(into: buffer)
//} catch let error as NSError {
//    
//}
//
//let tim = TimerUtils.start("copy")
//
//let copy: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: avFile!.processingFormat, frameCapacity: AVAudioFrameCount(Double(10) * avFile!.processingFormat.sampleRate))
//
//print("FL:", buffer.frameLength)
//
//let numChannels = Int(avFile!.processingFormat.channelCount)
//let sampleRate = avFile!.processingFormat.sampleRate
//let seconds = 8
//let offset = AVAudioFrameCount(seconds * sampleRate)
//
//for c in 0..<numChannels {
//    
//    let srcData = buffer.floatChannelData?.advanced(by: c).pointee
//    let destData = copy.floatChannelData?.advanced(by: c).pointee
//    
//    for i in offset..<buffer.frameLength {
//        
//        let src = (srcData?.advanced(by: Int(i)).pointee)!
//        destData!.advanced(by: Int(i)).pointee = src
//    }
//}
//
//copy.frameLength = buffer.frameLength
//tim.end()
//
//TimerUtils.printStats()
//
//player.scheduleBuffer(copy, completionHandler: {print("Done !")})
//player.play()
//
//sleep(30)
