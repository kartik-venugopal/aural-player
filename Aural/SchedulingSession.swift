/*
    Represents one buffer scheduling session. It can have one of three states:
 
    1 - Scheduling and playback ongoing
 
    This is the initial state, and indicates that buffer scheduling and playback are to continue normally.
 
    2 - Scheduling completed, playback ongoing
 
    This occurs when the end of file (EOF) is encountered when scheduling a buffer. This indicates that no more scheduling is to be done. However, this does not affect playback, which continues normally.
 
    3 - Scheduling completed, playback completed
 
    This occurs when the last buffer has finished playing back. Both scheduling and playback are stopped, and observers are notified of playback completion.
 
    -------------------------
 
    Note that, because of the look ahead scheduling algorithm, the EOF will be reached a few seconds before playback actually completes. This is state 2. Then, playback completes, and that is the terminal state 3.
 
 */

import Foundation

class SchedulingSession {
    
    var schedulingCompleted: Bool = false
    var playbackCompleted: Bool = false
}
