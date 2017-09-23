//import Foundation
////
////let file = URL(fileURLWithPath: "/Users/kven/Music/03_Oolaa.mp3")
////
////ObjectGraph.initialize()
////let player = ObjectGraph.getAG().playerNode
////
////var audioFile: AVAudioFile? = nil
////do {
////    try audioFile = AVAudioFile(forReading: file)
////} catch let error as NSError {
////}
////
////let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: audioFile!.processingFormat, frameCapacity: AVAudioFrameCount(Double(5) * audioFile!.processingFormat.sampleRate))
////
////do {
////    try audioFile!.read(into: buffer)
////} catch let error as NSError {
////}
////
////buffer.mutableAudioBufferList.pointee.mBuffers.mData = buffer.audioBufferList.pointee.mBuffers.mData?.advanced(by: (44100 * 3))
////
////print("FL:", buffer.frameLength)
////
////player.volume = 0.3
////player.scheduleBuffer(buffer, completionHandler: {print("Done !")})
////player.play()
////
////print("Playing !")
////
////sleep(10)
//
//let s1 = "Muthu"
//let s2 = "Muthusami"
//let s3 = "sami"
//
//print(s1.contains(s2))
//print(s2.contains(s1))
//print(s2.contains(s3))
//print(s1.contains(s3))
