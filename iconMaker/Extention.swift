//
//  Extention.swift
//  iconMaker
//
//  Created by 7080 on 2023/3/24.
//

import Cocoa

var appKeyWindow: NSWindow? {
    for window in NSApplication.shared.windows {
        if window.isKeyWindow {
            return window
        }
    }
    
    return nil
}
