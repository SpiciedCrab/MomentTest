//
//  Plugins.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/29.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation

// MARK: - TweetValidator
protocol TweetValidator {
    func validate(twwet: Tweet) -> Bool
}

// MARK: - TweetFetcher
protocol TweetFetcher {
    func refreshTweet(fetcher: @escaping (Result<Tweets, MomentException>) -> Void)
    func cancelFetch()
    
    var isFirstPage: Bool { get set }
}

// MARK: - TweetHandler
protocol TweetHandler {
    func handleTweets(tweets: [Tweet]) -> [TweetInfo]
}
