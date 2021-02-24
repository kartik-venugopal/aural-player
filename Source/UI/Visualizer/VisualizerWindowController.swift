import Cocoa
import AVFoundation

let visualizationAnalysisBufferSize: Int = 2048

class VisualizerWindowController: NSWindowController, AudioGraphRenderObserverProtocol, NSWindowDelegate {
    
    override var windowNibName: String? {return "Visualizer"}
    
    @IBOutlet weak var containerBox: VisualizerContainer!
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var spectrogram: Spectrogram!
    @IBOutlet weak var supernova: Supernova!
    @IBOutlet weak var discoBall: DiscoBall!
    
    @IBOutlet weak var typeMenuButton: NSPopUpButton!
    @IBOutlet weak var typeMenu: NSMenu!
    @IBOutlet weak var spectrogramMenuItem: NSMenuItem!
    @IBOutlet weak var supernovaMenuItem: NSMenuItem!
    @IBOutlet weak var discoBallMenuItem: NSMenuItem!

    @IBOutlet weak var optionsBox: NSBox!
    
    @IBOutlet weak var startColorPicker: NSColorWell!
    @IBOutlet weak var endColorPicker: NSColorWell!
    
//    @IBOutlet weak var lblBands: NSTextField!
//    @IBOutlet weak var bandsMenu: NSPopUpButton!
    
    var vizView: VisualizerViewProtocol!
    var allViews: [VisualizerViewProtocol] = []
    private let fft: FFT = ObjectGraph.fft
    private var audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    override func awakeFromNib() {
        
        window?.delegate = self
        window?.isMovableByWindowBackground = true
        window?.aspectRatio = NSSize(width: 3.0, height: 2.0)
        
        [spectrogram, supernova, discoBall].forEach {$0?.anchorToView($0!.superview!)}
        
        spectrogramMenuItem.representedObject = VisualizationType.spectrogram
        supernovaMenuItem.representedObject = VisualizationType.supernova
        discoBallMenuItem.representedObject = VisualizationType.discoBall
        
        NotificationCenter.default.addObserver(forName: Notification.Name("showOptions"), object: nil, queue: nil, using: {_ in
            
//            if let theVizView = self.vizView, theVizView.type == .spectrogram {
//                NSView.showViews(self.lblBands, self.bandsMenu)
//
//            } else {
//                NSView.hideViews(self.lblBands, self.bandsMenu)
//            }
            
            self.optionsBox.show()
        })
        
        NotificationCenter.default.addObserver(forName: Notification.Name("hideOptions"), object: nil, queue: nil, using: {_ in
            self.optionsBox.hide()
        })
        
        allViews = [spectrogram, supernova, discoBall]
    }
    
    override func showWindow(_ sender: Any?) {
        
        super.showWindow(sender)
        
        audioGraph.outputDeviceBufferSize = visualizationAnalysisBufferSize
        fft.setUp(sampleRate: Float(audioGraph.outputDeviceSampleRate), bufferSize: audioGraph.outputDeviceBufferSize)
     
        containerBox.startTracking()
        initUI(type: VisualizerViewState.type, lowAmplitudeColor: VisualizerViewState.options.lowAmplitudeColor, highAmplitudeColor: VisualizerViewState.options.highAmplitudeColor)
        
        audioGraph.registerRenderObserver(self)
    }
    
    private func initUI(type: VisualizationType, lowAmplitudeColor: NSColor, highAmplitudeColor: NSColor) {
        
        changeType(type)
        vizView.setColors(startColor: lowAmplitudeColor, endColor: highAmplitudeColor)
        
        for item in typeMenu.items {
            
            if let representedType = item.representedObject as? VisualizationType, representedType == type {
                typeMenuButton.select(item)
            }
        }
        
        startColorPicker.color = lowAmplitudeColor
        endColorPicker.color = highAmplitudeColor
        
        [spectrogram, supernova, discoBall].forEach {
            
            if $0 !== (vizView as! NSView) {
                ($0 as? VisualizerViewProtocol)?.setColors(startColor: lowAmplitudeColor, endColor: highAmplitudeColor)
            }
        }
    }
    
    @IBAction func changeTypeAction(_ sender: NSPopUpButton) {
        
        if let vizType = sender.selectedItem?.representedObject as? VisualizationType {
            changeType(vizType)
        }
    }
    
    func changeType(_ type: VisualizationType) {
        
        vizView?.dismissView()
        vizView = nil
        
        VisualizerViewState.type = type
        
        switch type {

        case .spectrogram:      spectrogram.presentView(with: fft)
                                vizView = spectrogram
                                tabView.selectTabViewItem(at: 0)

        case .supernova:        supernova.presentView(with: fft)
                                vizView = supernova
                                tabView.selectTabViewItem(at: 1)

        case .discoBall:        discoBall.presentView(with: fft)
                                vizView = discoBall
                                tabView.selectTabViewItem(at: 2)
        }
    }
    
    func rendered(timeStamp: AudioTimeStamp, frameCount: UInt32, audioBuffer: AudioBufferList) {
        
        if let theVizView = vizView {
            
            fft.analyze(audioBuffer)
            
            DispatchQueue.main.async {
                theVizView.update(with: self.fft)
            }
        }
    }
    
    func deviceChanged(newDeviceBufferSize: Int, newDeviceSampleRate: Double) {
        
        if newDeviceBufferSize != visualizationAnalysisBufferSize {
            audioGraph.outputDeviceBufferSize = visualizationAnalysisBufferSize
        }
    }
    
    @IBAction func setColorsAction(_ sender: NSColorWell) {
        
        vizView.setColors(startColor: startColorPicker.color, endColor: endColorPicker.color)
        
        [spectrogram, supernova, discoBall].forEach {
            
            if $0 !== (vizView as! NSView) {
                ($0 as? VisualizerViewProtocol)?.setColors(startColor: startColorPicker.color, endColor: endColorPicker.color)
            }
        }
        
        VisualizerViewState.options.setColors(lowAmplitudeColor: startColorPicker.color, highAmplitudeColor: endColorPicker.color)
    }
    
    @IBAction func closeWindowAction(_ sender: Any) {
        close()
    }
    
    override func close() {
        
        super.close()
        
        vizView = nil
        
        audioGraph.removeRenderObserver(self)
        fft.deallocate()

        containerBox.stopTracking()
        optionsBox.hide()
        
        allViews.forEach {$0.dismissView()}
    }
    
    // TODO
    func deviceSampleRateChanged(newSampleRate: Double) {
        NSLog("**** Device SR changed: \(newSampleRate)")
    }
    
    //    @IBAction func changeNumberOfBandsAction(_ sender: NSPopUpButton) {
    //
    //        let numBands = sender.selectedTag()
    //
    //        if numBands > 0 {
    //            spectrogram.numberOfBands = numBands
    //        }
    //    }
}

enum VisualizationType: String, CaseIterable {
    
    case spectrogram, supernova, discoBall
}

class VisualizerViewOptions {
    
    var lowAmplitudeColor: NSColor = .blue
    var highAmplitudeColor: NSColor = .red
    
    func setColors(lowAmplitudeColor: NSColor, highAmplitudeColor: NSColor) {
        
        self.lowAmplitudeColor = lowAmplitudeColor
        self.highAmplitudeColor = highAmplitudeColor
    }
}

class VisualizerViewState {
    
    static var type: VisualizationType = .spectrogram
    static var options: VisualizerViewOptions = VisualizerViewOptions()
}
