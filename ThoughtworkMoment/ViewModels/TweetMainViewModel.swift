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

class TweetMainViewModel {
    
    // MARK: - Fields
    // Plugins to implement
    private let tweetValidator: TweetValidator
    private var tweetFetcher: TweetFetcher
    private var tweetHandler: TweetHandler
    
    // Normal Fields
    private var stored: [TweetInfo] = []
    private let disposeBag = DisposeBag()
    
    // Signal Inputs
    let refreshBegin: PublishRelay<Void> = PublishRelay()
    let refreshNext: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    // Signal Outputs
    let refreshState: BehaviorRelay<[TweetInfo]> = BehaviorRelay(value: [])
    let errorOutput: PublishRelay<String> = PublishRelay()
    let touchEndPage: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    // ThoughtwokrDefaultTweetValidator will limit the total count of tweets to 5,
    // So I use the ShowAllTweetValidator to ensure that the [pull up to add more]
    // feature can normally work
    init(tweetFetcher: TweetFetcher = NetworkTweetFetcher(),
         tweetValidator: TweetValidator = ShowAllTweetValidator(),
         tweetHandler: TweetHandler = SectionableTweetHandler()) {
        self.tweetValidator = tweetValidator
        self.tweetFetcher = tweetFetcher
        self.tweetHandler = tweetHandler
        setupBindings()
    }
    
    // MARK: - Privates
    private func setupBindings() {
        refreshBegin
            .do(onNext: {[weak self] (_) in
                guard let `self` = self else { return }
                self.refreshNext.accept(false)
                self.touchEndPage.accept(false)
            }).map { _ in  () }
            .flatMapLatest(obsRequest)
            .map { $0.list.filter(self.tweetValidator.validate) }
            .map(sliceTwwets).catchError({[weak self] (error)  in
                guard let self = self else { return Observable.of([]) }
                self.errorOutput.accept(error.localizedDescription)
                return Observable.of([])
            })
            .bind(to: refreshState)
            .disposed(by: disposeBag)
        
        refreshNext.distinctUntilChanged()
            .filter { $0 && self.tweetFetcher.isFirstPage }
            .map { _ in  }
            .map { _ in self.stored }
            .do(onNext: {[weak self] (_) in
                guard let `self` = self else { return }
                self.tweetFetcher.isFirstPage = false
                self.touchEndPage.accept(true)
            })
            .bind(to: refreshState)
            .disposed(by: disposeBag)
        
    }
    
    private func initPage() -> Bool {
        return true
    }
    
    private func obsRequest() -> Observable<Tweets> {
        return Observable.create {[weak self] (sub: AnyObserver<Result<Tweets, MomentException>>) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            self.tweetFetcher.refreshTweet { (result) in
                sub.onNext(result)
                sub.onCompleted()
            }
            
            return Disposables.create {
                self.tweetFetcher.cancelFetch()
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
        let sliced = tweetHandler.handleTweets(tweets: tweets)
        
        if tweetFetcher.isFirstPage {
            stored = sliced
        } else {
            stored.append(contentsOf: sliced)
        }
        
        touchEndPage.accept(stored.count <= 5)
        return stored.count >= 5 ? ([] + stored.prefix(upTo: 5)) : stored
    }
}
