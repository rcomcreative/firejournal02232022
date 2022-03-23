//
//  PinterestLayout.swift
//  DashboardTest
//
//  Created by DuRand Jones on 11/7/19.
//  Copyright © 2019 inSky LE. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionViewSS( _ collectionView: UICollectionView, heightForStartShiftCVCell indexPath: IndexPath ) -> CGFloat
    func collectionViewUPandE( _ collectionView: UICollectionView, heightForUpdateAndEndShiftCVCell indexPath: IndexPath ) -> CGFloat
    func collectionViewNForms( _ collectionView: UICollectionView, heightForNewFormsCVCell indexPath: IndexPath ) -> CGFloat
    func collectionViewTS( _ collectionView: UICollectionView, heightForTodaysShiftCVCell indexPath: IndexPath ) -> CGFloat
    func collectionViewUPS( _ collectionView: UICollectionView, heightForUpdateShiftCVCell indexPath: IndexPath ) -> CGFloat
    func collectionViewES( _ collectionView: UICollectionView, heightForEndShiftCVCell indexPath: IndexPath ) -> CGFloat
    func collectionViewTI( _ collectionView: UICollectionView, heightForTodaysIncidentsCVCell indexPath: IndexPath ) -> CGFloat
    func collectionViewW( _ collectionView: UICollectionView, heightForWeatherCVCell indexPath: IndexPath ) -> CGFloat
    func collectionViewIncidentMonths(_ collectionView: UICollectionView, heightForIncidentMonthsTotalsCVCell indexPath: IndexPath) ->CGFloat
    func collectionViewStationResources(_ collectionView: UICollectionView, heightForStationResourcesCVCell indexPath: IndexPath) ->CGFloat
    func whatIsTheShift() -> Shift
}

class PinterestLayout: UICollectionViewLayout {
    
    weak var delegate: PinterestLayoutDelegate? = nil
    /// number of Columns will either be 1 or 2
    var numberOfColumns = 1
    var visible = false
    
    var orientation: Int?
    var displayMode: Int?
    
    let userDefaults = UserDefaults.standard
    
    var widthOfParent: CGFloat!
    
    private let cellPadding: CGFloat = 6
    private let rightCellPadding: CGFloat = 20
    
    /// Cache is cleared during resize of iPad landscape/portrait and on iPhone
    var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentHeight: CGFloat = 0
    
    var contentWidth: CGFloat = 0
    
    var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    
    let nc = NotificationCenter.default
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    
    fileprivate func configureForShiftsCell(_ shift: Shift?, _ row1: inout CGFloat, _ collectionView: UICollectionView, _ indexPath: IndexPath, _ xOffset: inout [CGFloat], _ column: Int, _ yOffset: inout [CGFloat], _ columnWidth: CGFloat, _ fullHeight: inout CGFloat) {
        switch shift {
        case .start:
            row1 = delegate?.collectionViewTS(collectionView, heightForTodaysShiftCVCell: indexPath) ?? 0.0
        case .update:
            row1 = delegate?.collectionViewUPS(collectionView, heightForUpdateShiftCVCell: indexPath) ?? 0.0
        case .end:
            row1 = delegate?.collectionViewES(collectionView, heightForEndShiftCVCell: indexPath) ?? 0.0
        default: break
        }
        let height = cellPadding * 2 + row1
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        
        var insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        if insetFrame.width != 0 {
            do {
                let iframe = try NSKeyedArchiver.archivedData(withRootObject: insetFrame, requiringSecureCoding: true)
                userDefaults.set(iframe, forKey: FJkSHIFTCELLSINSETFRAME)
                userDefaults.synchronize()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } else {
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: widthOfParent, height: height)
            insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        }
        attributes.frame = insetFrame
        cache.append(attributes)
        fullHeight = fullHeight + height
    }
    
    fileprivate func configureForNewFormsCell(_ row2: inout CGFloat, _ collectionView: UICollectionView, _ indexPath: IndexPath, _ xOffset: inout [CGFloat], _ column: Int, _ yOffset: inout [CGFloat], _ columnWidth: CGFloat, _ fullHeight: inout CGFloat) {
        row2 = delegate?.collectionViewNForms(collectionView, heightForNewFormsCVCell: indexPath) ?? 0.0
        let height = cellPadding * 2 + row2
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        
        
        var insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        if insetFrame.width != 0 {
            do {
                let iframe = try NSKeyedArchiver.archivedData(withRootObject: insetFrame, requiringSecureCoding: true)
                userDefaults.set(iframe, forKey: FJkNEWFORMSINSETFRAME)
                userDefaults.synchronize()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } else {
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: widthOfParent, height: height)
            insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        }
        attributes.frame = insetFrame
        cache.append(attributes)
        fullHeight = fullHeight + height
    }
    
    fileprivate func configureForTodaysIncidentCell(_ row3: inout CGFloat, _ collectionView: UICollectionView, _ indexPath: IndexPath, _ xOffset: inout [CGFloat], _ column: Int, _ yOffset: inout [CGFloat], _ columnWidth: CGFloat, _ fullHeight: inout CGFloat) {
        row3 = delegate?.collectionViewTI(collectionView, heightForTodaysIncidentsCVCell: indexPath) ?? 0.0
        let height = cellPadding * 2 + row3
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        
        var insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        if insetFrame.width != 0 {
            do {
                let iframe = try NSKeyedArchiver.archivedData(withRootObject: insetFrame, requiringSecureCoding: true)
                userDefaults.set(iframe, forKey: FJkTODAYSINCIDENTINSETFRAME)
                userDefaults.synchronize()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } else {
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: widthOfParent, height: height)
            insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        }
        attributes.frame = insetFrame
        cache.append(attributes)
        fullHeight = fullHeight + height
    }
    
    fileprivate func configureForStationResourcesCell(_ row4: inout CGFloat, _ collectionView: UICollectionView, _ indexPath: IndexPath, _ xOffset: inout [CGFloat], _ column: Int, _ yOffset: inout [CGFloat], _ columnWidth: CGFloat, _ fullHeight: inout CGFloat) {
        row4 = delegate?.collectionViewStationResources(collectionView, heightForStationResourcesCVCell: indexPath) ?? 0.0
        let height = cellPadding * 2 + row4
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        
        var insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        if insetFrame.width != 0 {
            do {
                let iframe = try NSKeyedArchiver.archivedData(withRootObject: insetFrame, requiringSecureCoding: true)
                userDefaults.set(iframe, forKey:FJkSTATIONRESOURCEINSETFRAME)
                userDefaults.synchronize()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } else {
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: widthOfParent, height: height)
            insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        }
        attributes.frame = insetFrame
        cache.append(attributes)
        fullHeight = fullHeight + height
    }
    
    fileprivate func configureForIncidentTotalsCell(_ row5: inout CGFloat, _ collectionView: UICollectionView, _ indexPath: IndexPath, _ xOffset: inout [CGFloat], _ column: Int, _ yOffset: inout [CGFloat], _ columnWidth: CGFloat, _ fullHeight: inout CGFloat) {
        row5 =  delegate?.collectionViewIncidentMonths(collectionView, heightForIncidentMonthsTotalsCVCell: indexPath) ?? 0.0
        let height = cellPadding * 2 + row5
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        
        var insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        if insetFrame.width != 0 {
                   do {
                       let iframe = try NSKeyedArchiver.archivedData(withRootObject: insetFrame, requiringSecureCoding: true)
                       userDefaults.set(iframe, forKey:FJkINCIDENTTOTALSINSETFRAME)
                       userDefaults.synchronize()
                   } catch {
                       let nserror = error as NSError
                       fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                   }
               } else {
                   let frame = CGRect(x: xOffset[column], y: yOffset[column], width: widthOfParent, height: height)
                   insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
               }
        attributes.frame = insetFrame
        cache.append(attributes)
        fullHeight = fullHeight + height
    }
    
    fileprivate func configureForWeatherCell(_ row6: inout CGFloat, _ collectionView: UICollectionView, _ indexPath: IndexPath, _ xOffset: inout [CGFloat], _ column: Int, _ yOffset: inout [CGFloat], _ columnWidth: CGFloat, _ fullHeight: inout CGFloat) {
        row6 = delegate?.collectionViewW(collectionView, heightForWeatherCVCell: indexPath) ?? 0.0
        let height = cellPadding * 2 + row6
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        
        var insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        if insetFrame.width != 0 {
            do {
                let iframe = try NSKeyedArchiver.archivedData(withRootObject: insetFrame, requiringSecureCoding: true)
                userDefaults.set(iframe, forKey:FJkWEATHERINSETFRAME)
                userDefaults.synchronize()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } else {
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: widthOfParent, height: height)
            insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        }
        attributes.frame = insetFrame
        cache.append(attributes)
        fullHeight = fullHeight + height
    }
    
    fileprivate func configureShiftButtonCell(_ shift: Shift?, _ row0: inout CGFloat, _ collectionView: UICollectionView, _ indexPath: IndexPath, _ xOffset: inout [CGFloat], _ column: Int, _ yOffset: inout [CGFloat], _ columnWidth: CGFloat, _ fullHeight: inout CGFloat) {
        switch shift {
        case .start:
            row0 = delegate?.collectionViewUPandE(collectionView, heightForUpdateAndEndShiftCVCell: indexPath) ?? 0.0
        case .update:
            row0 = delegate?.collectionViewUPandE(collectionView, heightForUpdateAndEndShiftCVCell: indexPath) ?? 0.0
        case .end:
            row0 = delegate?.collectionViewSS(collectionView, heightForStartShiftCVCell: indexPath) ?? 0.0
        default: break
        }
        let height = cellPadding * 2 + row0
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
        
        var insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        if insetFrame.width != 0 {
            do {
                let iframe = try NSKeyedArchiver.archivedData(withRootObject: insetFrame, requiringSecureCoding: true)
                userDefaults.set(iframe, forKey:FJkSHIFTBUTTONINSETFRAME)
                userDefaults.synchronize()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } else {
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: widthOfParent, height: height)
            insetFrame = frame.insetBy(dx: rightCellPadding, dy: cellPadding)
        }
        attributes.frame = insetFrame
        cache.append(attributes)
        fullHeight = fullHeight + height
    }
    
    override func prepare() {
//        print("orientation = \(orientation) visible = \(visible) numberofcolumns = \(numberOfColumns)")
        if numberOfColumns == 0 {
            if Device.IS_IPAD {
                switch orientation {
                    case 1, 2, 0:
                        if visible {
                            numberOfColumns = 1
                        } else {
                            numberOfColumns = 1
//                            numberOfColumns = 2
                        }
                    case 3, 4:
                        numberOfColumns = 1
//                    numberOfColumns = 2
                    default:
                        numberOfColumns = 1
                }
            } else {
                numberOfColumns = 1
            }
        }
//        print("orientation = \(orientation) visible = \(visible) numberofcolumns = \(numberOfColumns)")
//        let device = (UIApplication.shared.delegate as? AppDelegate)?.device
//        displayMode = userDefaults.integer(forKey: displayModeOfApp)
//        if Device.IS_IPAD {
//            if device == 1 || device == 2 || device == 0{
//                if visible {
//                    numberOfColumns = 1
//                } else {
//                    numberOfColumns = 2
//                }
////                if displayMode == 1 || displayMode == nil {
////                    numberOfColumns = 1
////                } else if displayMode == 2 {
////                    numberOfColumns = 2
////                }
//            } else {
//                numberOfColumns = 2
//            }
//        } else {
//            numberOfColumns = 1
//        }
//        //      numberOfColumns = 1
        guard cache.isEmpty,
            let collectionView = collectionView else {
                return
        }
        
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        
        for column in 0..<numberOfColumns {
            xOffset.append( CGFloat(column) *  columnWidth )
        }
        
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns )
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            let shift = delegate?.whatIsTheShift()
            let row = indexPath.row
            var row0: CGFloat = 0.0
            var row1: CGFloat = 0.0
            var row2: CGFloat = 0.0
            var row3: CGFloat = 0.0
            var row4: CGFloat = 0.0
            var row5: CGFloat = 0.0
            var row6: CGFloat = 0.0
            var fullHeight: CGFloat = 0.0
            
            switch  row {
            case 0:
                configureShiftButtonCell(shift, &row0, collectionView, indexPath, &xOffset, column, &yOffset, columnWidth, &fullHeight)
            case 1:
                configureForNewFormsCell(&row2, collectionView, indexPath, &xOffset, column, &yOffset, columnWidth, &fullHeight)
            case 2:
                configureForShiftsCell(shift, &row1, collectionView, indexPath, &xOffset, column, &yOffset, columnWidth, &fullHeight)
            case 3:
//                if numberOfColumns == 1 {
//                    configureForStationResourcesCell(&row3, collectionView, indexPath, &xOffset, column, &yOffset, columnWidth, &fullHeight)
//                } else {
                    configureForTodaysIncidentCell(&row3, collectionView, indexPath, &xOffset, column, &yOffset, columnWidth, &fullHeight)
//                }
            case 4:
//                if numberOfColumns == 1 {
//                    configureForTodaysIncidentCell(&row4, collectionView, indexPath, &xOffset, column, &yOffset, columnWidth, &fullHeight)
//                } else {
                    configureForStationResourcesCell(&row4, collectionView, indexPath, &xOffset, column, &yOffset, columnWidth, &fullHeight)
//                }
            case 5:
                configureForIncidentTotalsCell(&row5, collectionView, indexPath, &xOffset, column, &yOffset, columnWidth, &fullHeight)
            case 6:
                configureForWeatherCell(&row6, collectionView, indexPath, &xOffset, column, &yOffset, columnWidth, &fullHeight)
            default: break
            }
            
            //            let height = cellPadding * 10 + row0 + row1 + row2 + row3 + row4
//            print("here is row0 \(fullHeight)")
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: fullHeight)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + fullHeight
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
            
        }
        
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
    
    //    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    //      return cache[indexPath.item]
    //    }
    
    
    
}
