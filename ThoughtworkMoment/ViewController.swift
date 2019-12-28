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

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            let layout = AlighLeftFlowLayout()
            layout.estimatedItemSize = CGSize(width: CGFloat.screenWidth, height: 99)
            collectionView.setCollectionViewLayout(layout, animated: false)
        }
    }
    
    private let viewModel = TweetMainViewModel()
    
    let disposeBag = DisposeBag()
    
    var tweets : [TweetInfo] = [] {
        didSet{
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return UIEdgeInsets.zero
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let module = tweets[indexPath.section].subModules[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: module.type.rawValue, for: indexPath) as? CellProviding else {
            return UICollectionViewCell()
        }
        
        cell.setup(vm: module)
        return cell.view
    }
}
