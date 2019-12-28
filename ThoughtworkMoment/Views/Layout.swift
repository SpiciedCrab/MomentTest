//
//  Layout.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/28.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation
import UIKit

protocol UICollectionViewDelegateLeftAlignedLayout: UICollectionViewDelegateFlowLayout {
    
}

extension UICollectionViewLayoutAttributes {
    func leftAlignFrame(with sectionInset: UIEdgeInsets, margin: CGFloat? = 0) {
        var frame = self.frame
        frame.origin.x = sectionInset.left + (margin ?? 0)
        self.frame = frame
    }
}

class AlighLeftFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let originalAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        let updatedAttributes = NSMutableArray.init(array: originalAttributes)
        
        for attribute in originalAttributes {
            if (attribute.representedElementKind == nil) {
                let index = updatedAttributes.index(of: attribute)
                updatedAttributes[index] = self.layoutAttributesForItem(at: attribute.indexPath) as Any
            }
        }
        
        return (updatedAttributes as! [UICollectionViewLayoutAttributes])
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let currentItemAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as! UICollectionViewLayoutAttributes

        let sectionInset = self.evaluatedSectionInsetForItem(at: indexPath.section)
        
        let isFirstItemInSection: Bool = indexPath.item == 0
        
        if isFirstItemInSection {
            currentItemAttributes.leftAlignFrame(with:sectionInset)
            return currentItemAttributes
        }
        
        let layoutWidth: CGFloat = (self.collectionView?.frame.size.width)! - sectionInset.left - sectionInset.right
        
        let previousIndexPath = NSIndexPath.init(item: indexPath.item - 1, section: indexPath.section)
        
        let previousFrame = self.layoutAttributesForItem(at: previousIndexPath as IndexPath)?.frame
        
        let previousFrameRightPoint = (previousFrame?.origin.x)! + previousFrame!.size.width
        
        let currentFrame = currentItemAttributes.frame
        
        let strecthedCurrentFrame = CGRect(x: sectionInset.left, y: currentFrame.origin.y, width: layoutWidth, height: currentFrame.size.height)
        
        let isFirstItemInRow = !previousFrame!.intersects(strecthedCurrentFrame)
        
        if isFirstItemInRow {
            currentItemAttributes.leftAlignFrame(with: sectionInset,
                                                 margin: currentFrame.width == currentFrame.height ? 50 : 0)
            return currentItemAttributes
        }
        
        var frame = currentItemAttributes.frame
        frame.origin.x = previousFrameRightPoint + self.evaluatedMinimumInteritemSpacingForSection(at: indexPath.section)
        
        currentItemAttributes.frame = frame
        
        return currentItemAttributes
        
    }
    
    func evaluatedSectionInsetForItem(at index: NSInteger) -> UIEdgeInsets {

        if (self.collectionView?.delegate?.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:))))! {
            
            guard let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout else {
                return sectionInset
            }
            
            return (delegate.collectionView?(self.collectionView!, layout: self, insetForSectionAt: index))!
            
        } else {
            return sectionInset
        }
        
    }
    
    func evaluatedMinimumInteritemSpacingForSection(at index: NSInteger) -> CGFloat {
        if (self.collectionView?.delegate?.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))))! {
            let delegate = self.collectionView?.delegate as! UICollectionViewDelegateFlowLayout
            return (delegate.collectionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAt: index))!
        } else {
            return self.minimumInteritemSpacing
        }
    }
    
}
