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
    private let tweetValidator: TweetValidator
    private let disposeBag = DisposeBag()
    
    // inputs
    let refreshBegin: PublishRelay<Void> = PublishRelay()
    let refreshNext: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    // outputs
    let refreshState: BehaviorRelay<[TweetInfo]> = BehaviorRelay(value: [])
    let activityIndicator: ActivityIndicator = ActivityIndicator()
    let errorOutput: PublishRelay<String> = PublishRelay()

    // ThoughtwokrDefaultTweetValidator will limit the total count of tweets to 5,
    // So I use the ShowAllTweetValidator to ensure that the [pull up to add more]
    // feature can normally work
    init(tweetValidator: TweetValidator = ShowAllTweetValidator()) {
        self.tweetValidator = tweetValidator
        setupBindings()
    }
    
    private func setupBindings() {
        refreshBegin
            .do(onNext: {[weak self] (_) in
                guard let `self` = self else { return }
                self.refreshNext.accept(false)
            }).map(initPage)
            .filter { $0 }.map { _ in  () }
            .trackActivity(activityIndicator)
            .flatMapLatest(obsRequest)
            .map { $0.list.filter(self.tweetValidator.validate) }
            .map(sliceTwwets).catchError({[weak self] (error)  in
                guard let self = self else { return Observable.of([]) }
                self.errorOutput.accept(error.localizedDescription)
                return Observable.of([])
            }).bind(to: refreshState)
            .disposed(by: disposeBag)
        
        refreshNext.distinctUntilChanged().filter { $0 }
            .map { _ in  }.map(increasePage)
            .filter { $0 }
            .map { _ in self.stored }
            .bind(to: refreshState)
            .disposed(by: disposeBag)
        
    }
    
    private func initPage() -> Bool {
        tweetApi.currentPage = 0
        return true
    }
    
    private func increasePage() -> Bool {
        
        tweetApi.currentPage += 1
        return tweetApi.currentPage <= totalPage
    }
    
    
    private func obsRequest() -> Observable<Tweets> {
        return Observable.create {[weak self] (sub: AnyObserver<Result<Tweets, MomentException>>) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            self.fire.fire(request: &self.tweetApi) { (result: Result<Tweets, MomentException>) in
                sub.onNext(result)
                sub.onCompleted()
            }
            
            return Disposables.create {
                self.tweetApi.cancelToken?.cancel()
            }
        }.map(resultToTweets)
    }
    
    private func resultToTweets(result: Result<Tweets, MomentException>) -> Tweets {
        switch result {
        case .success(let tweets):
            return tweets
        case .failure(let error):
            let realError = error as MomentException
            errorOutput.accept(realError.msg)
            return Tweets(list: [])
        }
    }
    
    private func sliceTwwets(tweets: [Tweet]) -> [TweetInfo] {
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
        
        if(tweetApi.isFirstPage) {
            stored = sliced
        } else {
            stored.append(contentsOf: sliced)
        }
        
        return stored.count >= 5 ? ([] + stored.prefix(upTo: 5)) : stored
    }
}
