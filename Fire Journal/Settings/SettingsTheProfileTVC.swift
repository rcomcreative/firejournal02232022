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


class SettingsTheProfileTVC: UITableViewController,CLLocationManagerDelegate {
    
    
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
    var fju: FireJournalUser!
    var theLocation: FCLocation!
    var entity:String = "FireJournalUser"
    var attribute:String = "userGuid"
    var sortAttribute:String = "lastName"
    var city: String = ""
    var streetNum: String = ""
    var streetName: String = ""
    var stateName: String = ""
    var zipNum: String = ""
    var locationManager: CLLocationManager!
    var theUsersLocation: CLLocation!
    var objectID: NSManagedObjectID!
    var showMap:Bool = false
    var cellArray = [UITableViewCell]()
    var indexPathArray = [IndexPath]()
    var alertUp: Bool = false
    var fdidChosen: Bool = false
    
    lazy var getUserLocation: GetTheUserLocation = { return GetTheUserLocation.init() }()
    var theUserRegion: MKCoordinateRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch compact {
        case .compact: break
        case .regular: break
        }
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        registerCells()
        getUserLocation.determineLocation()
        
        let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
        let button2 = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateTheProfile(_:)))
        navigationItem.leftItemsSupplementBackButton = true
        let button3 = self.splitViewController?.displayModeButtonItem
        let button4 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(updateTheProfile(_:)))
        
            // MARK: navigation
        navigationItem.setLeftBarButtonItems([button3 ?? button4, button1], animated: true)
        navigationItem.setRightBarButtonItems([button2], animated: true)
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
        } else {
            
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
        
        if objectID != nil {
            fju = context.object(with: objectID) as? FireJournalUser
            if fju.theLocation != nil {
                theLocation = fju.theLocation
            }
            if let _ = fju.fdid {
                fdidChosen = true
            }
        } else {
            delegate?.theProfileReturnToSettings(compact: .compact)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if getUserLocation.currentLocation == nil {
            getUserLocation.determineLocation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
        //    MARK: -ALERTS-
    
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
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
            if let id = self.objectID {
            nc.post(name:Notification.Name(rawValue: FJkSETTINGS_FROM_MASTER),
                    object: nil,
                    userInfo: ["sizeTrait":compact,"userObjID": id])
            }
        }
    }
    
    @IBAction func goBackToSettings(_ sender: Any) {
        closeItUp()
    }
    
    @IBAction func updateTheProfile(_ sender: Any) {
        saveToCD()
    }
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Settins The Profile TVC deal here"])
            }
            DispatchQueue.main.async {
                self.nc.post(name: .fireJournalUserModifiedSendToCloud , object: nil, userInfo: ["objectID": self.objectID! ])
            }
            theAlert(message: "Your profile has been updated.")
            switch compact {
            case .compact:
                delegate?.theProfileSavedNowGoToSettings(compact: compact)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            case .regular:
                DispatchQueue.main.async {
                    nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                            object: nil,
                            userInfo: ["sizeTrait": self.compact])
                    nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }   catch let error as NSError {
            let nserror = error
            let errorMessage = "SettingsTheProfileTVC saveToCD() Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    func theAlert(message: String) {
        let alert = UIAlertController.init(title: "Update", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    fileprivate func presentModal(type:FJSettings,sizeTrait:SizeTrait)->Void {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let controller: SettingsProfileDataTVC = storyBoard.instantiateViewController(withIdentifier:"SettingsProfileDataTVC") as! SettingsProfileDataTVC
        if fju != nil {
            controller.userObjtID = fju.objectID
        }
        switch type {
        case .fdid:
            controller.titleName = "Fire Journal FDIDs"
            controller.type = FJSettings.fdid
        default: break
        }
        controller.compact = compact
        controller.delegate = self
        controller.transitioningDelegate = slideInTransitioningDelgate
        controller.modalPresentationStyle = .custom
        if Device.IS_IPHONE {
        let navigator = UINavigationController.init(rootViewController: controller)
        self.present(navigator, animated: true, completion: nil)
        } else {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    
}

extension SettingsTheProfileTVC {
    
    
        // MARK: - Table view data source
    func registerCells() {
        tableView.register(UINib(nibName: "ProfileLabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelTextFieldCell")
        
        tableView.register(UINib(nibName: "ProfileLabelCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelCell")
        
        tableView.register(UINib(nibName: "ProfileLabelTextFieldIndicatorCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelTextFieldIndicatorCell")
        
        tableView.register(UINib(nibName: "ProfileLabelWithLocationButtonsCell", bundle: nil), forCellReuseIdentifier: "ProfileLabelWithLocationButtonsCell")
        
        tableView.register(RankTVCell.self, forCellReuseIdentifier: "RankTVCell")
        tableView.register(UINib(nibName: "NewAddressFieldsButtonsCell", bundle: nil), forCellReuseIdentifier: "NewAddressFieldsButtonsCell")
        tableView.register(ProfileLabelTextFieldTVCell.self, forCellReuseIdentifier: "ProfileLabelTextFieldTVCell")
        tableView.register(MultipleAddButtonTVCell.self, forCellReuseIdentifier: "MultipleAddButtonTVCell")
        
    }
    
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
        return 66
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
        //
        /// - Parameters:
        ///   - tableView: self.tableview
        ///   - indexPath: the indexPath for each cell
        /// - Returns: CGFloat
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0, 1, 2, 3, 12, 13:
            if Device.IS_IPHONE {
                return 100
            } else {
                return 50
            }
        case 5, 6, 7, 8:
            if Device.IS_IPHONE {
                return 100
            } else {
                return 55
            }
        case 9:
            return 85
        case 10:
            if fdidChosen {
                return 44
            } else {
                return 0
            }
        case 14:
            if Device.IS_IPHONE {
                return 390
            } else {
                return  310
            }
        default:
            return 44
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldTVCell", for: indexPath) as! ProfileLabelTextFieldTVCell
            cell = configureProfileLabelTextFieldTVCell(cell, index: indexPath)
            return cell
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldTVCell", for: indexPath) as! ProfileLabelTextFieldTVCell
            cell = configureProfileLabelTextFieldTVCell(cell, index: indexPath)
            return cell
        case 2:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldTVCell", for: indexPath) as! ProfileLabelTextFieldTVCell
            cell = configureProfileLabelTextFieldTVCell(cell, index: indexPath)
            return cell
        case 3:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldTVCell", for: indexPath) as! ProfileLabelTextFieldTVCell
            cell = configureProfileLabelTextFieldTVCell(cell, index: indexPath)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelCell", for: indexPath) as! ProfileLabelCell
            cell.subjectL.text = "My Assignment"
            indexPathArray.append(indexPath)
            return cell
        case 5:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RankTVCell", for: indexPath) as! RankTVCell
            cell = configureRankTVCell(cell, index: indexPath)
            cell.selectionStyle = .none
            cell.configureTheButton()
            return cell
        case 6:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RankTVCell", for: indexPath) as! RankTVCell
            cell = configureRankTVCell(cell, index: indexPath)
            cell.selectionStyle = .none
            cell.configureTheButton()
            return cell
        case 7:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RankTVCell", for: indexPath) as! RankTVCell
            cell = configureRankTVCell(cell, index: indexPath)
            cell.selectionStyle = .none
            cell.configureTheButton()
            return cell
        case 8:
            var cell = tableView.dequeueReusableCell(withIdentifier: "RankTVCell", for: indexPath) as! RankTVCell
            cell = configureRankTVCell(cell, index: indexPath)
            cell.selectionStyle = .none
            cell.configureTheButton()
            return cell
        case 9:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 10:
            if fdidChosen {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelCell", for: indexPath) as! ProfileLabelCell
                if let fdid = fju.fdid {
                    cell.subjectL.text = fdid
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelCell", for: indexPath) as! ProfileLabelCell
                cell.subjectL.text = ""
                return cell
            }
        case 11:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelCell", for: indexPath) as! ProfileLabelCell
            cell.subjectL.text = "My Primary Fire Station"
            indexPathArray.append(indexPath)
            return cell
        case 12:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldTVCell", for: indexPath) as! ProfileLabelTextFieldTVCell
            cell = configureProfileLabelTextFieldTVCell(cell, index: indexPath)
            return cell
        case 13:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelTextFieldTVCell", for: indexPath) as! ProfileLabelTextFieldTVCell
            cell = configureProfileLabelTextFieldTVCell(cell, index: indexPath)
            return cell
        case 14:
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewAddressFieldsButtonsCell", for: indexPath) as! NewAddressFieldsButtonsCell
            let tag = indexPath.row
            cell = configureNewAddressFieldsButtonsCell( cell , at: indexPath , tag: tag)
            cell.configureNewMapButton(type: IncidentTypes.journal)
            cell.configureNewLocationButton(type: IncidentTypes.journal)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileLabelCell", for: indexPath) as! ProfileLabelCell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch row {
        case 9:
            if Device.IS_IPHONE {
                presentModal(type: FJSettings.fdid, sizeTrait: compact)
            } else {
                presentModal(type: FJSettings.fdid, sizeTrait: compact)
//                delegate?.profileSettingsGetData(type:FJSettings.fdid,compact:compact)
            }
        default: break
        }
    }
    
    func configureProfileLabelTextFieldTVCell(_ cell: ProfileLabelTextFieldTVCell, index: IndexPath) -> ProfileLabelTextFieldTVCell {
        let row = index.row
        cell.tag = row
        cell.index = index
        cell.delegate = self
        switch row {
        case 0:
            cell.subject = "First Name"
            if let first = fju.firstName {
                cell.aDescription = first
            }
        case 1:
            cell.subject = "Last Name"
            if let last = fju.lastName {
                cell.aDescription = last
            }
        case 2:
            cell.subject = "Email Address"
            if let email = fju.emailAddress {
                cell.aDescription = email
            }
        case 3:
            cell.subject = "Phone Number"
            if let phone = fju.mobileNumber {
                cell.aDescription = phone
            }
        case 12:
            cell.subject = "Fire Station"
            if let station = fju.fireStation {
                cell.aDescription = station
            }
        case 13:
            cell.subject = "Website"
            if let site = fju.fireStationWebSite {
                cell.aDescription = site
            }
        default: break
        }
        cell.configure()
        return cell
    }
    
    func configureRankTVCell(_ cell: RankTVCell, index: IndexPath) -> RankTVCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        cell.indexPath = index
        cell.theSubjectTF.font = UIFont.preferredFont(forTextStyle: .caption1)
        switch row {
        case 5:
            cell.type = IncidentTypes.platoon
            if fju != nil {
                if let platoon = fju.tempPlatoon {
                    cell.theSubjectTF.text = platoon
                }
            }
        case 6:
            cell.type = IncidentTypes.theRanks
            if fju != nil {
                if let rank = fju.rank {
                    cell.theSubjectTF.text = rank
                }
            }
        case 7:
            cell.type = IncidentTypes.assignment
            if fju != nil {
                if let assignment = fju.tempAssignment {
                    cell.theSubjectTF.text = assignment
                }
            }
        case 8:
            cell.type = IncidentTypes.apparatus
            if fju != nil {
                if let apparatus = fju.tempApparatus {
                    cell.theSubjectTF.text = apparatus
                }
            }
        default: break
        }
        return cell
    }
    
    func configureMultipleAddButtonTVCell(_ cell: MultipleAddButtonTVCell, index: IndexPath) -> MultipleAddButtonTVCell {
        cell.tag = index.row
        cell.indexPath = index
        let section = index.section
        let row = index.row
        cell.delegate = self
        switch section {
        case 0:
            switch row {
            case 9:
                cell.type = IncidentTypes.fdid
                cell.aBackgroundColor = "FJBlueColor"
                cell.aChoice = ""
            default: break
            }
        default: break
        }
        return cell
    }
    
        //    MARK:- Address fields and buttons cell
    
        /// configuring the NewAddressFieldsButtonsCell
        /// - Parameters:
        ///   - cell: NewAddressFieldsButtonsCell
        ///   - indexPath: indexPath of cell
        ///   - tag: cell.tag int
        /// - Returns: street, city, state, zip, latitude, and longitude with map buttons
    func configureNewAddressFieldsButtonsCell(_ cell: NewAddressFieldsButtonsCell, at indexPath: IndexPath, tag: Int) -> NewAddressFieldsButtonsCell {
        cell.tag = tag
        cell.delegate = self
        cell.subjectL.text = "Address:"
        var streetAddress: String = ""
        var city: String = ""
        var state: String = ""
        var zip: String = ""
        var latitude: String = ""
        var longitude: String = ""
        if fju.theLocation != nil {
            theLocation = fju.theLocation
            if let number = theLocation.streetNumber {
                streetAddress = number + " "
            }
            if let street = theLocation.streetName {
                streetAddress = streetAddress + street
            }
            if let c = theLocation.city {
                city = c
            }
            if let s = theLocation.state {
                state = s
            }
            if let z = theLocation.zip {
                zip = z
            }
            if theLocation.latitude != 0.0 {
                latitude = String(theLocation.latitude)
            }
            if theLocation.longitude != 0.0 {
                longitude = String(theLocation.longitude)
            }
        }
        cell.addressTF.text = streetAddress
        cell.addressTF.placeholder = "100 Grant"
        cell.addressTF.textColor = UIColor.label
        cell.cityTF.text = city
        cell.cityTF.placeholder = "City"
        cell.cityTF.textColor = UIColor.label
        cell.stateTF.text = state
        cell.stateTF.placeholder = "State"
        cell.stateTF.textColor = UIColor.label
        cell.zipTF.text = zip
        cell.zipTF.placeholder = "Zip Code"
        cell.zipTF.textColor = UIColor.label
        cell.addressLatitudeTF.text = latitude
        cell.addressLatitudeTF.textColor = UIColor.label
        cell.addressLongitudeTF.text = longitude
        cell.addressLongitudeTF.textColor = UIColor.label
        cell.addressLatitudeTF.placeholder = "Latitude"
        cell.addressLongitudeTF.placeholder = "Longitude"
        return cell
    }
    
}

extension SettingsTheProfileTVC: NewAddressFieldsButtonsCellDelegate {
    
    func worldBTapped(tag: Int) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "OnBoard", bundle:nil)
        let onBoardAddressSearchlVC = storyBoard.instantiateViewController(withIdentifier: "OnBoardAddressSearch") as! OnBoardAddressSearch
        guard let region = getUserLocation.cameraBoundary else {
            mapAlert()
            return }
        theUserRegion = region
        onBoardAddressSearchlVC.type = IncidentTypes.allIncidents
        onBoardAddressSearchlVC.boundarys = theUserRegion
        onBoardAddressSearchlVC.searches = getUserLocation.searchBoundary
        onBoardAddressSearchlVC.stationBoundary = getUserLocation.mapBoundary
        onBoardAddressSearchlVC.theMapTag = tag
        onBoardAddressSearchlVC.delegate = self
        self.present(onBoardAddressSearchlVC, animated: true, completion: nil)
    }
    
    func worldB2Tapped(tag: Int) {
        
    }
    
    fileprivate func saveTheLocation() {
        do {
            try context.save()
            
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Settins The Profile TVC deal here"])
            }
            DispatchQueue.main.async {
                let objectID = self.theLocation.objectID
                    self.nc.post(name: .fireJournalModifyFCLocationToCloud, object: nil, userInfo: ["objectID": objectID as NSManagedObjectID])
            }
            DispatchQueue.main.async {
                self.nc.post(name: .fireJournalUserModifiedSendToCloud , object: nil, userInfo: ["objectID": self.fju.objectID])
            }
            
        }   catch let error as NSError {
            let nserror = error
            let errorMessage = "SettingsTheProfileTVC saveToCD() Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    func locationBTapped(tag: Int) {
        
        guard let location = getUserLocation.currentLocation else {
            mapAlert()
            return
        }
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            switch tag {
            case 14:
                if self.theLocation != nil {
                    self.theLocation.location = location
                    self.theLocation.latitude = location.coordinate.latitude
                    self.theLocation.longitude = location.coordinate.longitude
                    guard let count = placemarks?.count else {
                        self.errorAlert(errorMessage: "There were no placemarks in this location-  failed with error" + (error?.localizedDescription ?? ""))
                        return
                    }
                    if count != 0 {
                        guard let pm = placemarks?[0] else { return }
                        if pm.thoroughfare != nil {
                            if let pmCity = pm.locality {
                                self.theLocation.city = "\(pmCity)"
                            } else {
                                self.theLocation.city = ""
                            }
                            if let pmSubThroughfare = pm.subThoroughfare {
                                self.theLocation.streetNumber = "\(pmSubThroughfare)"
                            } else {
                                self.theLocation.streetNumber = ""
                            }
                            if let pmThoroughfare = pm.thoroughfare {
                                self.theLocation.streetName = "\(pmThoroughfare)"
                            } else {
                                self.theLocation.streetName = ""
                            }
                            if let pmState = pm.administrativeArea {
                                self.theLocation.state = "\(pmState)"
                            } else {
                                self.theLocation.state = ""
                            }
                            if let pmZip = pm.postalCode {
                                self.theLocation.zip = "\(pmZip)"
                            } else {
                                self.theLocation.zip = ""
                            }
                            
                            let index = IndexPath(row: 14, section: 0)
                            self.tableView.reloadRows(at: [index], with: .automatic)
                        }
                    }
                    self.saveTheLocation()
                } else {
                    self.theLocation = FCLocation(context: self.context)
                    self.theLocation.guid = UUID()
                    self.fju.theLocation = self.theLocation
                    if let guid = self.fju.userGuid {
                        self.theLocation.userGuid = guid
                    }
                    self.theLocation.location = location
                    self.theLocation.latitude = location.coordinate.latitude
                    self.theLocation.longitude = location.coordinate.longitude
                    guard let count = placemarks?.count else {
                        self.errorAlert(errorMessage: "There were no placemarks in this location-  failed with error" + (error?.localizedDescription ?? ""))
                        return
                    }
                    if count != 0 {
                        guard let pm = placemarks?[0] else { return }
                        if pm.thoroughfare != nil {
                            if let pmCity = pm.locality {
                                self.theLocation.city = "\(pmCity)"
                            } else {
                                self.theLocation.city = ""
                            }
                            if let pmSubThroughfare = pm.subThoroughfare {
                                self.theLocation.streetNumber = "\(pmSubThroughfare)"
                            } else {
                                self.theLocation.streetNumber = ""
                            }
                            if let pmThoroughfare = pm.thoroughfare {
                                self.theLocation.streetName = "\(pmThoroughfare)"
                            } else {
                                self.theLocation.streetName = ""
                            }
                            if let pmState = pm.administrativeArea {
                                self.theLocation.state = "\(pmState)"
                            } else {
                                self.theLocation.state = ""
                            }
                            if let pmZip = pm.postalCode {
                                self.theLocation.zip = "\(pmZip)"
                            } else {
                                self.theLocation.zip = ""
                            }
                            
                            let index = IndexPath(row: 14, section: 0)
                            self.tableView.reloadRows(at: [index], with: .automatic)
                        }
                    }
                    self.saveTheLocation()
                }
            default: break
            }
            
        })
    }
    
    
}

extension SettingsTheProfileTVC: OnBoardAddressSearchDelegate {
    
    func addressHasBeenChosen(location: CLLocationCoordinate2D, address: String, tag: Int) {
        self.dismiss(animated: true, completion: nil )
        let theUserLocation = CLLocation.init(latitude: location.latitude, longitude: location.longitude)
        
        CLGeocoder().reverseGeocodeLocation(theUserLocation, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                self.errorAlert(errorMessage: "Reverse geocoder failed with error" + (error?.localizedDescription ?? ""))
                return
            }
            
            guard let count = placemarks?.count else {
                self.errorAlert(errorMessage: "There were no placemarks in this location-  failed with error" + (error?.localizedDescription ?? ""))
                return
            }
            if count != 0 {
                switch tag {
                case 14:
                    if self.theLocation != nil {
                        self.theLocation.location = theUserLocation
                        self.theLocation.latitude = location.latitude
                        self.theLocation.longitude = location.longitude
                        guard let pm = placemarks?[0] else { return }
                        if pm.thoroughfare != nil {
                            if let pmCity = pm.locality {
                                self.theLocation.city = "\(pmCity)"
                            } else {
                                self.theLocation.city = ""
                            }
                            if let pmSubThroughfare = pm.subThoroughfare {
                                self.theLocation.streetNumber = "\(pmSubThroughfare)"
                            } else {
                                self.theLocation.streetNumber = ""
                            }
                            if let pmThoroughfare = pm.thoroughfare {
                                self.theLocation.streetName = "\(pmThoroughfare)"
                            } else {
                                self.theLocation.streetName = ""
                            }
                            if let pmState = pm.administrativeArea {
                                self.theLocation.state = "\(pmState)"
                            } else {
                                self.theLocation.state = ""
                            }
                            if let pmZip = pm.postalCode {
                                self.theLocation.zip = "\(pmZip)"
                            } else {
                                self.theLocation.zip = ""
                            }
                            
                            
                            let index = IndexPath(row: 14, section: 0)
                            self.tableView.reloadRows(at: [index], with: .automatic)
                        }
                        self.saveTheLocation()
                    } else {
                        self.theLocation = FCLocation(context: self.context)
                        self.theLocation.guid = UUID()
                        self.fju.theLocation = self.theLocation
                        if let guid = self.fju.userGuid {
                            self.theLocation.userGuid = guid
                        }
                        self.fju.theLocation = self.theLocation
                        self.theLocation.location = theUserLocation
                        self.theLocation.latitude = location.latitude
                        self.theLocation.longitude = location.longitude
                        guard let pm = placemarks?[0] else { return }
                        if pm.thoroughfare != nil {
                            if let pmCity = pm.locality {
                                self.theLocation.city = "\(pmCity)"
                            } else {
                                self.theLocation.city = ""
                            }
                            if let pmSubThroughfare = pm.subThoroughfare {
                                self.theLocation.streetNumber = "\(pmSubThroughfare)"
                            } else {
                                self.theLocation.streetNumber = ""
                            }
                            if let pmThoroughfare = pm.thoroughfare {
                                self.theLocation.streetName = "\(pmThoroughfare)"
                            } else {
                                self.theLocation.streetName = ""
                            }
                            if let pmState = pm.administrativeArea {
                                self.theLocation.state = "\(pmState)"
                            } else {
                                self.theLocation.state = ""
                            }
                            if let pmZip = pm.postalCode {
                                self.theLocation.zip = "\(pmZip)"
                            } else {
                                self.theLocation.zip = ""
                            }
                            
                            
                            let index = IndexPath(row: 14, section: 0)
                            self.tableView.reloadRows(at: [index], with: .automatic)
                        }
                        self.saveTheLocation()
                    }
                default: break
                }
            }
            
        })
    }
    
}

extension SettingsTheProfileTVC: MultipleAddButtonTVCellDelegate {
    
    func multiAddBTapped(type: IncidentTypes, index: IndexPath) {
        if Device.IS_IPHONE {
            presentModal(type: FJSettings.fdid, sizeTrait: compact)
        } else {
            presentModal(type: FJSettings.fdid, sizeTrait: compact)
//            delegate?.profileSettingsGetData(type:FJSettings.fdid,compact:compact)
        }
    }
    
    func multiTitleChosen(type: IncidentTypes, title: String, index: IndexPath) {
    }
    
    
}

extension SettingsTheProfileTVC: RankTVCellDelegate {
    
    func theButtonChoiceWasMade(_ text: String, index: IndexPath, tag: Int) {
        switch tag {
        case 5:
            fju.platoon = text
            fju.tempPlatoon = text
            tableView.reloadRows(at: [IndexPath(row:5, section: 0)], with: .automatic)
        case 6:
            fju.rank = text
            tableView.reloadRows(at: [IndexPath(row:6, section: 0)], with: .automatic)
        case 7:
            fju.tempAssignment = text
            tableView.reloadRows(at: [IndexPath(row:7, section: 0)], with: .automatic)
        case 8:
            fju.tempApparatus = text
            tableView.reloadRows(at: [IndexPath(row:8, section: 0)], with: .automatic)
        default: break
        }
    }
    
}

extension SettingsTheProfileTVC: ProfileLabelTextFieldTVCellDelegate {
    
    func profileDescriptionChanged(text: String, tag: Int) {
        switch tag {
        case 0:
            fju.firstName = text
        case 1:
            fju.lastName = text
        case 2:
            fju.emailAddress = text
        case 3:
            fju.mobileNumber = text
        case 12:
            fju.fireStation = text
        case 13:
            fju.fireStationWebSite = text
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
        let okAction = UIAlertAction.init(title: "Thanks", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapAlert() {
        let subject = InfoBodyText.mapErrorSubject.rawValue
        let message = InfoBodyText.mapErrorDescription.rawValue
        let alert = UIAlertController.init(title: subject, message: message, preferredStyle: .alert)
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

extension SettingsTheProfileTVC: SettingsProfileDataDelegate {
    
        //    MARK: -SettingsProfileDataDelegate
    func settingsProfileDataCanceled() {
        if objectID != nil {
            fju = context.object(with: objectID) as? FireJournalUser
            fdidChosen = true
            self.tableView.reloadData()
        } else {
            delegate?.theProfileReturnToSettings(compact: .compact)
        }
    }
    
    func settingsProfileDataChosen(type: FJSettings, _ object: String) {
        
    }
    
}
