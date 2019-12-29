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

typealias FireType<T> = ((Result<T, MomentException>) -> Void) -> Void

extension PublishSubject {
    func fixDebounce() -> Observable<Element> {
        return self
    }
}

extension Reactive where Base: UIImageView {
    public var networkPath: Binder<String> {
        return Binder(self.base) { imgView, path in
            imgView.networkImage(path: path)
        }
    }
}
