//
//  SettingsProfileTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/20/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

protocol SettingsProfileTVCDelegate: AnyObject {
    func profileReturnToSettings(compact:SizeTrait)
    func profileSavedNowGoToSettings(compact:SizeTrait)
    func profileSettingsGetData(type:FJSettings,compact:SizeTrait)
}

class SettingsProfileTVC: UITableViewController,CLLocationManagerDelegate,UITextFieldDelegate {
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var platoonTF: UITextField!
    @IBOutlet weak var rankTF: UITextField!
    @IBOutlet weak var assignmentTF: UITextField!
    @IBOutlet weak var fdidTF: UITextField!
    @IBOutlet weak var apparatusTF: UITextField!
    @IBOutlet weak var fireStationNumberTF: UITextField!
    @IBOutlet weak var streetNumberTF: UITextField!
    @IBOutlet weak var streetNameTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var zipCodeTF: UITextField!
    @IBOutlet weak var websiteURLTF: UITextField!
    @IBOutlet weak var fireDepartmentTF: UITextField!
    @IBOutlet weak var resetB: UIButton!
    

    @IBOutlet weak var worldB: UIButton!
    @IBOutlet weak var locationB: UIButton!
    
    let nc = NotificationCenter.default
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var fireJournalUser:FireJournalUserOnboard!
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
    
    var compact:SizeTrait = .regular
    
    weak var delegate:SettingsProfileTVCDelegate? = nil
    
    @IBAction func resetTheDataBTapped(_ sender: UIButton) {
        
    }
    
    
    @IBAction func locationBTapped(_ sender: Any) {
        determineLocation()
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
                self.cityTF.text = self.city
                self.streetNum = "\(pm.subThoroughfare!)"
                self.streetNumberTF.text = self.streetNum
                self.streetName = "\(pm.thoroughfare!)"
                self.streetNameTF.text = self.streetName
                self.stateName = "\(pm.administrativeArea!)"
                self.stateTF.text = self.stateName
                self.zipNum = "\(pm.postalCode!)"
                self.zipCodeTF.text = self.zipNum
                self.theUsersLocation = userLocation
                self.tableView.reloadData()
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    @IBAction func worldBTapped(_ sender: Any) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        getTheUser(entity: entity, attribute: attribute, sortAttribute: sortAttribute)
        
        if fju.userGuid != "" {
            fireJournalUser = FireJournalUserOnboard()
            firstNameTF.text = fju.firstName ?? ""
            fireJournalUser.fjuFirstName = fju.firstName ?? ""
            lastNameTF.text = fju.lastName ?? ""
            fireJournalUser.fjuLastName = fju.lastName ?? ""
            emailTF.text = fju.emailAddress ?? ""
            fireJournalUser.fjuEmailAddress = fju.emailAddress ?? ""
            phoneTF.text = fju.mobileNumber ?? ""
            fireJournalUser.fjuPhoneNumber = fju.mobileNumber ?? ""
            platoonTF.text = fju.platoon ?? ""
            fireJournalUser.fjuPlatoon = fju.platoon ?? ""
            rankTF.text = fju.rank ?? ""
            fireJournalUser.fjuRank = fju.rank ?? ""
            assignmentTF.text = fju.initialAssignment ?? ""
            fireJournalUser.fjuAssignment = fju.initialAssignment ?? ""
            fdidTF.text = fju.fdid ?? ""
            fireJournalUser.fjuFDID = fju.fdid ?? ""
            apparatusTF.text = fju.initialApparatus ?? ""
            fireJournalUser.fjuApparatus = fju.initialApparatus ?? ""
            fireStationNumberTF.text = fju.fireStation ?? ""
            fireJournalUser.fjuFireStation = fju.fireStation ?? ""
            streetNumberTF.text = fju.fireStationStreetNumber ?? ""
            fireJournalUser.fjuStreetNum = fju.fireStationStreetNumber ?? ""
            streetNameTF.text = fju.fireStationStreetName ?? ""
            fireJournalUser.fjuStreetName = fju.fireStationStreetName ?? ""
            cityTF.text = fju.fireStationCity ?? ""
            fireJournalUser.fjuCity = fju.fireStationCity ?? ""
            stateTF.text = fju.fireStationState ?? ""
            fireJournalUser.fjuState = fju.fireStationState ?? ""
            zipCodeTF.text = fju.fireStationZipCode ?? ""
            fireJournalUser.fjuZip = fju.fireStationZipCode ?? ""
            websiteURLTF.text = fju.fireStationWebSite ?? ""
            fireJournalUser.fjuWebSite = fju.fireStationWebSite ?? ""
            fireDepartmentTF.text = fju.fireDepartment ?? ""
            fireJournalUser.fjuFireDepartment = fju.fireDepartment ?? ""
        }
        
        switch compact {
        case .compact:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateTheProfile(_:)))
            
            navigationItem.setLeftBarButtonItems([button1], animated: true)
            
            navigationItem.setRightBarButtonItems([button2], animated: true)
        case .regular:
            let button1 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            let button2 = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateTheProfile(_:)))
            
//            navigationItem.leftItemsSupplementBackButton = true
//            let button3 = self.splitViewController?.displayModeButtonItem
            navigationItem.setLeftBarButtonItems([button1], animated: true)
            
            navigationItem.setRightBarButtonItems([button2], animated: true)
        }
        
        self.title = titleName
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
            switch compact {
            case .compact:
                print("compact SETTING PROFILE")
            case .regular:
                print("regular SETTING PROFILE")
            }
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func goBackToSettings(_ sender: Any) {
        switch compact {
        case .compact:
            delegate?.profileReturnToSettings(compact: compact)
        case .regular:
            nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                                           object: nil,
                                           userInfo: ["sizeTrait":compact])
        }
    }
    
    @IBAction func updateTheProfile(_ sender: Any) {
        fju.firstName = firstNameTF.text ?? ""
        fju.lastName = lastNameTF.text ?? ""
        fju.emailAddress = emailTF.text ?? ""
        fju.mobileNumber = phoneTF.text ?? ""
        fju.platoon = platoonTF.text ?? ""
        fju.rank = rankTF.text ?? ""
        fju.initialAssignment = assignmentTF.text ?? ""
        fju.fdid = fdidTF.text ?? ""
        fju.initialApparatus = apparatusTF.text ?? ""
        fju.fireStation = fireStationNumberTF.text ?? ""
        fju.fireStationStreetNumber = streetNumberTF.text ?? ""
        fju.fireStationStreetName = streetNameTF.text ?? ""
        fju.fireStationCity = cityTF.text ?? ""
        fju.fireStationState = stateTF.text ?? ""
        fju.fireStationZipCode = zipCodeTF.text ?? ""
        fju.fireStationWebSite = websiteURLTF.text ?? ""
        fju.fireDepartment = fireDepartmentTF.text ?? ""
        
        /// location saved as Data with secureCodeing
        if theUsersLocation != nil {
            if let location = theUsersLocation {
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
    
    override func viewWillLayoutSubviews() {
        firstNameTF.isUserInteractionEnabled = true
        firstNameTF.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if launchNC != nil {
            launchNC.removeNC()
        }
    }
    
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            let nc = NotificationCenter.default
            getTheLastSaved(guid: fju.userGuid ?? "")
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"Settings Profile TVC deal here"])
                print("we have saved to the cloud")
            }
            DispatchQueue.main.async {
                self.nc.post(name: .fireJournalUserModifiedSendToCloud , object: nil, userInfo: ["objectID": self.objectID!])
            }
            switch compact {
            case .compact:
                delegate?.profileSavedNowGoToSettings(compact: compact)
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
            let errorMessage = "SettingsProfileTVC saveToCD() Unresolved error \(nserror), \(nserror.userInfo)"
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
            print("Fetch  FireJournalUser failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("MyProfileHeaderV", owner: self, options: nil)?.first as! MyProfileHeaderV
        let color = ButtonsForFJ092018.blueGradientColor
        headerV.colorV.backgroundColor = color
        headerV.subjetL.text = "My Profile"
        headerV.descriptionTV.text = "Your profile settings help with keeping your journal, incident and NFIRS forms filled out correctly with the most accurate information available."
        return headerV
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 20
    }
    
    /// Mark: -tableView heightForRowAt
    /// Using TableSize class to build the size for each cell for each type of MenuItems
    ///
    /// - Parameters:
    ///   - tableView: self.tableview
    ///   - indexPath: the indexPath for each cell
    /// - Returns: CGFloat
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0...10:
            return 44
        case 11:
            return 65
        case 12...19:
            return 44
        default:
            return 44
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch row {
        case 0, 1, 2, 3, 4, 5 :
            print("here is the row you are tapping on \(row)")
            break
        case 6:
            switch compact {
            case .compact:
                delegate?.profileSettingsGetData(type:FJSettings.platoon,compact:compact)
            case .regular:
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkSETTINGSPROFILEDATACalled),
                                 object: nil,
                                 userInfo: ["type":FJSettings.platoon,"sizeTrait":self.compact])
                }
            }
        case 7:
            switch compact {
            case .compact:
                delegate?.profileSettingsGetData(type:FJSettings.rank,compact:compact)
            case .regular:
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkSETTINGSPROFILEDATACalled),
                             object: nil,
                             userInfo: ["type":FJSettings.rank,"sizeTrait":self.compact])
            }
            }
        case 8:
            switch compact {
            case .compact:
                delegate?.profileSettingsGetData(type:FJSettings.assignment,compact:compact)
            case .regular:
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkSETTINGSPROFILEDATACalled),
                             object: nil,
                             userInfo: ["type":FJSettings.assignment,"sizeTrait":self.compact])
            }
            }
        case 9:
            switch compact {
            case .compact:
                delegate?.profileSettingsGetData(type:FJSettings.fdid,compact:compact)
            case .regular:
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkSETTINGSPROFILEDATACalled),
                             object: nil,
                             userInfo: ["type":FJSettings.fdid,"sizeTrait":self.compact])
            }
            }
        case 10:
            switch compact {
            case .compact:
                delegate?.profileSettingsGetData(type:FJSettings.apparatus,compact:compact)
            case .regular:
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkSETTINGSPROFILEDATACalled),
                             object: nil,
                             userInfo: ["type":FJSettings.apparatus,"sizeTrait":self.compact])
            }
            }
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if editingStyle == .delete
            {
                
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
    }

}
