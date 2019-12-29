//
//  ImageExtension.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/28.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func networkImage(path: String, contentMode mode: UIView.ContentMode = .center) {
        guard let url = URL(string: path) else {
            return
        }
        contentMode = mode
        
        if let cachedImage = ImageManager.shared.findCachedImage(path: path) {
            self.image = cachedImage
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, resp, error in
            ImageManager.shared.finishSession(key: "\(self.hashValue)")
            guard let httpURLResponse = resp as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = httpURLResponse.mimeType,
                mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async() {
                let sizeChange = self.frame.size
                
                UIGraphicsBeginImageContextWithOptions(sizeChange, false, 0.0)
                
                image.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
                
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                guard let realImage = resizedImage else {
                    return
                }
                
                self.image = realImage
                ImageManager.shared.cacheImage(path: path, image: realImage)
            }
        }
        
        ImageManager.shared.cacheSession(key: "\(hashValue)", task: task)
        task.resume()
    }
    
    func cancelDownloading() {
        ImageManager.shared.cancelSession(key: "\(hashValue)")
    }
}

