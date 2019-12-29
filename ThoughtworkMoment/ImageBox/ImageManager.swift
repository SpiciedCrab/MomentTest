//
//  ImageManager.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/28.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation
import UIKit

class ImageManager {
    static let shared: ImageManager = ImageManager()
    private var sessionCache: [String: URLSessionDataTask] = [:]
    private var imageCache: [String: UIImage] = [:]
    
    func cacheSession(key: String, task: URLSessionDataTask) {
        if(sessionCache.keys.contains(key)) {
            sessionCache[key]?.cancel()
        }
        sessionCache[key] = task
    }
    
    func cancelSession(key: String) {
        sessionCache[key]?.cancel()
        finishSession(key: key)
    }
    
    func finishSession(key: String) {
        sessionCache.removeValue(forKey: key)
    }
    
    func cacheImage(path: String, image: UIImage) {
        imageCache[path] = image
    }
    
    func findCachedImage(path: String) -> UIImage? {
        return imageCache[path]
    }
    
    func clearCache() {
        imageCache.removeAll()
        sessionCache.removeAll()
    }
}
