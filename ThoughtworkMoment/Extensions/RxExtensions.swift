//
//  RxExtensions.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/28.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import RxSwiftUtilities
import UIKit

typealias FireType<T> = ((Result<T, MomentException>) -> Void) -> Void

extension PublishSubject {
    func fixDebounce() -> Observable<Element> {
        return self
    }
}

extension Reactive where Base: UIImageView {
    public var networkPath: Binder<String> {
        return Binder(self.base) { imgView, path in
            imgView.networkImage(path: path, size: imgView.bounds.size)
        }
    }
}

private var prepareForReuseBag: Int8 = 0

@objc public protocol RxReusable: class {
    func prepareForReuse()
}

extension UITableViewCell: RxReusable {}
extension UICollectionViewCell: RxReusable {}
extension UITableViewHeaderFooterView: RxReusable {}
extension UICollectionReusableView: RxReusable {}

extension Reactive where Base: RxReusable {
    var prepareForReuse: Observable<Void> {
        return Observable.of(sentMessage(#selector(Base.prepareForReuse)).map { _ in }, deallocated).merge()
    }

    var reuseBag: DisposeBag {
        MainScheduler.ensureExecutingOnScheduler()

        if let bag = objc_getAssociatedObject(base, &prepareForReuseBag) as? DisposeBag {
            return bag
        }

        let bag = DisposeBag()
        objc_setAssociatedObject(base, &prepareForReuseBag, bag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)

        _ = sentMessage(#selector(Base.prepareForReuse))
            .subscribe(onNext: { [weak base] _ in
                guard let `base` = base else { return }
                let newBag = DisposeBag()
                objc_setAssociatedObject(base, &prepareForReuseBag, newBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            })

        return bag
    }
}
