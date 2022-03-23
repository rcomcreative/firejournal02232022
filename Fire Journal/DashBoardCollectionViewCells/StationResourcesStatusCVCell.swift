//
//  StationResourcesStatusCVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 1/2/20.
//  Copyright © 2020 inSky LE. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreLocation


class StationResourcesStatusCVCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var headerIV: UIImageView!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var stationResourcesCV: UICollectionView!
    
    var resources = [UserFDResource]()
    var fetchedResources: [UserFDResources]!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fdResources = [UserFDResources]()
    
    func buildResources() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDResources")
                       let sectionSortDescriptor = NSSortDescriptor(key: "fdResource", ascending: true)
                       let sortDescriptors = [sectionSortDescriptor]
                       fetchRequest.sortDescriptors = sortDescriptors
                       fetchRequest.returnsObjectsAsFaults = false
                       do {
                        fetchedResources = try context.fetch(fetchRequest) as? [UserFDResources]
                           if fetchedResources.count == 0 {
                           } else {
                               for resource in fetchedResources {
                                   let objectID = resource.objectID
                                   var customImage: Bool = false
                                   let imageType: Int64 = resource.fdResourceType
                                   var name: String = ""
                                   if let resourceName = resource.fdResource {
                                       name = resourceName
                                   }
                                   if resource.customResource {
                                           customImage = true
                                   }
                                   let r = UserFDResource.init(type: imageType, resource: name, objectID: objectID, custom: customImage)
                                   r.resourceStatusImageName = resource.fdResource ??  ""
                                   if let count = Int64(resource.fdResourcesPersonnelCount ?? "0") {
                                       r.resourcePersonnelCount = count
                                   }
                                   r.resourceManufacturer = resource.fdManufacturer ?? ""
                                   r.resourceID = resource.fdResourceID ?? ""
                                   r.resourceShopNumber = resource.fdShopNumber ?? ""
                                   r.resourceApparatus = resource.fdResourceApparatus ?? ""
                                   r.resourceSpecialities = resource.fdResourcesSpecialties ?? ""
                                   r.resourceDescription = resource.fdResourceDescription ?? ""
                                   r.resourceYear = resource.fdYear ?? ""
                                   resources.append(r)
                                   fdResources.append(resource)
                               }
                           }
                       }  catch {
                           let nserror = error as NSError
                           let errorMessage = "SettingsUserFDResourcesTVC getUserFDResources Unresolved error \(nserror), \(nserror.userInfo)"
                           print(errorMessage)
                       }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundViews()
        configureCells()
        
        buildResources()
        
        let frCollectionViewHeight = CGFloat(150)
        let fdFrame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: frCollectionViewHeight)
        stationResourcesCV.frame = fdFrame
        let height = self.contentView.bounds.height + (stationResourcesCV.frame.height - 30.0)
        let frame2 = CGRect(x: 0.0, y: 0.0, width: self.contentView.bounds.width, height: height)
        self.contentView.frame = frame2
        self.stationResourcesCV.dataSource = self
        self.stationResourcesCV.delegate = self
        }
        
        func roundViews() {
            self.contentView.layer.cornerRadius = 6
            self.contentView.clipsToBounds = true
            self.contentView.layer.borderColor = UIColor.systemRed.cgColor
            self.contentView.layer.borderWidth = 2
        }
    
    func configureCells() {
        stationResourcesCV.register(UINib.init(nibName: "UserFDResourceCVCell", bundle: nil), forCellWithReuseIdentifier: "UserFDResourceCVCellIdentifier")
       stationResourcesCV.register(UINib.init(nibName: "UserFDResourceCustomCVCell", bundle: nil), forCellWithReuseIdentifier: "UserFDResourceCustomCVCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let resource = fdResources[row]
        let custom = resource.customResource
        switch collectionView {
        case stationResourcesCV:
            if custom {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserFDResourceCustomCVCell", for: indexPath as IndexPath) as! UserFDResourceCustomCVCell
                cell.userFDResource = fdResources[row]
//                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserFDResourceCVCellIdentifier", for: indexPath as IndexPath) as! UserFDResourceCVCell
                cell.userFDResource = resource
                cell.delegate = self
                return cell
            }
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserFDResourceCVCellIdentifier", for: indexPath as IndexPath) as! UserFDResourceCVCell
            return cell
        }
    }

}

extension StationResourcesStatusCVCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView {
        case stationResourcesCV:
            // Number of cells
            let collectionViewWidth: CGFloat!
            let collectionViewHeight: CGFloat!
            if Device.IS_IPAD {
//                collectionViewWidth = 53.27272727272727
                let inset: CGFloat = 10
//                let minimumLineSpacing: CGFloat = 10
                let minimumInteritemSpacing: CGFloat = 10
                let cellsPerRow = 5
                let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
                collectionViewWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
                
//                collectionViewWidth =   collectionView.bounds.width/8.5
               collectionViewHeight = 111
            } else {
               collectionViewWidth = collectionView.bounds.width/5.0
               collectionViewHeight = 111
            }
            return CGSize(width: collectionViewWidth, height: collectionViewHeight)
        default:
            // Number of cells
            let collectionViewWidth: CGFloat!
            let collectionViewHeight: CGFloat!
            collectionViewWidth = 342
//                collectionView.bounds.width
            collectionViewHeight = 82.0
            return CGSize(width: collectionViewWidth, height: collectionViewHeight)
        }
        
    }
    
}

extension StationResourcesStatusCVCell: UserFDResourceCVCellDelegate {
    func userFDResourceCVTapped(resource: UserFDResources) {
        let resourced = resource.fdResource ?? ""
        print("no custom tapped \(resourced)")
//        delegate?.aResourceHasBeenTappedForEditing(resource: resource)
    }
}
