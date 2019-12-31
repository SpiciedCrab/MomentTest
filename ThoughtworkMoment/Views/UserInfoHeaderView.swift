//
//  UserInfoHeaderView.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/29.
//  Copyright © 2019 Harly. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class UserInfoHeaderView: UICollectionReusableView {
    
    // MARK: - Fields
    private let profileViewModel = ProfileViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UIs
    @IBOutlet private weak var profileBg: UIImageView!
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var nickLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialBindings()
        profileViewModel.refreshUserInfo.onNext(())
    }
    
    // MARK: - Privates
    private func initialBindings() {
        profileViewModel.userNameBinding.asDriver()
            .drive(nickLabel.rx.text)
            .disposed(by: disposeBag)
        
        profileViewModel.avatarBinding.asDriver()
            .drive(avatar.rx.networkPath)
            .disposed(by: disposeBag)
        
        profileViewModel.profileImageBinding.asDriver()
            .drive(profileBg.rx.networkPath)
            .disposed(by: disposeBag)
    }
    
}
