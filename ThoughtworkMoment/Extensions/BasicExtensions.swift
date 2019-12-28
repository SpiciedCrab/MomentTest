//
//  StringExtensions.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/28.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func fontSize(font: UIFont, maxWidth: CGFloat, maxHeight: CGFloat = 999) -> CGSize {
        return (self as NSString)
            .boundingRect(with: CGSize(width: maxWidth, height: maxHeight),
                          options: .usesLineFragmentOrigin,
                          attributes: [NSAttributedString.Key.font: font],
                          context: nil).size
    }
}

extension CGFloat {
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
}
