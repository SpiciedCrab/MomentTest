//
//  CommentCell.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell, CellProviding {
    
    @IBOutlet weak private var nickNameLabel: UILabel!
    @IBOutlet weak private var commentLabel: UILabel!
    @IBOutlet weak private var labelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var trailing: NSLayoutConstraint!
    @IBOutlet weak private var leading: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelConstraint.constant = CGFloat.screenWidth - trailing.constant - leading.constant
    }
    
    func setup(vm: TweetSlicing) {
        guard let commentSlicing = vm as? CommentTweet else {
            return
        }
        
        nickNameLabel.text = commentSlicing.comment.sender?.nick ?? defaultNickName
        commentLabel.text = commentSlicing.comment.content
    }
}
