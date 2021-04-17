import Cocoa

class MasterPresetView: MasterView {
    
    override func awakeFromNib() {
        
        buttons = [btnEQBypass, btnPitchBypass, btnTimeBypass, btnReverbBypass, btnDelayBypass, btnFilterBypass]
        images = [imgEQBypass, imgPitchBypass, imgTimeBypass, imgReverbBypass, imgDelayBypass, imgFilterBypass]
        labels = [lblEQ, lblPitch, lblTime, lblReverb, lblDelay, lblFilter]
    }
}
