    //
    //  SettingsTVC.swift
    //  dashboard
    //
    //  Created by DuRand Jones on 9/4/18.
    //  Copyright © 2018 PureCommand LLC. All rights reserved.
    //

import UIKit
import Foundation
import CoreData

protocol SettingsTVCDelegate: AnyObject {
    func settingsTapped()
    func settingsLoadPage(settings:FJSettings, userObjectID: NSManagedObjectID)
}

class SettingsTVC: UITableViewController {
    
    weak var delegate:SettingsTVCDelegate? = nil
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    let nc = NotificationCenter.default
    var splitVC:UISplitViewController!
    let userDefaults = UserDefaults.standard
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var titleName: String = ""
    var controllerName:String = ""
    var myShift:MenuItems! = nil
    var segue:String = ""
    var collapsed:Bool = false
    var compact:SizeTrait = .regular
    var device:Device!
    var count: Int = 0
    var alertUp: Bool = false
    var userObjectID: NSManagedObjectID!
    var child: SpinnerViewController!
    var childAdded: Bool = false
    
    
    //    MARK: -REMOVE DATA
    /**Send to CloudKit manager
     
    check if true FJkREMOVEALLDATA
    notification post fireJournalRemoveAllDataFromCloudKit
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        device = Device.init()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        count = theCount(entity: "UserFDResources")
        
        collapsed = userDefaults.bool(forKey: FJkFJISCOLLAPSED)
        
        switch compact {
        case .compact:
            navigationItem.leftItemsSupplementBackButton = true
            let button3 = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(goBackToMaster(_:)))
            navigationItem.setLeftBarButtonItems([button3], animated: true)
        default: break
        }
        
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        
            //        MARK: -OBSERVE WHEN TAGS HAVE BEEN RELOADED
        nc.addObserver(self, selector: #selector(tagsAreLoadedNow(ns:)), name: NSNotification.Name(rawValue: FJkReloadUserTagsFinished), object: nil)
        
        
            //        MARK: -OBSERVE WHEN RANK HAVE BEEN RELOADED
        nc.addObserver(self, selector: #selector(rankAreLoadedNow(ns:)), name: NSNotification.Name(rawValue: FJkReloadUserRankFinished), object: nil)
        
            //        MARK: -OBSERVE WHEN  PLATOON HAVE BEEN RELOADED
        nc.addObserver(self, selector: #selector(platoonAreLoadedNow(ns:)), name: NSNotification.Name(rawValue: FJkReloadUserPlatoonFinished), object: nil)
        
            //        MARK: -OBSERVE WHEN  LOCALINCIDENTTYPE HAVE BEEN RELOADED
        nc.addObserver(self, selector: #selector(localIncidentTypeAreLoadedNow(ns:)), name: NSNotification.Name(rawValue: FJkReloadLocalIncidentTypesFinished), object: nil)
        
//        MARK: -OBSERVE FOR ZONE DELETION FAILURE-
        nc.addObserver(self, selector: #selector(zoneDeletionFailure(nc:)), name: .fConCKZoneFailure, object: nil)
        
            //        MARK: -OBSERVE FOR ZONE DELETION SUCCESS-
        nc.addObserver(self, selector: #selector(zoneDeletionSuccess(nc:)), name: .fConCKZoneSuccess, object: nil)

            //        MARK: -OBSERVE FOR SUBSCRIPTION FAILURE-
        nc.addObserver(self, selector: #selector(zoneDeletionFailure(nc:)), name: .fConCKSubscriptionFailure, object: nil)
        
            //        MARK: -OBSERVE FOR Core DATA DELETION FAILURE-
        nc.addObserver(self, selector: #selector(zoneDeletionFailure(nc:)), name: .fConCDFailure, object: nil)

            //        MARK: -OBSERVE FOR CORE DATA DELETION SUCCESS-
        nc.addObserver(self, selector: #selector(coreDataDeletionSuccess(nc:)), name: .fConCDSuccess, object: nil)

        
        registerCells()
        
        let delete = userDefaults.bool(forKey: FJkREMOVEALLDATA)
        
        if delete {
            createSpinnerView()
            DispatchQueue.main.async {
                self.nc.post(name: .fireJournalRemoveAllDataFromCloudKit, object: nil)
            }
        }
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: "SettingsTVCell", bundle: nil), forCellReuseIdentifier: "SettingsTVCellIdentifier")
    }
    
    @IBAction func goBackToMaster(_ sender: Any) {
        delegate?.settingsTapped()
    }
    
    @objc func zoneDeletionSuccess(nc: Notification) {
        DispatchQueue.main.async {
            self.nc.post(name: .fireJournalRemoveAllDataFromCD, object: nil)
        }
    }
    
    
    @objc func coreDataDeletionSuccess(nc: Notification) {
        removeSpinnerView {
            let message = "Your data on this device has been removed and will now be returned to the agreement screen"
            completionAlert(message)
        }
    }
    
    @objc func zoneDeletionFailure(nc: Notification) {
        if let userInfo = nc.userInfo as! [String: Any]? {
            if let errorMessage = userInfo["errorMessage"] as? String {
                removeSpinnerView {
                    errorAlert(errorMessage)
                }
            }
        }
    }
    
    func createSpinnerView() {
        child = SpinnerViewController()
        childAdded = true
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func removeSpinnerView(completionBlock: () -> ()) {
        if childAdded {
            DispatchQueue.main.async {
                    // then remove the spinner view controller
                self.child.willMove(toParent: nil)
                self.child.view.removeFromSuperview()
                self.child.removeFromParent()
            }
            childAdded = false
            completionBlock()
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
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if launchNC != nil {
            launchNC.removeNC()
        }
    }
    

    
        // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
        return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
            // MARK: - Table view data source// MARK: - Table View
            override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let headerV = Bundle.main.loadNibNamed("SettingsModalHeadzerSaveDismiss", owner: self, options: nil)?.first as! SettingsModalHeadzerSaveDismiss
                return headerV
            }
        
            override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                return 126
            }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.item
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTVCellIdentifier", for: indexPath) as! SettingsTVCell
        configureCell(theRow: row, theCell: cell)
        return cell
    }
    
    private func configureCell(theRow row: Int, theCell cell: SettingsTVCell) {
        var fontSize = 26
        if Device.IS_IPHONE {
            fontSize = 18
            cell.settingsSubjectL.font = cell.settingsSubjectL.font.withSize(CGFloat(fontSize))
        }
        switch row {
        case 0:
            cell.iconIV.image = UIImage(named: "Profile")
            cell.settingsSubjectL.text = "My Profile"
            cell.settingType = FJSettings.myProfile
        case 1:
            cell.iconIV.image = UIImage(named: "TagsIcon")
            cell.settingsSubjectL.text = "Tags"
            cell.settingType = FJSettings.tags
        case 2:
            cell.iconIV.image = UIImage(named: "SettingsIconDefault")
            cell.settingsSubjectL.text = "Local Incident Types"
            cell.settingType = FJSettings.localIncidentTypes
        case 3:
            cell.iconIV.image = UIImage(named: "ICONS_06092022_dataManagement")
            cell.settingsSubjectL.text = "Your Data"
            cell.settingType = FJSettings.resetData
        case 4:
            cell.iconIV.image = UIImage(named: "SettingsICloudIcon")
            cell.settingsSubjectL.text = "About Membership"
            cell.settingType = FJSettings.cloud
        case 5:
            cell.iconIV.image = UIImage(named: "SettingsIconDefault")
            cell.settingsSubjectL.text = "Terms and Conditions"
            cell.settingType = FJSettings.terms
        case 6:
            cell.iconIV.image = UIImage(named: "SettingsIconDefault")
            cell.settingsSubjectL.text = "User Privacy"
            cell.settingType = FJSettings.privacy
        default:
            cell.iconIV.image = UIImage(named: "MyFireEMSResource")
            cell.settingsSubjectL.text = "My Fire/EMS Resources"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsTVCell
            launchSettingsPage(cell.settingType)
        case 1:
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsTVCell
            launchSettingsPage(cell.settingType)
        case 2:
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsTVCell
            launchSettingsPage(cell.settingType)
        case 3:
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsTVCell
            launchSettingsPage(cell.settingType)
        case 4:
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsTVCell
            launchSettingsPage(cell.settingType)
        case 5:
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsTVCell
            launchSettingsPage(cell.settingType)
        case 6:
            let cell = tableView.cellForRow(at: indexPath)! as! SettingsTVCell
            launchSettingsPage(cell.settingType)
        default:break
        }
    }
    
    
    
    private func launchSettingsPage(_ settings:FJSettings) {
        switch settings {
        case .myProfile:
            switch compact {
            case .compact:
                if userObjectID != nil {
                    delegate?.settingsLoadPage(settings: settings, userObjectID: userObjectID)
                }
            case .regular:
                if userObjectID != nil {
                    nc.post(name:Notification.Name(rawValue: FJkPROFILE_FROM_MASTER),
                            object: nil,
                            userInfo: ["sizeTrait":compact, "userObjID": userObjectID!])
                }
            }
        case .cloud:
            if collapsed {
                if userObjectID != nil {
                    delegate?.settingsLoadPage(settings: settings, userObjectID: userObjectID)
                }
            } else {
                if userObjectID != nil {
                    nc.post(name:Notification.Name(rawValue: FJkSETTINGSFJCLOUDCalled),
                            object: nil,
                            userInfo: ["sizeTrait":compact, "userObjID": userObjectID!])
                }
            }
        case .crewMembers:
            if collapsed {
                if userObjectID != nil {
                    delegate?.settingsLoadPage(settings: settings, userObjectID: userObjectID)
                }
            } else {
                if userObjectID != nil {
                    nc.post(name:Notification.Name(rawValue:FJkSETTINGSCREWCalled),
                            object: nil,
                            userInfo: ["sizeTrait":compact, "userObjID": userObjectID!])
                }
            }
        case .tags:
            let count = theCount(entity: "Tag")
            if count == 0 {
                if !alertUp {
                    tagsPresentAlert()
                }
            } else {
                if collapsed {
                    if userObjectID != nil {
                        delegate?.settingsLoadPage(settings: settings, userObjectID: userObjectID)
                    }
                } else {
                    if userObjectID != nil {
                        nc.post(name:Notification.Name(rawValue: FJkSETTINGSTAGSCalled),
                                object: nil,
                                userInfo: ["sizeTrait":compact, "userObjID": userObjectID!])
                    }
                }
            }
        case .rank:
            let count = theCount(entity: "UserRank")
            if count == 0 {
                if !alertUp {
                    rankPresentAlert()
                }
            } else {
                if collapsed {
                    if userObjectID != nil {
                        delegate?.settingsLoadPage(settings: settings, userObjectID: userObjectID)
                    }
                } else {
                    if userObjectID != nil {
                        nc.post(name:Notification.Name(rawValue:FJkSETTINGRANKCalled),
                                object: nil,
                                userInfo: ["sizeTrait":compact, "userObjID": userObjectID!])
                    }
                }
            }
        case .platoon:
            let count = theCount(entity: "UserPlatoon")
            if count == 0 {
                if !alertUp {
                    platoonPresentAlert()
                }
            } else {
                if collapsed {
                    if userObjectID != nil {
                        delegate?.settingsLoadPage(settings: settings, userObjectID: userObjectID)
                    }
                } else {
                    if userObjectID != nil {
                        nc.post(name:Notification.Name(rawValue:FJkSETTINGPLATOONCalled),
                                object: nil,
                                userInfo: ["sizeTrait":compact, "userObjID": userObjectID!])
                    }
                }
            }
        case .localIncidentTypes:
            let count = theCount(entity: "UserLocalIncidentType")
            if count == 0 {
                if !alertUp {
                    localIncidentTypePresentAlert()
                }
            } else {
                if collapsed {
                    if userObjectID != nil {
                        delegate?.settingsLoadPage(settings: settings, userObjectID: userObjectID)
                    }
                } else {
                    if userObjectID != nil {
                        nc.post(name:Notification.Name(rawValue:FJkSETTINGLOCALINCIDENTTYPECalled),
                                object: nil,
                                userInfo: ["sizeTrait":compact, "userObjID": userObjectID!])
                    }
                }
            }
        case .terms:
            if collapsed {
                if userObjectID != nil {
                    delegate?.settingsLoadPage(settings: settings, userObjectID: userObjectID)
                }
            } else {
                if userObjectID != nil {
                    nc.post(name:Notification.Name(rawValue:FJkSETTINGTERMSCalled),
                            object: nil,
                            userInfo: ["sizeTrait":compact, "userObjID": userObjectID!])
                }
            }
        case .privacy:
            if collapsed {
                if userObjectID != nil {
                    delegate?.settingsLoadPage(settings: settings, userObjectID: userObjectID)
                }
            } else {
                if userObjectID != nil {
                    nc.post(name:Notification.Name(rawValue: FJkSETTINGPRIVACYCalled),
                            object: nil,
                            userInfo: ["sizeTrait":compact, "userObjID": userObjectID!])
                }
            }
        case .resetData:
            if collapsed {
                if userObjectID != nil {
                    delegate?.settingsLoadPage(settings: settings, userObjectID: userObjectID)
                }
            } else {
                if userObjectID != nil {
                    nc.post(name:Notification.Name(rawValue: FJkSETTINGRESETDATACalled),
                            object: nil,
                            userInfo: ["sizeTrait":compact, "userObjID": userObjectID!])
                }
            }
        default:
            break
        }
    }
    
}

extension SettingsTVC {
    
        //    MARK: -ALERTS-
            func completionAlert(_ message: String) {
                let alert = UIAlertController.init(title: "Deletion Completed", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                    self.moveToAgreement()
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
    
    func moveToAgreement() {
        DispatchQueue.main.async {
            self.nc.post(name: .fConCKCDDeletionCompleted,
                    object: nil,
                    userInfo: nil )
        }
    }
            
            func errorAlert(_ errorMessage: String ) {
                let alert = UIAlertController.init(title: "Deletion Error", message: errorMessage, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
            
                /// Alert presented when there are no Fire Station Resources chosen yet
            func presentAlert() {
                let title: InfoBodyText = .myFireStationResourcesSupportNotesSubject2
                let message: InfoBodyText = .myFireStationResourcesSupportNotes2
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
            
                /// Reload Default Tags Alert
            func tagsPresentAlert() {
                let title: InfoBodyText = .tagsAreEmptySubject
                let message: InfoBodyText = .tagsAreEmpty
                let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                    
                    let nc = NotificationCenter.default
                    DispatchQueue.main.async {
                        nc.post(name:Notification.Name(rawValue: FJkReloadUserTagsCalled),
                                object: nil,
                                userInfo: nil )
                    }
                })
                
                alert.addAction(okAction)
                let noAction = UIAlertAction.init(title: "No", style: .default, handler: {_ in
                    self.alertUp = false
                })
                alert.addAction(noAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
    
        //    MARK: -RELOAD THE USER RANK ALERT
    func rankPresentAlert() {
        let title: InfoBodyText = .rankAreEmptySubject
        let message: InfoBodyText = .rankAreEmpty
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
            
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkReloadUserRankCalled),
                        object: nil,
                        userInfo: nil )
            }
        })
        
        alert.addAction(okAction)
        let noAction = UIAlertAction.init(title: "No", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(noAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
        //    MARK: -RELOAD THE USER PLATOON ALERT
    func platoonPresentAlert() {
        let title: InfoBodyText = .platoonAreEmptySubject
        let message: InfoBodyText = .platoonAreEmpty
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
            
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkReloadUserPlatoonCalled),
                        object: nil,
                        userInfo: nil )
            }
        })
        
        alert.addAction(okAction)
        let noAction = UIAlertAction.init(title: "No", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(noAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
        //    MARK: -RELOAD THE LOCAL INCIDENT TYPE ALERT
    func localIncidentTypePresentAlert() {
        let title: InfoBodyText = .localIncidentTypesAreEmptySubject
        let message: InfoBodyText = .localIncidentTypesAreEmpty
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
            
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkReloadLocalIncidentTypesCalled),
                        object: nil,
                        userInfo: nil )
            }
        })
        
        alert.addAction(okAction)
        let noAction = UIAlertAction.init(title: "No", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(noAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension SettingsTVC: NSFetchedResultsControllerDelegate {
    
    func theCount(entity: String)->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
}

extension SettingsTVC {
    
    func countIsZero() {
        if !alertUp {
            presentAlert()
        }
    }
    

    
        //    MARK: -RELOAD THE TAGS PAGE
        /// Reloads the Tags Settings page with populated tags
        /// - Parameter ns: no userInfo
    @objc func tagsAreLoadedNow( ns: Notification ) {
        if collapsed {
            if userObjectID != nil {
                delegate?.settingsLoadPage(settings: FJSettings.tags, userObjectID: userObjectID)
            }
        } else {
            nc.post(name:Notification.Name(rawValue:FJkSETTINGSTAGSCalled),
                    object: nil,
                    userInfo: ["sizeTrait":compact])
        }
    }
    
    
    
    
        //    MARK: -RELOAD THE RANK PAGE
        /// Reloads the RANK Settings page with populated tags
        /// - Parameter ns: no userInfo
    @objc func rankAreLoadedNow( ns: Notification ) {
        if collapsed {
            if userObjectID != nil {
                delegate?.settingsLoadPage(settings: FJSettings.rank, userObjectID: userObjectID)
            }
        } else {
            nc.post(name:Notification.Name(rawValue:FJkSETTINGRANKCalled),
                    object: nil,
                    userInfo: ["sizeTrait":compact])
        }
    }
    
    
        //    MARK: -RELOAD THE PLATOON PAGE
        /// Reloads the PLATOON Settings page with populated tags
        /// - Parameter ns: no userInfo
    @objc func platoonAreLoadedNow( ns: Notification ) {
        if collapsed {
            if userObjectID != nil {
                delegate?.settingsLoadPage(settings: FJSettings.platoon, userObjectID: userObjectID)
            }
        } else {
            nc.post(name:Notification.Name(rawValue:FJkSETTINGPLATOONCalled),
                    object: nil,
                    userInfo: ["sizeTrait":compact])
        }
    }
    
    
        //    MARK: -RELOAD THE LOCAL INCIDENT TYPES PAGE
        /// Reloads the LOCAL INCIDENT TYPES Settings page with populated tags
        /// - Parameter ns: no userInfo
    @objc func localIncidentTypeAreLoadedNow( ns: Notification ) {
        if collapsed {
            if userObjectID != nil {
                delegate?.settingsLoadPage(settings: FJSettings.localIncidentTypes, userObjectID: userObjectID)
            }
        } else {
            if userObjectID != nil {
                nc.post(name:Notification.Name(rawValue:FJkSETTINGLOCALINCIDENTTYPECalled),
                        object: nil,
                        userInfo: ["sizeTrait":compact, "userObjID": userObjectID!])
            }
        }
    }
    
}
