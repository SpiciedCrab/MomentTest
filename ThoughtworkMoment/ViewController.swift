//
//  ViewController.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import RxSwiftUtilities

class ViewController: UIViewController {

    // MARK: - UIs
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            let layout = AlighLeftFlowLayout()
            layout.estimatedItemSize = CGSize(width: CGFloat.screenWidth, height: 99)
            collectionView.setCollectionViewLayout(layout, animated: false)
            
            collectionView.register(UINib(nibName: "UserInfoHeaderView",
                                          bundle: Bundle.main),
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: "UserInfoHeaderView")
            
            collectionView.register(UICollectionReusableView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: "blank")
        }
    }
    
    // MARK: - Fields
    private let viewModel = TweetMainViewModel()
    private let disposeBag = DisposeBag()
    private var tweets : [TweetInfo] = [] {
        didSet{
            collectionView.reloadData()
        }
    }
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInsetAdjustmentBehavior = .never
        
        viewModel.activityIndicator
            .drive(UIApplication.shared
                .rx
                .isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        
        viewModel.refreshState.observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (infos) in
                guard let `self` = self else { return }
                self.tweets = infos
            }).disposed(by: disposeBag)
        
        collectionView.rx.contentOffset
            .filter { $0.y >= self.collectionView.contentSize.height / 3 }
            .map { _ in () }
            .bind(to: viewModel.refreshNext)
            .disposed(by: disposeBag)
        
        viewModel.refreshBegin.onNext(())
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let module = tweets[indexPath.section].subModules[indexPath.row]
        return CGSize(width: module.cellWidth, height: module.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return tweets[section].subModules.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tweets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if(section != 0 ) {
            return CGSize.zero
        }
        return CGSize(width: CGFloat.screenWidth, height: CGFloat.screenHeight / 4)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: CGFloat.screenWidth, height: 20)
//    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section == 0 {
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UserInfoHeaderView", for: indexPath)
            } else {
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "blank", for: indexPath)
            }
            
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let module = tweets[indexPath.section].subModules[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: module.type.rawValue, for: indexPath) as? CellProviding else {
            return UICollectionViewCell()
        }
        
        cell.setup(vm: module)
        return cell.view
    }
}
