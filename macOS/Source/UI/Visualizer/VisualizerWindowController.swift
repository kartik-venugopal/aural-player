//
//  VisualizerWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

class VisualizerWindowController: NSWindowController, NSWindowDelegate {
    
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
    
    var currentView: VisualizerViewProtocol!
    var allViews: [VisualizerViewProtocol] = []
    
    private lazy var visualizer: Visualizer = Visualizer(renderCallback: updateCurrentView)
    
    private lazy var player: PlaybackInfoDelegateProtocol = playbackInfoDelegate
    
    private lazy var uiState: VisualizerUIState = visualizerUIState
    
    private(set) lazy var messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        theWindow.isMovableByWindowBackground = true
        messenger.subscribeAsync(to: .AudioGraph.outputDeviceChanged, handler: audioOutputDeviceChanged)
    }
    
    override func awakeFromNib() {
        
        window?.aspectRatio = NSSize(width: 3.0, height: 2.0)
        
        [spectrogram, supernova, discoBall].forEach {$0?.anchorToSuperview()}
        
        spectrogramMenuItem.representedObject = VisualizationType.spectrogram
        supernovaMenuItem.representedObject = VisualizationType.supernova
        discoBallMenuItem.representedObject = VisualizationType.discoBall
        
        allViews = [spectrogram, supernova, discoBall]
    }
    
    override func destroy() {
        
        super.destroy()
        
        close()
        visualizer.destroy()
        messenger.unsubscribeFromAll()
    }
    
    override func showWindow(_ sender: Any?) {
        
        super.showWindow(sender)
        
        containerBox.startTracking()
        
        initUI(type: uiState.type, lowAmplitudeColor: uiState.options.lowAmplitudeColor,
               highAmplitudeColor: uiState.options.highAmplitudeColor)
        
        visualizer.startAnalysis()
        playbackStateChanged()
        
        window?.orderFront(self)
        
        messenger.subscribeAsync(to: .Player.playbackStateChanged, handler: playbackStateChanged)
    }
    
    private func initUI(type: VisualizationType, lowAmplitudeColor: NSColor, highAmplitudeColor: NSColor) {
        
        startColorPicker.color = lowAmplitudeColor
        endColorPicker.color = highAmplitudeColor
        
        if let vizTypeItem = typeMenu.items.first(where: {type == ($0.representedObject as? VisualizationType)}) {
            typeMenuButton.select(vizTypeItem)
        }
        
        changeType(type)
        updateViewColors()
    }
    
    @IBAction func changeTypeAction(_ sender: NSPopUpButton) {
        
        if let vizType = sender.selectedItem?.representedObject as? VisualizationType {
            changeType(vizType)
        }
    }
    
    private func changeType(_ type: VisualizationType) {
        
        currentView?.dismissView()
        currentView = nil
        
        uiState.type = type
        
        switch type {

        case .spectrogram:      spectrogram.presentView(with: fft)
                                currentView = spectrogram
                                tabView.selectTabViewItem(at: 0)

        case .supernova:        supernova.presentView(with: fft)
                                currentView = supernova
                                tabView.selectTabViewItem(at: 1)

        case .discoBall:        discoBall.presentView(with: fft)
                                currentView = discoBall
                                tabView.selectTabViewItem(at: 2)
        }
    }
    
    // Render callback function (updates the current view with the latest FFT data).
    private func updateCurrentView() {
        
        guard let theCurrentView = currentView else {return}
        
        DispatchQueue.main.async {
            theCurrentView.update(with: fft)
        }
    }
    
    @IBAction func setColorsAction(_ sender: NSColorWell) {
        
        updateViewColors()
        
        uiState.options.setColors(lowAmplitudeColor: startColorPicker.color,
                                  highAmplitudeColor: endColorPicker.color)
    }
    
    private func updateViewColors() {
        
        currentView.setColors(startColor: startColorPicker.color, endColor: endColorPicker.color)
        
        DispatchQueue.main.async {
            
            // Do this for all views not equal to the current view.
            self.allViews.filter {$0.type != self.currentView?.type}.forEach {
                
                $0.setColors(startColor: self.startColorPicker.color,
                             endColor: self.endColorPicker.color)
            }
        }
    }
    
    // When the audio output device changes, restart the audio engine and continue playback as before.
    func audioOutputDeviceChanged() {
        
        allViews.forEach {
            $0.setUp(with: fft)
        }
    }
    
    func playbackStateChanged() {
        
        switch player.state {
            
        case .playing:
            visualizer.resumeAnalysis()
            
        case .paused:
            visualizer.pauseAnalysis()
            
        case .stopped:
            
            visualizer.pauseAnalysis()
            allViews.forEach {$0.reset()}
        }
    }
    
    @IBAction func closeWindowAction(_ sender: Any) {
        close()
    }
    
    override func close() {
        
        super.close()
        
        currentView = nil
        visualizer.stopAnalysis()

        containerBox.stopTracking()
        optionsBox.hide()
        
        allViews.forEach {$0.dismissView()}
        
        messenger.unsubscribe(from: .Player.playbackStateChanged)
    }
}
