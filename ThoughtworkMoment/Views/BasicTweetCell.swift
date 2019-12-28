//
//  BasicTweetCell.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import UIKit

class BasicTweetCell: UICollectionViewCell, CellProviding {
    @IBOutlet private weak var avatarImage: UIImageView!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var nickNameLabel: UILabel!
    @IBOutlet private weak var labelConstraint: NSLayoutConstraint!
    @IBOutlet private weak var container: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        container.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        labelConstraint.constant = CGFloat.screenWidth - 40 - 30
    }
    
    func setup(vm: TweetSlicing) {
        guard let basicSlicing = vm as? BasicTweet else {
            return
        }
        
        contentLabel.text = basicSlicing.content
        nickNameLabel.text = basicSlicing.nickName
    }
}
