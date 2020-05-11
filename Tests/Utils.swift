import Foundation

func executionTimeFor(_ task: () -> Void) -> Double {
    
    let startTime = CFAbsoluteTimeGetCurrent()
    task()
    return CFAbsoluteTimeGetCurrent() - startTime
}

func executeAfter(_ timeSeconds: Double, work: @escaping @convention(block) () -> Void) {
    
    let startTime = CFAbsoluteTimeGetCurrent()

    while CFAbsoluteTimeGetCurrent() < (startTime + timeSeconds) {usleep(100000)}
    
    work()
}
