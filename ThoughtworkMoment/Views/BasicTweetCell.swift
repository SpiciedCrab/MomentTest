//
//  BasicTweetCell.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import UIKit
import RxSwift
class BasicTweetCell: UICollectionViewCell, CellProviding {
    @IBOutlet private weak var avatarImage: UIImageView!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var nickNameLabel: UILabel!
    @IBOutlet private weak var labelConstraint: NSLayoutConstraint!
    @IBOutlet private weak var container: UIView!
    @IBOutlet private weak var labelButton: UIButton!
    
    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        container.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func setup(vm: TweetSlicing) {
        guard let basicSlicing = vm as? BasicTweet else {
            return
        }
        
        contentLabel.text = basicSlicing.content
        nickNameLabel.text = basicSlicing.nickName
        avatarImage.networkImage(path: basicSlicing.senderAvatar, size: CGSize(width: 40, height: 40))
    
        labelButton.rx.tap.subscribe(onNext: { (_) in
            let detailVc = ContentDetailViewController(nibName: "ContentDetailViewController", bundle: Bundle.main)
            detailVc.text = basicSlicing.content
            UIViewController.current?.navigationController?.pushViewController(detailVc, animated: true)
            }).disposed(by: disposeBag)
        
        labelConstraint.constant = CGFloat.screenWidth
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImage.cancelDownloading()
        disposeBag = DisposeBag()
    }
}
