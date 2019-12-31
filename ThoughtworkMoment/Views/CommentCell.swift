//
//  CommentCell.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import RxSwiftUtilities

class CommentCell: UICollectionViewCell {
    
    // MARK: - UIs
    @IBOutlet weak private var nickNameLabel: UILabel!
    @IBOutlet weak private var commentLabel: UILabel!
    @IBOutlet weak private var labelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var trailing: NSLayoutConstraint!
    @IBOutlet weak private var leading: NSLayoutConstraint!
    
    // MARK: - Lifecycles
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private var tweet: CommentTweet?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tweet?.disposeBag = DisposeBag()
    }
}

extension CommentCell: CellProviding {
    func setup(vm: TweetSlicing) {
        guard let commentSlicing = vm as? CommentTweet else {
            return
        }
        tweet = commentSlicing
        nickNameLabel.text = "\(commentSlicing.comment.sender?.nick ?? defaultNickName) :"
        commentLabel.text = commentSlicing.comment.content
        labelConstraint.constant = CGFloat.screenWidth - trailing.constant - leading.constant
        commentSlicing.onItemTapped.bind(onNext: { (_) in
            print("tappedcomment \(commentSlicing.comment)")
            commentSlicing.didTapHandled.onNext(true)
        }).disposed(by: commentSlicing.disposeBag)
    }
    
}
