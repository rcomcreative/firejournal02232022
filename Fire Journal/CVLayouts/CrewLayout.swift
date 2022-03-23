    //
    //  CrewLayout.swift
    //  DashboardTest
    //
    //  Created by DuRand Jones on 11/14/19.
    //  Copyright © 2019 inSky LE. All rights reserved.
    //
    
    import UIKit

    protocol CrewLayoutProtocol: AnyObject{
        func crewCollectionView( _ collectionView: UICollectionView, heightForUpdateCrewCVCell indexPath: IndexPath ) -> CGFloat
    }
    
    class CrewLayout: UICollectionViewLayout {
        
        weak var delegate: CrewLayoutProtocol? = nil
        var numberOfColumns = 2
        var orientation: Int?
        var displayMode: Int?
        
        let userDefaults = UserDefaults.standard
        
        private let cellPadding: CGFloat = 6
        private let rightCellPadding: CGFloat = 20
        
        /// Cache is cleared during resize of iPad landscape/portrait and on iPhone
        var cache = [UICollectionViewLayoutAttributes]()
        
        private var contentHeight: CGFloat = 0
        
        var contentWidth: CGFloat = 0
        
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        override var collectionViewContentSize: CGSize {
            return CGSize(width: contentWidth, height: contentHeight)
        }
        
        override func prepare() {
               let device = (UIApplication.shared.delegate as? AppDelegate)?.device
                      displayMode = userDefaults.integer(forKey: displayModeOfApp)
                      
                      if Device.IS_IPAD {
                          if device == 1 || device == 2 || device == 0{
                              if displayMode == 1 || displayMode == nil {
                                  numberOfColumns = 1
                              } else if displayMode == 2 {
                                  numberOfColumns = 1
                              }
                          } else {
                              numberOfColumns = 1
                          }
                      } else {
                          numberOfColumns = 1
                      }
                      
                      guard cache.isEmpty, let collectionView = collectionView else {
                              return
                      }
                      
                      let columnWidth = contentWidth / CGFloat(numberOfColumns)
                      var xOffset: [CGFloat] = []
                      
                      for column in 0..<numberOfColumns {
                          xOffset.append( CGFloat(column) *  columnWidth )
                      }
                      
//                      for item in 0..<collectionView.numberOfItems(inSection: 0) {
                          
//                          let indexPath = IndexPath(item: item, section: 0)
//                          let row = indexPath.row
//                          var fullHeight: CGFloat = 0.0
//                          var row0: CGFloat = 0.0
                          
                          
//                      }
        }
    }
