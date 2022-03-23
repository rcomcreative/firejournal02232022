//
//  ResourcesLayout.swift
//  DashboardTest
//
//  Created by DuRand Jones on 11/14/19.
//  Copyright © 2019 inSky LE. All rights reserved.
//

import UIKit

protocol ResourcesLayoutProtocol: AnyObject{
    func resourcesCollectionView( _ collectionView: UICollectionView, heightForUserFDResourcesCell indexPath: IndexPath ) -> CGFloat
}

class ResourcesLayout: UICollectionViewLayout {
    
    weak var delegate: ResourcesLayoutProtocol? = nil
    var numberOfColumns = 2
    var orientation: Int?
    var displayMode: Int?
    
    let userDefaults = UserDefaults.standard
    
    private let cellPadding: CGFloat = 6
    private let rightCellPadding: CGFloat = 6
    
    /// Cache is cleared during resize of iPad landscape/portrait and on iPhone
    var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentHeight: CGFloat = 0
    
    var contentWidth: CGFloat = 92.0
    
    var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        let device = (UIApplication.shared.delegate as? AppDelegate)?.device
        displayMode = userDefaults.integer(forKey: displayModeOfApp)
        
        if Device.IS_IPAD {
            contentWidth = 92.0
            if device == 1 || device == 2 || device == 0{
                if displayMode == 1 || displayMode == nil {
                    numberOfColumns = 4
                } else if displayMode == 2 {
                    numberOfColumns = 4
                }
            } else {
                numberOfColumns = 4
            }
        } else {
            contentWidth = 72
            numberOfColumns = 4
        }
        
        guard cache.isEmpty, let collectionView = collectionView else {
                return
        }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        
        for column in 0..<numberOfColumns {
            xOffset.append( CGFloat(column) *  columnWidth )
        }
        
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns )

        var fullHeight: CGFloat = 0.0

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
//            let row = indexPath.row
            let row0: CGFloat = 111.0
//            row0 = delegate?.resourcesCollectionView(collectionView, heightForUserFDResourcesCell: indexPath) ?? 0.0
            let height = cellPadding * 2 + row0
            let width = cellPadding * 2 + contentWidth
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: width, height: height)
            
            let insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
            
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            if item == 0 {
                fullHeight = fullHeight + height
            } else if item == 5 {
                fullHeight = fullHeight + height
            }
            
        }
        
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: fullHeight)
        
        contentHeight = max(contentHeight, frame.maxY)
        yOffset[column] = yOffset[column] + fullHeight
        
        column = column < (numberOfColumns - 1) ? (column + 1) : 0
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if !visibleLayoutAttributes.isEmpty {
            visibleLayoutAttributes.removeAll()
        }
        
        if cache.isEmpty {
            prepare()
        }
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        return visibleLayoutAttributes
    }
        
}
