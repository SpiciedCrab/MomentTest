//
//  TweetFetcher.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/30.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation

extension TweetFetcher {
    func cancelFetch() {
        
    }
}

class NetworkTweetFetcher: TweetFetcher {
    private let fire = Firer()
    private var tweetApi = TweetsApi(userName: "jsmith")
    var isFirstPage: Bool = true
    
    func refreshTweet(fetcher: @escaping (Result<Tweets, MomentException>) -> Void) {
        self.fire.fire(request: &self.tweetApi) {[weak self] (result: Result<Tweets, MomentException>) in
            guard let `self` = self else { return }
            self.isFirstPage = true
            fetcher(result)
        }
    }
    
    func cancelFetch() {
        tweetApi.cancelToken?.cancel()
    }
}

class MockTweetFetcher: TweetFetcher {
    var isFirstPage: Bool = true
    func refreshTweet(fetcher: @escaping (Result<Tweets, MomentException>) -> Void) {
        let tweet1 = Tweet(uniqueId: "1", content: "haha", sender: Sender(username: "guagua", nick: "guagua", avatar: nil, profileImage: nil), images: [], comments: [])
        
        let tweet2 = Tweet(uniqueId: "2", content: "haha2", sender: Sender(username: "guagua2", nick: "guagua2", avatar: nil, profileImage: nil), images: [], comments: [])
        isFirstPage = true
        fetcher(Result.success(Tweets(list: [tweet1, tweet2])))
    }
}

