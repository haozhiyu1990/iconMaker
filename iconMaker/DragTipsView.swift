//
//  DragTipsView.swift
//  iconMaker
//
//  Created by 7080 on 2023/3/23.
//

import Cocoa

class DragTipsView: NSView {
    
    init() {
        super.init(frame: .zero)
        isHidden = true
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.9).cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        NSColor.white.set()
        NSBezierPath.defaultLineWidth = 1
        let offset: CGFloat = 10
        let newRect = NSRect(x: offset, y: offset, width: dirtyRect.width - offset * 2, height: dirtyRect.height - offset * 2)
        let dashPattern: [CGFloat] = [5.0, 5.0]
        let path = NSBezierPath(roundedRect: newRect, xRadius: 10, yRadius: 10)
        path.setLineDash(dashPattern, count: 2, phase: 2)
        path.stroke()

        let tipsStr = "拖到这里"
        let attTipsStr = NSMutableAttributedString(string: tipsStr)
        attTipsStr.addAttributes([.font : NSFont.systemFont(ofSize: 90, weight: .bold), .foregroundColor : NSColor.white], range: NSMakeRange(0, tipsStr.count))
        let strSize = attTipsStr.size()
        attTipsStr.draw(in: NSRect(x: (dirtyRect.width - strSize.width) / 2, y: (dirtyRect.height - strSize.height) / 2, width: strSize.width, height: strSize.height))
    }
    
}
