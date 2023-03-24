//
//  BaseView.swift
//  iconMaker
//
//  Created by 7080 on 2023/3/22.
//

import Cocoa

class BaseView : NSView {

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureLayers()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayers()
    }

    /// Configure the Layers
    func configureLayers() {
        wantsLayer = true
        notifyViewRedesigned()
    }

    var background: NSColor = NSColor(red: 88.3 / 256, green: 104.4 / 256, blue: 118.5 / 256, alpha: 1.0) {
        didSet {
            notifyViewRedesigned()
        }
    }

    var foreground: NSColor = NSColor(red: 66.3 / 256, green: 173.7 / 256, blue: 106.4 / 256, alpha: 1.0) {
        didSet {
            notifyViewRedesigned()
        }
    }

    var cornerRadius: CGFloat = 5.0 {
        didSet {
            notifyViewRedesigned()
        }
    }

    /// Call when any IBInspectable variable is changed
    func notifyViewRedesigned() {
        layer?.backgroundColor = background.cgColor
        layer?.cornerRadius = cornerRadius
    }
}
