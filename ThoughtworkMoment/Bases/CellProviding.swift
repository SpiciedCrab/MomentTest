//
//  CellProviding.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation
import UIKit

protocol CellProviding {
    func setup(vm: TweetSlicing)
    
    var view: UICollectionViewCell { get }
}

extension CellProviding where Self: UICollectionViewCell {
    var view: UICollectionViewCell {
        return self
    }
}
