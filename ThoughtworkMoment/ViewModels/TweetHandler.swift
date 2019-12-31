//
//  TweetHandler.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/30.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation

class SectionableTweetHandler: TweetHandler {
    func handleTweets(tweets: [Tweet]) -> [TweetInfo] {
        var sliced: [TweetInfo] = []
        var index = 0;
        for var tweet in tweets {
            tweet.uniqueId = UUID().uuidString
            var modules: [TweetSlicing] = []
            let basicT = BasicTweet(tweetId: tweet.uniqueId,
                                   content: tweet.content,
                                   sender: tweet.sender)
            
            modules.append(basicT)
            
            if(!tweet.images.isEmpty) {
                let imagesT = tweet.images.map{ ImageTweet(tweetId: tweet.uniqueId, image: $0) }
                modules.append(contentsOf: imagesT)
            }
            
            if(!tweet.comments.isEmpty) {
                let commentsT = tweet.comments
                    .map{ CommentTweet(tweetId: tweet.uniqueId, comment: $0) }
                
                modules.append(contentsOf: commentsT)
            }
            
            sliced.append(TweetInfo(tweetId: tweet.uniqueId, index: index ,subModules: modules))
            index += 1
        }
        
        return sliced
    }
}
