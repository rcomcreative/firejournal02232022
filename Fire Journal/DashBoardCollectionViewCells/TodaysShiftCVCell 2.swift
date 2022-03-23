//
//  TodaysShiftCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/4/19.
//  Copyright © 2019 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreLocation

class TodaysShiftCVCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    //    MARK: -Objects-
    @IBOutlet weak var gradientHeaderIV: UIImageView!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var shiftSubjectL: UILabel!
    @IBOutlet weak var shiftStatusSubjectL: UILabel!
    @IBOutlet weak var shiftStatusL: UILabel!    
    @IBOutlet weak var statusSubjectL: UILabel!
    @IBOutlet weak var statusL: UILabel!
    @IBOutlet weak var shiftStartTimeSubjectL: UILabel!
    @IBOutlet weak var shiftStartTimeL: UILabel!
    @IBOutlet weak var platoonSubjectL: UILabel!
    @IBOutlet weak var platoonColorIV: UIImageView!
    @IBOutlet weak var platoonL: UILabel!
    @IBOutlet weak var fireStationSubjectL: UILabel!
    @IBOutlet weak var fireStationNumL: UILabel!
    @IBOutlet weak var assignmentSubjectL: UILabel!
    @IBOutlet weak var assignmentL: UILabel!
    @IBOutlet weak var assignedApparatusSubjectL: UILabel!
    @IBOutlet weak var assignedApparatusL: UILabel!
    @IBOutlet weak var resourceSubjectL: UILabel!
    @IBOutlet weak var resourcesCV: UICollectionView!
    @IBOutlet weak var supervisorSubjectL: UILabel!
    @IBOutlet weak var supervisorL: UILabel!
    @IBOutlet weak var weatherSubjectL: UILabel!
    @IBOutlet weak var weatherL: UILabel!
    @IBOutlet weak var burnSubjectL: UILabel!
    @IBOutlet weak var burnL: UILabel!
    @IBOutlet weak var windSubjectL: UILabel!
    @IBOutlet weak var windL: UILabel!
    
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
    
    var shiftData: TodayShiftData! {
        didSet {
            self.shiftStatusL.text = self.shiftData.shiftStatusName
            self.statusL.text = self.shiftData.shiftStartDate
            self.shiftStartTimeL.text = self.shiftData.shiftStartTime
            self.platoonL.text = self.shiftData.shiftPlatoonName
            self.fireStationNumL.text = self.shiftData.shiftFireStationNumber
            self.assignmentL.text = self.shiftData.shiftAssignment
            self.supervisorL.text = self.shiftData.shiftSupervisor
            self.fdResources = self.shiftData.resources
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
            print("TodaysShiftCVC THEUSERTIMECOUNT line 66 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func buildTheStatus() {
        let utGuid = userDefaults.string(forKey: FJkUSERTIMEGUID)
        theUserTimeCount(entity: "UserTime", guid: utGuid ?? "")
        if utGuid == fjUserTime.userTimeGuid {
            if let time = fjUserTime.userStartShiftTime {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE MMM dd,YYYY"
                let stringDate = dateFormatter.string(from: time )
                statusL.text = stringDate
                dateFormatter.dateFormat = "HH:mm"
                let stringTime = dateFormatter.string(from: time )
                shiftStartTimeL.text = "\(stringTime) HRs"
            }
            if let platoon = fjUserTime.startShiftPlatoon {
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
            if let station = fjUserTime.startShiftFireStation {
                fireStationNumL.text = station
            }
            if let assignment = fjUserTime.startShiftAssignment {
                assignmentL.text = assignment
            }
            if let apparatus = fjUserTime.startShiftApparatus {
                assignedApparatusL.text = apparatus
            }
            if let supervisor = fjUserTime.startShiftSupervisor {
                supervisorL.text = supervisor
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
    
    //    MARK: -Properties
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundViews()
//        if theAgreement {
//            buildTheStatus()
//            buildResources()
            
            registerTheCells()
            
            self.resourcesCV.dataSource = self
            self.resourcesCV.delegate = self
//        }
    }
    
    func roundViews() {
        self.contentView.layer.cornerRadius = 6
        self.contentView.clipsToBounds = true
        self.contentView.layer.borderColor = UIColor.systemRed.cgColor
        self.contentView.layer.borderWidth = 2
    }
    
    func registerTheCells() {
        resourcesCV.register(UINib.init(nibName: "UserFDResourceCVCell", bundle: nil), forCellWithReuseIdentifier: "UserFDResourceCVCellIdentifier")
        resourcesCV.register(UINib.init(nibName: "UserFDResourceCustomCVCell", bundle: nil), forCellWithReuseIdentifier: "UserFDResourceCustomCVCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fdResources.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let resource = fdResources[row]
        let custom = resource.customResource
        switch collectionView {
        case resourcesCV:
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


extension TodaysShiftCVCell:  UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView {
        case resourcesCV:
            // Number of cells
            let collectionViewWidth: CGFloat!
            let collectionViewHeight: CGFloat!
            if Device.IS_IPAD {
                collectionViewWidth = 53.27272727272727
//                    collectionView.bounds.width/5.5
               collectionViewHeight = 240
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

extension TodaysShiftCVCell: ResourcesLayoutProtocol {
    func resourcesCollectionView(_ collectionView: UICollectionView, heightForUserFDResourcesCell indexPath: IndexPath) -> CGFloat {
        let indexPath = indexPath
        let cell = resourcesCV.dequeueReusableCell(withReuseIdentifier: "UserFDResourceCVCellIdentifier", for: indexPath as IndexPath) as! UserFDResourceCVCell
        let height = cell.contentView.bounds.size.height
        return height
    }
}
