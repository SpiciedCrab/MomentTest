//
//  ImageCell.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var imageWidth: NSLayoutConstraint!

    override func prepareForReuse() {
        super.prepareForReuse()
        image.reset()
    }
}

extension ImageCell: CellProviding {
    func setup(vm: TweetSlicing) {
        guard let imageSlicing = vm as? ImageTweet else {
            return
        }
        
        imageWidth.constant = imageSlicing.cellWidth - 20
        image.networkImage(path: imageSlicing.image.url, size: CGSize(width: imageSlicing.cellWidth - 20, height: imageSlicing.cellHeight - 20))
    }
}
