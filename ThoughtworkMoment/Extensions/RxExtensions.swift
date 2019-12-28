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

extension PublishSubject {
    func fixDebounce() -> Observable<Element> {
        return self
    }
}
