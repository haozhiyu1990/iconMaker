//
//  AppDelegate.swift
//  iconMaker
//
//  Created by 7080 on 2023/3/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let window = NSApplication.shared.windows.first {
            window.title = (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? ""
        }
        
        StoringData.instand.configData()
    }
    
    @IBAction func newWindowAction(_ sender: Any) {
        if let lastWindow = NSApplication.shared.windows.filter({ $0.title == ((Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? "") }).last {
            if !lastWindow.isVisible {
                lastWindow.makeKeyAndOrderFront(nil)
                return
            }
            let storyBoard = NSStoryboard(name: "Main", bundle: Bundle.main)
            let controller = storyBoard.instantiateInitialController() as? NSWindowController
            if let window = controller?.window {
                window.title = (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? ""
                window.setFrame(.init(x: lastWindow.frame.minX + 20, y: lastWindow.frame.minY + 20, width: lastWindow.frame.width, height: lastWindow.frame.height), display: true, animate: false)
                window.makeKeyAndOrderFront(nil)
            }
        }
    }
    
    @IBAction func showPreferencesAction(_ sender: Any?) {
        let preferencesTitle = "偏好设置"
        for window in NSApplication.shared.windows {
            if window.title == preferencesTitle {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
        let storyBoard = NSStoryboard(name: "Main", bundle: Bundle.main)
        let preferences = storyBoard.instantiateController(withIdentifier: "PreferencesWindow") as? NSWindowController
        if let window = preferences?.window {
            guard let screen = NSScreen.main?.frame else { return }
            let width = window.frame.width
            let height = window.frame.height
            window.setFrame(.init(x: (screen.width - width) / 2, y: (screen.height - height) / 2 + 300, width: width, height: height), display: true, animate: false)
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}

