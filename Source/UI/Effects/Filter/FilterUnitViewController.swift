//
//  FilterUnitViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Filter effects unit
 */
class FilterUnitViewController: EffectsUnitViewController {
    
    override var nibName: NSNib.Name? {"FilterUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var filterUnitView: FilterUnitView!
    @IBOutlet weak var bandsTableView: NSTableView!
    @IBOutlet weak var lblSummary: NSTextField!
    @IBOutlet weak var btnAddBandMenu: NSPopUpButton!
    
    var bandEditors: [LazyWindowLoader<FilterBandEditorDialogController>] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var filterUnit: FilterUnitProtocol = audioGraph.filterUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()

        let bandsDataFunction = {[weak self] in self?.filterUnit.bands ?? []}
        filterUnitView.initialize(stateFunction: unitStateFunction, bandsDataFunction: bandsDataFunction)
        updateSummary()
    }
 
    override func initControls() {

        super.initControls()
        
        addEditorsForAllBands()
        bandsTableView.reloadData()
        updateSummary()
        filterUnitView.redrawChart()
    }
    
    private func addEditorsForAllBands() {
        
        for bandIndex in filterUnit.bands.indices {
            
            let editor = LazyWindowLoader<FilterBandEditorDialogController>()
            
            editor.controllerInitFunction = {controller in
                
                controller.forceLoadingOfWindow()
                controller.bandIndex = bandIndex
            }
            
            bandEditors.append(editor)
//            initEditorWindowMagnetism(for: editor, showWindow: false)
        }
    }
    
    func initEditorWindowMagnetism(for editor: LazyWindowLoader<FilterBandEditorDialogController>, showWindow: Bool) {
        
        if preferences.viewPreferences.windowMagnetism {
            appModeManager.mainWindow?.addChildWindow(editor.window, ordered: .above)
        }
        
        if !showWindow {
            editor.window.hide()
        }
    }
    
    private func updateSummary() {
        
        let numberOfBands = filterUnit.numberOfBands
        
        guard numberOfBands > 0 else {
            
            lblSummary.stringValue = "0 bands"
            return
        }
        
        let numberOfActiveBands = filterUnit.numberOfActiveBands
        let bandsCardinalString = numberOfBands == 1 ? "band" : "bands"
        
        lblSummary.stringValue = "\(numberOfBands) \(bandsCardinalString)  (\(numberOfActiveBands) active)"
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    @IBAction func addBandStopBandAction(_ sender: AnyObject) {
        doAddBand(ofType: .bandStop)
    }
    
    @IBAction func addBandPassBandAction(_ sender: AnyObject) {
        doAddBand(ofType: .bandPass)
    }
    
    @IBAction func addLowPassBandAction(_ sender: AnyObject) {
        doAddBand(ofType: .lowPass)
    }
    
    @IBAction func addHighPassBandAction(_ sender: AnyObject) {
        doAddBand(ofType: .highPass)
    }
    
    private func doAddBand(ofType bandType: FilterBandType) {
        
        guard filterUnit.numberOfBands < filterUnit.maximumNumberOfBands else {
            
            NSAlert.showError(withTitle: "Cannot add Filter band", andText: "The Filter unit already has the maximum of \(filterUnit.maximumNumberOfBands) bands.")
            return
        }
        
        let newBandInfo: (band: FilterBand, index: Int) = filterUnit.addBand(ofType: bandType)
        bandsTableView.noteNumberOfRowsChanged()
        updateSummary()
        filterUnitView.redrawChart()
        
        let bandEditor = LazyWindowLoader<FilterBandEditorDialogController>()
        
        bandEditor.controllerInitFunction = {controller in
            
            controller.forceLoadingOfWindow()
            controller.bandIndex = newBandInfo.index
        }
        
        bandEditors.append(bandEditor)
        
        initEditorWindowMagnetism(for: bandEditor, showWindow: true)
        bandEditor.showWindow()
    }
    
    @IBAction func removeBandsAction(_ sender: AnyObject) {
        
        // TODO: Before removing, remove the bypass switches in the removed rows as FX unit state observers.
        
        let selRows = bandsTableView.selectedRowIndexes
        guard selRows.isNonEmpty else {return}
        
        for index in selRows.sortedDescending() {
            bandEditors[index].destroy()
        }
        
        bandEditors.removeItems(at: selRows)
        
        filterUnit.removeBands(at: selRows)
        bandsTableView.reloadData()
        updateSummary()
        filterUnitView.redrawChart()
        
        for (index, editor) in bandEditors.enumerated() {
            
            if editor.isWindowLoaded {
                editor.controller.bandIndex = index
                
            } else {
                
                editor.controllerInitFunction = {controller in
                    
                    controller.forceLoadingOfWindow()
                    controller.bandIndex = index
                }
            }
        }
    }
    
    // Applies a preset to the effects unit
    @IBAction override func presetsAction(_ sender: AnyObject) {
        
        for editor in bandEditors {
            editor.destroy()
        }
        
        bandEditors.removeAll()
        
        effectsUnit.applyPreset(named: sender.title)
        bandsTableView.reloadData()
        updateSummary()
        filterUnitView.redrawChart()
        
        addEditorsForAllBands()
    }
    
    // Table view double-click action
    @IBAction func editSelectedBandAction(_ sender: NSTableView) {
        
        bandEditors[sender.selectedRow].showWindow()
        initEditorWindowMagnetism(for: bandEditors[sender.selectedRow], showWindow: true)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribe(to: .Effects.FilterUnit.bandUpdated, handler: bandUpdated(_:))
        
        //fontSchemesManager.registerObservers([self, lblSummary], forProperty: \.smallFont)
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: backgroundColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, handler: buttonColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primaryTextColor, handler: primaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: secondaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primarySelectedTextColor, handler: primarySelectedTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondarySelectedTextColor, handler: secondarySelectedTextColorChanged(_:))
        
//        colorSchemesManager.registerObserver(lblSummary, forProperty: \.secondaryTextColor)
//        colorSchemesManager.registerSchemeObserver(self, forProperties: [\.backgroundColor, \.primaryTextColor, \.secondaryTextColor])
//        colorSchemesManager.registerObserver(addButtonMenuIcon, forProperty: \.buttonColor)
        
        messenger.subscribe(to: .Effects.FilterUnit.bandBypassStateUpdated, handler: updateSummary)
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        filterUnitView.stateChanged()
    }
    
    private func bandUpdated(_ band: Int) {
        bandsTableView.reloadRows([band], columns: [2, 3])
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        
        bandsTableView.reloadAllRows(columns: [0, 2, 3])
        filterUnitView.redrawChart()
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        buttonColorChanged(systemColorScheme.buttonColor)
        lblSummary.textColor = systemColorScheme.secondaryTextColor
        
        bandsTableView.setBackgroundColor(systemColorScheme.backgroundColor)
        bandsTableView.reloadDataMaintainingSelection()
        
        filterUnitView.redrawChart()
    }
    
    private func backgroundColorChanged(_ newColor: NSColor) {
        bandsTableView.setBackgroundColor(newColor)
    }
    
    private func buttonColorChanged(_ newColor: NSColor) {
        
        // Edit buttons
        bandsTableView.reloadAllRows(columns: [4])
        btnAddBandMenu.colorChanged(newColor)
    }
    
    private func primaryTextColorChanged(_ newColor: NSColor) {
        bandsTableView.reloadAllRows(columns: [3])
    }
    
    private func secondaryTextColorChanged(_ newColor: NSColor) {
        
        bandsTableView.reloadAllRows(columns: [2])
        lblSummary.textColor = newColor
    }
    
    private func primarySelectedTextColorChanged(_ newColor: NSColor) {
        bandsTableView.reloadRows(bandsTableView.selectedRowIndexes.toArray())
    }
    
    private func secondarySelectedTextColorChanged(_ newColor: NSColor) {
        bandsTableView.reloadRows(bandsTableView.selectedRowIndexes.toArray())
    }
    
    override func activeControlColorChanged(_ newColor: NSColor) {
        
        super.activeControlColorChanged(newColor)
        filterUnitView.redrawChart()
    }
    
    override func inactiveControlColorChanged(_ newColor: NSColor) {
        
        super.inactiveControlColorChanged(newColor)
        filterUnitView.redrawChart()
    }
    
    override func suppressedControlColorChanged(_ newColor: NSColor) {
        
        super.suppressedControlColorChanged(newColor)
        filterUnitView.redrawChart()
    }
}

extension FilterUnitViewController: ThemeInitialization {
    
    func initTheme() {
        
        super.fontSchemeChanged()
        super.colorSchemeChanged()
        
        buttonColorChanged(systemColorScheme.buttonColor)
        lblSummary.textColor = systemColorScheme.secondaryTextColor
        
        bandsTableView.colorSchemeChanged()
        filterUnitView.redrawChart()
    }
}
