//
//  ProfileViewModel.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/29.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import RxSwiftUtilities

class ProfileViewModel {
    private let fire = Firer()
    private var userApi = UserInfoApi(userName: "jsmith")
    private let disposeBag = DisposeBag()
    
    // inputs
    var refreshUserInfo: PublishSubject<Void> = PublishSubject()
    
    // outputs
    var userNameBinding: BehaviorRelay<String> = BehaviorRelay(value: "")
    var avatarBinding: BehaviorRelay<String> = BehaviorRelay(value: "")
    var profileImageBinding: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    init() {
        refreshUserInfo
            .flatMapLatest(obsRequest)
            .startWith(Sender.buildDefault()).subscribe(onNext: {[weak self] (sender) in
                guard let `self` = self else { return }
                self.userNameBinding.accept(sender.nick)
                self.avatarBinding.accept(sender.avatar ?? "")
                self.profileImageBinding.accept(sender.profileImage ?? "")
            }).disposed(by: disposeBag)
    }
    
    private func obsRequest() -> Observable<Sender> {
        return Observable.create {[weak self] (sub: AnyObserver<Sender>) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            self.fire.fire(request: &self.userApi) { (result: Result<Sender, MomentException>) in
                switch result {
                case .success(let sweets):
                    sub.onNext(sweets)
                case .failure(let error):
                    sub.onError(error)
                }
            }
            
            return Disposables.create {
                self.userApi.cancelToken?.cancel()
            }
        }
    }
    
}
