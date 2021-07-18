//
//  VisualizerWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

class VisualizerWindowController: NSWindowController, NSWindowDelegate, AudioGraphRenderObserverProtocol, Destroyable {
    
    override var windowNibName: String? {"Visualizer"}
    
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
    
    var vizView: VisualizerViewProtocol!
    var allViews: [VisualizerViewProtocol] = []
    private lazy var fft: FFT = FFT()
    private var audioGraph: AudioGraphDelegateProtocol = objectGraph.audioGraphDelegate
    
    private var normalDeviceBufferSize: Int = 0
    
    private lazy var messenger = Messenger(for: self)
    
    private lazy var uiState: VisualizerUIState = objectGraph.visualizerUIState
    
    override func awakeFromNib() {
        
        window?.delegate = self
        window?.isMovableByWindowBackground = true
        window?.aspectRatio = NSSize(width: 3.0, height: 2.0)
        
        [spectrogram, supernova, discoBall].forEach {$0?.anchorToView($0!.superview!)}
        
        spectrogramMenuItem.representedObject = VisualizationType.spectrogram
        supernovaMenuItem.representedObject = VisualizationType.supernova
        discoBallMenuItem.representedObject = VisualizationType.discoBall
        
        allViews = [spectrogram, supernova, discoBall]
        
        messenger.subscribe(to: .visualizer_showOptions, handler: showOptions)
        messenger.subscribe(to: .visualizer_hideOptions, handler: hideOptions)
    }
    
    func destroy() {
        
        close()
        messenger.unsubscribeFromAll()
    }
    
    override func showWindow(_ sender: Any?) {
        
        super.showWindow(sender)
        
        normalDeviceBufferSize = audioGraph.outputDeviceBufferSize
        audioGraph.outputDeviceBufferSize = visualizationAnalysisBufferSize
        
        fft.setUp(sampleRate: Float(audioGraph.outputDeviceSampleRate), bufferSize: audioGraph.outputDeviceBufferSize)
     
        containerBox.startTracking()
        initUI(type: uiState.type, lowAmplitudeColor: uiState.options.lowAmplitudeColor,
               highAmplitudeColor: uiState.options.highAmplitudeColor)
        
        audioGraph.registerRenderObserver(self)
        
        window?.orderFront(self)
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
        
        uiState.type = type
        
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
    
    // TODO
    func deviceSampleRateChanged(newSampleRate: Double) {
//        NSLog("**** Device SR changed: \(newSampleRate)")
    }
    
    private func showOptions() {
        self.optionsBox.show()
    }
    
    private func hideOptions() {
        self.optionsBox.hide()
    }
    
    @IBAction func setColorsAction(_ sender: NSColorWell) {
        
        vizView.setColors(startColor: startColorPicker.color, endColor: endColorPicker.color)
        
        [spectrogram, supernova, discoBall].forEach {
            
            if $0 !== (vizView as! NSView) {
                
                ($0 as? VisualizerViewProtocol)?.setColors(startColor: startColorPicker.color,
                                                           endColor: endColorPicker.color)
            }
        }
        
        uiState.options.setColors(lowAmplitudeColor: startColorPicker.color,
                                  highAmplitudeColor: endColorPicker.color)
    }
    
    @IBAction func closeWindowAction(_ sender: Any) {
        close()
    }
    
    override func close() {
        
        super.close()
        
        vizView = nil
        
        audioGraph.removeRenderObserver(self)
        audioGraph.outputDeviceBufferSize = normalDeviceBufferSize
        
        fft.deallocate()

        containerBox.stopTracking()
        optionsBox.hide()
        
        allViews.forEach {$0.dismissView()}
    }
}
