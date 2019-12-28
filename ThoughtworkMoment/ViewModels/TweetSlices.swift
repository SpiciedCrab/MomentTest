//
//  TweetViewModels.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation

struct TweetInfo {
    var tweetId: String = ""
    var subModules: [TweetSlicing] = []
    
    mutating func generateId() {
        tweetId = UUID().uuidString
    }
}

class BasicTweet: TweetSlicing {
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
}
