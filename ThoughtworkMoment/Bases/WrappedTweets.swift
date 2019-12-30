//
//  WrappedTweets.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

enum TweetType: String {
    case basic = "basicTweet"
    case images = "imageTweet"
    case comments = "commentTweet"
    case tools = "toolTweet"
    case end = "endTweet"
}

protocol TweetSlicing {
    var tweetId: String { get set }
    var type: TweetType { get }
    var cellHeight: CGFloat { get }
    var cellWidth: CGFloat { get }
    
    var onItemTapped: PublishSubject<Void>  { get set }
    var didTapHandled: PublishSubject<Bool>  { get set }
}
