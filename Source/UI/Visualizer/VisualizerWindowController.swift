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
    
    @IBOutlet weak var typeMenu: NSMenu!
    @IBOutlet weak var spectrogramMenuItem: NSMenuItem!
    @IBOutlet weak var supernovaMenuItem: NSMenuItem!
    @IBOutlet weak var discoBallMenuItem: NSMenuItem!

    @IBOutlet weak var optionsBox: NSBox!
    
    @IBOutlet weak var startColorPicker: NSColorWell!
    @IBOutlet weak var endColorPicker: NSColorWell!
    
    @IBOutlet weak var lblBands: NSTextField!
    @IBOutlet weak var bandsMenu: NSPopUpButton!
    
    var vizView: VisualizerViewProtocol!
    var allViews: [VisualizerViewProtocol] = []
    private let fft: FFT = ObjectGraph.fft
    private var audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    override func awakeFromNib() {
        
        window?.delegate = self
        window?.isMovableByWindowBackground = true
        window?.aspectRatio = NSSize(width: 3.0, height: 2.0)
        
        [spectrogram, supernova, discoBall].forEach {$0?.anchorToView($0!.superview!)}
        
//        FrequencyData.numBands = 27
//        spectrogram.numberOfBands = 27
        
        spectrogramMenuItem.representedObject = VisualizationType.spectrogram
        supernovaMenuItem.representedObject = VisualizationType.supernova
        discoBallMenuItem.representedObject = VisualizationType.discoBall
        
        NotificationCenter.default.addObserver(forName: Notification.Name("showOptions"), object: nil, queue: nil, using: {_ in
            
            if let theVizView = self.vizView, theVizView.type == .spectrogram {
                NSView.showViews(self.lblBands, self.bandsMenu)
                
            } else {
                NSView.hideViews(self.lblBands, self.bandsMenu)
            }
            
            self.optionsBox.show()
        })
        
        NotificationCenter.default.addObserver(forName: Notification.Name("hideOptions"), object: nil, queue: nil, using: {_ in
            self.optionsBox.hide()
        })
        
        allViews = [spectrogram, supernova, discoBall]
//        allViews = [spectrogram, supernova]
    }
    
    override func showWindow(_ sender: Any?) {
        
        super.showWindow(sender)
        
        audioGraph.outputDeviceBufferSize = visualizationAnalysisBufferSize
        fft.setUp(sampleRate: Float(audioGraph.outputDeviceSampleRate), bufferSize: audioGraph.outputDeviceBufferSize)
     
        containerBox.startTracking()
        changeType(VisualizerUIState.type)
        
        audioGraph.registerRenderObserver(self)
    }
    
    @IBAction func changeTypeAction(_ sender: NSPopUpButton) {
        
        if let vizType = sender.selectedItem?.representedObject as? VisualizationType {
            changeType(vizType)
        }
    }
    
    func changeType(_ type: VisualizationType) {
        
        vizView = nil
        allViews.forEach {$0.dismissView()}
        
        VisualizerUIState.type = type
        
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
    
    @IBAction func fullScreenAction(_ sender: Any) {
        
        // TODO: Figure out which screen the window is on (more). And use that screen.
        
        if let screenFrame = NSScreen.main?.visibleFrame {
            window?.setFrame(screenFrame, display: true)
        }
    }
    
    @IBAction func closeWindowAction(_ sender: Any) {
        close()
    }
    
    override func close() {
        
        super.close()
        
        vizView = nil
        allViews.forEach {$0.dismissView()}
        
        audioGraph.removeRenderObserver(self)
        fft.deallocate()

        containerBox.stopTracking()
        optionsBox.hide()
        
        allViews.forEach {$0.dismissView()}
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
    
    // TODO
    func deviceSampleRateChanged(newSampleRate: Double) {
        NSLog("**** Device SR changed: \(newSampleRate)")
    }
    
    @IBAction func changeNumberOfBandsAction(_ sender: NSPopUpButton) {
        
        let numBands = sender.selectedTag()
        
        if numBands > 0 {
            spectrogram.numberOfBands = numBands
        }
    }
    
    @IBAction func setColorsAction(_ sender: NSColorWell) {
        
        vizView.setColors(startColor: self.startColorPicker.color, endColor: self.endColorPicker.color)
        
        [spectrogram, supernova, discoBall].forEach {
            
            if $0 !== (vizView as! NSView) {
                ($0 as? VisualizerViewProtocol)?.setColors(startColor: self.startColorPicker.color, endColor: self.endColorPicker.color)
            }
        }
    }
}

enum VisualizationType {
    
    case spectrogram, supernova, discoBall
}

class VisualizerContainer: NSBox {
    
    override func viewDidEndLiveResize() {
        
        super.viewDidEndLiveResize()
        
        self.removeAllTrackingAreas()
        self.updateTrackingAreas()
        
        NotificationCenter.default.post(name: Notification.Name("hideOptions"), object: nil)
    }
    
    // Signals the view to start tracking mouse movements.
    func startTracking() {
        
        self.removeAllTrackingAreas()
        self.updateTrackingAreas()
    }
    
    // Signals the view to stop tracking mouse movements.
    func stopTracking() {
        self.removeAllTrackingAreas()
    }
    
    override func updateTrackingAreas() {
        
        // Create a tracking area that covers the bounds of the view. It should respond whenever the mouse enters or exits.
        addTrackingArea(NSTrackingArea(rect: self.bounds, options: [NSTrackingArea.Options.activeAlways, NSTrackingArea.Options.mouseEnteredAndExited], owner: self, userInfo: nil))
        
        super.updateTrackingAreas()
    }
    
    override func mouseEntered(with event: NSEvent) {
        NotificationCenter.default.post(name: Notification.Name("showOptions"), object: nil)
    }
    
    override func mouseExited(with event: NSEvent) {
        NotificationCenter.default.post(name: Notification.Name("hideOptions"), object: nil)
    }
}

class VisualizerViewOptions {
    
    var lowAmplitudeColor: NSColor = .blue
    var highAmplitudeColor: NSColor = .red
    
    func setColors(startColor: NSColor, endColor: NSColor) {
        
    }
}

class SpectrogramOptions: VisualizerViewOptions {
    
    var numberOfBands: Int = 10
}

class SupernovaOptions: VisualizerViewOptions {}

class DiscoBallOptions: VisualizerViewOptions {}

class VisualizerUIState {
    
    static var type: VisualizationType = .spectrogram
    static var options: VisualizerViewOptions = SpectrogramOptions()
}
