//
//  CustomBtn.swift
//  iconMaker
//
//  Created by 7080 on 2023/3/21.
//

import Cocoa

class CustomBtn: NSButton {
    let backgroundColor: NSColor = NSColor(red: 41 / 255.0, green: 44 / 255.0, blue: 46 / 255.0, alpha: 1)
    var foregroundColor: NSColor {
        get {
            if isHighlighted {
                return .white.blended(withFraction: 0.2, of: .black) ?? .white
            } else {
                return .white
            }
        }
    }
    
    
    init(target: Any?, action: Selector?) {
        super.init(frame: .zero)
        self.target = target as AnyObject?
        self.action = action
        wantsLayer = true
        isBordered = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
        
        let lineWidth: CGFloat = 14
        
        var rect = dirtyRect
        rect.origin.x = lineWidth
        rect.origin.y = lineWidth
        rect.size.width -= (lineWidth * 2)
        rect.size.height -= (lineWidth * 2)

        NSBezierPath.defaultLineWidth = lineWidth
        
        foregroundColor.set()
        NSBezierPath(roundedRect: rect, xRadius: 20, yRadius: 20).stroke()
        
        backgroundColor.set()
        let offsetX = dirtyRect.width / 3
        let offsetY = dirtyRect.height / 3
        
        NSBezierPath.strokeLine(from: NSPoint(x: dirtyRect.minX + offsetX, y: 0), to: NSPoint(x: dirtyRect.minX + offsetX, y: dirtyRect.maxY))
        NSBezierPath.strokeLine(from: NSPoint(x: dirtyRect.minX + offsetX * 2, y: 0), to: NSPoint(x: dirtyRect.minX + offsetX * 2, y: dirtyRect.maxY))
        
        NSBezierPath.strokeLine(from: NSPoint(x: 0, y: dirtyRect.minY + offsetY), to: NSPoint(x: dirtyRect.maxX, y: dirtyRect.minY + offsetY))
        NSBezierPath.strokeLine(from: NSPoint(x: 0, y: dirtyRect.minY + offsetY * 2), to: NSPoint(x: dirtyRect.maxX, y: dirtyRect.minY + offsetY * 2))
        
        foregroundColor.set()
        NSBezierPath.defaultLineCapStyle = .round
        let center = NSPoint(x: dirtyRect.midX, y: dirtyRect.midY)
        let offset: CGFloat = 40
        
        NSBezierPath.strokeLine(from: center, to: NSPoint(x: center.x, y: center.y + offset))
        NSBezierPath.strokeLine(from: center, to: NSPoint(x: center.x, y: center.y - offset))
        NSBezierPath.strokeLine(from: center, to: NSPoint(x: center.x + offset, y: center.y))
        NSBezierPath.strokeLine(from: center, to: NSPoint(x: center.x - offset, y: center.y))
    }
    
}
