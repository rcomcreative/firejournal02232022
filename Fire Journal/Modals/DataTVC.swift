//
//  DataTVC.swift
//  dashboard
//
//  Created by DuRand Jones on 9/14/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData


protocol DataTVCDelegate: AnyObject {

    func theDataTVCCancelled()
    func theDataSaveTapped(type:IncidentTypes)
    func theJournalDataSaveTapped(type:JournalTypes,user:UserEntryInfo)
}

enum UserInfo {
    case user
    case entryType
    case fireStation
    case platoon
    case apparatus
    case assignment
}

class DataTVC: UITableViewController,dismissSaveCellDelegate,LabelTextFieldCellDelegate,SegmentCellDelegate,LabelTextFieldWithDirectionCellDelegate,DataModalTVCDelegate,NSFetchedResultsControllerDelegate,JournalSegmentDelegate {
    
    
    func dataModalCancelCalled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theDataModalChosen(objectID:NSManagedObjectID, user: UserInfo) {
        switch user {
        case .platoon:
            let platoon = context.object(with:objectID) as? UserPlatoon
            theUser.platoon = platoon?.platoon ?? ""
            journalStructure.journalPlatoon = theUser.platoon
            theUser.platoonGuid = platoon?.platoonGuid ?? ""
            theUser.platoonDefault = platoon?.defaultPlatoon ?? true
        case .apparatus:
            let apparatus = context.object(with:objectID) as? UserApparatusType
            theUser.apparatus = apparatus?.apparatus ?? ""
            journalStructure.journalApparatus = theUser.apparatus
            theUser.apparatusGuid = apparatus?.apparatusGuid ?? ""
            theUser.apparatusDefault = apparatus?.defaultApparatus ?? true
        case .assignment:
            let assignment = context.object(with:objectID) as? UserAssignments
            theUser.assignment = assignment?.assignment ?? ""
            journalStructure.journalAssignment = theUser.assignment
            theUser.assignmentGuid = assignment?.assignmentGuid ?? ""
            theUser.assignmentDefault = assignment?.defaultAssignment ?? true
        default:
            print("none")
        }
        tableView.reloadData()
    }
    
    
    
    fileprivate func setUpDataStructur(myShift: MenuItems) {
        switch myShift {
        case .incidents:
            incidentStructure = IncidentData.init()
        case .journal,.personal:
            journalStructure = JournalData.init()
        case .nfirsBasic1Search:
            incidentStructure = IncidentData.init()
        case .startShift:
            startShiftStructure = StartShiftData.init()
        case .endShift:
            endShiftStructure = EndShiftData.init()
        default:
            print("none")
        }
    }
    
    fileprivate func presentModal(menuType: MenuItems, title: String, type: UserInfo) {
        setUpDataStructur(myShift: menuType)
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "DataModalTVC") as! DataModalTVC
        modalTVC.delegate = self
        modalTVC.transitioningDelegate = slideInTransitioningDelgate
        modalTVC.title = title
        modalTVC.myShift = menuType
        modalTVC.userInfo = type
        modalTVC.modalPresentationStyle = .custom
        self.present(modalTVC, animated: true, completion: nil)
    }
    //    MARK: -LabelTextFieldWithDirectionCellDELEGATE
    func directionalBJWasTapped(type: UserInfo) {
        switch type {
        case .platoon:
//            presentModal(menuType: myShift, title: "Platoon", type: type)
            loadPlatoonTVC()
        case .apparatus:
            presentModal(menuType: myShift, title: "Apparatus", type: type)
        case .assignment:
            presentModal(menuType: myShift, title: "Assignment", type: type)
        default:
            print("no type")
        }
    }
    func directionalBTapped(type: IncidentTypes) {
        //        <#code#>
    }
    func theTextFieldHasBeenEdited2(text: String) {
//        <#code#>
    }
    func theTextFieldHasBeenEdited(text: String, type: UserInfo) {
        switch type {
        case .fireStation:
            journalStructure.journalFireStation = text
        case .platoon:
            journalStructure.journalPlatoon = text
        case .apparatus:
            journalStructure.journalApparatus = text
        case .assignment:
            journalStructure.journalAssignment = text
        default:
            print("no userinfo type")
        }
        print(journalStructure!)
        tableView.reloadData()
    }
    //    MARK: -SegmentCellDelegate
    func sectionChosen(type: MenuItems) {
        switch type {
        case .fire:
            incidentStructure.incidentType = "Fire"
        case .ems:
            incidentStructure.incidentType = "EMS"
        case .rescue:
            incidentStructure.incidentType = "Rescue"
        default:
            print("no type")
        }
        segmentType = type
        tableView.reloadData()
    }
    //    MARK: -JournalSegmentDelegate
    func journalSectionChosen(type: MenuItems) {
        switch type {
        case .station:
            journalStructure.journalType = "Station"
            theUser.entryType = .station
        case .community:
            journalStructure.journalType = "Community"
            theUser.entryType = .community
        case .members:
            journalStructure.journalType = "Members"
            theUser.entryType = .members
        case .training:
            journalStructure.journalType = "Training"
            theUser.entryType = .training
        default:
            journalStructure.journalType = "Station"
            theUser.entryType = .station
        }
        segmentType = type
        tableView.reloadData()
    }
    //    MARK: -LabelTextFieldCellDELEGATE
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
        switch myShift {
        case .journal,.personal:
            switch journalType {
            case .userInfo:
                journalStructure.journalUser = text
                theUser.user = text
            case .fireStation:
                journalStructure.journalFireStation = text
                theUser.fireStation = text
            default:
                print(text)
            }
        default:
            print(text)
        }
    }
    
    
    func incidentLabelTFEditing(text:String, myShift: MenuItems, type: IncidentTypes){}
    func incidentLabelTFFinishedEditing(text:String,myShift:MenuItems, type: IncidentTypes){}
    
    func userInfoTextFieldEditing(text:String, myShift: MenuItems, journalType: JournalTypes){
        switch journalType {
        case .userInfo:
            journalStructure.journalUser = text
            theUser.user = text
        case .fireStation:
            journalStructure.journalFireStation = text
            theUser.fireStation = text
        default:
            print("no")
        }
    }
    func userInfoTextFieldFinishedEditing(text:String, myShift: MenuItems, journalType: JournalTypes ){
        switch journalType {
        case .userInfo:
            journalStructure.journalUser = text
            theUser.user = text
        case .fireStation:
            journalStructure.journalFireStation = text
            theUser.fireStation = text
        default:
            print("no")
        }
        tableView.reloadData()
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        switch myShift {
        case .journal,.personal:
            switch journalType {
            case .userInfo:
                journalStructure.journalUser = text
            default:
                print(text)
            }
        default:
            print(text)
        }
    }
    
    func dismissBTapped() {
        self.dismiss(animated: true, completion: nil)
        delegate?.theDataTVCCancelled()
    }
    
    func saveBTapped() {
        switch myShift {
        case .incidents:
            delegate?.theDataSaveTapped(type: incidentType)
        case .journal,.personal:
            delegate?.theJournalDataSaveTapped(type:journalType,user:theUser)
        default:
            print("we shouldn't be here")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //    MARK: -PROPERTIES
    weak var delegate:DataTVCDelegate? = nil    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    var myShift:MenuItems = .journal
    var myShiftTitle: String = ""
    var incidentType: IncidentTypes = .fire
    var journalType:JournalTypes = .station
    
    var segmentType: MenuItems = .journal
    
    var incidentStructure: IncidentData!
    var journalStructure: JournalData!
    var startShiftStructure: StartShiftData!
    var endShiftStructure: EndShiftData!
    var alarmStructure: AlarmData!
    var ics214Structure: ICS214Data!
    var theUser: UserEntryInfo!
    var entryType: MenuItems = .station
    var userName: String = ""
    var fireStation: String = ""
    var platoon: String = ""
    var platoonGuid: String = ""
    var apparatus: String = ""
    var apparatusGuid: String = ""
    var assignment: String = ""
    var assignmentGuid: String = ""
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let nc = NotificationCenter.default
    var fetched:Array<Any>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        theUser = UserEntryInfo.init(user:"")
        
        self.title = myShiftTitle
        tableView.register(UINib(nibName: "dismissSaveCell", bundle: nil), forCellReuseIdentifier: "dismissSaveCell")
        tableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        tableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        tableView.register(UINib(nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: "SegmentCell")
        tableView.register(UINib(nibName: "JournalSegmentCell", bundle: nil), forCellReuseIdentifier: "JournalSegmentCell")
        tableView.register(UINib(nibName: "LabelTextFieldWithDirectionCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldWithDirectionCell")
        roundViews()
        configureStructure()
    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    func configureStructure() {
        switch myShift {
        case .incidents:
            incidentStructure = IncidentData.init()
        case .incidentSearch:
            incidentStructure = IncidentData.init()
        case .journal,.personal:
            journalStructure = JournalData.init()
            theUser.user = userName
            theUser.entryType = entryType
            theUser.fireStation = fireStation
            theUser.platoon = platoon
            theUser.platoonGuid = platoonGuid
            theUser.apparatus = apparatus
            theUser.apparatusGuid = apparatusGuid
            theUser.assignment = assignment
            theUser.assignmentGuid = assignmentGuid
        case .nfirsBasic1Search:
            incidentStructure = IncidentData.init()
        case .startShift:
            startShiftStructure = StartShiftData.init()
        case .endShift:
            endShiftStructure = EndShiftData.init()
        case .alarmSearch:
            alarmStructure = AlarmData.init()
        case .ics214Search:
            ics214Structure = ICS214Data.init()
        default:
            print("none")
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
        // #warning Incomplete implementation, return the number of rows
        return 8
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return  44
        case 1:
            return 44
        case 2:
            switch myShift{
            case .incidents:
                return 44
            case .journal,.personal:
                switch journalType {
                case .userInfo:
                    return 85
                default:
                    return 44
                }
            default:
                return 44
            }
        case 3:
            switch myShift{
            case .incidents:
                return 44
            case .journal:
                switch journalType{
                case .userInfo:
                    return 85
                default:
                    return 44
                }
            case .personal:
                return 44
            default:
                return 44
            }
        case 4:
            switch myShift{
            case .incidents:
                return 44
            case .journal,.personal:
                switch journalType{
                case .userInfo:
                    return 85
                default:
                    return 44
                }
            default:
                return 44
            }
        case 5:
            switch myShift{
            case .incidents:
                return 44
            case .journal,.personal:
                switch journalType{
                case .userInfo:
                    return 81
                default:
                    return 44
                }
            default:
                return 44
            }
        case 6:
            switch myShift{
            case .incidents:
                return 44
            case .journal,.personal:
                switch journalType{
                case .userInfo:
                    return 81
                default:
                    return 44
                }
            default:
                return 44
            }
        case 7:
            switch myShift{
            case .incidents:
                return 44
            case .journal,.personal:
                switch journalType{
                case .userInfo:
                    return 81
                default:
                    return 44
                }
            default:
                return 44
            }
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "dismissSaveCell", for: indexPath) as! dismissSaveCell
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            switch myShift {
            case .incidents:
                cell.modalTitleL.textColor =  UIColor(red: 0.82, green: 0.01, blue: 0.11, alpha: 1.0)
            case .journal,.personal:
                cell.modalTitleL.textColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
            default:
                cell.modalTitleL.textColor = UIColor.black
            }
            cell.modalTitleL.text = myShiftTitle
            return cell
        case 2:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            case .journal,.personal:
                switch journalType{
                case .userInfo:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    cell.delegate = self
                    cell.subjectL.text = "User"
                    cell.theShift = myShift
                    cell.journalType = .userInfo
                    if theUser.user != "" {
                        cell.descriptionTF.text = theUser.user
                    } else {
                         if #available(iOS 13.0, *) {
                                                   cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
                                               } else {
                                                   cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
                                               }
                    }
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    return cell
                }
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            }
        case 3:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            case .journal:
                switch journalType {
                case .userInfo:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "JournalSegmentCell", for: indexPath) as! JournalSegmentCell
                    cell.delegate = self
                    cell.subjectL.text = "Entry Type"
                    cell.myShift = .journal
                    cell.typeSegment.setTitle("Station", forSegmentAt: 0)
                    cell.typeSegment.setTitle("Community", forSegmentAt: 1)
                    cell.typeSegment.setTitle("Members", forSegmentAt: 2)
                    cell.typeSegment.setTitle("Training", forSegmentAt: 3)
                    cell.typeSegment.tintColor = UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 1)
                    switch theUser.entryType {
                        case .station:
                            cell.typeSegment.selectedSegmentIndex = 0
                            theUser.entryType = .station
                            theUser.entryTypeS = "Station"
                        case .community:
                            cell.typeSegment.selectedSegmentIndex = 1
                            theUser.entryType = .community
                            theUser.entryTypeS = "Community"
                        case .members:
                            cell.typeSegment.selectedSegmentIndex = 2
                            theUser.entryType = .members
                            theUser.entryTypeS = "Members"
                        case .training:
                            cell.typeSegment.selectedSegmentIndex = 3
                            theUser.entryType = .training
                            theUser.entryTypeS = "Training"
                        default:
                            cell.typeSegment.selectedSegmentIndex = 0
                            theUser.entryType = .station
                            theUser.entryTypeS = "Station"
                        }
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    return cell
                }
            case .personal:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell.delegate = self
                cell.subjectL.text = "PRIVATE"
                cell.theShift = myShift
                cell.journalType = .userInfo
                cell.descriptionTF.isHidden = true
                cell.descriptionTF.alpha = 0.0
//                if theUser.user != "" {
//                    cell.descriptionTF.text = theUser.user
//                } else {
//                    cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Captain Mark Smith",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0)])
//                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            }
        case 4:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            case .journal,.personal:
                switch journalType {
                case .userInfo:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    cell.delegate = self
                    cell.subjectL.text = "Fire Station"
                    cell.theShift = myShift
                    cell.journalType = .fireStation
                    if theUser.fireStation != "" {
                        cell.descriptionTF.text = theUser.fireStation
                    } else {
                         if #available(iOS 13.0, *) {
                                                   cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
                                               } else {
                                                   cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
                                               }
                    }
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    return cell
                }
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            }
        case 5:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            case .journal,.personal:
                switch journalType {
                case .userInfo:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                    cell.delegate = self
                    cell.subjectL.text = "Platoon"
                    cell.userInfo = .platoon
                    cell.myShift = myShift
                    if theUser.platoon != "" {
                        cell.descriptionTF.text = theUser.platoon
                    } else {
                        if #available(iOS 13.0, *) {
                                                   cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
                                               } else {
                                                   cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
                                               }
                    }
                    let image = UIImage(named: "ICONS_Directional blue")
                    cell.moreB.setImage(image, for: .normal)
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    return cell
                }
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            }
        case 6:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            case .journal,.personal:
                switch journalType {
                case .userInfo:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                    cell.delegate = self
                    cell.subjectL.text = "Apparatus"
                    cell.userInfo = .apparatus
                    cell.myShift = myShift
                    
                    if theUser.apparatus != "" {
                        cell.descriptionTF.text = theUser.apparatus
                    } else {
                        if #available(iOS 13.0, *) {
                            cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
                        } else {
                            cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
                        }
                    }
                    let image = UIImage(named: "ICONS_Directional blue")
                    cell.moreB.setImage(image, for: .normal)
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    return cell
                }
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            }
        case 7:
            switch myShift {
            case .incidents:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            case .journal,.personal:
                switch journalType {
                case .userInfo:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldWithDirectionCell", for: indexPath) as! LabelTextFieldWithDirectionCell
                    cell.delegate = self
                    cell.subjectL.text = "Assignment"
                    cell.userInfo = .assignment
                    cell.myShift = myShift
                    if theUser.assignment != "" {
                        cell.descriptionTF.text = theUser.assignment
                    } else {
                         if #available(iOS 13.0, *) {
                                                   cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])
                                               } else {
                                                   cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Structure Fire",attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.37, green: 0.55, blue: 0.77, alpha: 0.45)])
                                               }
                    }
                    let image = UIImage(named: "ICONS_Directional blue")
                    cell.moreB.setImage(image, for: .normal)
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    return cell
                }
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }
    
    
}

extension DataTVC {
    
    private func loadPlatoonTVC(){
        let platoons = getThePlatoons()
        let storyboard = UIStoryboard(name: "Platoons", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! PlatoonsVC
        vc.platoons = platoons
        vc.delegate = self
        present(vc, animated: true )
    }
    
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
                    print("JournalModalTVC line 325 Fetch Error: \(error.localizedDescription)")
            }
        return platoons
    }
}

extension DataTVC: PlatoonsVCDelegate {
    func platoonsCancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func platoonsVCChosen(platoon: UserPlatoon) {
        journalStructure.journalPlatoon = platoon.platoon ?? ""
        journalStructure.journalPlatoonGuid = platoon.platoonGuid ?? ""
        theUser.platoon = platoon.platoon ?? ""
        theUser.platoonGuid = platoon.platoonGuid ?? ""
        let indexPath = IndexPath(row: 5, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        self.dismiss(animated: true, completion: nil)
    }
    
}
