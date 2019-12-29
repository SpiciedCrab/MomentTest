//
//  Plugins.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/29.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation

protocol TweetValidator {
    func validate(twwet: Tweet) -> Bool
}

struct ThoughtwokrDefaultTweetValidator: TweetValidator {
    
    // ignore the tweet which does not contain a content and images
    func validate(twwet: Tweet) -> Bool {
        return !twwet.content.isEmpty && !twwet.images.isEmpty
    }
}

struct ShowAllTweetValidator: TweetValidator {
    func validate(twwet: Tweet) -> Bool {
        return true
    }
}
