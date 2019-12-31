//
//  TweetsTests.swift
//  ThoughtworkMomentTests
//
//  Created by Harly on 2019/12/31.
//  Copyright © 2019 Harly. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import RxBlocking

@testable import ThoughtworkMoment

class UTTweetFetcher: TweetFetcher {
    var isFirstPage: Bool = true
    
    static let mockTweets = [1,2,3,4,5,6,7,8,9,10].map { idx -> Tweet in
        return Tweet(uniqueId: "\(idx.string)", content: "\(idx)", sender: Sender(username: "guagua \(idx)", nick: "guagua \(idx)", avatar: nil, profileImage: nil), images: [ImageInfo(url: "\(idx)")], comments: [Comment(content: "1234 \(idx)", sender: Sender(username: "guagua \(idx + 1)", nick: "guagua \(idx + 1)"))])
    }
    
    func refreshTweet(fetcher: @escaping (Result<Tweets, MomentException>) -> Void) {
        isFirstPage = true
        fetcher(Result.success(Tweets(list: UTTweetFetcher.mockTweets)))
    }
}


class TweetsTests: XCTestCase {

    var testViewModel: TweetMainViewModel!
    
    override func setUp() {
        testViewModel = TweetMainViewModel(tweetFetcher: UTTweetFetcher(),
                                           tweetValidator: ShowAllTweetValidator(),
                                           tweetHandler: SectionableTweetHandler())
    }

    override func tearDown() {
        
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    // Description:
    // Testing pulling down and pulling up
    func testTweetsCounts() {
        testViewModel.refreshBegin.accept(())
        let result = try? testViewModel.refreshState.toBlocking().last()
        guard let realResult = result else {
            XCTFail("Result do not exist")
            return
        }
        
        // 1. Count should be 5 when first launching.
        XCTAssertEqual(realResult.count, 5)
        
        testViewModel.refreshNext.accept(true)
        
        let refreshedResult = try? testViewModel.refreshState.toBlocking().last()
        guard let realRefreshedResult = refreshedResult else {
            XCTFail("Result do not exist")
            return
        }

        // 2. Count should equal to the total length of the mock data after pulling up.
        XCTAssertEqual(realRefreshedResult.count, UTTweetFetcher.mockTweets.count)
        
        testViewModel.refreshBegin.accept(())
        
        let pulldownResult = try? testViewModel.refreshState.toBlocking().first()
        guard let realPulldownResult = pulldownResult else {
            XCTFail("Result do not exist")
            return
        }

        // 3. Count should be 5 after pulling down.
        XCTAssertEqual(realPulldownResult.count, 5)
    }
}
