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
import ESPullToRefresh

class ViewController: UIViewController {

    // MARK: - UIs
    private var header: UIView?
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            initialLayout()
            
            collectionView.register(view: UserInfoHeaderView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
            
            collectionView.register(view: BottomLineView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
            
            collectionView.register(UICollectionReusableView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: "blankHeader")
            
            collectionView.register(UICollectionReusableView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                    withReuseIdentifier: "blankFooter")
            
            let refreshHeader = collectionView.es.addPullToRefresh {
                UIView.animate(withDuration: 0.3) {
                    self.header?.alpha = 1
                }
                self.viewModel.refreshBegin.accept(())
            }
            
            refreshHeader.frame = CGRect(x: 0, y: 0, width: refreshHeader.bounds.size.width, height: 88)
            
            header = refreshHeader
            
            collectionView.es.addInfiniteScrolling {
                self.viewModel.refreshNext.accept(true)
            }
        }
    }
    
    // MARK: - Fields
    private let viewModel = TweetMainViewModel()
    private let disposeBag = DisposeBag()
    private var tweets : [TweetInfo] = [] {
        didSet{
            UIView.animate(withDuration: 0.3) {
                self.header?.alpha = 0
            }
            
            collectionView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
            
            Observable.merge(tweets.map { $0.didTapHandled }).map { $0.index }.asDriver(onErrorJustReturn: 0).drive(onNext: {(idx) in
                print("Resolved fron \(idx)")
            }).disposed(by: disposeBag)
            
            collectionView.reloadData()
        }
    }
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInsetAdjustmentBehavior = .never
        
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
        
        viewModel.touchEndPage.observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] (isEnd) in
            guard let `self` = self else { return }
            if isEnd {
                self.collectionView.es.noticeNoMoreData()
            } else {
                self.collectionView.es.resetNoMoreData()
            }
            }).disposed(by: disposeBag)
        
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
        return CGSize(width: CGFloat.screenWidth, height: headerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: CGFloat.screenWidth, height: footerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section == 0 {
                return collectionView.dequeueReusableSupplementaryView(view: UserInfoHeaderView.self, of: kind, for: indexPath) ?? UICollectionReusableView()
            } else {
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "blankHeader", for: indexPath)
            }
            
        } else {
            return collectionView.dequeueReusableSupplementaryView(view: BottomLineView.self, of: kind, for: indexPath) ?? UICollectionReusableView()
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
    }
}
