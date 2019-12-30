//
//  TweetViewModels.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

let defaultNickName = "这孩子木有名字"
let nickFont = UIFont.preferredFont(forTextStyle: .subheadline)
let contentFont = UIFont.preferredFont(forTextStyle: .caption1)

// MARK: - TweetInfo
class TweetInfo {
    private var disposeBag = DisposeBag()
    var tweetId: String = ""
    var index: Int = 0
    var subModules: [TweetSlicing] = []
    var onItemTapped: PublishSubject<IndexPath> = PublishSubject()
    var didTapHandled: PublishSubject<TweetInfo> = PublishSubject()
    
    func generateId() {
        tweetId = UUID().uuidString
    }
    
    init(tweetId: String, index: Int, subModules: [TweetSlicing]) {
        self.tweetId = tweetId
        self.subModules = subModules
        self.index = index
        
        onItemTapped.subscribe(onNext: {[weak self] (idxPath) in
            guard let `self` = self else { return }
            let module = self.subModules[idxPath.row]
            module.onItemTapped.onNext(())
        }).disposed(by: disposeBag)
        
        Observable.merge(subModules
            .map { $0.didTapHandled.filter { $0 } })
            .map { _ in self }
            .bind(to: didTapHandled)
            .disposed(by: disposeBag)
    }
}

// MARK: - BasicTweet
class BasicTweet: TweetSlicing {
    
    var cellHeight: CGFloat {
        return nickFont.lineHeight + 10 + 10 + content.fontSize(
            font: UIFont.preferredFont(forTextStyle: .caption1),
            maxWidth: 10 + 10 + 44 + 10,
            maxHeight: 999).height
    }
    
    var cellWidth: CGFloat {
        return CGFloat.screenWidth
    }
    
    var tweetId: String = ""
    var type: TweetType {
        return .basic
    }
    
    var onItemTapped: PublishSubject<Void> = PublishSubject()
    var didTapHandled: PublishSubject<Bool> = PublishSubject()
    
    init(tweetId: String, content: String, sender: Sender?) {
        self.content = content
        self.sender = sender
    }

    var content: String = ""
    var sender: Sender?
    
    var nickName: String {
        return sender?.nick ?? defaultNickName
    }
    
    var senderAvatar: String {
        return sender?.avatar ?? ""
    }
}

// MARK: - ImageTweet
class ImageTweet: TweetSlicing {
    var tweetId: String = ""
    var type: TweetType  {
        return .images
    }
    
    var onItemTapped: PublishSubject<Void> = PublishSubject()
    var didTapHandled: PublishSubject<Bool> = PublishSubject()
    
    init(tweetId: String, image: ImageInfo) {
        self.image = image
    }

    let image: ImageInfo
    
    var cellHeight: CGFloat {
        return cellWidth
    }
    
    var cellWidth: CGFloat {
        return (CGFloat.screenWidth - 40 - 30) / 3
    }
}

// MARK: - CommentTweet
class CommentTweet: TweetSlicing {
    var tweetId: String = ""
    var type: TweetType {
        return .comments
    }

    var onItemTapped: PublishSubject<Void> = PublishSubject()
    var didTapHandled: PublishSubject<Bool> = PublishSubject()
    var disposeBag = DisposeBag()
    
    init(tweetId: String, comment: Comment) {
        self.comment = comment
    }
    
    let comment: Comment
    
    var cellWidth: CGFloat {
        return CGFloat.screenWidth
    }
    
    var cellHeight: CGFloat {
        let nickNameHeight: CGFloat = nickFont.lineHeight + 10 + 10
        return nickNameHeight + comment.content.fontSize(
            font: contentFont,
            maxWidth: 10 + 10 + 44 + 10,
            maxHeight: 999).height
    }
}
