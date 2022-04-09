//
//  SettingsTheProfileTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/14/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

protocol SettingsTheProfileDelegate: AnyObject {
    func theProfileReturnToSettings(compact:SizeTrait)
    func theProfileSavedNowGoToSettings(compact:SizeTrait)
    func profileSettingsGetData(type:FJSettings,compact:SizeTrait)
}


class SettingsTheProfileTVC: UITableViewController,ProfileLabelTextDelegate,ProfileLabelWithLocationButtonsDelegate,CLLocationManagerDelegate, MapViewCellDelegate,SettingsProfileDataDelegate {
    
    //    MARK: -SettingsProfileDataDelegate
    func settingsProfileDataCanceled() {
        getTheUserNow()
        self.tableView.reloadData()
    }
    
    func settingsProfileDataChosen(type: FJSettings, _ object: String) {

    }
    
    
    
    //    MARK: -Properties
    @IBOutlet weak var navBar: UINavigationBar!
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    weak var delegate:SettingsTheProfileDelegate? = nil
    var compact:SizeTrait = SizeTrait.regular
    var fireJournalUser:FireJournalUserOnboard!
    let nc = NotificationCenter.default
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var fetched:Array<Any>!
    var fju:FireJournalUser!
    var entity:String = "FireJournalUser"
    var attribute:String = "userGuid"
    var sortAttribute:String = "lastName"
    var city: String = ""
    var streetNum: String = ""
    var streetName: String = ""
    var stateName: String = ""
    var zipNum: String = ""
    var locationManager:CLLocationManager!
    var theUsersLocation: CLLocation!
    var objectID:NSManagedObjectID? = nil
    var showMap:Bool = false
    var cellArray = [UITableViewCell]()
    var indexPathArray = [IndexPath]()
    var alertUp: Bool = false
    
    
    //    MARK: -MapViewCellDelegate
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
    
    func theAddressHasBeenChosen(addressStreetNum: String, addressStreetName: String, addressCity: String, addressState: String, addressZip: String, location: CLLocation) {
        
        fireJournalUser.fjuStreetNum = addressStreetNum
        fireJournalUser.fjuStreetName = addressStreetName
        fireJournalUser.fjuCity = addressCity
        fireJournalUser.fjuState = addressState
        fireJournalUser.fjuZip = addressZip
        fireJournalUser.fjuLocation = location
        showMap = false
        self.tableView.reloadData()
    }
    
    //    MARK: -ProfileLabelWithLocationButtonsDelegate
    func theProfileLocationBTapped() {
        determineLocation()
    }
    
    func theProfileWorldBTapped() {
        print("world tapped")
        if showMap {
            showMap = false
        } else {
            showMap = true
        }
        tableView.reloadData()
    }
    
    func determineLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
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
                self.fireJournalUser.fjuCity = self.city
                self.streetNum = "\(pm.subThoroughfare!)"
                self.fireJournalUser.fjuStreetNum = self.streetNum
                self.streetName = "\(pm.thoroughfare!)"
                self.fireJournalUser.fjuStreetName = self.streetName
                self.stateName = "\(pm.administrativeArea!)"
                self.fireJournalUser.fjuState = self.stateName
                self.zipNum = "\(pm.postalCode!)"
                self.fireJournalUser.fjuZip = self.zipNum
                self.theUsersLocation = userLocation
                self.tableView.reloadData()
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    
    func profileTextFieldDidBeginEditing(text: String,fju: String) {
//        print(text)
//        switch fju {
//        case "fjuFirstName":
//            print(fju)
//        case "fjuLastName":
//            print(fju)
//        case "fjuEmailAddress":
//            print(fju)
//        case "fjuPhoneNumber":
//            print(fju)
//        default: break
//        }
    }
    
    func profileTextFieldDidEndEdit(text: String, fju: String) {
        switch fju {
        case "fjuFirstName":
           fireJournalUser.fjuFirstName = text
        case "fjuLastName":
            fireJournalUser.fjuLastName = text
        case "fjuEmailAddress":
            fireJournalUser.fjuEmailAddress = text
        case "fjuPhoneNumber":
            fireJournalUser.fjuPhoneNumber = text
        case "fjuFireStation":
            fireJournalUser.fjuFireStation = text
        case "fjuStreetNum":
            fireJournalUser.fjuStreetNum = text
        case "fjuStreetName":
            fireJournalUser.fjuStreetName = text
        case "fjuCity":
            fireJournalUser.fjuCity = text
        case "fjuState":
            fireJournalUser.fjuState = text
        case "fjuZip":
            fireJournalUser.fjuZip = text
        case "fjuFireDepartment":
            fireJournalUser.fjuFireDepartment = text
        case "fjuWebSite":
            fireJournalUser.fjuWebSite = text
        default: break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        saveToCD()
        super.viewWillDisappear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    fileprivate func registerCells() {
        //        MARK: -REGISTER TABLECELLS
        tableView.register(UINib(nibName: "ProfileLabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelTextFieldCell")
        
        tableView.register(UINib(nibName: "ProfileLabelCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelCell")
        
        tableView.register(UINib(nibName: "ProfileLabelTextFieldIndicatorCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelTextFieldIndicatorCell")
        
        tableView.register(UINib(nibName: "ProfileLabelWithLocationButtonsCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelWithLocationButtonsCell")
        
        tableView.register(UINib(nibName: "MapViewCell", bundle: nil), forCellReuseIdentifier: "MapViewCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch compact {
        case .compact: break
        case .regular:break
//            roundViews()
        }
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        //        MARK: -create background context
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        registerCells()
        
        let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
        let button2 = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateTheProfile(_:)))
        navigationItem.leftItemsSupplementBackButton = true
        let button3 = self.splitViewController?.displayModeButtonItem
        let button4 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(updateTheProfile(_:)))
        
//        self.title = "My Profile"
        // MARK: navigation
        navigationItem.setLeftBarButtonItems([button3 ?? button4, button1], animated: true)
        navigationItem.setRightBarButtonItems([button2], animated: true)
        
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
        
        getTheUserNow()
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
    }
    
    func getTheUserNow() {
        getTheUser(entity: entity, attribute: attribute, sortAttribute: sortAttribute)
        
        if fju != nil {
            if fju.userGuid != "" {
                fireJournalUser = FireJournalUserOnboard()
                fireJournalUser.fjuFirstName = fju.firstName ?? ""
                fireJournalUser.fjuLastName = fju.lastName ?? ""
                fireJournalUser.fjuEmailAddress = fju.emailAddress ?? ""
                fireJournalUser.fjuPhoneNumber = fju.mobileNumber ?? ""
                fireJournalUser.fjuPlatoon = fju.platoon ?? ""
                fireJournalUser.fjuRank = fju.rank ?? ""
                fireJournalUser.fjuAssignment = fju.initialAssignment ?? ""
                fireJournalUser.fjuFDID = fju.fdid ?? ""
                fireJournalUser.fjuApparatus = fju.initialApparatus ?? ""
                fireJournalUser.fjuFireStation = fju.fireStation ?? ""
                fireJournalUser.fjuStreetNum = fju.fireStationStreetNumber ?? ""
                fireJournalUser.fjuStreetName = fju.fireStationStreetName ?? ""
                fireJournalUser.fjuCity = fju.fireStationCity ?? ""
                fireJournalUser.fjuState = fju.fireStationState ?? ""
                fireJournalUser.fjuZip = fju.fireStationZipCode ?? ""
                fireJournalUser.fjuWebSite = fju.fireStationWebSite ?? ""
                fireJournalUser.fjuFireDepartment = fju.fireDepartment ?? ""
            }
        }
    }
    
    @objc func compactOrRegular(ns: Notification) {
//        if let userInfo = ns.userInfo as! [String: Any]?
//        {
//            compact = userInfo["compact"] as? SizeTrait ?? .regular
//            switch compact {
//            case .compact:
//                print("compact SETTING PROFILE")
//            case .regular:
//                print("regular SETTING PROFILE")
//            }
//        }
//
//        self.tableView.reloadData()
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    
    func closeItUp() {
        if  Device.IS_IPHONE {
             delegate?.theProfileReturnToSettings(compact: compact)
        } else {
           nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                                object: nil,
                                userInfo: ["sizeTrait":compact])
        }
    }
    
    @IBAction func goBackToSettings(_ sender: Any) {
        closeItUp()
//        switch compact {
//        case .compact:
//            delegate?.theProfileReturnToSettings(compact: compact)
//        case .regular:
//            nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
//                    object: nil,
//                    userInfo: ["sizeTrait":compact])
//        }
    }
    
    func walkThroughTheFields() {
        if Device.IS_IPAD {
        let cellArray2 = [1,2,3,4,13,14,15,16,17,18,19,20]
        for cell in cellArray2 {
                if cell > 4 {
                    scrollToBottomLandscapeIPad()
                } else {
                    scrollToTheTopOfIPad()
                }
            }
        } else if Device.IS_IPHONE {
            let cellArray2 = [1,2,3,4,13,14,15]
            for cell in cellArray2 {
            if cell > 13 {
                scrollToBottom()
            } else {
                scrollToTheTopOfIPad()
                }
            }
        }
    }
    
    func scrollToTheTopOfIPad() {
       
            let top = IndexPath(row: 0, section: 0)

            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: top, at: .top, animated: false)
                let cellArray2 = [1,2,3,4]
                for cell in cellArray2 {
                let indexPath = IndexPath(row: cell, section: 0)
                    let cell = self.tableView.cellForRow(at: indexPath) as! ProfileLabelTextFieldCell
                    _ = cell.textFieldShouldEndEditing(cell.descriptionTF)
                }
            }
    }
    
    func scrollToBottomLandscapeIPad() {
        let sections = self.tableView.numberOfSections

        if sections > 0 {

            let rows = self.tableView.numberOfRows(inSection: sections - 1)

            let last = IndexPath(row: rows - 1, section: sections - 1)

            DispatchQueue.main.async {

                self.tableView.scrollToRow(at: last, at: .bottom, animated: false)
                let cellArray3 = [13,14,15,16,17,18,19,20]
                for c in cellArray3 {
                    let indexPath = IndexPath(row: c, section: 0)
                    let cell = self.tableView.cellForRow(at: indexPath) as! ProfileLabelTextFieldCell
                    _ = cell.textFieldShouldEndEditing(cell.descriptionTF)
                }

            }
        }
    }
    
    func scrollToBottom() {

        let sections = self.tableView.numberOfSections

        if sections > 0 {

            let rows = self.tableView.numberOfRows(inSection: sections - 1)

            let last = IndexPath(row: rows - 1, section: sections - 1)

            DispatchQueue.main.async {

                self.tableView.scrollToRow(at: last, at: .bottom, animated: false)
                let cellArray3 = [15,16,17,18,19,20]
                for c in cellArray3 {
                    let indexPath = IndexPath(row: c, section: 0)
                    let cell = self.tableView.cellForRow(at: indexPath) as! ProfileLabelTextFieldCell
                    _ = cell.textFieldShouldEndEditing(cell.descriptionTF)
                }

            }
        }
    }
    
    @IBAction func updateTheProfile(_ sender: Any) {
        walkThroughTheFields()
        tableView.reloadData()
         fju.firstName = fireJournalUser.fjuFirstName
         fju.lastName = fireJournalUser.fjuLastName
        var name = ""
        if let first:String = fireJournalUser?.fjuFirstName {
            name = first
        }
        if let last:String = fireJournalUser?.fjuLastName {
            name = "\(name) \(last)"
        }
        fju.userName = name
         fju.emailAddress = fireJournalUser.fjuEmailAddress
         fju.mobileNumber = fireJournalUser.fjuPhoneNumber
         fju.platoon = fireJournalUser.fjuPlatoon
         fju.rank = fireJournalUser.fjuRank
         fju.initialAssignment = fireJournalUser.fjuAssignment
         fju.fdid = fireJournalUser.fjuFDID
         fju.initialApparatus = fireJournalUser.fjuApparatus
         fju.fireStation = fireJournalUser.fjuFireStation
         fju.fireStationStreetNumber = fireJournalUser.fjuStreetNum
         fju.fireStationStreetName = fireJournalUser.fjuStreetName
         fju.fireStationCity = fireJournalUser.fjuCity
         fju.fireStationState = fireJournalUser.fjuState
         fju.fireStationZipCode = fireJournalUser.fjuZip
         fju.fireStationWebSite = fireJournalUser.fjuWebSite
         fju.fireDepartment = fireJournalUser.fjuFireDepartment
        
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
         fju.fjpUserModDate = Date()
         fju.fjpUserBackedUp = false
        saveToCD()
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            let nc = NotificationCenter.default
            getTheLastSaved(guid: fju.userGuid ?? "")
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Settins The Profile TVC deal here"])
                print("we have saved to the cloud")
            }
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkFJUserModifiedSendToCloud),
                        object: nil,
                        userInfo: ["objectID":self.objectID!])
            }
            switch compact {
            case .compact:
                delegate?.theProfileSavedNowGoToSettings(compact: compact)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            case .regular:
                DispatchQueue.main.async {
                    nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                            object: nil,
                            userInfo: ["sizeTrait":self.compact])
                    nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }   catch let error as NSError {
            let nserror = error
            let errorMessage = "SettingsTheProfileTVC saveToCD() Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: FJkPERSISTENT_STORE_ERROR_REPORTING), object: nil, userInfo:["errorMessage":errorMessage])
//            }
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
        fetchRequest.fetchBatchSize = 20
        do {
            self.fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
            let fjUser = self.fetched.last as! FireJournalUser
            self.objectID = fjUser.objectID
        } catch let error as NSError {
            print("SettingsTheProfileTVC line 382 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    
    private func getTheUser(entity: String, attribute: String, sortAttribute: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", attribute, "")
        let sectionSortDescriptor = NSSortDescriptor(key: sortAttribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20

        do {
            self.fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
            if self.fetched.isEmpty {
                print("no user available")
            } else {
                self.fju = self.fetched.last as? FireJournalUser
            }
        } catch let error as NSError {
            print("SettingsTheProfileTVC line 405 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    // MARK: - Table view data source
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("MyProfileHeaderV", owner: self, options: nil)?.first as! MyProfileHeaderV
        let color: UIColor = UIColor(named: "MasterBackgrndColor") ?? ButtonsForFJ092018.blueGradientColor
        headerV.colorV.backgroundColor = color
        headerV.subjetL.text = "My Profile"
        headerV.delegate = self
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if self.title == "My Profile" {
//            return 66
//        }
        return 66
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 21
    }
    ///
    /// - Parameters:
    ///   - tableView: self.tableview
    ///   - indexPath: the indexPath for each cell
    /// - Returns: CGFloat
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 0
        case 1...10:
            return 44
        case 11:
            return 65
        case 12:
            if(showMap) {
                return 500
            } else {
                return 0
            }
        case 15:
            return 44
        default:
            return 44
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelCell", for: indexPath) as! ProfileLabelCell
            cell.subjectL.text = "Tell Us About Yourself"
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldCell", for: indexPath) as! ProfileLabelTextFieldCell
            cell.delegate = self
            cell.fju = "fjuFirstName"
            cell.subjectL.text = "First Name"
            cell.descriptionTF.placeholder = "John"
            cell.descriptionTF.text = fireJournalUser.fjuFirstName
            cell.tag = 1
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldCell", for: indexPath) as! ProfileLabelTextFieldCell
            cell.delegate = self
            cell.fju = "fjuLastName"
            cell.subjectL.text = "Last Name"
            cell.descriptionTF.placeholder = "Marks"
            cell.descriptionTF.text = fireJournalUser.fjuLastName
            cell.tag = 2
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldCell", for: indexPath) as! ProfileLabelTextFieldCell
            cell.delegate = self
            cell.fju = "fjuEmailAddress"
            cell.subjectL.text = "Email Address"
            cell.descriptionTF.placeholder = "johnmarks@verizon.com"
            cell.descriptionTF.text = fireJournalUser.fjuEmailAddress
            cell.tag = 3
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldCell", for: indexPath) as! ProfileLabelTextFieldCell
            cell.delegate = self
            cell.fju = "fjuPhoneNumber"
            cell.subjectL.text = "Phone Number"
            cell.descriptionTF.placeholder = "800-010-9999"
            cell.descriptionTF.text = fireJournalUser.fjuPhoneNumber
            cell.tag = 4
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelCell", for: indexPath) as! ProfileLabelCell
            cell.subjectL.text = "My Assignment"
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldIndicatorCell", for: indexPath) as! ProfileLabelTextFieldIndicatorCell
            cell.subjectL.text = "Platoon"
            cell.descriptionTF.placeholder = "B-Platoon"
            cell.descriptionTF.text = fireJournalUser.fjuPlatoon
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldIndicatorCell", for: indexPath) as! ProfileLabelTextFieldIndicatorCell
            cell.subjectL.text = "Rank"
            cell.descriptionTF.placeholder = "Commander"
            cell.descriptionTF.text = fireJournalUser.fjuRank
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldIndicatorCell", for: indexPath) as! ProfileLabelTextFieldIndicatorCell
            cell.subjectL.text = "Assignment"
            cell.descriptionTF.placeholder = "Bureau Commander"
            cell.descriptionTF.text = fireJournalUser.fjuAssignment
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldIndicatorCell", for: indexPath) as! ProfileLabelTextFieldIndicatorCell
            cell.subjectL.text = "FDID"
            cell.descriptionTF.placeholder = "31005"
            cell.descriptionTF.text = fireJournalUser.fjuFDID
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldIndicatorCell", for: indexPath) as! ProfileLabelTextFieldIndicatorCell
            cell.subjectL.text = "Apparatus"
            cell.descriptionTF.placeholder = "Engine"
            cell.descriptionTF.text = fireJournalUser.fjuApparatus
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 11:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelWithLocationButtonsCell", for: indexPath) as! ProfileLabelWithLocationButtonsCell
            cell.delegate = self
            cell.subjectL.text = "My Primary Fire Station"
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 12:
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
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 13:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldCell", for: indexPath) as! ProfileLabelTextFieldCell
            cell.delegate = self
            cell.fju = "fjuFireStation"
            cell.subjectL.text = "Fire Station"
            cell.descriptionTF.placeholder = "76"
            cell.descriptionTF.text = fireJournalUser.fjuFireStation
            cell.tag = 5
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 14:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldCell", for: indexPath) as! ProfileLabelTextFieldCell
            cell.delegate = self
            cell.fju = "fjuStreetNum"
            cell.subjectL.text = "Street Number"
            cell.descriptionTF.placeholder = "101"
            cell.descriptionTF.text = fireJournalUser.fjuStreetNum
            cell.tag = 6
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 15:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldCell", for: indexPath) as! ProfileLabelTextFieldCell
            cell.delegate = self
            cell.fju = "fjuStreetName"
            cell.subjectL.text = "Street/Highway"
            cell.descriptionTF.placeholder = "Grant Ave"
            cell.descriptionTF.text = fireJournalUser.fjuStreetName
            cell.tag = 7
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 16:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldCell", for: indexPath) as! ProfileLabelTextFieldCell
            cell.delegate = self
            cell.fju = "fjuCity"
            cell.subjectL.text = "City"
            cell.descriptionTF.placeholder = "Los Angeles"
            cell.descriptionTF.text = fireJournalUser.fjuCity
            cell.tag = 8
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 17:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldCell", for: indexPath) as! ProfileLabelTextFieldCell
            cell.delegate = self
            cell.fju = "fjuState"
            cell.subjectL.text = "State"
            cell.descriptionTF.placeholder = "CA"
            cell.descriptionTF.text = fireJournalUser.fjuState
            cell.tag = 9
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 18:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldCell", for: indexPath) as! ProfileLabelTextFieldCell
            cell.delegate = self
            cell.fju = "fjuZip"
            cell.subjectL.text = "Zip"
            cell.descriptionTF.placeholder = "90001"
            cell.descriptionTF.text = fireJournalUser.fjuZip
            cell.tag = 10
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 19:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldCell", for: indexPath) as! ProfileLabelTextFieldCell
            cell.delegate = self
            cell.fju = "fjuFireDepartment"
            cell.subjectL.text = "Fire Department"
            cell.descriptionTF.placeholder = "LAFD"
            cell.descriptionTF.text = fireJournalUser.fjuFireDepartment
            cell.tag = 11
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        case 20:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldCell", for: indexPath) as! ProfileLabelTextFieldCell
            cell.delegate = self
            cell.fju = "fjuWebSite"
            cell.subjectL.text = "Website"
            cell.descriptionTF.placeholder = "LAFD.org"
            cell.descriptionTF.text = fireJournalUser.fjuWebSite
            cell.tag = 12
            cellArray.append(cell)
            indexPathArray.append(indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelCell", for: indexPath) as! ProfileLabelCell
            return cell
        }
    }
    
    fileprivate func presentModal(type:FJSettings,sizeTrait:SizeTrait)->Void {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let controller:SettingsProfileDataTVC = storyBoard.instantiateViewController(withIdentifier:"SettingsProfileDataTVC") as! SettingsProfileDataTVC
        switch type {
        case .platoon:
            controller.titleName = "Fire Journal Platoons"
            controller.type = FJSettings.platoon
        case .rank:
            controller.titleName = "Fire Journal Ranks"
            controller.type = FJSettings.rank
        case .assignment:
            controller.titleName = "Fire Journal Assignments"
            controller.type = FJSettings.assignment
        case .fdid:
            controller.titleName = "Fire Journal FDIDs"
            controller.type = FJSettings.fdid
        case .apparatus:
            controller.titleName = "Fire Journal Apparatus"
            controller.type = FJSettings.apparatus
        default: break
        }
        controller.compact = compact
        controller.delegate = self
        controller.transitioningDelegate = slideInTransitioningDelgate
        controller.modalPresentationStyle = .custom
//        let navigator = UINavigationController.init(rootViewController: controller)
        self.present(controller, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch row {
        case 0, 1, 2, 3, 4, 5 :
            print("here is the row you are tapping on \(row)")
            break
        case 6:
            getThePlatoonVC()
//            if Device.IS_IPHONE {
//                presentModal(type: FJSettings.platoon, sizeTrait: compact)
//            } else {
//                delegate?.profileSettingsGetData(type:FJSettings.platoon,compact:compact)
//            }
        case 7:
            if Device.IS_IPHONE {
                presentModal(type: FJSettings.rank, sizeTrait: compact)
            } else {
                delegate?.profileSettingsGetData(type:FJSettings.rank,compact:compact)
            }
        case 8:
            if Device.IS_IPHONE {
                presentModal(type: FJSettings.assignment, sizeTrait: compact)
            } else {
                delegate?.profileSettingsGetData(type:FJSettings.assignment,compact:compact)
            }
        case 9:
            if Device.IS_IPHONE {
                presentModal(type: FJSettings.fdid, sizeTrait: compact)
            } else {
                delegate?.profileSettingsGetData(type:FJSettings.fdid,compact:compact)
            }
        case 10:
            if Device.IS_IPHONE {
                presentModal(type: FJSettings.apparatus, sizeTrait: compact)
            } else {
                delegate?.profileSettingsGetData(type:FJSettings.apparatus,compact:compact)
            }
        default: break
        }
    }

}

extension SettingsTheProfileTVC: MyProfileHeaderVDelegate {
    func myProfileHeaderInfoBTapped() {
        if !alertUp {
                presentTheAlert()
            }
        }
        
        func presentTheAlert() {
            let title: InfoBodyText = .myProfileSupportNotesSubject
            let message: InfoBodyText = .myProfileSupportNotes
            let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    
    
}

extension SettingsTheProfileTVC {
    
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
                    print("StartShiftModalTVC line 433 Fetch Error: \(error.localizedDescription)")
            }
        return platoons
    }
    
    private func getThePlatoonVC() {
        let platoons = getThePlatoons()
        let storyboard = UIStoryboard(name: "Platoons", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! PlatoonsVC
        vc.platoons = platoons
        vc.delegate = self
        present(vc, animated: true )
    }
    
}

extension SettingsTheProfileTVC: PlatoonsVCDelegate {
    
    func platoonsCancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func platoonsVCChosen(platoon: UserPlatoon) {
        fireJournalUser.fjuPlatoon = platoon.platoon ?? ""
        fireJournalUser.fjuPlatoonGuid = platoon.platoonGuid ?? ""
        fireJournalUser.fjuPlatoonTemp = platoon.platoon ?? ""
        fju.platoon = platoon.platoon ?? ""
        fju.platoonGuid = platoon.platoonGuid ?? ""
        fju.platoonDefault = true
        fju.tempPlatoon = platoon.platoon ?? ""
        let indexPath = IndexPath(row: 6, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        self.dismiss(animated: true, completion: nil)
    }
    
}
