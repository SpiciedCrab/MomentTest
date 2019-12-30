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
import ESPullToRefresh

class ViewController: UIViewController {

    // MARK: - UIs
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            
            initialLayout()
            collectionView.register(UINib(nibName: "UserInfoHeaderView",
                                          bundle: Bundle.main),
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: "UserInfoHeaderView")
            
            collectionView.register(UICollectionReusableView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: "blank")
            
            collectionView.es.addPullToRefresh {
                self.collectionView.es.resetNoMoreData()
                self.viewModel.refreshBegin.accept(())
            }
            
            collectionView.es.addInfiniteScrolling {
                self.viewModel.refreshNext.accept(true)
                self.collectionView.es.noticeNoMoreData()
            }
            
        }
    }
    
    // MARK: - Fields
    private let viewModel = TweetMainViewModel()
    private let disposeBag = DisposeBag()
    private var tweets : [TweetInfo] = [] {
        didSet{
            collectionView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
            
            Observable.merge(tweets.map { $0.didTapHandled }).map { $0.index }.asDriver(onErrorJustReturn: 0).drive(onNext: {[weak self] (idx) in
                guard let `self` = self else { return }
                self.collectionView.collectionViewLayout.invalidateLayout()
                UIView.performWithoutAnimation {
                    self.collectionView.reloadSections(IndexSet(integer: idx))
                }
                self.initialLayout()
            }).disposed(by: disposeBag)
            
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
    
        NotificationCenter .default.rx.notification(UIDevice.orientationDidChangeNotification)
            .subscribe(onNext: {[weak self] noti in
                guard let `self` = self else { return }
                self.updateViewConstraints()
                self.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
        
        viewModel.errorOutput.observeOn(MainScheduler.asyncInstance).bind { (error) in
            let alert = UIAlertController(title: "出错啦", message: error, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: {[weak self] action in
                guard let `self` = self else { return }
                self.viewModel.refreshBegin.accept(())
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        collectionView.es.startPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func initialLayout() {
        let layout = AlighLeftFlowLayout()
        layout.estimatedItemSize = CGSize(width: CGFloat.screenWidth, height: 500)
        collectionView.setCollectionViewLayout(layout, animated: false)
        
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
        return CGSize(width: CGFloat.screenWidth, height: 300)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = tweets[indexPath.section]
        section.onItemTapped.onNext(indexPath)
        self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredVertically, animated: true)
    }
}
