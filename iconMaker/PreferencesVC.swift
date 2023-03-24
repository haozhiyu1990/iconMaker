//
//  PreferencesVC.swift
//  iconMaker
//
//  Created by 7080 on 2023/3/23.
//

import Cocoa

class PreferencesVC: NSViewController {
    @IBOutlet weak var iOSCheck: NSButton!
    @IBOutlet weak var macOSCheck: NSButton!
    @IBOutlet weak var watchOSCheck: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let configValues = StoringData.instand.currentValue()
        iOSCheck.state = configValues.iOSCheck ? .on : .off
        macOSCheck.state = configValues.macOSCheck ? .on : .off
        watchOSCheck.state = configValues.watchOSCheck ? .on : .off
    }
    
    @IBAction func iOSCliek(_ sender: NSButton) {
        StoringData.instand.updata(iOSCheck: sender.state == .on ? true : false)
    }
    
    @IBAction func macOSCliek(_ sender: NSButton) {
        StoringData.instand.updata(macOSCheck: sender.state == .on ? true : false)
    }
    
    @IBAction func watchOSCliek(_ sender: NSButton) {
        StoringData.instand.updata(watchOSCheck: sender.state == .on ? true : false)
    }
}
