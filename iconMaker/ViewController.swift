//
//  ViewController.swift
//  iconMaker
//
//  Created by 7080 on 2023/3/21.
//

import Cocoa
import SnapKit
import CleanJSON
import ZipArchive
import SwiftShell

class ViewController: NSViewController {
    let backgroundColor: NSColor = NSColor(red: 41 / 255.0, green: 44 / 255.0, blue: 46 / 255.0, alpha: 1)
    lazy var generateBtn: NSButton = {
        let generate = NSButton(title: "生成Icon", target: self, action: #selector(generateIcon))
        generate.isHidden = true
        return generate
    }()
    lazy var showImageView: NSImageView = {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleAxesIndependently
        imageView.wantsLayer = true
        imageView.layer?.cornerRadius = 50
        return imageView
    }()
    lazy var addInBtn: CustomBtn = CustomBtn(target: self, action: #selector(btnAction))
    lazy var tipsText: NSTextField = {
        let tips = NSTextField(string: "点击或者拖拽图片文件 ( 1024 x 1024 )")
        tips.isEditable = false
        tips.isSelectable = false
        tips.isBezeled = false
        tips.isBordered = false
        tips.backgroundColor = backgroundColor
        tips.font = .systemFont(ofSize: 10)
        tips.textColor = .white.blended(withFraction: 0.3, of: .black)
        return tips
    }()
    lazy var dragTipsView = DragTipsView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.wantsLayer = true
        view.layer?.backgroundColor = backgroundColor.cgColor
        
        let dragView = DragView(entered: fileEntered, exited: fileExited, complete: fileComplete)
        view.addSubview(showImageView)
        view.addSubview(generateBtn)
        view.addSubview(dragView)
        view.addSubview(addInBtn)
        view.addSubview(tipsText)
        view.addSubview(dragTipsView)
        
        addInBtn.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(230)
        }
        dragView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tipsText.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
            $0.size.equalTo(tipsText.sizeThatFits(.zero))
        }
        showImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-30)
            $0.width.height.equalTo(300)
        }
        generateBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(showImageView.snp.bottom).offset(45)
        }
        dragTipsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func fileEntered() {
        dragTipsView.isHidden = false
    }
    
    func fileExited() {
        dragTipsView.isHidden = true
    }
    
    func fileComplete(filePath: String) {
        dragTipsView.isHidden = true
        showImage(filePath: filePath)
    }
    
    @objc func btnAction() {
        let dialog = NSOpenPanel()
//        dialog.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        dialog.title = "选择图片"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["png", "jpg"]

        if let window = appKeyWindow {
            dialog.beginSheetModal(for: window) { response in
                if response == .OK {
                    let results = dialog.urls
                    for result in results {
                        self.showImage(filePath: result.path)
                    }
                }
            }
        } else {
            if dialog.runModal() == .OK {
                let results = dialog.urls
                for result in results {
                    showImage(filePath: result.path)
                }
            }
        }
    }
    
    func showImage(filePath: String) {
        let originImageUrl = URL(fileURLWithPath: filePath)
        if let image = NSImage(contentsOf: originImageUrl) {
            if image.size.width != 1024 || image.size.height != 1024 {
                showAlert()
                return
            }
            
            showImageView.image = image
            generateBtn.isHidden = false
            
            addInBtn.isHidden = true
            tipsText.isHidden = true
        } else {
            showAlert()
        }
    }
    
    func showAlert(message: String = "请选择尺寸是 1024 x 1024 的图片.") {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.1) {
            let alert = NSAlert()
            alert.messageText = message
            if let window = appKeyWindow {
                alert.beginSheetModal(for: window) {
                    if $0 == .cancel, message.contains("请至少选择") {
                        self.presentPreferences()
                    }
                }
            } else {
                if alert.runModal() == .cancel, message.contains("请至少选择")  {
                    self.presentPreferences()
                }
            }
        }
    }
    
    func presentPreferences() {
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            delegate.showPreferencesAction(nil)
        }
    }
    
    @objc func generateIcon() {
        HUD.show()
        DispatchQueue.main.async {
            self.resizeAppIcon(image: self.showImageView.image)
        }
    }
    
    func resizeAppIcon(image: NSImage?) {
        if let url = Bundle.main.url(forResource: "Contents", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let model = try CleanJSONDecoder().decode(IconConfig.self, from: data)
                var images = model.images
                
                guard let originImage = image else { throw IconError(localizedDescription: "图片不存在") }
                guard let outUrl = getOutFileUrl() else { throw IconError(localizedDescription: "输出路径不存在") }
                
                for (idx, image) in images.enumerated() {
                    let size = image.size.components(separatedBy: "x").first ?? ""
                    let scale = image.scale.components(separatedBy: "x").first ?? ""
                    let sizeValue = Double(size) ?? 0
                    let scaleValue = Double(scale) ?? 1
                    images[idx].imageSize = sizeValue * scaleValue
                    let names = [image.idiom, image.platform, "\(size)X\(size)", image.scale].compactMap { str -> String? in
                        if str.count == 0 || str == "1x" || str == "universal" {
                            return nil
                        }
                        if str.contains("x") {
                            return "@\(str)"
                        }
                        return str.replacingOccurrences(of: "X", with: "x")
                    }
                    let imageName = "\(names.joined(separator: "_").replacingOccurrences(of: "_@", with: "@")).png"
                    images[idx].imageName = imageName
                    images[idx].isMac = imageName.contains("mac")
                }
                
                var imageInfos = [IconConfig.ConfigInfo]()
                let configValues = StoringData.instand.currentValue()
                if configValues.iOSCheck {
                    imageInfos += images.filter({ $0.imageName.contains("ios") })
                }
                if configValues.macOSCheck {
                    imageInfos += images.filter({ $0.imageName.contains("mac") })
                }
                if configValues.watchOSCheck {
                    imageInfos += images.filter({ $0.imageName.contains("watch") })
                }

                if imageInfos.count == 0 {
                    showAlert(message: "请至少选择一种类型！")
                    HUD.dismiss()
                    return
                }
                
                for imageInfo in imageInfos {
                    let newSize = NSSize(width: imageInfo.imageSize, height: imageInfo.imageSize)
                    save(image: resize(image: originImage, newSize: newSize, isMac: imageInfo.isMac), toURL: outUrl.appendingPathComponent(imageInfo.imageName), fileType: .png)
                }
                exprotIconFile()
            } catch {
                print(error.localizedDescription)
                showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func exprotIconFile() {
        HUD.dismiss()
        let save = NSSavePanel()
        save.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        save.prompt = "导出"
        save.nameFieldLabel = "文件名:"
        save.nameFieldStringValue = "AppIcon"
        if let window = appKeyWindow {
            save.beginSheetModal(for: window) { reponse in
                if reponse == .OK {
                    self.exprotIconFileWithPath(url: save.url)
                } else {
                    self.removeGenerateFile()
                }
            }
        } else {
            if save.runModal() == .OK {
                exprotIconFileWithPath(url: save.url)
            } else {
                removeGenerateFile()
            }
        }
    }
    
    func removeGenerateFile() {
        guard let zipUrl = getOutFileUrl() else { return }
        if let subPaths = FileManager.default.subpaths(atPath: zipUrl.path) {
            for subPath in subPaths.reversed() {
                do {
                    try FileManager.default.removeItem(at: zipUrl.appendingPathComponent(subPath))
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func exprotIconFileWithPath(url outUrl: URL?) {
        guard let exportUrl = outUrl, let zipUrl = getOutFileUrl() else { return }
        if SSZipArchive.createZipFile(atPath: exportUrl.appendingPathExtension("zip").path, withContentsOfDirectory: zipUrl.path) {
            run(bash: "open -R \(exportUrl.appendingPathExtension("zip").path)")
            
            showImageView.image = nil
            generateBtn.isHidden = true
            
            addInBtn.isHidden = false
            tipsText.isHidden = false
            
            if let subPaths = FileManager.default.subpaths(atPath: zipUrl.path) {
                for subPath in subPaths.reversed() {
                    do {
                        try FileManager.default.removeItem(at: zipUrl.appendingPathComponent(subPath))
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func getOutFileUrl() -> URL? {
        var url = FileManager.default.temporaryDirectory
        url.appendPathComponent("appIcons")
        
        var isDir = ObjCBool(false)
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) || !isDir.boolValue {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                print(error.localizedDescription)
                showAlert(message: error.localizedDescription)
                return nil
            }
        }
        
        return url
    }
    
    func resize(image: NSImage, newSize: NSSize, isMac: Bool) -> NSImage {
        let newImage = NSImage(size: newSize)
        
        if isMac {
            let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: imageRep)
            let inset: CGFloat = CGFloat(Int(newSize.width * 0.09))
            let cornerRadius: CGFloat = CGFloat(Int(newSize.width * 0.2))
            let path = NSBezierPath(roundedRect: NSRect(x: inset, y: inset, width: newSize.width - inset * 2, height: newSize.height - inset * 2), xRadius: cornerRadius, yRadius: cornerRadius)
            path.addClip()
            image.draw(in: NSRect(x: inset, y: inset, width: newSize.width - inset * 2, height: newSize.height - inset * 2), from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height), operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()
            newImage.addRepresentation(imageRep)
        } else {
            newImage.lockFocus()
            image.draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height),
                       from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
                       operation: .copy,
                       fraction: 1.0)
            newImage.unlockFocus()
        }
        
        return newImage
    }
    
    @discardableResult
    func save(image: NSImage, toURL url: URL, fileType: NSBitmapImageRep.FileType) -> Bool {
        guard let data = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let imageData = bitmap.representation(using: fileType, properties: [:])
        else {
            return false
        }
        
        do {
            try imageData.write(to: url)
            return true
        } catch {
            print("Error saving image: \(error)")
            return false
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

