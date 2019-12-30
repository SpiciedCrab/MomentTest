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
    private let imageSignal = DispatchSemaphore(value: 1)
    private let sessionSignal = DispatchSemaphore(value: 1)
    
    func cacheSession(key: String, task: URLSessionDataTask) {
        if(sessionCache.keys.contains(key)) {
            sessionCache[key]?.cancel()
        }
        sessionSignal.wait()
        sessionCache[key] = task
        sessionSignal.signal()
    }
    
    func cancelSession(key: String) {
        sessionCache[key]?.cancel()
        finishSession(key: key)
    }
    
    func finishSession(key: String) {
        sessionCache.removeValue(forKey: key)
    }
    
    func cacheImage(path: String, image: UIImage) {
        imageSignal.wait()
        imageCache[path] = image
        imageSignal.signal()
    }
    
    func findCachedImage(path: String) -> UIImage? {
        return imageCache[path]
    }
    
    func clearCache() {
        imageCache.removeAll()
        sessionCache.removeAll()
    }
}
