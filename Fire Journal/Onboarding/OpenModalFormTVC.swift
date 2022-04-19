//
//  OpenModalFormTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 10/10/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

struct FireJournalUserOnboard {
    var statusAMorOvertime:Bool = true
    var fjuFirstName:String = ""
    var fjuLastName:String = ""
    var fjuEmailAddress:String = ""
    var fjuPhoneNumber:String = ""
    var fjuPlatoon:String = ""
    var fjuPlatoonGuid:String = ""
    var fjuPlatoonTemp:String = ""
    var fjuRank:String = ""
    var fjuFireStation:String = ""
    var fjuAssignment:String = ""
    var fjuAssignmentGuid:String = ""
    var fjuAssignmentTemp:String = ""
    var fjuFDID:String = ""
    var fjuApparatus:String = ""
    var fjuApparatusGuid:String = ""
    var fjuApparatusTemp:String = ""
    var fjuStreetNum:String = ""
    var fjuStreetName:String = ""
    var fjuCity:String = ""
    var fjuState:String = ""
    var fjuZip:String = ""
    var fjuModDate:Date = Date()
    var fjuSearchDate:Date = Date()
    var fjuUserName:String = ""
    var fjuGuid:String = ""
    var fjuLocation:CLLocation?
    var fjuResources:String = ""
    var fjuCrew:String = ""
    var fjuWebSite:String = ""
    var fjuFireDepartment:String = ""
}

protocol OpenModalFormTVCDelegate: AnyObject {
    func theFormIsComplete( yesNo: Bool )
}

class OpenModalFormTVC: UITableViewController,CLLocationManagerDelegate,UITextFieldDelegate ,OnboardDataTVCDelegate {
    
    //    MARK: -PROPERTIES-
    var locationManager:CLLocationManager!
    var city: String = ""
    var streetNum: String = ""
    var streetName: String = ""
    var stateName: String = ""
    var zipNum: String = ""
    var currentLocation: CLLocation!
    var segue:String = "onboardDataSegue"
    var fireJournalUser: FireJournalUserOnboard!
    let userDefaults = UserDefaults.standard
    weak var delegate:OpenModalFormTVCDelegate? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var entity:String = ""
    var attribute:String = ""
    var headerTitle:String = ""
    var incidentType: IncidentTypes!
    let nc = NotificationCenter.default
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var userIsFromCloud:Bool = false
    var fju:FireJournalUser!
    var objectID:NSManagedObjectID? = nil
    var platoons = [UserPlatoon]()
    
    var fetched:Array<Any>!
    
    //    MARK: -IBOutlets-
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailAddressTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var platoonTF: UITextField!
    @IBOutlet weak var rankTF: UITextField!
    @IBOutlet weak var fireStationTF: UITextField!
    @IBOutlet weak var assignmentTF: UITextField!
    @IBOutlet weak var fdidTF: UITextField!
    @IBOutlet weak var apparatusTF: UITextField!
    
    @IBOutlet weak var laterB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    
    
    //    MARK: -UITextFieldDelegate
    //    MARK: -textFieldDelegate
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        let tag = textField.tag
        switch tag {
        case 10:
            fireJournalUser.fjuFirstName = text
        case 11:
            fireJournalUser.fjuLastName = text
        case 12:
            fireJournalUser.fjuEmailAddress = text
        case 13:
            fireJournalUser.fjuPhoneNumber = text
        case 14:
            fireJournalUser.fjuFireStation = text
        default:
            print("no problemo")
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        let tag = textField.tag
        switch tag {
        case 10:
            fireJournalUser.fjuFirstName = text
        case 11:
            fireJournalUser.fjuLastName = text
        case 12:
            fireJournalUser.fjuEmailAddress = text
        case 13:
            fireJournalUser.fjuPhoneNumber = text
        case 14:
            fireJournalUser.fjuFireStation = text
        default:
            print("no problemo")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        let tag = textField.tag
        switch tag {
        case 10:
            fireJournalUser.fjuFirstName = text
        case 11:
            fireJournalUser.fjuLastName = text
        case 12:
            fireJournalUser.fjuEmailAddress = text
        case 13:
            fireJournalUser.fjuPhoneNumber = text
        case 14:
            fireJournalUser.fjuFireStation = text
        default:
            print("no problemo")
        }
    }
    
    //    MARK: -OnboardDataTVCDelegate
    func theCellWasTapped(object: NSManagedObject, type: IncidentTypes) {
        self.dismiss(animated: true, completion: nil)
        switch type {
        case .assignment:
            let userAssignemnt:UserAssignments = object as! UserAssignments
            fireJournalUser.fjuAssignment = userAssignemnt.assignment ?? ""
            fireJournalUser.fjuAssignmentGuid = userAssignemnt.assignmentGuid ?? ""
            fireJournalUser.fjuAssignmentTemp = userAssignemnt.assignment ?? ""
            assignmentTF.text = fireJournalUser.fjuAssignment
        case .apparatus:
            let userApparatus:UserApparatusType = object as! UserApparatusType
            fireJournalUser.fjuApparatus = userApparatus.apparatus ?? ""
            fireJournalUser.fjuApparatusGuid = userApparatus.apparatusGuid ?? ""
            fireJournalUser.fjuApparatusTemp = userApparatus.apparatus ?? ""
            apparatusTF.text = fireJournalUser.fjuApparatus
        case .platoon:
            let userPlatoon:UserPlatoon = object as! UserPlatoon
            fireJournalUser.fjuPlatoon = userPlatoon.platoon ?? ""
            fireJournalUser.fjuPlatoonGuid = userPlatoon.platoonGuid ?? ""
            fireJournalUser.fjuPlatoonTemp = userPlatoon.platoon ?? ""
            platoonTF.text = fireJournalUser.fjuPlatoon
        case .rank:
            let userRank:UserRank = object as! UserRank
            fireJournalUser.fjuRank = userRank.rank ?? ""
            rankTF.text = fireJournalUser.fjuRank
        case .fdid:
            let userFDID:UserFDID = object as! UserFDID
            fireJournalUser.fjuFDID = userFDID.fdidNumber ?? ""
            fdidTF.text = fireJournalUser.fjuFDID
        default:
            print("nothing here")
        }
    }
    
    func theDataModalWasCanceled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func getTheFireJournalUser()->Int {
        var count: Int = 0
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "userGuid", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
            if self.fetched.isEmpty {
                count = 0
            } else {
                fju = (self.fetched.last as? FireJournalUser)!
                count = 1
            }
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
        return count
    }
    
    private func buildFJUOnBoard() {
        if fju != nil  && fireJournalUser != nil {
            fireJournalUser.statusAMorOvertime = fju.shiftStatusAMorOver
            fireJournalUser.fjuFirstName = fju.firstName ?? ""
            firstNameTF.text = fireJournalUser.fjuFirstName
            fireJournalUser.fjuLastName = fju.lastName ?? ""
            lastNameTF.text = fireJournalUser.fjuLastName
            fireJournalUser.fjuEmailAddress = fju.emailAddress ?? ""
            emailAddressTF.text = fireJournalUser.fjuEmailAddress
            fireJournalUser.fjuPhoneNumber = fju.mobileNumber ?? ""
            phoneTF.text = fireJournalUser.fjuPhoneNumber
            fireJournalUser.fjuPlatoon = fju.platoon ?? ""
            platoonTF.text = fireJournalUser.fjuPlatoon
            fireJournalUser.fjuPlatoonGuid = fju.platoonGuid ?? ""
            fireJournalUser.fjuPlatoonTemp = fju.tempPlatoon ?? ""
            fireJournalUser.fjuRank = fju.rank ?? ""
            rankTF.text = fireJournalUser.fjuRank
            fireJournalUser.fjuFireStation = fju.fireStation ?? ""
            fireStationTF.text = fireJournalUser.fjuFireStation
            fireJournalUser.fjuAssignment = fju.initialAssignment ?? ""
            assignmentTF.text = fireJournalUser.fjuAssignment
            fireJournalUser.fjuAssignmentGuid = fju.assignmentGuid ?? ""
            fireJournalUser.fjuAssignmentTemp = fju.tempAssignment ?? ""
            fireJournalUser.fjuFDID = fju.fdid ?? ""
            fdidTF.text = fireJournalUser.fjuFDID
            fireJournalUser.fjuApparatus = fju.initialApparatus ?? ""
            apparatusTF.text = fireJournalUser.fjuApparatus
            fireJournalUser.fjuApparatusGuid = fju.apparatusGuid ?? ""
            fireJournalUser.fjuApparatusTemp = fju.tempApparatus ?? ""
            fireJournalUser.fjuStreetNum = fju.fireStationStreetNumber ?? ""
            fireJournalUser.fjuStreetName = fju.fireStationStreetName ?? ""
            fireJournalUser.fjuCity = fju.fireStationCity ?? ""
            fireJournalUser.fjuState = fju.fireStationState ?? ""
            fireJournalUser.fjuZip = fju.fireStationZipCode ?? ""
            fireJournalUser.fjuModDate = fju.fjpUserModDate ?? Date()
            fireJournalUser.fjuSearchDate = fju.fjpUserSearchDate ?? Date()
            fireJournalUser.fjuUserName = fju.userName ?? ""
            fireJournalUser.fjuGuid = fju.userGuid ?? ""
            //fireJournalUser.fjuLocation = fju.
            fireJournalUser.fjuResources = fju.defaultResources ?? ""
            fireJournalUser.fjuCrew = fju.defaultCrew ?? ""
            fireJournalUser.fjuWebSite = fju.fireStationWebSite ?? ""
            fireJournalUser.fjuFireDepartment = fju.fireDepartment ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundViews()
        determineLocation()
        fireJournalUser = FireJournalUserOnboard()
        userIsFromCloud = userDefaults.bool(forKey: FJkFJUSERSavedToCoreDataFromCloud)
        if userIsFromCloud {
            _ = getTheFireJournalUser()
            buildFJUOnBoard()
            
        }
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    func determineLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        launchNC.removeNC()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if placemarks?.count != 0 {
                let pm = placemarks![0]
                if let pmCity = pm.locality {
                    self.city = "\(pmCity)"
                } else {
                    self.city = ""
                }
                if let pmSubThroughfare = pm.subThoroughfare {
                    self.streetNum = "\(pmSubThroughfare)"
                } else {
                    self.streetNum = ""
                }
                if let pmThoroughfare = pm.thoroughfare {
                    self.streetName = "\(pmThoroughfare)"
                } else {
                    self.streetName = ""
                }
                if let pmState = pm.administrativeArea {
                    self.stateName = "\(pmState)"
                } else {
                    self.stateName = ""
                }
                if let pmZip = pm.postalCode {
                    self.zipNum = "\(pmZip)"
                } else {
                    self.zipNum = ""
                }
                self.fireJournalUser.fjuCity = self.city
                self.fireJournalUser.fjuStreetNum = self.streetNum
                self.fireJournalUser.fjuStreetName = self.streetName
                self.fireJournalUser.fjuState = self.stateName
                self.fireJournalUser.fjuZip = self.zipNum
                self.fireJournalUser.fjuLocation = userLocation
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func alertUser(first:Bool,last:Bool,email:Bool,fireStation:Bool) {
        var message: String = InfoBodyText.onboardUserSaveErrorMessage.rawValue
        if first {
            message = "\(message) First Name,"
        }
        if last {
            message = "\(message) Last Name,"
        }
        if email {
            message = "\(message) Email Address,"
        }
        if fireStation {
            message = "\(message) Fire Station"
        }
        let title:String = "Sign In"
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    //    MARK: -button actions
    @IBAction func saveUserB(_ sender: Any) {
        _ = textFieldShouldEndEditing(firstNameTF)
        _ = textFieldShouldEndEditing(lastNameTF)
        _ = textFieldShouldEndEditing(emailAddressTF)
        _ = textFieldShouldEndEditing(phoneTF)
        _ = textFieldShouldEndEditing(fireStationTF)
        
        var firstNameB = false
        var lastNameB = false
        var fireStationB = false
        var emailB = false
        
        if firstNameTF.text == "" {
            firstNameB = true
        }
        if lastNameTF.text == "" {
            lastNameB = true
        }
        if fireStationTF.text == "" {
            fireStationB = true
        }
        if emailAddressTF.text == "" {
            emailB = true
        }
        
        if !firstNameB, !lastNameB, !fireStationB, !emailB {
            if userIsFromCloud {
                if fireJournalUser != nil && fju != nil {
                    fju.firstName = fireJournalUser.fjuFirstName
                    fju.lastName = fireJournalUser.fjuLastName
                    let first = fireJournalUser.fjuFirstName
                    let last = fireJournalUser.fjuLastName
                    fju.userName = "\(first) \(last)"
                    fireJournalUser.fjuUserName = "\(first) \(last)"
                    fju.shiftStatusAMorOver = fireJournalUser.statusAMorOvertime
                    fju.emailAddress = fireJournalUser.fjuEmailAddress
                    fju.mobileNumber = fireJournalUser.fjuPhoneNumber
                    fju.platoon = fireJournalUser.fjuPlatoon
                    fju.platoonGuid = fireJournalUser.fjuPlatoonGuid
                    fju.tempPlatoon = fireJournalUser.fjuPlatoonTemp
                    fju.rank = fireJournalUser.fjuRank
                    fju.fireStation = fireJournalUser.fjuFireStation
                    fju.initialAssignment = fireJournalUser.fjuAssignment
                    fju.assignmentGuid = fireJournalUser.fjuAssignmentGuid
                    fju.tempAssignment = fireJournalUser.fjuAssignmentTemp
                    fju.tempFireStation = fju.fireStation
                    fju.fdid = fireJournalUser.fjuFDID
                    fju.initialApparatus = fireJournalUser.fjuApparatus
                    fju.apparatusGuid = fireJournalUser.fjuApparatusGuid
                    fju.tempApparatus = fireJournalUser.fjuApparatusTemp
                    fju.fireStationStreetNumber = fireJournalUser.fjuStreetNum
                    fju.fireStationStreetName = fireJournalUser.fjuStreetName
                    fju.fireStationCity = fireJournalUser.fjuCity
                    fju.fireStationState = fireJournalUser.fjuState
                    fju.fireStationZipCode = fireJournalUser.fjuZip
                    fju.fjpUserModDate = fireJournalUser.fjuModDate
                    fju.fjpUserSearchDate = fireJournalUser.fjuSearchDate
                    fju.fjpUserBackedUp = false
                    
                        /// location saved as Data with secureCodeing
                    if fireJournalUser.fjuLocation != nil {
                        if let location = fireJournalUser.fjuLocation {
                            do {
                                let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                                fju.fjuLocationSC = data as NSObject
                            } catch {
                                print("got an error here")
                            }
                        }
                    }
                    
                    let fjuJournal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
                    let journalModDate = Date()
                    let jGuidDate = GuidFormatter.init(date:journalModDate)
                    let jGuid:String = jGuidDate.formatGuid()
                    fjuJournal.fjpJGuidForReference = "01."+jGuid
                    let searchDate = FormattedDate.init(date:journalModDate)
                    let sDate:String = searchDate.formatTheDate()
                    let header:String = "New User created \(sDate)"
                    fjuJournal.journalHeader = header
                    fjuJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
                    fjuJournal.journalEntryType = "Station"
                    let modDate = Date()
                    fjuJournal.journalCreationDate = modDate
                    fjuJournal.journalModDate = modDate
                    fjuJournal.journalDateSearch = sDate
                    fjuJournal.fjpIncReference = ""
                    fjuJournal.fjpUserReference = fireJournalUser.fjuGuid
                    let journalEntry:String = "New User created \(fireJournalUser.fjuFirstName) \(fireJournalUser.fjuLastName) on \(sDate)"
                    fjuJournal.journalOverview = journalEntry as NSObject
                    fjuJournal.journalTempPlatoon = fireJournalUser.fjuPlatoonTemp
                    fjuJournal.journalTempApparatus = fireJournalUser.fjuApparatusTemp
                    fjuJournal.journalTempAssignment = fireJournalUser.fjuAssignmentTemp
                    fjuJournal.journalTempFireStation = fireJournalUser.fjuFireStation
                    fjuJournal.journalFireStation = fireJournalUser.fjuFireStation
                    fjuJournal.journalBackedUp = false
                    fjuJournal.journalPhotoTaken = false
                    
                        //                MARK: -LOCATION-
                        /// location saved as Data with secureCodeing
                    if fireJournalUser.fjuLocation != nil {
                        if let location = fireJournalUser.fjuLocation {
                            do {
                                let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                                fjuJournal.journalLocationSC = data as NSObject
                            } catch {
                                print("got an error here")
                            }
                        }
                    }
                    fjuJournal.journalStreetNumber = fireJournalUser.fjuStreetNum
                    fjuJournal.journalStreetName = fireJournalUser.fjuStreetName
                    fjuJournal.journalCity = fireJournalUser.fjuCity
                    fjuJournal.journalState = fireJournalUser.fjuState
                    fjuJournal.journalZip = fireJournalUser.fjuZip
                    fjuJournal.journalPrivate = true
                    
                    
                    saveToCD()
                    delegate?.theFormIsComplete(yesNo: true)
                }
            } else {
                let fju = FireJournalUser.init(entity: NSEntityDescription.entity(forEntityName: "FireJournalUser", in: context)!, insertInto: context)
                fju.firstName = fireJournalUser.fjuFirstName
                fju.lastName = fireJournalUser.fjuLastName
                let first = fireJournalUser.fjuFirstName
                let last = fireJournalUser.fjuLastName
                fju.userName = "\(first) \(last)"
                fireJournalUser.fjuUserName = "\(first) \(last)"
                fju.shiftStatusAMorOver = fireJournalUser.statusAMorOvertime
                fju.emailAddress = fireJournalUser.fjuEmailAddress
                fju.mobileNumber = fireJournalUser.fjuPhoneNumber
                fju.platoon = fireJournalUser.fjuPlatoon
                fju.platoonGuid = fireJournalUser.fjuPlatoonGuid
                fju.tempPlatoon = fireJournalUser.fjuPlatoonTemp
                fju.rank = fireJournalUser.fjuRank
                fju.fireStation = fireJournalUser.fjuFireStation
                fju.initialAssignment = fireJournalUser.fjuAssignment
                fju.assignmentGuid = fireJournalUser.fjuAssignmentGuid
                fju.tempAssignment = fireJournalUser.fjuAssignmentTemp
                fju.tempFireStation = fju.fireStation
                fju.fdid = fireJournalUser.fjuFDID
                fju.initialApparatus = fireJournalUser.fjuApparatus
                fju.apparatusGuid = fireJournalUser.fjuApparatusGuid
                fju.tempApparatus = fireJournalUser.fjuApparatusTemp
                fju.fireStationStreetNumber = fireJournalUser.fjuStreetNum
                fju.fireStationStreetName = fireJournalUser.fjuStreetName
                fju.fireStationCity = fireJournalUser.fjuCity
                fju.fireStationState = fireJournalUser.fjuState
                fju.fireStationZipCode = fireJournalUser.fjuZip
                let modDate = Date()
                fju.fjpUserModDate = modDate
                fju.fjpUserSearchDate = modDate
                fju.fjpUserBackedUp = false
                let guidDate = GuidFormatter.init(date:modDate)
                let guid:String = guidDate.formatGuid()
                fireJournalUser.fjuGuid = "01"+guid
                fju.userGuid = fireJournalUser.fjuGuid
                fireJournalUser.fjuModDate = modDate
                fireJournalUser.fjuSearchDate = modDate
                
                let fjuJournal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
                let journalModDate = Date()
                let jGuidDate = GuidFormatter.init(date:journalModDate)
                let jGuid:String = jGuidDate.formatGuid()
                fjuJournal.fjpJGuidForReference = "01."+jGuid
                let searchDate = FormattedDate.init(date:journalModDate)
                let sDate:String = searchDate.formatTheDate()
                let header:String = "New User created \(sDate)"
                fjuJournal.journalHeader = header
                fjuJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
                fjuJournal.journalEntryType = "Station"
                fjuJournal.journalCreationDate = modDate
                fjuJournal.journalModDate = modDate
                fjuJournal.journalDateSearch = sDate
                fjuJournal.fjpIncReference = ""
                fjuJournal.fjpUserReference = fireJournalUser.fjuGuid
                let journalEntry:String = "New User created \(fireJournalUser.fjuFirstName) \(fireJournalUser.fjuLastName) on \(sDate)"
                fjuJournal.journalOverview = journalEntry as NSObject
                fjuJournal.journalTempPlatoon = fireJournalUser.fjuPlatoonTemp
                fjuJournal.journalTempApparatus = fireJournalUser.fjuApparatusTemp
                fjuJournal.journalTempAssignment = fireJournalUser.fjuAssignmentTemp
                fjuJournal.journalTempFireStation = fireJournalUser.fjuFireStation
                fjuJournal.journalFireStation = fireJournalUser.fjuFireStation
                fjuJournal.journalBackedUp = false
                fjuJournal.journalPhotoTaken = false
                
//                MARK: -LOCATION-
                /// location saved as Data with secureCodeing
                if fireJournalUser.fjuLocation != nil {
                    if let location = fireJournalUser.fjuLocation {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                        fjuJournal.journalLocationSC = data as NSObject
                    } catch {
                        print("got an error here")
                    }
                    }
                }
                fjuJournal.journalStreetNumber = fireJournalUser.fjuStreetNum
                fjuJournal.journalStreetName = fireJournalUser.fjuStreetName
                fjuJournal.journalCity = fireJournalUser.fjuCity
                fjuJournal.journalState = fireJournalUser.fjuState
                fjuJournal.journalZip = fireJournalUser.fjuZip
                fjuJournal.journalPrivate = true
                
                
                saveToCD()
                
                delegate?.theFormIsComplete(yesNo: true)
            }
            DispatchQueue.main.async {
                self.userDefaults.set(true, forKey: FJkUserAgreementAgreed)
                self.userDefaults.synchronize()
            }
        } else {
            alertUser(first:firstNameB,last:lastNameB,email:emailB,fireStation:fireStationB)
            DispatchQueue.main.async {
                self.userDefaults.set(false, forKey: FJkUserAgreementAgreed)
                self.userDefaults.synchronize()
            }
        }
    }
    
    @IBAction func laterUserB(_ sender: Any) {
        let fju = FireJournalUser.init(entity: NSEntityDescription.entity(forEntityName: "FireJournalUser", in: context)!, insertInto: context)
        fju.firstName = fireJournalUser.fjuFirstName
        fju.lastName = fireJournalUser.fjuLastName
        fju.emailAddress = fireJournalUser.fjuEmailAddress
        fju.mobileNumber = fireJournalUser.fjuPhoneNumber
        fju.platoon = fireJournalUser.fjuPlatoon
        fju.platoonGuid = fireJournalUser.fjuPlatoonGuid
        fju.tempPlatoon = fireJournalUser.fjuPlatoonTemp
        fju.rank = fireJournalUser.fjuRank
        fju.fireStation = fireJournalUser.fjuFireStation
        fju.initialAssignment = fireJournalUser.fjuAssignment
        fju.assignmentGuid = fireJournalUser.fjuAssignmentGuid
        fju.tempAssignment = fireJournalUser.fjuAssignmentTemp
        fju.fdid = fireJournalUser.fjuFDID
        fju.initialApparatus = fireJournalUser.fjuApparatus
        fju.apparatusGuid = fireJournalUser.fjuApparatusGuid
        fju.tempApparatus = fireJournalUser.fjuApparatusTemp
        fju.fireStationStreetNumber = fireJournalUser.fjuStreetNum
        fju.fireStationStreetName = fireJournalUser.fjuStreetName
        fju.fireStationCity = fireJournalUser.fjuCity
        fju.fireStationState = fireJournalUser.fjuState
        fju.fireStationZipCode = fireJournalUser.fjuZip
        let modDate = Date()
        fju.fjpUserModDate = modDate
        fju.fjpUserSearchDate = modDate
        fju.fjpUserBackedUp = false
        
        
        let fjuJournal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
        let journalModDate = Date()
        let jGuidDate = GuidFormatter.init(date:journalModDate)
        let jGuid:String = jGuidDate.formatGuid()
        fjuJournal.fjpJGuidForReference = "01."+jGuid
        let searchDate = FormattedDate.init(date:journalModDate)
        let sDate:String = searchDate.formatTheDate()
        let header:String = "Unfinished User created \(sDate)"
        fjuJournal.journalHeader = header
        fjuJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        fjuJournal.journalEntryType = "Station"
        fjuJournal.journalCreationDate = journalModDate
        fjuJournal.journalModDate = journalModDate
        fjuJournal.journalDateSearch = sDate
        fjuJournal.fjpIncReference = ""
        fjuJournal.fjpUserReference = fireJournalUser.fjuGuid
        let journalEntry:String = "New User created \(fireJournalUser.fjuFirstName) \(fireJournalUser.fjuLastName) on \(sDate)"
        fjuJournal.journalOverview = journalEntry as NSObject
        fjuJournal.journalTempPlatoon = fireJournalUser.fjuPlatoonTemp
        fjuJournal.journalTempApparatus = fireJournalUser.fjuApparatusTemp
        fjuJournal.journalTempAssignment = fireJournalUser.fjuAssignmentTemp
        fjuJournal.journalTempFireStation = fireJournalUser.fjuFireStation
        fjuJournal.journalFireStation = fireJournalUser.fjuFireStation
        fjuJournal.journalBackedUp = false
        fjuJournal.journalPhotoTaken = false
        
//        MARK: -LOCATION-
        /// location saved as Data with secureCodeing
        if fireJournalUser.fjuLocation != nil {
            if let location = fireJournalUser.fjuLocation {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                fjuJournal.journalLocationSC = data as NSObject
            } catch {
                print("got an error here")
            }
            }
        }
        
        fjuJournal.journalStreetNumber = fireJournalUser.fjuStreetNum
        fjuJournal.journalStreetName = fireJournalUser.fjuStreetName
        fjuJournal.journalCity = fireJournalUser.fjuCity
        fjuJournal.journalState = fireJournalUser.fjuState
        fjuJournal.journalZip = fireJournalUser.fjuZip
        fjuJournal.journalPrivate = true
        fjuJournal.fireJournalUserInfo = fju
        
        saveToCD()
        delegate?.theFormIsComplete(yesNo: false)
        
    }
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Open Modal Form TVC merge that"])
            }
            let nc = NotificationCenter.default
            if let guid = fireJournalUser?.fjuGuid {
                getTheLastSaved(guid: guid )
            }
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue: FJkFireJournalUserSaved),
                        object: nil,
                        userInfo: ["user":self.fireJournalUser as FireJournalUserOnboard])
                if self.userIsFromCloud {
                    self.nc.post(name: .fireJournalUserModifiedSendToCloud , object: nil, userInfo: ["objectID": self.objectID as Any])
                } else {
                    nc.post(name:Notification.Name(rawValue:FJkFJUserNEWSendToCloud),
                            object: nil,
                            userInfo: ["user":self.objectID!])
                }
            }
        } catch {
            let nserror = error as NSError
            let errorMessage = "OpenModalFormTVC saveToCD() Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    private func getTheLastSaved(guid: String) {
        if guid == "" {
            return
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        let predicate = NSPredicate(format: "%K == %@", "userGuid", guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "fjpUserModDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        do {
            self.fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
            let fjUser = self.fetched.last as! FireJournalUser
            self.objectID = fjUser.objectID
        } catch let error as NSError {
            let errorMessage = "OpenModalFormTVC saveToCD() Unresolved error \(error), \(error.userInfo)"
            print(errorMessage)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 12
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch row {
        case 6:
            loadPlatoonTVC()
            //            print("tapping 6")
            //            entity = "UserPlatoon"
            //            attribute = "platoon"
            //            headerTitle = "Choose Your Platoon"
            //            incidentType = .platoon
        //            performSegue(withIdentifier: segue, sender: self)
        case 7:
            print("tapping 7")
            entity = "UserRank"
            attribute = "rank"
            headerTitle = "Choose Your Rank"
            incidentType = .rank
            performSegue(withIdentifier: segue, sender: self)
        case 9:
            print("tapping 9")
            entity = "UserAssignments"
            attribute = "assignment"
            headerTitle = "Choose Your Assignment"
            incidentType = .assignment
            performSegue(withIdentifier: segue, sender: self)
        case 10:
            print("tapping 10")
            entity = "UserFDID"
            attribute = "hqState"
            headerTitle = "Choose Your FDID"
            incidentType = .fdid
            performSegue(withIdentifier: segue, sender: self)
        case 11:
            print("tapping 11")
            entity = "UserApparatusType"
            attribute = "apparatus"
            headerTitle = "Choose Your Apparatus"
            incidentType = .apparatus
            performSegue(withIdentifier: segue, sender: self)
        default:
            print("one of 0-5, or 8")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "onboardDataSegue" {
            let detailTV:OnboardDataTVC = segue.destination as! OnboardDataTVC
            detailTV.delegate = self
            detailTV.context = context
            detailTV.entity = entity
            detailTV.attribute = attribute
            detailTV.headerTitle = headerTitle
            detailTV.incidentType = incidentType
            if entity == "UserFDID" {
                detailTV.theState = stateName
                detailTV.theCity = city
            }
        }
        
    }
    
    private func loadPlatoonTVC(){
        let platoons = getThePlatoons()
        let storyboard = UIStoryboard(name: "Platoons", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! PlatoonsVC
        vc.platoons = platoons
        vc.delegate = self
        present(vc, animated: true )
    }
    
    
}

extension OpenModalFormTVC: PlatoonsVCDelegate {
    
    // Mark: -Get The Data Platoons-
    /// GetThePlatoons returns Array of Platoons used PlatoonTVC
    private func getThePlatoons() -> [UserPlatoon] {
        var platoons = [UserPlatoon]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserPlatoon" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "platoon", "")
        fetchRequest.predicate = predicate
        let sectionSortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            platoons = try context.fetch(fetchRequest) as! [UserPlatoon]
        }  catch let error as NSError {
            print("OpenModalFormTVC line 803 Fetch Error: \(error.localizedDescription)")
        }
        return platoons
    }
    
    func platoonsCancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func platoonsVCChosen(platoon: UserPlatoon) {
        let userPlatoon:UserPlatoon = platoon
        fireJournalUser.fjuPlatoon = userPlatoon.platoon ?? ""
        fireJournalUser.fjuPlatoonGuid = userPlatoon.platoonGuid ?? ""
        fireJournalUser.fjuPlatoonTemp = userPlatoon.platoon ?? ""
        platoonTF.text = userPlatoon.platoon ?? ""
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}
