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

extension Int {
    var string: String {
        return "\(self)"
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

extension UIViewController {
    static public var current: UIViewController? {
        var vc: UIViewController? = UIApplication.shared.windows.first?.rootViewController
        while true {
            if let tabVC = vc as? UITabBarController {
                vc = tabVC.selectedViewController
            } else if let navVC = vc as? UINavigationController {
                vc = navVC.visibleViewController
            } else if let presentedVC = vc?.presentedViewController {
                vc = presentedVC
            } else {
                break
            }
        }
    
        return vc
    }
}

extension UICollectionReusableView {
    static var reuseId: String {
        return "\(Self.self)"
    }
}

extension UICollectionView {
    func register<View: UICollectionReusableView>
        (view: View.Type, forSupplementaryViewOfKind: String) {
        register(UINib(nibName: View.reuseId,
                       bundle: Bundle.main),
                 forSupplementaryViewOfKind: forSupplementaryViewOfKind,
                 withReuseIdentifier: View.reuseId)
    }
    
    func dequeueReusableSupplementaryView<View: UICollectionReusableView>(view: View.Type , of kind: String, for indexPath: IndexPath) -> View? {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: View.reuseId, for: indexPath) as? View
    }
}
