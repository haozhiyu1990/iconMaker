//
//  StoringData.swift
//  iconMaker
//
//  Created by 7080 on 2023/3/23.
//

import Cocoa

struct StoringDataModel: Codable {
    var iOSCheck: Bool
    var macOSCheck: Bool
    var watchOSCheck: Bool
}

class StoringData {
    static let instand = StoringData()
    private init() {}
    private var storingData: StoringDataModel?
    
    private func loadData(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            storingData = try PropertyListDecoder().decode(StoringDataModel.self, from: data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func currentValue() -> (iOSCheck : Bool, macOSCheck : Bool, watchOSCheck : Bool) {
        guard let storingData = storingData else { return (true, true, true) }
        return (storingData.iOSCheck, storingData.macOSCheck, storingData.watchOSCheck)
    }
    
    func updata(iOSCheck: Bool? = nil, macOSCheck: Bool? = nil, watchOSCheck: Bool? = nil) {
        if let iOSCheck = iOSCheck {
            storingData?.iOSCheck = iOSCheck
        }
        if let macOSCheck = macOSCheck {
            storingData?.macOSCheck = macOSCheck
        }
        if let watchOSCheck = watchOSCheck {
            storingData?.watchOSCheck = watchOSCheck
        }
        
        guard let resourceURL = Bundle.main.resourceURL else { return }
        let userDataUrl = resourceURL.appendingPathComponent("userData.plist")
        guard let storingData = storingData else { return }
        do {
            let data = try PropertyListEncoder().encode(storingData)
            try data.write(to: userDataUrl)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func configData() {
        if let resourceURL = Bundle.main.resourceURL {
            let userDataUrl = resourceURL.appendingPathComponent("userData.plist")
            if !FileManager.default.fileExists(atPath: userDataUrl.path) {
                let userData = StoringDataModel(iOSCheck: true, macOSCheck: true, watchOSCheck: true)
                
                do {
                    let data = try PropertyListEncoder().encode(userData)
                    try data.write(to: userDataUrl)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            loadData(url: userDataUrl)
        }
    }
}
