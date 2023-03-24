//
//  IconConfig.swift
//  iconMaker
//
//  Created by 7080 on 2023/3/21.
//

import Foundation

struct IconError: Error {
    var localizedDescription: String
}

struct IconConfig: Codable {
    var images: [ConfigInfo]
    var info: InfoModel
    
    struct ConfigInfo: Codable {
        var idiom: String
        var platform: String
        var scale: String
        var size: String
        
        var imageSize: Double
        var imageName: String
        var isMac: Bool
    }
    
    struct InfoModel: Codable {
        var author: String
        var version: Int
    }
}
