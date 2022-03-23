//
//  UpdateShiftCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/4/19.
//  Copyright © 2019 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreLocation

class UpdateShiftCVCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //    MARK: -Objects-
    @IBOutlet weak var gradientHeaderIV: UIImageView!
    @IBOutlet weak var shiftIconIV: UIImageView!
    @IBOutlet weak var shiftStatusSubjectL: UILabel!
    @IBOutlet weak var shiftStatusL: UILabel!
    @IBOutlet weak var shiftSubjectL: UILabel!
    @IBOutlet weak var statusSubjectL: UILabel!
    @IBOutlet weak var statusDateL: UILabel!
    @IBOutlet weak var shiftUpdateTimeSubjectL: UILabel!
    @IBOutlet weak var shiftUpdateTimeL: UILabel!
    @IBOutlet weak var platoonSubjectL: UILabel!
    @IBOutlet weak var platoonColorIV: UIImageView!
    @IBOutlet weak var platoonL: UILabel!
    @IBOutlet weak var fireStationSubjectL: UILabel!
    @IBOutlet weak var fireStationL: UILabel!
    @IBOutlet weak var resourcesSubjectL: UILabel!
    @IBOutlet weak var resourcesCollectionV: UICollectionView!
    @IBOutlet weak var crewSubjectL: UILabel!
    @IBOutlet weak var crewCV: UICollectionView!
    
    var column: Int = 1
    //    MARK: -Properties
    var resources = [UserFDResource]()
    var fetchedResources: [UserFDResources]!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fdResources = [UserFDResources]()
    let userDefaults = UserDefaults.standard
    var fjUserTime:UserTime!
    
    private var theAgreement: Bool = false
    var agreementAccepted: Bool = false {
        didSet {
            self.theAgreement = self.agreementAccepted
        }
    }
    
    var updateShiftData: UpdateShiftDashbaordData! {
        didSet {
            self.fdResources = self.updateShiftData.resources
            self.shiftStatusL.text = self.updateShiftData.shiftStatusName
            self.statusDateL.text = self.updateShiftData.shiftUpdateDate
            self.shiftUpdateTimeL.text = self.updateShiftData.shiftUpdateTime
            self.platoonL.text = self.updateShiftData.shiftPlatoonName
            self.fireStationL.text = self.updateShiftData.shiftFireStationNumber
        }
    }
    
    private func theUserTimeCount(entity: String, guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", "userTimeGuid", guid)
        fetchRequest.predicate = predicate
        do {
            let userFetched = try context.fetch(fetchRequest) as! [UserTime]
            if userFetched.isEmpty {
                
            } else {
                fjUserTime = userFetched.last!
            }
        } catch let error as NSError {
            print("UpdateShiftCVC THEUSERTIMECOUNT line 57 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func buildTheStatus() {
    let utGuid = userDefaults.string(forKey: FJkUSERTIMEGUID)
        theUserTimeCount(entity: "UserTime", guid: utGuid ?? "")
    if utGuid == fjUserTime.userTimeGuid {
        if let time = fjUserTime.userUpdateShiftTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE MMM dd,YYYY"
            let stringDate = dateFormatter.string(from: time )
            statusDateL.text = stringDate
            dateFormatter.dateFormat = "HH:mm"
            let stringTime = dateFormatter.string(from: time )
            shiftUpdateTimeL.text = "\(stringTime) HRs"
        }
        if let platoon = fjUserTime.updateShiftPlatoon {
            if platoon == "Platoon A" {
                platoonL.text = platoon
                platoonL.textColor = UIColor.systemRed
            } else if platoon == "Platoon B" {
                platoonL.text = platoon
                platoonL.textColor = UIColor.systemBlue
            } else if platoon == "Platoon C" {
                platoonL.text = platoon
                platoonL.textColor = UIColor.systemGreen
            } else if platoon == "Platoon D" {
                platoonL.text = platoon
                platoonL.textColor = UIColor.systemOrange
            }
        }
        if let station = fjUserTime.updateShiftFireStation {
            fireStationL.text = station
        }
        }
    }
    
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
//      r
                registerTheCells()

                
                self.resourcesCollectionV.dataSource = self
                self.resourcesCollectionV.delegate = self
//            }
        }
        
        func roundViews() {
            self.contentView.layer.cornerRadius = 6
            self.contentView.clipsToBounds = true
            self.contentView.layer.borderColor = UIColor.systemRed.cgColor
            self.contentView.layer.borderWidth = 2
        }
    
    func registerTheCells() {
        resourcesCollectionV.register(UINib.init(nibName: "UserFDResourceCVCell", bundle: nil), forCellWithReuseIdentifier: "UserFDResourceCVCellIdentifier")
        resourcesCollectionV.register(UINib.init(nibName: "UserFDResourceCustomCVCell", bundle: nil), forCellWithReuseIdentifier: "UserFDResourceCustomCVCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fdResources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let resource = fdResources[row]
        let custom = resource.customResource
        switch collectionView {
        case resourcesCollectionV:
            if custom {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserFDResourceCustomCVCell", for: indexPath as IndexPath) as! UserFDResourceCustomCVCell
                cell.userFDResource = resource
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserFDResourceCVCellIdentifier", for: indexPath as IndexPath) as! UserFDResourceCVCell
                cell.userFDResource = resource
                return cell
            }
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserFDResourceCVCellIdentifier", for: indexPath as IndexPath) as! UserFDResourceCVCell
                        return cell
        }
    }

}

extension UpdateShiftCVCell:  UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth: CGFloat!
        let collectionViewHeight: CGFloat!
        if Device.IS_IPAD {
            collectionViewWidth = 53.27272727272727
            collectionViewHeight = 145
        } else {
            collectionViewWidth = collectionView.bounds.width/5.0
            collectionViewHeight = 111
        }
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
        
    }
    
}

extension UpdateShiftCVCell: ResourcesLayoutProtocol {
    func resourcesCollectionView(_ collectionView: UICollectionView, heightForUserFDResourcesCell indexPath: IndexPath) -> CGFloat {
        let indexPath = indexPath
        let cell = resourcesCollectionV.dequeueReusableCell(withReuseIdentifier: "UserFDResourceCVCellIdentifier", for: indexPath as IndexPath) as! UserFDResourceCVCell
        let height = cell.contentView.bounds.size.height
        return height
    }
}

extension UpdateShiftCVCell: CrewLayoutProtocol {
    func crewCollectionView(_ collectionView: UICollectionView, heightForUpdateCrewCVCell indexPath: IndexPath) -> CGFloat {
        let indexPath = indexPath
        let cell = crewCV.dequeueReusableCell(withReuseIdentifier: "UpdateCrewCVCellIdentifier", for: indexPath as IndexPath) as! UpdateCrewCVCell
        let height = cell.contentView.bounds.size.height
        return height
    }
}
