//
//  ImageCell.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell, CellProviding{
    
    @IBOutlet private weak var image: UIImageView!
    
    func setup(vm: TweetSlicing) {
        guard let imageSlicing = vm as? ImageTweet else {
            return
        }
        
        image.networkImage(path: imageSlicing.image.url)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image.cancelDownloading()
    }
}
