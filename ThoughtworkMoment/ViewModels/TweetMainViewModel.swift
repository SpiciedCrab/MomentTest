//
//  TweetMainViewModel.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import RxSwiftUtilities

class TweetMainViewModel {
    private let fire = Firer()
    var tweetApi = TweetsApi(userName: "jsmith")
    private var totalPage = 10
    private var stored: [TweetInfo] = []
    
    // inputs
    var refreshBegin: PublishSubject<Void> = PublishSubject()
    var refreshNext: PublishSubject<Void> = PublishSubject()
    
    // outputs
    var refreshState: Observable<[TweetInfo]>!
    let activityIndicator: ActivityIndicator = ActivityIndicator()

    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        refreshState = Observable.merge(
            [refreshBegin.map(initPage)])
            .filter { $0 }.map { _ in  () }
            .trackActivity(activityIndicator)
            .flatMapLatest(obsRequest)
            .startWith(Tweets(list: []))
            .map(sliceTwwets)
    }
    
    private func initPage() -> Bool {
        tweetApi.currentPage = 0
        return true
    }
    
    private func increasePage() -> Bool {
        tweetApi.currentPage += 1
        return tweetApi.currentPage >= totalPage
    }
    
    
    private func obsRequest() -> Observable<Tweets> {
        return Observable.create {[weak self] (sub: AnyObserver<Tweets>) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            self.fire.fire(request: &self.tweetApi) { (result: Result<Tweets, MomentException>) in
                switch result {
                case .success(let sweets):
                    sub.onNext(sweets)
                case .failure(let error):
                    sub.onError(error)
                }
            }
            
            return Disposables.create {
                self.tweetApi.cancelToken?.cancel()
            }
        }
    }
    
    private func sliceTwwets(tweetsSummary: Tweets) -> [TweetInfo] {
        var sliced: [TweetInfo] = []
        let tweets = tweetsSummary.list
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
            
            sliced.append(TweetInfo(tweetId: tweet.uniqueId, subModules: modules))
        }
        
        if(tweetApi.isFirstPage) {
            stored = sliced
        } else {
            stored.append(contentsOf: sliced)
        }
        
        return stored
    }
}
