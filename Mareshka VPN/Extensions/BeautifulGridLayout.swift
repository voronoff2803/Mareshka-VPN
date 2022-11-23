//
//  BeautifulGridLayout.swift
//  BeautifulGridLayout
//
//  Created by Suguru Kishimoto on 2016/01/29.
//
//

import UIKit

public extension UICollectionView {
    
//    func adaptBeautifulGrid(numberOfGridsPerRow: Int, gridLineSpace space: CGFloat) {
//        adaptBeautifulGrid(numberOfGridsPerRow: numberOfGridsPerRow, gridLineSpace: space)
//    }
    
    func adaptBeautifulGrid(numberOfGridsPerRow: Int, gridLineSpace space: CGFloat) {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        guard numberOfGridsPerRow > 0 else {
            return
        }
        
        let inset = layout.sectionInset
        
        let isScrollDirectionVertical = layout.scrollDirection == .vertical
        var length = isScrollDirectionVertical ? self.frame.width : self.frame.height
        length -= space * CGFloat(numberOfGridsPerRow - 1)
        length -= isScrollDirectionVertical ? (inset.left + inset.right) : (inset.top + inset.bottom)
        let side = length / CGFloat(numberOfGridsPerRow) - 1
        
        guard side > 0.0 else {
            return
        }
        layout.itemSize = CGSize(width: side, height: side)
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.invalidateLayout()
    }

}

