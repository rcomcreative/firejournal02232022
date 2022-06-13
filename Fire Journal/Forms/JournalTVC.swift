//
//  JournalTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 9/4/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

public enum JournalTypes:Int {
    case overview
    case discussion
    case nextSteps
    case summary
    case station
    case community
    case members
    case crew
    case tags
    case userInfo
    case endShift
    case startShift
    case incidentNote
    case alarmNote
    case arrivalNote
    case controlledNote
    case lastUnitStandingNote
    case fireStation
    case platoon
    case apparatus
    case assignment
    case personal
}

protocol JournalTVCDelegate: AnyObject {
    func goBack()
    func journalSaveTapped()
    func journalBackToList()
}



class JournalTVC: UITableViewController,JournalInfoCellDelegate, LabelTextViewDirectionalCellDelegate, AddressFieldsButtonsCellDelegate,MapViewCellDelegate,PhotoTVCellDelegate,CLLocationManagerDelegate,DataTVCDelegate,DataModalTVCDelegate,NSFetchedResultsControllerDelegate,TagsTVCDelegate,CrewModalTVCDelegate {
    
    //    MARK: -Properties-
    var saveV: UIView!
    var savedL: UILabel!
    var saveLConstraint: NSLayoutConstraint!
    var sizeTrait: SizeTrait = .regular
    var journalType: JournalTypes = .station
    var journalStructure: JournalData!
    weak var delegate:JournalTVCDelegate? = nil
    var titleName:String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var controllerName:String = ""
    var myShift:MenuItems = .journal
    var city: String = ""
    var streetNum: String = ""
    var streetName: String = ""
    var stateName: String = ""
    var zipNum: String = ""
    var showMap: Bool = false
    let nc = NotificationCenter.default
    var compact:SizeTrait = .regular
    var currentLocation: CLLocation!
    var locationManager:CLLocationManager!
    var theTags = [String]()
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var id = NSManagedObjectID()
    var journal:Journal!
    var fju:FireJournalUser!
    var fjuStreetName: String = ""
    var fjuStreetNumber: String = ""
    var fjuCity: String = ""
    var fjuState: String = ""
    var fjuZip: String = ""
    var theUser: UserEntryInfo!
    var theUserCrew: UserCrews!
    var theCrew: TheCrew!
    var fetched:Array<Any>!
    var showSaved:Bool = false
    var objectID: NSManagedObjectID!
    var timeStampedNextSteps: Bool = false
    var timeStampedDiscussion: Bool = false
    var timeStampedSummary: Bool = false
    var overViewHeight: CGFloat = 110
    var discussionHeight: CGFloat = 200
    var nextStepsHeight: CGFloat = 200
    var summaryHeight: CGFloat = 200
    var alertUp: Bool = false
    
    //    MARK: -CrewModalTVCDelegate
    func theCrewModalCancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theCrewModalChosenTapped(crew: TheCrew, objectID: NSManagedObjectID) {
        theUserCrew = context.object(with: objectID) as? UserCrews
        journalStructure.journalCrewCombine = " \(crew.crew)"
        journalStructure.journalCrewName = crew.crewName
        journalStructure.journalCrew = crew.crew
        journalStructure.journalCrewA = crew.crew.components(separatedBy: ",")
        theCrew = crew
        self.dismiss(animated: true, completion:nil)
        tableView.reloadData()
    }
    
    func theDataModalChosen(objectID: NSManagedObjectID, user: UserInfo) {
        // TODO:
    }
    
    func dataModalCancelCalled() {
        self.dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
    
    fileprivate func presentModal(menuType: MenuItems, title: String, type: JournalTypes) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "DataTVC") as! DataTVC
        dataTVC.delegate = self
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        dataTVC.myShiftTitle = title
        dataTVC.myShift = menuType
        dataTVC.journalType = type
        dataTVC.theUser = UserEntryInfo.init(user:"")
        dataTVC.theUser = theUser
        dataTVC.userName = theUser.user
        dataTVC.entryType = theUser.entryType
        dataTVC.platoon = theUser.platoon
        dataTVC.fireStation = theUser.fireStation
        dataTVC.apparatus = theUser.apparatus
        dataTVC.assignment = theUser.assignment
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
    }
    
    fileprivate func presentModalTwo(menuType: MenuItems, title: String, type: JournalTypes) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "DataModalTVC") as! DataModalTVC
        dataTVC.delegate = self
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        dataTVC.headerTitle = title
        dataTVC.myShift = menuType
        dataTVC.journalType = type
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
    }
    
    fileprivate func presentCrew(menuType:MenuItems, title:String, type:JournalTypes){
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "RelieveSupervisorModal", bundle:nil)
        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "RelieveSupervisorModalTVC") as! RelieveSupervisorModalTVC
        dataTVC.delegate = self
        dataTVC.headerTitle = "Crew"
        dataTVC.menuType = MenuItems.journal
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "CrewModalTVC") as! CrewModalTVC
        //        dataTVC.delegate = self
        //        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        //        dataTVC.headerTitle = title
        //        dataTVC.myShift = menuType
        //        dataTVC.modalPresentationStyle = .custom
        //        self.present(dataTVC, animated: true, completion: nil)
    }
    
    //    MARK: -TagsTVCDelegate
    func theCancelTagsBTapped() {}
    func theTagsHaveBeenChosen(tags:Array<String>) {
        theTags = tags.filter { $0 != "" }
        let tag:String = theTags.joined(separator: ", ")
        journalStructure.journalTags = tag
        journalStructure.journalTagsA = theTags
        tableView.reloadData()
    }
    
    fileprivate func presentTags(menuType:MenuItems, title:String, type:JournalTypes) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "TagsTVC") as! TagsTVC
        dataTVC.delegate = self
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        if journalStructure.journalTagsA.count != 0 {
            dataTVC.selected = journalStructure.journalTagsA
        }
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
    }
    
    //    MARK: -DataTVCDelegate
    func theJournalDataSaveTapped(type: JournalTypes,user:UserEntryInfo) {
        
        theUser.platoon = user.platoon
        theUser.platoonGuid = user.platoonGuid
        theUser.platoonDefault = user.platoonDefault
        journalStructure.journalPlatoon = user.platoon
        
        theUser.assignment = user.assignment
        theUser.assignmentGuid = user.assignmentGuid
        theUser.assignmentDefault = user.assignmentDefault
        journalStructure.journalAssignment = user.assignment
        
        theUser.apparatus = user.apparatus
        theUser.apparatusGuid = user.apparatusGuid
        theUser.apparatusDefault = user.apparatusDefault
        journalStructure.journalApparatus = user.apparatus
        
        theUser.user = user.user
        journalStructure.journalUser = user.user
        theUser.entryType = user.entryType
        journalStructure.journalType = user.entryTypeS
        switch user.entryType {
        case .station:
            journalStructure.journalTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        case .community:
            journalStructure.journalTypeImageName = "ICONS_communityboard color"
        case .members:
            journalStructure.journalTypeImageName = "ICONS_Membersboard color"
        case .training:
            journalStructure.journalTypeImageName = "ICONS_training"
        default:
            journalStructure.journalTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        }
        theUser.fireStation = user.fireStation
        journalStructure.journalFireStation = user.fireStation
        DispatchQueue.main.async {
            self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                         object: nil, userInfo: ["shift":MenuItems.journal])
        }
        tableView.reloadData()
    }
    func theDataTVCCancelled() {
    }
    func theDataSaveTapped(type: IncidentTypes) {
    }
    //    MARK: -PhotoTVCellDelegate
    func cameraButtonTapped() {
        //        TODO:
    }
    //    MARK: -MAPVIEWCEllDelgate
    func theMapCellInfoBTapped() {
        presentAlert()
    }
    
    func presentAlert() {
        let title: InfoBodyText = .mapSupportNotesSubject
        let message: InfoBodyText = .mapSupportNotes
        let alert = UIAlertController.init(title: title.rawValue , message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func theMapLocationHasBeenChosen(location: CLLocation) {
        //        <#code#>
    }
    
    func theMapCancelButtonTapped() {
        //        <#code#>
    }
    func theAddressHasBeenChosen(addressStreetNum:String,addressStreetName:String, addressCity: String, addressState: String, addressZip: String, location: CLLocation) {
        currentLocation = location
        journalStructure.journalLocation = currentLocation
        journalStructure.journalLongitude = String(currentLocation.coordinate.longitude)
        journalStructure.journalLatitude = String(currentLocation.coordinate.latitude)
        streetNum = addressStreetNum
        journalStructure.journalStreetNum = streetNum
        streetName = addressStreetName
        journalStructure.journalStreetName = addressStreetName
        city = addressCity
        journalStructure.journalCity = addressCity
        stateName = addressState
        journalStructure.journalState = addressState
        zipNum = addressZip
        journalStructure.journalZip = addressZip
        
        if showMap {
            showMap = false
        } else {
            showMap = true
        }
        
        self.tableView.reloadData()
    }
    
    //    MARK: -AddressFieldsButtonsCellDELEGATE
    func worldBTapped() {
        if showMap {
            showMap = false
        } else {
            showMap = true
        }
        //        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
        
        self.tableView.reloadData()
        if showMap {
            let rowNumber: Int = 8
            let sectionNumber: Int = 0
            let indexPath = IndexPath(item: rowNumber, section: sectionNumber)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    func addressFieldFinishedEditing(address: String, tag: Int) {
        //        TODO:
    }
    
    
    func locationBTapped() {
        determineLocation()
    }
    
    
    func determineLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //                locationManager.requestAlwaysAuthorization()
            //                locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) -> Void in
            print(userLocation)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if placemarks?.count != 0 {
                let pm = placemarks![0]
                print(pm.locality!)
                self.city = "\(pm.locality!)"
                self.journalStructure.journalCity = "\(pm.locality!)"
                self.streetNum = "\(pm.subThoroughfare!)"
                self.journalStructure.journalStreetNum = "\(pm.subThoroughfare!)"
                self.streetName = "\(pm.thoroughfare!)"
                self.journalStructure.journalStreetName = "\(pm.thoroughfare!)"
                self.stateName = "\(pm.administrativeArea!)"
                self.journalStructure.journalState = "\(pm.administrativeArea!)"
                self.zipNum = "\(pm.postalCode!)"
                self.journalStructure.journalZip = "\(pm.postalCode!)"
                self.journalStructure.journalLocation = userLocation
                self.journalStructure.journalLatitude = String(userLocation.coordinate.latitude)
                self.journalStructure.journalLongitude = String(userLocation.coordinate.longitude)
                self.tableView.reloadData()
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func addressHasBeenFinished() {
        //        <#code#>
    }
    //    MARK: -LabelTextViewDirectionalCell
    func theDirectionalButtonWasTapped(type:JournalTypes) {
        switch type {
        case .crew:
            presentCrew(menuType: myShift, title: "Crew", type: type)
        case .tags:
            presentTags(menuType: myShift, title: "Tags", type: type)
        default:
            print("that's all folks")
        }
    }
    func theTextViewIsFinishedEditing(type:JournalTypes,text:String) {
        //        <#code#>
    }
    
    
    //    MARK: -JournalInfoCellDelegate
    func theInfoBTapped() {
        presentModal(menuType: myShift, title: "User Info", type: .userInfo)
    }
    
    
    
    fileprivate func registerCells() {
        tableView.register(UINib(nibName: "ControllerLabelCell", bundle: nil), forCellReuseIdentifier: "ControllerLabelCell")
        tableView.register(UINib(nibName: "JournalInfoCell",bundle: nil), forCellReuseIdentifier: "JournalInfoCell")
        tableView.register(UINib(nibName: "LabelTextViewCell",bundle: nil), forCellReuseIdentifier: "LabelTextViewCell")
        tableView.register(UINib(nibName: "LabelTextViewTimeStampCell",bundle: nil), forCellReuseIdentifier: "LabelTextViewTimeStampCell")
        tableView.register(UINib(nibName: "LabelTextViewDirectionalCell",bundle: nil), forCellReuseIdentifier: "LabelTextViewDirectionalCell")
        tableView.register(UINib(nibName: "AddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "AddressFieldsButtonsCell")
        tableView.register(UINib(nibName: "MapViewCell", bundle: nil), forCellReuseIdentifier: "MapViewCell")
        tableView.register(UINib(nibName: "PhotosTVCell", bundle: nil), forCellReuseIdentifier: "PhotosTVCell")
    }
    
    fileprivate func savingDialog() {
        //        MARK: -SAVING DIALOG
        saveV = UIView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
        saveV.translatesAutoresizingMaskIntoConstraints = false
        savedL = UILabel.init(frame: CGRect(x: 0, y: 8, width: 300, height: 44))
        savedL.text = "Your Journal Entry Is Being Saved"
        savedL.textColor = UIColor.blue
        savedL.adjustsFontSizeToFitWidth = true
        saveV.addSubview(savedL)
        self.view.addSubview(saveV)
        
        saveLConstraint = NSLayoutConstraint(
            item: saveV as UIView,
            attribute: NSLayoutConstraint.Attribute.top,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self.view,
            attribute: NSLayoutConstraint.Attribute.top,
            multiplier: 1.0,
            constant: -50
        )
        self.view.addConstraint(saveLConstraint)
        let saveTContraint = NSLayoutConstraint(
            item: saveV as UIView,
            attribute: NSLayoutConstraint.Attribute.right,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self.view,
            attribute: NSLayoutConstraint.Attribute.right,
            multiplier: 1.0,
            constant: 300
        )
        self.view.addConstraint(saveTContraint)
    }
    
    fileprivate func buildTheJournal() {
        journalStructure = JournalData.init()
        
        
        journal = context.object(with: id) as? Journal
        print(journal.journalHeader ?? "")
        journalStructure.journalTitle = journal.journalHeader ?? ""
        if let overView = journal.journalOverview as? String {
            journalStructure.journalOverview = overView
        }
        journalStructure.journalTypeImageName = journal.journalEntryTypeImageName ?? "100515IconSet_092016_Stationboard c0l0r"
        let jDate = journal.journalCreationDate
        let fullyFormattedDate = FullDateFormat.init(date:jDate ?? Date())
        let journalDate:String = fullyFormattedDate.formatFullyTheDate()
        journalStructure.journalDate = jDate
        journalStructure.journalCreationDate = journalDate
        journalStructure.journalStreetNum = journal.journalStreetNumber ?? ""
        journalStructure.journalStreetName = journal.journalStreetName ?? ""
        journalStructure.journalLongitude = journal.journalLongitude ?? ""
        journalStructure.journalLatitude = journal.journalLatitude ?? ""
        journalStructure.journalCity = journal.journalCity ?? ""
        journalStructure.journalState = journal.journalState ?? ""
        journalStructure.journalZip = journal.journalZip ?? ""
        journalStructure.journalDiscussion = journal.journalDiscussion as? String ?? ""
        journalStructure.journalNextSteps = journal.journalNextSteps as? String ?? ""
        journalStructure.journalSummary = journal.journalSummary as? String ?? ""
        
        //        MARK: -LOCATION-
        /// journalLocaiton unarchived with secureCoding
        if journal.journalLocationSC != nil {
            if let location = journal.journalLocationSC {
                guard let  archivedData = location as? Data else { return }
                do {
                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return }
                    let location:CLLocation = unarchivedLocation
                    journalStructure.journalLocation = location
                } catch {
                    print("boy there was an error here")
                }
            }
        }
        journalStructure.journalUserGuid = journal.fjpUserReference ?? ""
        journalStructure.journalGuid = journal.fjpJGuidForReference ?? ""
        getTheUser(userGuid: journalStructure.journalUserGuid)
        journalStructure.journalType = journal.journalEntryType ?? ""
        journalStructure.journalFireStation = journal.journalTempFireStation ?? ""
        journalStructure.journalPlatoon = journal.journalTempPlatoon ?? ""
        journalStructure.journalApparatus = journal.journalTempApparatus ?? ""
        journalStructure.journalAssignment = journal.journalTempAssignment ?? ""
        
        theUser.fireStation = journal.journalTempFireStation ?? ""
        theUser.platoon = journal.journalTempPlatoon ?? ""
        theUser.assignment = journal.journalTempAssignment ?? ""
        theUser.apparatus = journal.journalTempApparatus ?? ""
        if journalStructure.journalType == "Station" {
            theUser.entryType = .station
        } else if journalStructure.journalType == "Community" {
            theUser.entryType = .community
        } else if journalStructure.journalType == "Members" {
            theUser.entryType = .members
        } else if journalStructure.journalType == "Training" {
            theUser.entryType = .training
        } else {
            theUser.entryType = .station
        }
        
        var tagsA = [String]()
        for tags in journal?.journalTagDetails as! Set<JournalTags> {
            print(tags.journalTag ?? "no tag")
            let tag = tags.journalTag ?? ""
            tagsA.append(tag)
        }
        tagsA = tagsA.filter { $0 != ""}
        tagsA = Array(NSOrderedSet(array: tagsA)) as! [String]
        journalStructure.journalTagsA = tagsA
        let tag:String = tagsA.joined(separator: ", ")
        journalStructure.journalTags = tag
        
        var crewA = [String]()
        for crews in journal?.journalAttendDetails as! Set<JournalAttend> {
            print(crews.journalAttendee ?? "no crew")
            let crew = crews.journalAttendee ?? ""
            crewA.append(crew)
        }
        crewA = crewA.filter {$0 != ""}
        crewA = Array(NSOrderedSet(array: crewA)) as! [String]
        journalStructure.journalCrewA = crewA
        let crew:String = crewA.joined(separator: ", ")
        journalStructure.journalCrewCombine = crew
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleName
        theUser = UserEntryInfo.init(user:"")
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveJournal(_:)))
        navigationItem.rightBarButtonItem = saveButton
        if Device.IS_IPHONE {
            let listButton = UIBarButtonItem(title: "Journal", style: .plain, target: self, action: #selector(returnToList(_:)))
            navigationItem.leftBarButtonItem = listButton
            navigationItem.setLeftBarButtonItems([listButton], animated: true)
            navigationItem.leftItemsSupplementBackButton = false
        }
        _ = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action:nil)
        
        registerCells()
        
        buildTheJournal()
        
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        //        savingDialog()
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
        } else {
            //            let backgroundImage = UIImage(named: "headerBar2")
            //            self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
        
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc private func returnToList(_ sender:Any) {
        closeItUp()
    }
    
    func closeItUp() {
        if  Device.IS_IPHONE {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:"FJkJOURNALLISTSEGUE"),
                             object: nil,
                             userInfo: nil)
            }
        }
    }
    
    @objc private func saveJournal(_ sender:Any) {
        
        //        TODO: SAVE ANIMATION NEEDS WORK
        //        UIView.animateKeyframes(withDuration: 3, delay: 0, animations: {
        //
        //            self.saveLConstraint.constant = 5
        //            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.05, animations:{
        //                self.view.layoutIfNeeded()
        //            })
        //
        //            self.saveLConstraint.constant = -50
        //            UIView.addKeyframe(withRelativeStartTime: 0.95, relativeDuration: 0.1, animations:{
        //                self.view.layoutIfNeeded()
        //            })
        //        })
        
        journal.journalOverview = journalStructure.journalOverview  as NSObject
        journal.journalStreetNumber = journalStructure.journalStreetNum
        journal.journalStreetName = journalStructure.journalStreetName
        journal.journalCity = journalStructure.journalCity
        journal.journalState = journalStructure.journalState
        journal.journalZip = journalStructure.journalZip
        journal.journalLatitude = journalStructure.journalLatitude
        journal.journalLongitude = journalStructure.journalLongitude
        journal.journalDiscussion = journalStructure.journalDiscussion as NSObject
        journal.journalNextSteps = journalStructure.journalNextSteps as NSObject
        journal.journalSummary = journalStructure.journalSummary as NSObject
        
        //        MARK: -LOCATION-
        /// journalLocation archived with secureCoding
        if journalStructure.journalLocation != nil {
            if let location = journalStructure.journalLocation {
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                    journal.journalLocationSC = data as NSObject
                } catch {
                    print("got an error here")
                }
            }
        }
        
        journal.journalEntryType = journalStructure.journalType
        journal.journalFireStation = theUser.fireStation
        journal.journalTempFireStation = theUser.fireStation
        journal.journalTempPlatoon = theUser.platoon
        journal.journalTempApparatus = theUser.apparatus
        journal.journalTempAssignment = theUser.assignment
        journal.journalModDate = Date()
        
        for ( _, tag ) in journalStructure.journalTagsA.enumerated() {
            let count = theCountForTags(guid: journal.fjpJGuidForReference ?? "", tag: tag)
            if count == 0 {
                let fjuJournalTags = JournalTags.init(entity: NSEntityDescription.entity(forEntityName: "JournalTags", in: context)!, insertInto: context)
                fjuJournalTags.journalTag = tag
                fjuJournalTags.journalTagBackUp = false
                fjuJournalTags.journalTagModDate = Date()
                fjuJournalTags.journalGuid = journal.fjpJGuidForReference
                journal.addToJournalTagDetails(fjuJournalTags)
            }
        }
        
        for ( _, crew ) in journalStructure.journalCrewA.enumerated() {
            let count = theCountForCrew(guid: journal.fjpJGuidForReference ?? "", crew: crew)
            if count == 0 {
                let fjuJournalCrew = JournalAttend.init(entity: NSEntityDescription.entity(forEntityName: "JournalAttend", in: context)!, insertInto: context)
                fjuJournalCrew.journalAttendee = crew
                fjuJournalCrew.journalAttendeeBackup = false
                fjuJournalCrew.journalAttendeeModDate = Date()
                fjuJournalCrew.fjpJournalReference = journal.fjpJGuidForReference
                journal.addToJournalAttendDetails(fjuJournalCrew)
            }
        }
        
        
        
        if fju.fireStation == "" {
            fju.fireStation = journal.journalTempFireStation
            fju.tempFireStation = journal.journalTempFireStation
        }
        
        journal.journalBackedUp = false
        
        saveToCD()
    }
    
    private func theCountForCrew(guid: String, crew: String)->Int {
        let attribute = "fjpJournalReference"
        let entity = "JournalAttend"
        let subAttribute = "journalAttendee"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicate2 = NSPredicate(format: "%K == %@", subAttribute, crew)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("JournalTVC line 614 Fetch Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func theCountForTags(guid: String, tag: String)->Int {
        let attribute = "journalGuid"
        let entity = "JournalTags"
        let subAttribute = "journalTag"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicate2 = NSPredicate(format: "%K == %@", subAttribute, tag)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("JournalTVC line 632 Fetch Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"merge that"])
            }
            
            //            self.showSaved = true
            self.tableView.reloadData()
            DispatchQueue.main.async {
                //                    self.getTheLastSaved()
                self.nc.post(name:Notification.Name(rawValue:FJkCKModifyJournalToCloud),
                             object: nil,
                             userInfo: ["objectID":self.id])
                //                    self.tableView.beginUpdates()
                //                    self.tableView.endUpdates()
            }
            
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                             object: nil, userInfo: ["shift":MenuItems.journal])
            }
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "JOURNALTVC SAVETOCD Unresolved error \(nserror) \(nserror.localizedDescription) \(String(describing: nserror._userInfo))"
            print(errorMessage)
            
        }
    }
    
    private func getTheUser(userGuid: String) {
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
            self.fju = self.fetched.last as? FireJournalUser
            journalStructure.journalUser = self.fju.userName ?? ""
            theUser.user = self.fju.userName ?? ""
            fjuStreetNumber = fju.fireStationStreetNumber ?? ""
            fjuStreetName = fju.fireStationStreetName ?? ""
            fjuCity = fju.fireStationCity ?? ""
            fjuState = fju.fireStationState ?? ""
            fjuZip = fju.fireStationZipCode ?? ""
        } catch let error as NSError {
            print("JournalTVC line 681 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    private func getTheLastSaved() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal" )
        let predicate = NSPredicate(format: "%K != %@", "fjpJGuidForReference", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        do {
            self.fetched = try context.fetch(fetchRequest) as! [Journal]
            let journal = self.fetched.last as! Journal
            self.objectID = journal.objectID
        } catch let error as NSError {
            print("JournalTVC line 698 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
            switch compact {
            case .compact: break
            case .regular: break
            }
        }
        //        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        //        launchNC.removeNC()
    }
    
    //    MARK: -delegate
    func gotBack() {
        //        TODO:
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellHeader = Bundle.main.loadNibNamed("YourDataSavedV", owner: self, options: nil)?.first as! YourDataSavedV
        
        cellHeader.yourDataSavedL.text = ""
        return cellHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if showSaved {
            return 44
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //        return 11 for photos
        return 10
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        
        switch row {
        case 0:
            return  105
        case 1:
            return 290
        case 2:
            if overViewHeight == 110 {
                overViewHeight = getOverViewSize()
            }
            return overViewHeight
        case 3:
            if discussionHeight == 200 {
                discussionHeight = getDiscussionHeight()
            }
            return discussionHeight
        case 4:
            if nextStepsHeight == 200 {
                nextStepsHeight = getNextStepsHeight()
            }
            return nextStepsHeight
        case 5:
            if summaryHeight == 200 {
                summaryHeight = getSummaryHeight()
            }
            return summaryHeight
        case 6:
            return 140
        case 7:
            return 287
        case 8:
            if(showMap) {
                return 500
            } else {
                return 0
            }
        case 9:
            return 140
        case 10:
            return 250
        default:
            return 44
        }
    }
    
    private func getOverViewSize()->CGFloat {
        if journalStructure.journalOverview != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: overViewHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = journalStructure.journalOverview
            let estimatedSize = textView.sizeThatFits(size)
            
            overViewHeight = estimatedSize.height + 110
        }
        return overViewHeight
    }
    
    private func getDiscussionHeight() ->CGFloat {
        if journalStructure.journalDiscussion != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: discussionHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = journalStructure.journalDiscussion
            let estimatedSize = textView.sizeThatFits(size)
            
            discussionHeight = estimatedSize.height + 110
        } else {
            discussionHeight = 200
        }
        return discussionHeight
    }
    
    private func getNextStepsHeight() ->CGFloat {
        if journalStructure.journalNextSteps != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: nextStepsHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = journalStructure.journalNextSteps
            let estimatedSize = textView.sizeThatFits(size)
            
            nextStepsHeight = estimatedSize.height + 110
        } else {
            nextStepsHeight = 200
        }
        return nextStepsHeight
    }
    
    private func getSummaryHeight() ->CGFloat {
        if journalStructure.journalSummary != "" {
            let textView = UITextView()
            textView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: summaryHeight)
            let size = CGSize(width: textView.frame.width, height: .infinity)
            textView.text = journalStructure.journalSummary
            let estimatedSize = textView.sizeThatFits(size)
            
            summaryHeight = estimatedSize.height + 110
        } else {
            summaryHeight = 200
        }
        return summaryHeight
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ControllerLabelCell", for: indexPath) as! ControllerLabelCell
            
            cell.dateL.text =  journalStructure.journalCreationDate
            cell.addressL.text = journalStructure.journalStreetNum+" "+journalStructure.journalStreetName+" "+journalStructure.journalCity
            switch myShift {
            case .journal:
                cell.controllerL.text = journalStructure.journalTitle
                let imageName = journalStructure.journalTypeImageName
                let image = UIImage(named: imageName)
                cell.typeIV.image = image
            case .personal:
                cell.controllerL.text = journalStructure.journalTitle
                let image = UIImage(named: "ICONS_BBLUELOCK")
                cell.typeIV.image = image
            default:
                cell.controllerL.text = journalStructure.journalTitle
            }
            cell.incidentEditB.isHidden = true
            cell.incidentEditB.alpha = 0.0
            cell.incidentEditB.isEnabled = false
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "JournalInfoCell", for: indexPath) as! JournalInfoCell
            cell.subjectL.text = "User Data"
            cell.label1L.text = "User"
            cell.label2L.text = "Entry Type"
            cell.label3L.text = "Fire Station"
            cell.label4L.text = "Platoon"
            cell.label5L.text = "Apparatus"
            cell.label6L.text = "Assignment"
            cell.userTF.text = journalStructure.journalUser
            cell.entryTypeTF.text = journalStructure.journalType
            cell.fireStationTF.text = journalStructure.journalFireStation
            cell.platoonTF.text = journalStructure.journalPlatoon
            cell.apparatusTF.text = journalStructure.journalApparatus
            cell.assignmentTF.text = journalStructure.journalAssignment
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewCell", for: indexPath) as! LabelTextViewCell
            cell.delegate = self
            cell.journalType = .overview
            cell.myShift = myShift
            cell.subjectL.text = "Overview"
            cell.journalType = .overview
            cell.descriptionTV.text = journalStructure.journalOverview
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewTimeStampCell", for: indexPath) as! LabelTextViewTimeStampCell
            cell.delegate = self
            cell.subjectL.text = "Discussion"
            cell.myShift = myShift
            cell.journalType = .discussion
            cell.descriptionTV.text = journalStructure.journalDiscussion
            timeStampedDiscussion = false
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewTimeStampCell", for: indexPath) as! LabelTextViewTimeStampCell
            cell.delegate = self
            cell.subjectL.text = "Next Steps"
            cell.myShift = myShift
            cell.journalType = .nextSteps
            cell.descriptionTV.text = journalStructure.journalNextSteps
            timeStampedNextSteps = false
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewTimeStampCell", for: indexPath) as! LabelTextViewTimeStampCell
            cell.delegate = self
            cell.subjectL.text = "Summary"
            cell.myShift = myShift
            cell.journalType = .summary
            cell.descriptionTV.text = journalStructure.journalSummary
            timeStampedSummary = false
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewDirectionalCell", for: indexPath) as! LabelTextViewDirectionalCell
            cell.delegate = self
            cell.subjectL.text = "Crew"
            cell.descriptionTV.textColor = UIColor.black
            if journalStructure.journalCrewCombine != "" {
                cell.descriptionTV.text = journalStructure.journalCrewCombine
            } else {
                cell.descriptionTV.text = ""
            }
            cell.journalType = .crew
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressFieldsButtonsCell", for: indexPath) as! AddressFieldsButtonsCell
            cell.subjectL.text = "Address"
            let image1 = UIImage(named: "ICONS_location blue")
            let image2 = UIImage(named: "ICONS_world blue")
            cell.locationB.setImage(image1, for: .normal)
            cell.mapB.setImage(image2, for: .normal)
            if journalStructure.journalStreetName == "" {
                if fjuStreetName == "" {
                    cell.addressTF.attributedPlaceholder = NSAttributedString(string: "100 Main Street",attributes: [NSAttributedString.Key.foregroundColor:UIColor.gray])
                } else {
                    cell.addressTF.text = "\(fjuStreetNumber) \(fjuStreetName)"
                    journalStructure.journalStreetNum = fjuStreetNumber
                    journalStructure.journalStreetName = fjuStreetName
                }
            } else {
                cell.addressTF.text = "\(journalStructure.journalStreetNum) \(journalStructure.journalStreetName)"
            }
            if #available(iOS 13.0, *) {
                cell.addressTF.textColor = UIColor.label
            } else {
                cell.addressTF.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
            }
            if journalStructure.journalCity == "" {
                if fjuCity == "" {
                    cell.cityTF.attributedPlaceholder = NSAttributedString(string: "Los Angeles",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                } else {
                    cell.cityTF.text = fjuCity
                    journalStructure.journalCity = fjuCity
                }
            } else {
                cell.cityTF.text = journalStructure.journalCity
            }
            if #available(iOS 13.0, *) {
                cell.cityTF.textColor = UIColor.label
            } else {
                cell.cityTF.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
            }
            if journalStructure.journalState == "" {
                if fjuState == "" {
                    cell.stateTF.attributedPlaceholder = NSAttributedString(string: "CA",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                } else {
                    cell.stateTF.text = fjuState
                    journalStructure.journalState = fjuState
                }
            } else {
                cell.stateTF.text = journalStructure.journalState
            }
            if #available(iOS 13.0, *) {
                cell.stateTF.textColor = UIColor.label
            } else {
                cell.stateTF.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
            }
            if journalStructure.journalZip == "" {
                if fjuZip == "" {
                    cell.zipTF.attributedPlaceholder = NSAttributedString(string: "90001",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                } else {
                    cell.zipTF.text = fjuZip
                    journalStructure.journalZip = fjuZip
                }
            } else {
                cell.zipTF.text = journalStructure.journalZip
            }
            if journalStructure.journalLocation != nil {
                if journalStructure.journalLongitude != "" {
                    cell.addressLongitudeTF.text = journalStructure.journalLongitude
                } else {
                    cell.addressLongitudeTF.attributedPlaceholder = NSAttributedString(string: "Address Longitude",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                }
                if journalStructure.journalLatitude != "" {
                    cell.addressLatitudeTF.text = journalStructure.journalLatitude
                } else {
                    cell.addressLatitudeTF.attributedPlaceholder = NSAttributedString(string: "Address Latitude",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                }
            }
            if #available(iOS 13.0, *) {
                cell.addressTF.textColor = UIColor.label
                cell.cityTF.textColor = UIColor.label
                cell.stateTF.textColor = UIColor.label
                cell.zipTF.textColor = UIColor.label
                cell.addressLongitudeTF.textColor = UIColor.label
                cell.addressLatitudeTF.textColor = UIColor.label
            } else {
                cell.addressTF.textColor = UIColor.black
                cell.cityTF.textColor = UIColor.black
                cell.stateTF.textColor = UIColor.black
                cell.zipTF.textColor = UIColor.black
                cell.addressLongitudeTF.textColor = UIColor.black
                cell.addressLatitudeTF.textColor = UIColor.black
            }
            cell.delegate = self
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell", for: indexPath) as! MapViewCell
            cell.delegate = self
            if(showMap) {
                let frame = CGRect(
                    origin: CGPoint(x: 0, y: 0),
                    size: CGSize(width: tableView.frame.size.width, height: 500)
                )
                cell.contentView.frame = frame
                cell.useAddressB.isHidden = false
                cell.useAddressB.alpha = 1.0
            } else {
                let frame = CGRect(
                    origin: CGPoint(x: 0, y: 0),
                    size: CGSize(width: tableView.frame.size.width, height: 0)
                )
                cell.contentView.frame = frame
                cell.useAddressB.isHidden = true
                cell.useAddressB.alpha = 0.0
            }
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextViewDirectionalCell", for: indexPath) as! LabelTextViewDirectionalCell
            cell.delegate = self
            cell.subjectL.text = "Tags"
            cell.descriptionTV.text = ""
            if journalStructure.journalTags != "" {
                if #available(iOS 13.0, *) {
                    cell.descriptionTV.textColor =  UIColor.label
                } else {
                    cell.descriptionTV.textColor =  UIColor.black
                }
                if journalStructure.journalTags != "" {
                    cell.descriptionTV.text = journalStructure.journalTags
                } else {
                    cell.descriptionTV.text = ""
                }
            }
            cell.journalType = .tags
            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotosTVCell", for: indexPath) as! PhotosTVCell
            cell.delegate = self
            cell.subjectL.text = "Journal Photos"
            cell.myShift = myShift
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    
}

extension JournalTVC: LabelTextViewCellDelegate {
    func textViewEditing(text: String, myShift: MenuItems,journalType:JournalTypes) {
        journalStructure.journalOverview = text
        
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewCell
        let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
        let estimatedSize = cell.descriptionTV.sizeThatFits(size)
        
        overViewHeight = estimatedSize.height + 52.5
        tableView.beginUpdates()
        cell.descriptionTV.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if Device.IS_IPAD {
                    constraint.constant = estimatedSize.height
                } else {
                    if estimatedSize.height < 400 {
                        constraint.constant = estimatedSize.height
                    } else {
                        constraint.constant = 400
                    }
                }
            }
            
        }
        tableView.endUpdates()
        
    }
    
    func textViewDoneEditing(text: String, myShift: MenuItems,journalType:JournalTypes) {
        journalStructure.journalOverview = text
        
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewCell
        let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
        let estimatedSize = cell.descriptionTV.sizeThatFits(size)
        
        overViewHeight = estimatedSize.height + 52.5
        tableView.beginUpdates()
        cell.descriptionTV.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if Device.IS_IPAD {
                    constraint.constant = estimatedSize.height
                } else {
                    if estimatedSize.height < 400 {
                        constraint.constant = estimatedSize.height
                    } else {
                        constraint.constant = 400
                    }
                }
            }
            
        }
        tableView.endUpdates()
    }
    
    func textViewEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes) {}
    func textViewDoneEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes) {}
}

extension JournalTVC: LabelTextViewTimeStampCellDelegate {
    //    MARK: -LabelTextViewTimeStampCellDelegate
    func timeStampTapped(type:JournalTypes) {
        switch type {
        case .discussion:
            timeStampedDiscussion = true
        case .nextSteps:
            timeStampedNextSteps = true
        case .summary:
            timeStampedSummary = true
        default:break
        }
        let username = fju.userName ?? ""
        let timeStamp = vcLaunch.timeStamp(date: Date(), user: username)
        switch type {
        case .discussion:
            let indexPath = IndexPath(row: 3, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewTimeStampCell
            if journalStructure.journalDiscussion == "" {
                _ = cell.textViewShouldEndEditing(cell.descriptionTV)
                cell.buttonTapped = true
            }
            journalStructure.journalDiscussion = cell.descriptionTV.text
            let text = journalStructure.journalDiscussion
            if text == "" {
                journalStructure.journalDiscussion = "\(timeStamp)\n"
            } else {
                journalStructure.journalDiscussion = "\(text)\n\(timeStamp)"
            }
            cell.buttonTapped = false
            updateDiscussionTextView()
        case .nextSteps:
            let indexPath = IndexPath(row: 4, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewTimeStampCell
            if journalStructure.journalNextSteps == "" {
                _ = cell.textViewShouldEndEditing(cell.descriptionTV)
                cell.buttonTapped = true
            }
            journalStructure.journalNextSteps = cell.descriptionTV.text
            let text = journalStructure.journalNextSteps
            if text == "" {
                journalStructure.journalNextSteps = "\(timeStamp)\n"
            } else {
                journalStructure.journalNextSteps = "\(text)\n\(timeStamp)"
            }
            cell.buttonTapped = false
            nextStepsUpdate()
        case .summary:
            let indexPath = IndexPath(row: 5, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewTimeStampCell
            if journalStructure.journalSummary == "" {
                _ = cell.textViewShouldEndEditing(cell.descriptionTV)
                cell.buttonTapped = true
            }
            journalStructure.journalSummary = cell.descriptionTV.text
            let text = journalStructure.journalSummary
            if text == "" {
                journalStructure.journalSummary = "\(timeStamp)\n"
            } else {
                journalStructure.journalSummary = "\(text)\n\(timeStamp)"
            }
            cell.buttonTapped = false
            summaryUpdate()
        default: break
        }
    }
    
    func tsTextViewEdited(text: String, journalType: JournalTypes, myShift: MenuItems) {
        switch journalType {
        case .discussion:
            journalStructure.journalDiscussion = text
            updateDiscussionTextView()
        case .nextSteps:
            journalStructure.journalNextSteps = text
            nextStepsUpdate()
        case .summary:
            journalStructure.journalSummary = text
            summaryUpdate()
        default: break
        }
    }
    
    private func updateDiscussionTextView() {
        let indexPath = IndexPath(row: 3, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewTimeStampCell
        let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
        cell.descriptionTV.text = journalStructure.journalDiscussion
        let estimatedSize = cell.descriptionTV.sizeThatFits(size)
        
        discussionHeight = estimatedSize.height + 80
        if discussionHeight < 200 {
            discussionHeight = 200
        }
        tableView.beginUpdates()
        cell.descriptionTV.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if Device.IS_IPAD {
                    constraint.constant = estimatedSize.height
                } else {
                    if estimatedSize.height < 400 {
                        constraint.constant = estimatedSize.height
                    } else {
                        constraint.constant = 400
                    }
                }
            }
            
        }
        tableView.endUpdates()
    }
    
    private func  nextStepsUpdate() {
        let indexPath = IndexPath(row: 4, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewTimeStampCell
        let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
        cell.descriptionTV.text = journalStructure.journalNextSteps
        let estimatedSize = cell.descriptionTV.sizeThatFits(size)
        
        nextStepsHeight = estimatedSize.height + 80
        if nextStepsHeight < 200 {
            nextStepsHeight = 200
        }
        tableView.beginUpdates()
        cell.descriptionTV.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if Device.IS_IPAD {
                    constraint.constant = estimatedSize.height
                } else {
                    if estimatedSize.height < 400 {
                        constraint.constant = estimatedSize.height
                    } else {
                        constraint.constant = 400
                    }
                }
            }
            
        }
        tableView.endUpdates()
    }
    
    private func summaryUpdate() {
        let indexPath = IndexPath(row: 5, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewTimeStampCell
        let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
        cell.descriptionTV.text = journalStructure.journalSummary
        let estimatedSize = cell.descriptionTV.sizeThatFits(size)
        
        summaryHeight = estimatedSize.height + 80
        if summaryHeight < 200 {
            summaryHeight = 200
        }
        tableView.beginUpdates()
        cell.descriptionTV.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if Device.IS_IPAD {
                    constraint.constant = estimatedSize.height
                } else {
                    if estimatedSize.height < 400 {
                        constraint.constant = estimatedSize.height
                    } else {
                        constraint.constant = 400
                    }
                }
            }
            
        }
        tableView.endUpdates()
    }
    
    func tsTextViewEndedEditing(text: String, journalType: JournalTypes, myShift: MenuItems) {
        switch journalType {
        case .discussion:
            self.resignFirstResponder()
            journalStructure.journalDiscussion = text
            if !timeStampedDiscussion {
                updateDiscussionTextView()
            }
        case .nextSteps:
            self.resignFirstResponder()
            journalStructure.journalNextSteps = text
            if !timeStampedNextSteps {
                nextStepsUpdate()
            }
        case .summary:
            self.resignFirstResponder()
            journalStructure.journalSummary = text
            if !timeStampedNextSteps {
                summaryUpdate()
            }
        default: break
        }
    }
    
}

extension JournalTVC:  RelieveSupervisorModalTVCDelegate {
    func relieveSupervisorModalCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func relieveSupervisorModalSave(relieveSupervisor: [UserAttendees], relieveOrSupervisor: Bool) {
        let crews = relieveSupervisor
        var array = [String]()
        for crew in crews {
            if crew.attendee != "" {
                array.append(crew.attendee!)
            }
        }
        journalStructure.journalCrewCombine = array.joined(separator: ",")
        journalStructure.journalCrewA = array
        let indexPath = IndexPath(row: 6, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        self.dismiss(animated: true, completion: nil)
    }
}
