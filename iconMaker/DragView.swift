//
//  DragView.swift
//  iconMaker
//
//  Created by 7080 on 2023/3/21.
//

import Cocoa

class DragView: NSView {
    private var enteredCallBack: (() -> Void)?
    private var exitedCallBack: (() -> Void)?
    private var completeCallBack: ((String) -> Void)?
    private let supportedTypes: [NSPasteboard.PasteboardType] = [.fileURL]

    init(entered: @escaping () -> Void, exited: @escaping () -> Void, complete: @escaping (String) -> Void) {
        super.init(frame: .zero)
        
        enteredCallBack = entered
        exitedCallBack = exited
        completeCallBack = complete
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        registerForDraggedTypes(supportedTypes)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        enteredCallBack?()
        if let contain = sender.draggingPasteboard.types?.contains(.fileURL), contain {
            return .copy
        }
        return []
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        exitedCallBack?()
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let contain = sender.draggingPasteboard.types?.contains(.fileURL), contain {
            return true
        }
        return false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if sender.draggingPasteboard.canReadObject(forClasses: [NSURL.self]) {
            if let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self]) as? [NSURL] {
                if let url = urls.first, let path = url.path {
                    completeCallBack?(path)
                }
            }
        }
        return true
    }
    
}
