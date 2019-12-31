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
    
    func networkImage(path: String, size: CGSize ) {
        guard let url = URL(string: path) else {
            return
        }
        
        if let cachedImage = ImageManager.shared.findCachedImage(path: path) {
            self.image = cachedImage
            return
        }
        
        var viewSize = size
        let ratio = size.width / size.height
        let task = URLSession.shared.dataTask(with: url) { data, resp, error in
            ImageManager.shared.finishSession(key: "\(self.hashValue)")
            guard let httpURLResponse = resp as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = httpURLResponse.mimeType,
                mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data) else { return }
            
            let imageSize = image.size
            
            DispatchQueue(label: "imageQue").async {
                
                let imageRatio = imageSize.width / imageSize.height
                if imageRatio > ratio {
                    viewSize = CGSize(width: viewSize.height * imageRatio,
                                      height: viewSize.height)
                } else {
                    viewSize = CGSize(width: viewSize.width,
                                      height: viewSize.width / imageRatio)
                }

                UIGraphicsBeginImageContextWithOptions(viewSize, false, UIScreen.main.scale)
                
                image.draw(in: CGRect(origin: CGPoint.zero, size: viewSize))
                
                let drawedImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                guard let realImage = drawedImage else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.image = realImage
                }
                
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

