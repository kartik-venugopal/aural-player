/*
    Customizes the look and feel of all ticked horizontal sliders
 */

import Cocoa

class TickedSliderCell: HorizontalSliderCell {
    
    var tickVerticalSpacing: CGFloat {return 1}
    var tickWidth: CGFloat {return 2}
    var tickColor: NSColor {return Colors.sliderNotchColor}
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        super.drawBar(inside: aRect, flipped: flipped)
        
        let ticksCount = self.numberOfTickMarks
        
        if (ticksCount > 2) {
            
            for i in 1...ticksCount - 2 {
                drawTick(i, aRect)
            }
            
        } else if (ticksCount == 1) {
            drawTick(0, aRect)
        }
    }
    
    private func drawTick(_ index: Int, _ aRect: NSRect) {
        
        let tickMinY = aRect.minY + tickVerticalSpacing
        let tickMaxY = aRect.maxY - tickVerticalSpacing
        
        let tickRect = rectOfTickMark(at: index)
        let x = (tickRect.minX + tickRect.maxX) / 2
        
        GraphicsUtils.drawLine(tickColor, pt1: NSMakePoint(x, tickMinY), pt2: NSMakePoint(x, tickMaxY), width: tickWidth)
    }
    
    override func drawTickMarks() {
        // Do nothing (ticks are drawn in drawBar)
    }
}

class PanTickedSliderCell: TickedSliderCell {
    
    override var barRadius: CGFloat {return 1}
    override var knobWidth: CGFloat {return 7}
    override var knobRadius: CGFloat {return 0.5}
    override var knobHeightOutsideBar: CGFloat {return 1}
}

class EffectsTickedSliderCell: TickedSliderCell {
    
    override var barRadius: CGFloat {return 1.5}
    override var barInsetY: CGFloat {return -1}
    override var knobRadius: CGFloat {return 1}
    override var knobHeightOutsideBar: CGFloat {return 1}
    
    override var tickVerticalSpacing: CGFloat {return 1.5}
    override var tickWidth: CGFloat {return 1.5}
}
