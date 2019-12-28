//
//  TweetViewModels.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation
import UIKit

let defaultNickName = "这孩子木有名字"
let nickFont = UIFont.preferredFont(forTextStyle: .subheadline)
let contentFont = UIFont.preferredFont(forTextStyle: .caption1)

struct TweetInfo {
    var tweetId: String = ""
    var subModules: [TweetSlicing] = []
    
    mutating func generateId() {
        tweetId = UUID().uuidString
    }
}

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
    
    init(tweetId: String, content: String, sender: Sender?) {
        self.content = content
        self.sender = sender
    }

    var content: String = ""
    var sender: Sender?
    
    var nickName: String {
        return sender?.nick ?? defaultNickName
    }
}

class ImageTweet: TweetSlicing {
    var tweetId: String = ""
    var type: TweetType  {
        return .images
    }
    
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

class CommentTweet: TweetSlicing {
    var tweetId: String = ""
    var type: TweetType {
        return .comments
    }

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
