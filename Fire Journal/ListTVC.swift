//
//  ListTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 9/20/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit


protocol ListTVCDelegate: AnyObject {

    func theJournalWasTapped()
    func menuWasTapped()
    func journalObjectChosen(type:MenuItems,id:NSManagedObjectID,compact:SizeTrait)
    func incidentTappedForMap(objectID:NSManagedObjectID,compact:SizeTrait)
}

class ListTVC: UITableViewController,NSFetchedResultsControllerDelegate, ModalTVCDelegate,UISplitViewControllerDelegate,CellHeaderSearchDelegate,IncidentTVCDelegate,JournalTVCDelegate, SettingsProfileTVCDelegate, ICS214DetailViewControllerDelegate,NewICS214ModalTVCDelegate,PersonalJournalDelegate  {
    
    weak var delegate:ListTVCDelegate? = nil
    var myShift: MenuItems = .journal
    var myShiftTwo: MenuItems = .incidents
    var titleName: String = ""
    
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var journalStructure: JournalData!
    var incidentStructure: IncidentData!
    var splitVC:UISplitViewController!
    var compact:SizeTrait = .regular
    let nc = NotificationCenter.default
    var device:Device!
    var color = UIColor.black
    
    var objectID:NSManagedObjectID!
    var fetched:Array<Any>!
    var entity:String = ""
    var attribute:String = ""
    var ckrData:Data!
    var theEntity:String = ""
    let userDefaults = UserDefaults.standard
    var alertUp:Bool = false
    
    var fju:FireJournalUser!
    var fjuStreetName: String = ""
    var fjuStreetNumber: String = ""
    var fjuCity: String = ""
    var fjuState: String = ""
    var fjuZip: String = ""
    
    let dateFormatter = DateFormatter()
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        device = Device.init()
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
//        self.title = titleName
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        let navigationBarAppearance = UINavigationBar.appearance()
        if #available(iOS 13.0, *) {
            if Device.IS_IPHONE {
                navigationBarAppearance.barTintColor = UIColor.systemBackground
                navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
                navigationBarAppearance.tintColor = .link
            } else {
                navigationBarAppearance.barTintColor = UIColor.systemBackground
                navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
                navigationBarAppearance.tintColor = .link
            }
        } else {
            navigationBarAppearance.barTintColor = UIColor.black
            navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
        self.splitViewController?.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(loadMenuUp(_:)))
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        nc.addObserver(self, selector: #selector(dataSavedReloadList(ns:)), name:NSNotification.Name(rawValue: FJkRELOADTHELIST), object: nil)
        nc.addObserver(self, selector: #selector(dataSavedReloadListForMap(ns:)), name:NSNotification.Name(rawValue: FJkTHEMAPTYPECHANGED), object: nil)
        nc.addObserver(self, selector: #selector(loadNewestICS214(ns:)), name:NSNotification.Name(rawValue: FJkICS214_NEW_TO_LIST), object: nil)
        nc.addObserver(self, selector: #selector(loadNewestARCForm(ns:)), name:NSNotification.Name(rawValue: FJkARCFORM_NEW_TO_LIST), object: nil)
        nc.addObserver(self, selector:#selector(noConnectionCalled(ns:)),name:NSNotification.Name(rawValue: kHAVENO_CONNECTIONALERT), object: nil)
        nc.addObserver(self, selector: #selector(viewNewestARCForm(ns:)), name:NSNotification.Name(rawValue: FJkNEWARCFORMCAMPAIGNCREATED), object: nil)
        
        switch myShift {
        case .journal:
            entity = "Journal"
            attribute = "journalDateSearch"
        case .incidents, .maps:
            entity = "Incident"
            attribute = "incidentSearchDate"
        case .personal:
            entity = "Journal"
            attribute = "journalDateSearch"
        case .arcForm:
            entity = "ARCrossForm"
            attribute = "arcFormGuid"
        case .ics214:
            entity = "ICS214Form"
            attribute = "ics214Guid"
        default:
            print("nothing to see here")
        }
        getTheUser()
        _ = getTheDataForTheList()
        
        tableView.allowsMultipleSelection = false
        
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
        registerTheCells()
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
    }
    
    func registerTheCells() {
        tableView.register(UINib(nibName: "LinkeJournalCell", bundle: nil), forCellReuseIdentifier: "LinkeJournalCell")
        tableView.register(UINib(nibName: "ARC_ListCell", bundle: nil), forCellReuseIdentifier: "ARC_ListCell")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        switch myShift {
        case .ics214:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewICS214Entry(_:)))
        case .arcForm:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewARCFormEntry(_:)))
        case .incidents:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewIncidentEntry(_:)))
        case .journal:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewJournalModalEntry(_:)))
        case .personal:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPersonalNewEntryModal(_:)))
        default:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewJournalEntry(_:)))
        }
    }
    
    private func getTheUser() {
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
            fjuStreetNumber = fju.fireStationStreetNumber ?? ""
            fjuStreetName = fju.fireStationStreetName ?? ""
            fjuCity = fju.fireStationCity ?? ""
            fjuState = fju.fireStationState ?? ""
            fjuZip = fju.fireStationZipCode ?? ""
            
        } catch let error as NSError {
            print("ListTVC line 681 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    //    MARK: -PersonalJournalDelegate
    func thePersonalJournalEntrySaved(){
        
    }
    func thePersonalJournalCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //    MARK: -NewARCFormDelegate
    func theARCFormCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //    MARK: -NewICS214ModalTVCDelegate
    func theCancelCalledOnNewICS214Modal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //    MARK: -ICS214DetailViewControllerDelegate
    func completeChanged() {
        //        TODO:
    }
    
    
    //    MARK: -ARCFormDetailTVCDelegate
    func arcFormCancelled() {
        //        TODO:
    }
    
    
    //    MARK: -SettingsProfileTVCDelegate
    
    func profileSettingsGetData(type:FJSettings,compact:SizeTrait){}
    func profileReturnToSettings(compact:SizeTrait) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact])
    }
    
    func profileSavedNowGoToSettings(compact:SizeTrait) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact])
    }
    func goBack() {
        //        <#code#>
    }
    
    func journalSaveTapped() {
        //        <#code#>
    }
    
    
    func journalBackToList(){
    }
    
    
    func incidentTapped() {
        //        <#code#>
    }
    
    func incidentSave(id: NSManagedObjectID, shift: MenuItems) {
        entity = "Incident"
        attribute = "incidentDateSearch"
        delegate?.journalObjectChosen(type:shift,id:id,compact: compact)
        _ = getTheDataForTheList()
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    //    MARK: -CellHeaderSearchDelegate
    func theSearchButtonTapped(type: MenuItems) {
        switch type {
        case .incidents:
            let title = "Incident Search"
            let vc:ModalTVC = vcLaunch.presentModal(menuType: .incidentSearch, title: title)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        case .journal:
            let title = "Journal Search"
            let vc:ModalTVC = vcLaunch.presentModal(menuType: .journal, title: title)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        case .maps:
            let title = "Incident Search"
            let vc:ModalTVC = vcLaunch.presentModal(menuType: .incidentSearch, title: title)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        case .personal:
            let title = "Personal Search"
            let vc:ModalTVC = vcLaunch.presentModal(menuType: .journal, title: title)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        default:
            print("not here")
        }
    }
    
    func theCancelModalDataTapped() {
        //        <#code#>
    }
    
    //    MARK: -ModalTVCDelegate
    
    
    func dismissTapped(shift: MenuItems) {
        print("here you go damnit")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func saveBTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func journalSaved(id:NSManagedObjectID,shift:MenuItems) {
        entity = "Journal"
        attribute = "journalDateSearch"
        delegate?.journalObjectChosen(type:shift,id:id,compact: compact)
        //        _ = getTheDataForTheList()
        //        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func formTypedTapped(shift: MenuItems) {
        //        <#code#>
    }
    
    @objc func noConnectionCalled(ns: Notification) {
        if vcLaunch.alertI == 0 {
            let alert = vcLaunch.networkUnavailable()
            self.present(alert,animated: true)
        }
    }
    
    @objc func loadNewestICS214(ns: Notification) {
        if (ns.userInfo as! [String: Any]?) != nil
        {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.delegate!.tableView!(tableView, didSelectRowAt: indexPath)
        }
    }
    
    @objc func loadNewestARCForm(ns: Notification) {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.delegate!.tableView!(tableView, didSelectRowAt: indexPath)
    }
    
    @objc func viewNewestARCForm(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]? {
            let id = userInfo["object"] as! NSManagedObjectID
            if (Device.IS_IPHONE){
                delegate?.journalObjectChosen(type: MenuItems.arcForm, id: id, compact: compact)
            } else {
                let storyboard = UIStoryboard(name: "Form", bundle: nil)
                let controller:ARC_FormTVC = storyboard.instantiateViewController(withIdentifier: "ARC_FormTVC") as! ARC_FormTVC
                let navigator = UINavigationController.init(rootViewController: controller)
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
                controller.delegate = self
                controller.objectID = id
                //                controller.titleName = "CRR Smoke Alarm Inspection Form"
                self.splitVC?.showDetailViewController(navigator, sender:self)
            }
        }
    }
    
    @objc func dataSavedReloadList(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            myShift = userInfo["shift"] as? MenuItems ?? .incidents
            tableView.reloadData()
        }
    }
    
    @objc func dataSavedReloadListForMap(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            myShiftTwo = userInfo["shift"] as? MenuItems ?? .incidents
            switch myShiftTwo {
            case .incidents, .fire, .ems, .rescue:
                entity = "Incident"
                attribute = "incidentSearchDate"
            case .ics214:
                entity = "ICS214Form"
                attribute = "ics214Guid"
            case .arcForm:
                entity = "ARCrossForm"
                attribute = "arcFormGuid"
            default: break
            }
            _ = getTheDataForTheList()
            tableView.reloadData()
        }
    }
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
            switch compact {
            case .compact:
                print("compact MASTER")
            case .regular:
                print("regular MASTER")
            }
        }
    }
    
    @IBAction func addNewARCFormEntry(_ sender:Any) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let vc: ARC_ViewController = vcLaunch.modalARCFormNewCalled()
        vc.title = "Campaign or Single"
        vc.delegate = self
        vc.transitioningDelegate = slideInTransitioningDelgate
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func addNewICS214Entry(_ sender:Any) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let vc:NewICS214ModalTVC = vcLaunch.modalICS214NewCalled()
        vc.title = "New ICS 214"
        //        let navigator = UINavigationController.init(rootViewController: vc)
        vc.delegate = self
        vc.transitioningDelegate = slideInTransitioningDelgate
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func addNewIncidentEntry(_ sender:Any) {
        let vc:NewerIncidentModalTVC = vcLaunch.presentNewIncidentModal()
        vc.delegate = self
        vc.context = context
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func addNewPersonalNewEntryModal(_ sender: Any) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let personalNewEntrylModalTVC = storyBoard.instantiateViewController(withIdentifier: "PersonalNewEntryModalTVC") as! PersonalNewEntryModalTVC
        personalNewEntrylModalTVC.transitioningDelegate = slideInTransitioningDelgate
        personalNewEntrylModalTVC.modalPresentationStyle = .custom
        personalNewEntrylModalTVC.context = context
        personalNewEntrylModalTVC.delegate = self
        self.present(personalNewEntrylModalTVC,animated: true)
    }
    
    @IBAction func addNewJournalModalEntry(_ sender:Any) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "JournalSB", bundle:nil)
        let newJournalModalTVC = storyBoard.instantiateInitialViewController() as? JournalModalTVC
        newJournalModalTVC?.transitioningDelegate = slideInTransitioningDelgate
        newJournalModalTVC?.modalPresentationStyle = .custom
        newJournalModalTVC?.context = context
        newJournalModalTVC?.delegate = self
        self.present(newJournalModalTVC!,animated: true)
    }
    
    @IBAction func addNewJournalEntry(_ sender:Any) {
        var title = ""
        switch myShift {
        case .journal:
            title = "New Journal Entry"
        case .incidents,.maps:
            title = "New Incident Entry"
        case .personal:
            title = "New Personal Entry"
        default:
            print("no shift")
        }
        let vc:ModalTVC = vcLaunch.presentModal(menuType: myShift, title: title)
        switch myShift {
        case .personal:
            let shift:MenuItems = .personal
            vc.myShift = shift
        case .journal:
            let shift:MenuItems = .journal
            vc.myShift = shift
        case .incidents, .maps:
            let shift:MenuItems = .incidents
            vc.myShift = shift
        default:
            print("no data")
        }
        vc.delegate = self
        vc.context = context
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    @IBAction func loadMenuUp(_ sender: Any) {
        if (Device.IS_IPHONE){
            delegate?.menuWasTapped()
        } else if(Device.IS_IPAD) {
            //            switch compact {
            ////            case .compact:
            //                delegate?.menuWasTapped()
            //            case .regular:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller:MasterViewController = storyboard.instantiateViewController(withIdentifier: "MasterViewController") as! MasterViewController
            let navigator = UINavigationController.init(rootViewController: controller)
            self.splitVC?.show(navigator, sender: self)
            let shift: MenuItems = .myShift
            controller.myShiftCellTapped(myShift: shift)
            //            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = _fetchedResultsController?.sections
        {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cell = configureCell(at: indexPath)
        return cell
    }
    
    func configureCell( at indexPath: IndexPath)->UITableViewCell {
        switch myShift {
        case .journal:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
            
            let journal = _fetchedResultsController?.object(at: indexPath) as! Journal
            let imageType:String = journal.journalEntryTypeImageName ?? "avalancheA"
            let image:UIImage = (UIImage(named:imageType) ?? nil) ?? UIImage(named:"avalancheA")!
            cell.journalTypeIV.image = image
            cell.journalHeader.textColor = UIColor.systemBlue
            cell.journalHeader.text = journal.journalHeader
            let theModDate:Date = journal.journalModDate ?? Date()
            let fullyFormattedDate = FullDateFormat.init(date:theModDate)
            let journalDate:String = fullyFormattedDate.formatFullyTheDate()
            cell.journalDateL.text = journalDate
            if journal.journalLocationSC != nil {
                let streetNum = journal.journalStreetNumber ?? ""
                let streetName = journal.journalStreetName ?? ""
                let city = journal.journalCity ?? ""
                let state = journal.journalState ?? ""
                let zip = journal.journalZip ?? ""
                cell.journalLocationL.text = "\(streetNum) \(streetName) \(city), \(state) \(zip)"
            } else {
                if fjuStreetNumber != "" {
                    cell.journalLocationL.text = "\(fjuStreetNumber) \(fjuStreetName) \(fjuCity), \(fjuState)"
                } else {
                    cell.journalLocationL.text = "No location available"
                }
            }
            return cell
        case .incidents:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
            let incident = _fetchedResultsController?.object(at: indexPath) as! Incident
            var imageType:String = incident.incidentEntryTypeImageName ?? "avalancheA"
            if imageType == "flameRed58" {
                imageType = "100515IconSet_092016_fireboard"
            } else if imageType == "ems58" {
                imageType = "100515IconSet_092016_emsboard"
            } else if imageType == "rescue58" {
                imageType = "100515IconSet_092016_rescueboard"
            } else if imageType == "avalancheA" {
                imageType = "100515IconSet_092016_fireboard"
            }
            let image:UIImage = UIImage(named:imageType)!
            cell.journalTypeIV.image = image
            let number = incident.incidentNumber ?? ""
            cell.journalHeader.textColor = UIColor.systemRed
            cell.journalHeader.text = "Incident #\(number)"
            let theModDate:Date = incident.incidentModDate ?? Date()
            let fullyFormattedDate = FullDateFormat.init(date:theModDate)
            let incidentDate:String = fullyFormattedDate.formatFullyTheDate()
            cell.journalDateL.text = incidentDate
            if incident.incidentLocationSC != nil {
                let streetNum = incident.incidentStreetNumber ?? ""
                let streetName = incident.incidentStreetHyway ?? ""
                let zip = incident.incidentZipCode ?? ""
                cell.journalLocationL.text = "\(streetNum) \(streetName) \(zip)"
            } else {
                cell.journalLocationL.text = "No location available"
            }
            
            return cell
        case .maps:
            switch myShiftTwo {
            case .incidents, .fire, .ems, .rescue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
                let incident = _fetchedResultsController?.object(at: indexPath) as! Incident
                var imageType:String = incident.incidentEntryTypeImageName ?? "avalancheA"
                if imageType == "flameRed58" {
                    imageType = "100515IconSet_092016_fireboard"
                } else if imageType == "ems58" {
                    imageType = "100515IconSet_092016_emsboard"
                } else if imageType == "rescue58" {
                    imageType = "100515IconSet_092016_rescueboard"
                } else if imageType == "avalancheA" {
                    imageType = "100515IconSet_092016_fireboard"
                }
                let image:UIImage = UIImage(named:imageType)!
                cell.journalTypeIV.image = image
                cell.journalHeader.textColor = UIColor.systemRed
                let number = incident.incidentNumber ?? ""
                cell.journalHeader.text = "Incident #\(number)"
                let theModDate:Date = incident.incidentModDate ?? Date()
                let fullyFormattedDate = FullDateFormat.init(date:theModDate)
                let incidentDate:String = fullyFormattedDate.formatFullyTheDate()
                cell.journalDateL.text = incidentDate
                if incident.incidentLocationSC != nil {
                    let streetNum = incident.incidentStreetNumber ?? ""
                    let streetName = incident.incidentStreetHyway ?? ""
                    let zip = incident.incidentZipCode ?? ""
                    cell.journalLocationL.text = "\(streetNum) \(streetName) \(zip)"
                } else {
                    cell.journalLocationL.text = "No location available"
                }
                return cell
            case .ics214:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
                let ics214 = _fetchedResultsController?.object(at: indexPath) as! ICS214Form
                let imageType:String = "100515IconSet_092016_ICS 214 Form"
                let image:UIImage = (UIImage(named:imageType) ?? nil) ?? UIImage(named:"avalancheA")!
                cell.journalTypeIV.image = image
                cell.journalHeader.textColor = UIColor.systemBlue
                if let name = ics214.ics214IncidentName {
                    if ics214.ics214Count > 0 {
                        //                        let count = Int(exactly:ics214.ics214Count)!
                        cell.journalHeader.text = "\(name)"
                    } else {
                        cell.journalHeader.text = "\(name)"
                    }
                }
                if let campaign = ics214.ics214Effort {
                    cell.journalDateL.text = "Effort: \(campaign)"
                }
                let toDate:String!
                let fromDate:String!
                let theModDate:Date = ics214.ics214FromTime ?? Date()
                let fullyFormattedDate = FullDateFormat.init(date:theModDate)
                fromDate = fullyFormattedDate.formatFullyTheDate()
                if let endDate = ics214.ics214CompletionDate {
                    let theModDate:Date = endDate
                    let fullyFormattedDate = FullDateFormat.init(date:theModDate)
                    toDate = fullyFormattedDate.formatFullyTheDate()
                } else {
                    toDate = "Incomplete"
                }
                cell.journalLocationL.text = "\(fromDate ?? "") : \(toDate ?? "")"
                return cell
            case .arcForm:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
                //
                //                let form = _fetchedResultsController?.object(at: indexPath) as! ARCrossForm
                //                cell.theObject = form.objectID
                //                let count = form.campaignCount
                //                var theCount = 0
                //                if count > 1 {
                //                    theCount = Int(count)
                //                }
                //                var name = ""
                //                if theCount > 1 {
                //                    name = form.campaignName ?? ""
                //                    cell.theCampaignName = "\(name) \(theCount)"
                //                } else {
                //                    cell.theCampaignName = form.campaignName
                //                }
                //                cell.theAddress = form.arcLocationAddress
                //                let theDate = form.arcCreationDate ?? Date()
                //                dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                //                let creationDate = dateFormatter.string(from: theDate)
                //                cell.theStartDate = creationDate
                //                let complete = form.cComplete
                //                if complete {
                //                    cell.theStatus = "Campaign Closed"
                //                } else {
                //                    cell.theStatus = "Campaign Open"
                //                }
                
                let arcForm = _fetchedResultsController?.object(at: indexPath) as! ARCrossForm
                let imageType:String = "100515IconSet_092016_redCross"
                let image:UIImage = (UIImage(named:imageType) ?? nil) ?? UIImage(named:"avalancheA")!
                cell.journalTypeIV.image = image
                cell.journalHeader.textColor = UIColor.systemBlue
                //                if let campaign = arcForm.campaignName {
                //                    cell.journalHeader.text = "\(campaign)"
                //                } else {
                //                    cell.journalHeader.text = "No Campaign"
                //                }
                let count = arcForm.campaignCount
                var theCount = 0
                if count > 1 {
                    theCount = Int(count)
                }
                var name = ""
                if theCount > 1 {
                    name = arcForm.campaignName ?? ""
                    cell.journalHeader.text = "\(name) \(theCount)"
                } else {
                    cell.journalHeader.text = arcForm.campaignName
                }
                var address:String = ""
                var city:String = ""
                var zip:String = ""
                var mobil:String = ""
                if let street = arcForm.arcLocationAddress {
                    address = street
                } else {
                    address = ""
                }
                if let c = arcForm.arcLocationCity {
                    city = c
                } else {
                    city = ""
                }
                if let z = arcForm.arcLocationZip {
                    zip = z
                } else {
                    zip = ""
                }
                if let m = arcForm.arcLocationAptMobile {
                    mobil = m
                } else {
                    mobil = ""
                }
                cell.journalDateL.text = "Address: \(address)\nCity: \(city) \(zip)\nApt/Mobile #: \(mobil)"
                if arcForm.cComplete {
                    cell.journalLocationL.text = "Campaign Incomplete"
                } else {
                    cell.journalLocationL.text = "Campaign Complete"
                }
                //                //                print("here campaignComplete \(arcForm.cComplete)")
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                cell.contentView.backgroundColor = UIColor.gray
                cell.textLabel?.text = "Click ME here"
                return cell
            }
        case .personal:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
            
            let journal = _fetchedResultsController?.object(at: indexPath) as! Journal
            let imageType:String = "ICONS_BBLUELOCK"
            let image:UIImage = (UIImage(named:imageType) ?? nil) ?? UIImage(named:"avalancheA")!
            cell.journalTypeIV.image = image
            cell.journalHeader.textColor = UIColor.systemBlue
            cell.journalHeader.text = journal.journalHeader
            let theModDate:Date = journal.journalModDate ?? Date()
            let fullyFormattedDate = FullDateFormat.init(date:theModDate)
            let journalDate:String = fullyFormattedDate.formatFullyTheDate()
            cell.journalDateL.text = journalDate
            cell.journalLocationL.text = ""
            return cell
        case .ics214:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
            let ics214 = _fetchedResultsController?.object(at: indexPath) as! ICS214Form
            let imageType:String = "100515IconSet_092016_ICS 214 Form"
            let image:UIImage = (UIImage(named:imageType) ?? nil) ?? UIImage(named:"avalancheA")!
            cell.journalTypeIV.image = image
            cell.journalHeader.textColor = UIColor.systemBlue
            if let name = ics214.ics214IncidentName {
                if ics214.ics214Count > 0 {
                    //                    let count = Int(exactly:ics214.ics214Count)!
                    cell.journalHeader.text = "\(name)"
                } else {
                    cell.journalHeader.text = "\(name)"
                }
            }
            if let campaign = ics214.ics214Effort {
                cell.journalDateL.text = "Effort: \(campaign)"
            }
            var toDate:String!
            let fromDate:String!
            let theModDate:Date = ics214.ics214FromTime ?? Date()
            let fullyFormattedDate = FullDateFormat.init(date:theModDate)
            fromDate = fullyFormattedDate.formatFullyTheDate()
            toDate = "Incomplete"
            if !ics214.ics214Completed {
                if let endDate = ics214.ics214CompletionDate {
                    let theModDate:Date = endDate
                    let fullyFormattedDate = FullDateFormat.init(date:theModDate)
                    toDate = fullyFormattedDate.formatFullyTheDate()
                }
            }
            cell.journalLocationL.text = "\(fromDate ?? "") : \(toDate ?? "")"
            return cell
        case .arcForm:
            //            let cell = tableView.dequeueReusableCell(withIdentifier: "ARC_ListCell", for: indexPath) as! ARC_ListCell
            //
            //            let form = _fetchedResultsController?.object(at: indexPath) as! ARCrossForm
            //            cell.theObject = form.objectID
            //            let count = form.campaignCount
            //            var theCount = 0
            //            if count > 1 {
            //                theCount = Int(count)
            //            }
            //            var name = ""
            //            if theCount > 1 {
            //                name = form.campaignName ?? ""
            //                cell.theCampaignName = "\(name) \(theCount)"
            //            } else {
            //                cell.theCampaignName = form.campaignName
            //            }
            //            cell.theAddress = form.arcLocationAddress
            //            let theDate = form.arcCreationDate ?? Date()
            //            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
            //            let creationDate = dateFormatter.string(from: theDate)
            //            cell.theStartDate = creationDate
            //            let complete = form.cComplete
            //            if complete {
            //                cell.theStatus = "Campaign Closed"
            //            } else {
            //                cell.theStatus = "Campaign Open"
            //            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "LinkeJournalCell", for: indexPath) as! LinkeJournalCell
            
            let arcForm = _fetchedResultsController?.object(at: indexPath) as! ARCrossForm
            let imageType:String = "100515IconSet_092016_redCross"
            let image:UIImage = (UIImage(named:imageType) ?? nil) ?? UIImage(named:"avalancheA")!
            cell.journalTypeIV.image = image
            cell.journalHeader.textColor = UIColor.systemBlue
            //                if let campaign = arcForm.campaignName {
            //                    cell.journalHeader.text = "\(campaign)"
            //                } else {
            //                    cell.journalHeader.text = "No Campaign"
            //                }
            let count = arcForm.campaignCount
            var theCount = 0
            if count > 1 {
                theCount = Int(count)
            }
            var name = ""
            if theCount > 1 {
                name = arcForm.campaignName ?? ""
                cell.journalHeader.text = "\(name) \(theCount)"
            } else {
                cell.journalHeader.text = arcForm.campaignName
            }
            var address:String = ""
            var city:String = ""
            var zip:String = ""
            var mobil:String = ""
            if let street = arcForm.arcLocationAddress {
                address = street
            } else {
                address = ""
            }
            if let c = arcForm.arcLocationCity {
                city = c
            } else {
                city = ""
            }
            if let z = arcForm.arcLocationZip {
                zip = z
            } else {
                zip = ""
            }
            if let m = arcForm.arcLocationAptMobile {
                mobil = m
            } else {
                mobil = ""
            }
            cell.journalDateL.text = "Address: \(address)\nCity: \(city) \(zip)\nApt/Mobile #: \(mobil)"
            if arcForm.cComplete {
                cell.journalLocationL.text = "Campaign Incomplete"
            } else {
                cell.journalLocationL.text = "Campaign Complete"
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            cell.contentView.backgroundColor = UIColor.gray
            cell.textLabel?.text = "Click ME here"
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellHeader = Bundle.main.loadNibNamed("CellHeaderSearch", owner: self, options: nil)?.first as! CellHeaderSearch
        //        cellHeader.titleHeader.text = titleName
        cellHeader.myShift = myShift
        cellHeader.delegate = self
        cellHeader.contentView.backgroundColor = color
        return cellHeader
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? LinkeJournalCell {
            cell.selectedV.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var id = NSManagedObjectID()
        let cell = tableView.cellForRow(at: indexPath) as! LinkeJournalCell
        cell.selectedV.isHidden = false
        switch myShift {
        case .journal:
            let journal = _fetchedResultsController?.object(at: indexPath) as! Journal
            id = journal.objectID
            if (Device.IS_IPHONE){
                delegate?.journalObjectChosen(type:myShift,id:id,compact: compact)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller:JournalTVC = storyboard.instantiateViewController(withIdentifier: "JournalTVC") as! JournalTVC
                let navigator = UINavigationController.init(rootViewController: controller)
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
                //        controller.context = context
                controller.id = id
                controller.sizeTrait = compact
                controller.myShift = .journal
                controller.delegate = self
                controller.titleName = "Journal"
                self.splitVC?.showDetailViewController(navigator, sender:self)
            }
        case .incidents:
            let incident = _fetchedResultsController?.object(at: indexPath) as! Incident
            id = incident.objectID
            if (Device.IS_IPHONE){
                delegate?.journalObjectChosen(type: myShift, id: id,compact: compact)
            } else {
                let storyboard = UIStoryboard(name: "IncidentVC", bundle: nil)
                let controller:IncidentVC = storyboard.instantiateViewController(withIdentifier: "IncidentVC") as! IncidentVC
                let navigator = UINavigationController.init(rootViewController: controller)
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
                controller.id = id
                self.splitVC?.showDetailViewController(navigator, sender:self)
            }
        case .personal:
            let journal = _fetchedResultsController?.object(at: indexPath) as! Journal
            id = journal.objectID
            if (Device.IS_IPHONE){
                delegate?.journalObjectChosen(type:myShift,id:id,compact: compact)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller:PersonalJournalTVC = storyboard.instantiateViewController(withIdentifier: "PersonalJournalTVC") as! PersonalJournalTVC
                let navigator = UINavigationController.init(rootViewController: controller)
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
                //        controller.context = context
                controller.id = id
                controller.sizeTrait = compact
                controller.myShift = .personal
                controller.delegate = self
                controller.titleName = "Personal Journal"
                self.splitVC?.showDetailViewController(navigator, sender:self)
            }
        case .maps:
            switch myShiftTwo {
            case .incidents, .ems, .fire, .rescue:
                let incident = _fetchedResultsController?.object(at: indexPath) as! Incident
                id = incident.objectID
                self.nc.post(name: NSNotification.Name(rawValue: FJkINCIDENTCHOSENFORMAP), object: nil, userInfo:["objectID":id])
            case .ics214:
                let ics214 = _fetchedResultsController?.object(at: indexPath) as! ICS214Form
                id = ics214.objectID
                self.nc.post(name: NSNotification.Name(rawValue: FJkICS214CHOSENFORMAP), object: nil, userInfo:["objectID":id])
            case .arcForm:
                let arcForm = _fetchedResultsController?.object(at: indexPath) as! ARCrossForm
                id = arcForm.objectID
                self.nc.post(name: NSNotification.Name(rawValue: FJkARCFORMCHOSENFORMAP), object: nil, userInfo:["objectID":id])
            default: break
            }
        case .ics214:
            let ics214 = _fetchedResultsController?.object(at: indexPath) as! ICS214Form
            id = ics214.objectID
            if (Device.IS_IPHONE){
                delegate?.journalObjectChosen(type: myShift, id: id,compact: compact)
            } else {
                let storyboard = UIStoryboard(name: "NewICS214", bundle: nil)
                let controller  = storyboard.instantiateViewController(identifier: "NewICS214DetailTVC") as! NewICS214DetailTVC
                let navigator = UINavigationController.init(rootViewController: controller)
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
                //        controller.managedObjectContext = context
                controller.delegate = self
                controller.objectID = id
                self.splitVC?.showDetailViewController(navigator, sender:self)
            }
        case .arcForm:
            let arcForm = _fetchedResultsController?.object(at: indexPath) as! ARCrossForm
            id = arcForm.objectID
            if (Device.IS_IPHONE){
                delegate?.journalObjectChosen(type: myShift, id: id,compact: compact)
            } else {
                let storyboard = UIStoryboard(name: "Form", bundle: nil)
                let controller:ARC_FormTVC = storyboard.instantiateViewController(withIdentifier: "ARC_FormTVC") as! ARC_FormTVC
                let navigator = UINavigationController.init(rootViewController: controller)
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
                controller.delegate = self
                controller.objectID = id
                //                controller.titleName = "CRR Smoke Alarm Inspection Form"
                self.splitVC?.showDetailViewController(navigator, sender:self)
            }
        default:
            print("nothing  called")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 77
            //            switch myShift {
            //            case .journal,.incidents,.ics214,.maps,.personal:
            //                return 77
            //            case .arcForm:
            //                return 150
            //            default:
            //                return 44
            //            }
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
            //            switch myShift {
            //            case .journal,.incidents,.ics214,.maps,.personal:
            //                return 77
            //            case .arcForm:
            //                return 150
            //            default:
            //                return 44
            //            }
        } else {
            return 77
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    /// unarchive the data that is the ckRecord archive saved with the object when sent to cloud
    ///
    /// - Parameter data: ckr data
    /// - Returns: returns from the ckrData the CKRecord.recordID.recordName
    func unarchiveTheRecord(data:Data) -> String {
        var ckRecord: CKRecord!
        var ckRecordName: String = ""
        do {
            let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: data)
            ckRecord = CKRecord(coder: unarchiver)
            if ckRecord.recordID.recordName != "" {
                ckRecordName = ckRecord.recordID.recordName
            } else {
                ckRecordName = ""
            }
        } catch {
            print("Couldn't read file.")
        }
        return ckRecordName
    }
    
    
    /// alert used to inform user that the object they want to delete can't be deleted
    ///
    /// - Parameter type: entity name
    func sorryCantDelete(type: String) {
        if !alertUp {
            let title: InfoBodyText = .deletionIncompleteSubject
            let message1: InfoBodyText = .deletionIncomplete
            let message2: InfoBodyText = .deletionIncomplete2
            let message = "\(message1.rawValue) \(type) \(message2.rawValue)"
            let alert = UIAlertController.init(title: title.rawValue, message: message , preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// deleting of entries have to check if the ckRecord.recordID.recordName includes a '.' period
    /// if not an alert is shown and the deletion process is halted
    /// - Parameters:
    ///   - tableView: self.tableview
    ///   - editingStyle: .delte
    ///   - indexPath: indexPath.row to delete
    ///  calls unarchiveTheRecord after pulling the ckr data from the entities object
    ///  calls sorryCantDelete func above
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if editingStyle == .delete
            {
                switch myShift {
                case .journal:
                    let journal = _fetchedResultsController?.object(at: indexPath) as! Journal
                    if let data = journal.fjJournalCKR {
                        ckrData = data as? Data
                        let recordName = unarchiveTheRecord(data: ckrData)
                        if !recordName.hasPeriod {
                            sorryCantDelete(type: "Journal")
                        } else {
                            context.delete(journal)
                            saveToCD()
                        }
                    }
                case .incidents:
                    let incident = _fetchedResultsController?.object(at: indexPath) as! Incident
                    if let data = incident.fjIncidentCKR {
                        ckrData = data as? Data
                        let recordName = unarchiveTheRecord(data: ckrData)
                        if !recordName.hasPeriod {
                            sorryCantDelete(type: "Incident")
                        } else {
                            context.delete(incident)
                            saveToCD()
                        }
                    }
                case .personal:
                    let journal = _fetchedResultsController?.object(at: indexPath) as! Journal
                    if let data = journal.fjJournalCKR {
                        ckrData = data as? Data
                        let recordName = unarchiveTheRecord(data: ckrData)
                        if !recordName.hasPeriod {
                            sorryCantDelete(type: "Personal Journal")
                        } else {
                            context.delete(journal)
                            saveToCD()
                        }
                    }
                case .maps:
                    let incident = _fetchedResultsController?.object(at: indexPath) as! Incident
                    if let data = incident.fjIncidentCKR {
                        ckrData = data as? Data
                        let recordName = unarchiveTheRecord(data: ckrData)
                        if !recordName.hasPeriod {
                            sorryCantDelete(type: "Incident")
                        } else {
                            context.delete(incident)
                            saveToCD()
                        }
                    }
                case .ics214:
                    let ics214 = _fetchedResultsController?.object(at: indexPath) as! ICS214Form
                    if let data = ics214.ics214CKR {
                        ckrData = data as? Data
                        let recordName = unarchiveTheRecord(data: ckrData)
                        if !recordName.hasPeriod {
                            sorryCantDelete(type: "ICS 214 Form")
                        } else {
                            context.delete(ics214)
                            saveToCD()
                        }
                    }
                case .arcForm:
                    let arcForm = _fetchedResultsController?.object(at: indexPath) as! ARCrossForm
                    if let data = arcForm.arcFormCKR {
                        ckrData = data as? Data
                        let recordName = unarchiveTheRecord(data: ckrData)
                        if !recordName.hasPeriod {
                            sorryCantDelete(type: "CRR Smoke Alarm Inspection Form")
                        } else {
                            context.delete(arcForm)
                            saveToCD()
                        }
                    }
                default: break
                }
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            
            //            MARK: - Load the first row into the detail page
            //            let indexPath = IndexPath(row: 0, section: 0)
            //            tableView.delegate!.tableView!(tableView, didSelectRowAt: indexPath)
            
            //            MARK: -Use the CloudKitReference saved as Data to send to
            //            : cloudkit the correct record to delete
            //            : sent to cloudKitmanager that loads deleteFromListOperation
            if let data = ckrData {
                DispatchQueue.main.async {
                    
                    self.nc.post(name:NSNotification.Name(rawValue:FJkDELETEFROMLIST),
                                 object: nil,
                                 userInfo: ["ckrObject":data])
                }
            }
            //            MARK: Make sure that coredata merges the changes
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"List merge that"])
            }
            
            
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "List SAVETOCD Unresolved error \(nserror) \(nserror.localizedDescription) \(String(describing: nserror._userInfo))"
            print(errorMessage)
            
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    //    MARK: -FetchResultsController and delegate
    //    : used for filling the list
    //    : and for deleting the rows when edited after the delete actions are called
    //    : in the tableview delegate - editingStyle
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil
    
    private func getTheDataForTheList() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let fresh = userDefaults.bool(forKey: FJkCHANGESINFROMCLOUD)
        if fresh {
            NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: nil)
            userDefaults.set(false, forKey: FJkCHANGESINFROMCLOUD)
            userDefaults.synchronize()
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        switch myShift {
        case .journal:
            let predicate = NSPredicate(format: "%K != %@", attribute, "")
            let predicate2 = NSPredicate(format: "%K == %@","journalPrivate", NSNumber(value:true))
            let predicate5 = NSPredicate(format: "%K == %@ || %K == %@ || %K == %@ || %K == %@","journalEntryType","Station","journalEntryType","Community","journalEntryType","Members","journalEntryType","Training")
            let predicate3 = NSPredicate(format: "%K != %@", "journalEntryTypeImageName","NOTJournal")
            let predicate4 = NSPredicate(format: "%K != %@","journalEntryTypeImageName","ICONS_BBLUELOCK")
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2,predicate3,predicate4,predicate5])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "journalModDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            print("nothing")
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Journal")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
        case .incidents:
            let predicate = NSPredicate(format: "%K != nil", attribute)
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Incident")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
        case .maps:
            switch myShiftTwo {
            case .incidents:
                let predicate = NSPredicate(format: "%K != %@", attribute, "")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Incident-All-Map")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            case .fire:
                let predicate = NSPredicate(format: "%K != %@", attribute, "")
                let predicateOne = NSPredicate(format: "%K = %@", "situationIncidentImage", "Fire")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicateOne])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Incident-Fire-Map")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            case .ems:
                let predicate = NSPredicate(format: "%K != %@", attribute, "")
                let predicateOne = NSPredicate(format: "%K = %@", "situationIncidentImage", "EMS")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicateOne])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Incident-EMS-Map")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            case .rescue:
                let predicate = NSPredicate(format: "%K != %@", attribute, "")
                let predicateOne = NSPredicate(format: "%K = %@", "situationIncidentImage", "Rescue")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicateOne])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Incident-RESCUE-Map")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            case .ics214:
                let predicate = NSPredicate(format: "%K != %@", "ics214Guid", "")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-ICS214-MAP")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            case .arcForm:
                let predicate = NSPredicate(format: "%K != %@", "arcFormGuid", "")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-ARCForm-MAP")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            default:
                let predicate = NSPredicate(format: "%K != %@", attribute, "")
                let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                fetchRequest.predicate = predicateCan
                let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Incident-All-Default-Map")
                aFetchedResultsController.delegate = self
                _fetchedResultsController = aFetchedResultsController
            }
        case .personal:
            let predicate1 = NSPredicate(format: "journalPrivate == %@", NSNumber(value: false))
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate1])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            fetchRequest.fetchBatchSize = 50
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-Personal")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
        case .ics214:
            let predicate = NSPredicate(format: "%K != %@", attribute, "")
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-ICS214")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
        case .arcForm:
            let predicate = NSPredicate(format: "%K != %@", attribute, "")
            let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
            fetchRequest.predicate = predicateCan
            let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master-ARCForm")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
        default:
            print("noting")
        }
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error as NSError {
            let nserror = error
            let errorMessage = "ListTVC getTheDataForTheList() Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        return _fetchedResultsController!
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.tableView.insertSections(sectionIndexSet as IndexSet, with: UITableView.RowAnimation.fade)
        case .delete:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            self.tableView.deleteSections(sectionIndexSet as IndexSet, with: UITableView.RowAnimation.fade)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type
        {
        case NSFetchedResultsChangeType.insert:
            print("NSFetchedResultsChangeType.insert detected")
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
                //                saveToCD()
            }
        case NSFetchedResultsChangeType.delete:
            print("NSFetchedResultsChangeType.Delete detected")
            if let deleteIndexPath = indexPath
            {
                tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
            }
        case NSFetchedResultsChangeType.update:
            print("NSFetchedResultsChangeType.update detected")
            if let indexPath = indexPath, let _ = tableView.cellForRow(at: indexPath) {
                _ = configureCell(at: indexPath)
                //                saveToCD()
            }
        case NSFetchedResultsChangeType.move:
            print("NSFetchedResultsChangeType.Move detected")
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRows(at: [deleteIndexPath], with: UITableView.RowAnimation.fade)
            }
            
            // Note that for Move, we insert a row at the __newIndexPath__
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRows(at: [insertIndexPath], with: UITableView.RowAnimation.fade)
            }
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.endUpdates()
    }
    
    
    
}

extension ListTVC: ARC_ViewControllerDelegate {
    
    func noCampaignSendSingle(single: String) {
        self.dismiss(animated: true, completion: {
            let storyboard = UIStoryboard(name: "Form", bundle: nil)
            let controller:ARC_FormTVC = storyboard.instantiateViewController(withIdentifier: "ARC_FormTVC") as! ARC_FormTVC
            let navigator = UINavigationController.init(rootViewController: controller)
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
            controller.delegate = self
            controller.objectID = nil
            self.splitVC?.showDetailViewController(navigator, sender:self)
        })
    }
    
    func singleBTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ListTVC: PersonalNewEntryModalTVCDelegate {
    func dismissPJModalTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func personalJournalModalSaved(id: NSManagedObjectID, shift: MenuItems) {
        entity = "Journal"
        attribute = "journalDateSearch"
        delegate?.journalObjectChosen(type: shift, id: id, compact: compact)
        _ = getTheDataForTheList()
        tableView.reloadData()
        self.dismiss(animated:true)
        nc.post(name:Notification.Name(rawValue:FJkPERSONAL_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact,"objectID":id])
    }
    
    
}

extension ListTVC: JournalModalTVCDelegate {
    func dismissJModalTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func journalModalSaved(id: NSManagedObjectID, shift: MenuItems) {
        entity = "Journal"
        attribute = "journalDateSearch"
        delegate?.journalObjectChosen(type: shift, id: id, compact: compact)
        _ = getTheDataForTheList()
        tableView.reloadData()
        self.dismiss(animated:true)
        nc.post(name:Notification.Name(rawValue:FJkJOURNAL_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact,"objectID":id])
    }
}

extension ListTVC: NewerIncidentModalTVCDelegate {
    func theNewIncidentCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theNewIncidentModalSaved(ojectID: NSManagedObjectID, shift: MenuItems) {
        entity = "Incident"
        attribute = "incidentDateSearch"
        delegate?.journalObjectChosen(type:shift,id:ojectID,compact: compact)
        _ = getTheDataForTheList()
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
        nc.post(name:Notification.Name(rawValue:FJkINCIDENT_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact,"objectID":ojectID])
    }
    
    
}

extension ListTVC: NewICS214DetailTVCDelegate {
    func theCampaignHasChanged() {}
}

extension ListTVC: ARC_FormDelegate {
    func theFormHasCancelled() {
        //        <#code#>
    }
    
    func theFormHasBeenSaved() {
        //        <#code#>
    }
    
    func theFormWantsNewForm() {
        //        <#code#>
    }
    
    
}
