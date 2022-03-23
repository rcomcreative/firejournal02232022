//
//  NewARCFormModalTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/5/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

@objc protocol NewARCFormDelegate:class {
    @objc optional func newARCFormCreated(date:Date, objectID: NSManagedObjectID)
    @objc optional func theARCFormCancelled()
}

class NewARCFormModalTVC: UITableViewController, ARCSegmentCellDelegate, NewCampaignCellDelegate,CellHeaderDelegate  {
    
    //    MARK: -CellHeaderDelegate
    func theCancelModalDataTapped() {
        dismiss(animated: true, completion: nil)
        delegate?.theARCFormCancelled!()
    }
    
    
    let nc = NotificationCenter.default
    
    var locationManager:CLLocationManager!
    var fju:FireJournalUser!
    var city:String = ""
    var state:String = ""
    var streetNum:String = ""
    var streetName:String = ""
    var zip:String = ""
    var newARCForm:ARCrossForm!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    weak var delegate:NewARCFormDelegate? = nil
    var aForm: Form!
    var cells = [CellBody]()
    var masterOrNot:Bool = false
    var masterObjectID:NSManagedObjectID? = nil
    var campaignName:String = ""
    let formText:String = "This form is to be used when inspecting a living space for working smoke alarms. You may use a single form, or create a campaign (such as when inspecting an entire street). Data may be shared, or, using Fire Journal Cloud (subscription required), you may create a PDF file that matches that used by the American Red Cross."
    let headerText:String = "CRR Smoke Alarm Inspection Form"
    var fetchedMasters:Array = [ARCrossForm]()
    var masterGuid:String = ""
    
    
    
    fileprivate func theCells() {
        let c0 = CellBody.init(cellAttributes:[ "value1" : Sections.Header ], type:[ "type" : CellType.header ], fType: [ "fValue1" : headerText, "fValue2": aForm.campaignTitle ],dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        let c1 = CellBody.init(cellAttributes:[ "value1" : Sections.IANotes ], type: [ "type" : CellType.textArea ], fType: [ "fValue1" : "", "fValue2" : formText ], dType: [ "Date" :Date()],bType:[ "fValue3" : false ], objID: [ "id" : nil])
        let c3 = CellBody.init(cellAttributes:[ "value1" : Sections.Segment ], type: [ "type" : CellType.segment ], fType: [ "fValue1" : "Campaign" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        
        cells = [c0,c1,c3]
    }
    
    fileprivate func theCellsTwo() {
        let c4 = CellBody.init(cellAttributes:[ "value1" : Sections.Campaign ], type: [ "type" : CellType.textField ], fType: [ "fValue1" : "Campaign Name:" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        
        cells.remove(at: 2)
        cells.insert(c4, at: 2)
        print("stop")
    }
    
    fileprivate func theCellsThree() {
        cells.remove(at: 2)
        let c12 = CellBody.init(cellAttributes:[ "value1" : Sections.MasterCampaign ], type: [ "type" : CellType.textWAccessory ], fType: [ "fValue1" :  "Choose A Campaign" ], dType: [ "Date" :Date()],bType:[ "fValue" : false ], objID: [ "id" : nil])
        cells.append(c12)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm")
        var predicate = NSPredicate.init()
        var predicate2 = NSPredicate.init()
        predicate = NSPredicate(format: "arcMaster == %@",NSNumber(value: true))
        predicate2 = NSPredicate(format: "cComplete == %@",NSNumber(value: true))
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
        fetchRequest.predicate = predicateCan
        let sectionSortDescriptor = NSSortDescriptor(key: "cStartDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        var c11:CellBody!
        do {
            fetchedMasters = try context.fetch(fetchRequest) as! [ARCrossForm]
            if fetchedMasters.count != 0 {
                for arCrossForm:ARCrossForm in fetchedMasters {
                    var campaignName:String = ""
                    var masterGuid:String = ""
                    var objectID:NSManagedObjectID? = nil
                    if let test2:String = arCrossForm.campaignName {
                        campaignName = test2
                    }
                    if let test3:String = arCrossForm.arcFormCampaignGuid {
                        masterGuid = test3
                    }
                    objectID = arCrossForm.objectID
                    let date:Date = arCrossForm.cStartDate!
//                    if !(arCrossForm.cComplete) {
                    c11 = CellBody.init(cellAttributes:[ "value1" : Sections.MasterCampaign ], type: [ "type" : CellType.label ], fType: [ "fValue1" :  campaignName, "fValue2" : masterGuid ], dType: [ "Date" :date],bType:[ "fValue" : false ], objID: [ "id" : objectID])
                    cells.append(c11)
//                    }
//                    print("hello")
                }
            }
        }  catch {
            
            let nserror = error as NSError
            let errorMessage = "NewARCFormModalTVC theCellsThree() Unresolved error \(nserror), \(nserror.userInfo)"
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: FJkPERSISTENT_STORE_ERROR_REPORTING), object: nil, userInfo:["errorMessage":errorMessage])
//            }
            print(errorMessage)
        }
        
    }
    
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundViews()
        tableView.register(UINib(nibName: "FormHeaderCell", bundle: nil), forCellReuseIdentifier: "FormHeaderCell")
        tableView.register(UINib(nibName: "ARCSegmentCell", bundle: nil), forCellReuseIdentifier: "ARCSegmentCell")
        tableView.register(UINib(nibName: "SectionLabelCell", bundle: nil), forCellReuseIdentifier: "SectionLabelCell")
        tableView.register(UINib(nibName: "LocationCell", bundle: nil), forCellReuseIdentifier: "LocationCell")
        tableView.register(UINib(nibName: "NewCampaignCell", bundle: nil), forCellReuseIdentifier: "NewCampaignCell")
        tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "TextViewCell")
        tableView.register(UINib(nibName: "ChooseCampaignCell", bundle: nil), forCellReuseIdentifier: "ChooseCampaignCell")
        tableView.register(UINib(nibName: "ARCOpeningParagraphCell", bundle: nil), forCellReuseIdentifier: "ARCOpeningParagraphCell")
//        tableView.register(UINib(nibName: "ARCTextViewCell", bundle: nil), forCellReuseIdentifier: "ARCTextViewCell")
        self.title = "ARC Smoke Alarm Form"
        aForm = Form.init()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)

        
        newARCForm = ARCrossForm.init(entity: NSEntityDescription.entity(forEntityName: "ARCrossForm", in: context)!, insertInto: context)
        theCells()
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    //    MARK: -ERROR ALERT
    @objc func errorInDataBaseLaunch(ns:Notification) -> Void {
        var errorString: String = ""
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            errorString = userInfo["errorMessage"] as? String ?? "There is no error to report."
        }
        let title:String = "Database Error"
        let alert = UIAlertController.init(title: title, message: errorString, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Thanks for the info", style: .default, handler: {_ in
            
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func addNewARCForm(_ sender:Any) {
        let userRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser")
        do {
            let userFetched = try context.fetch(userRequest) as! [FireJournalUser]
            if userFetched.count != 0 {
                fju = userFetched.last!
            }
        } catch let error as NSError {
            print("fJU error line 188 \(error.localizedDescription)")
        }
        var masterLocation:CLLocation?
        var address:String = ""
        var city: String = ""
        var apartment: String = ""
        var state: String = ""
        var zip: String = ""
        var location:Bool = false
        if masterOrNot {
            newARCForm.cStartDate = Date()
            newARCForm.arcCreationDate = Date()
            newARCForm.arcModDate = Date()
            newARCForm.arcBackup = false;
            let guid:String = guidForARCForm()
            newARCForm.arcFormGuid = guid
            newARCForm.arcFormCampaignGuid = guid
            newARCForm.arcMaster = masterOrNot
            newARCForm.campaignName = campaignName
            newARCForm.campaign = true
            newARCForm.reviewFEPlan = false
            newARCForm.createFEPlan = false
            newARCForm.residentContactInfo = false
            newARCForm.localHazard = false
            newARCForm.arcLocationAvailable = false
            newARCForm.arcLocation = nil
            newARCForm.cComplete = true
            let journalEntry:Journal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
            let resourceDate = Date()
            var uuidA:String = NSUUID().uuidString.lowercased()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
            let dateFrom = dateFormatter.string(from: resourceDate)
            uuidA = uuidA+dateFrom
            let uuidA1 = "01."+uuidA
            journalEntry.fjpJGuidForReference = uuidA1
            newARCForm.journalGuid = uuidA1
            journalEntry.fjpJournalModifiedDate = resourceDate
            journalEntry.journalEntryTypeImageName = "administrativeNewColor58"
            journalEntry.journalEntryType = "Station"
            if fju != nil {
                let platoon = fju.tempPlatoon  ?? ""
                journalEntry.journalTempPlatoon = platoon
                let assignment = fju.tempAssignment ?? ""
                journalEntry.journalTempAssignment = assignment
                let apparatus = fju.tempApparatus ?? ""
                journalEntry.journalTempApparatus = apparatus
                let fireStation = fju.tempFireStation ?? fju.fireStation ?? ""
                journalEntry.journalTempFireStation = fireStation
            }
            
            let name = newARCForm.campaignName ?? ""
            journalEntry.journalHeader = "ARC Campaign: \(name)"
            let incidentDate = Date()
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "MM/dd/YYYY HH:mm"
            let timeStamp = dateFormatter2.string(from: incidentDate)
            let user = "\(fju.firstName ?? "") \(fju.lastName ?? "")"
            let summary = "Time Stamp: \(timeStamp) Smoke Alarm Inspection Form:\(name) Master entered by \(user)"
            journalEntry.journalSummary = summary as NSObject
            
            let overview = "Smoke Alarm Inspection Form entered"
            journalEntry.journalOverview = overview as NSObject
            journalEntry.journalEntryType = "Station"
            journalEntry.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
            
            journalEntry.journalDateSearch = dateFrom
            journalEntry.journalCreationDate = resourceDate
            journalEntry.journalModDate = resourceDate
            journalEntry.journalPrivate = true
            journalEntry.journalBackedUp = false
            journalEntry.fjpUserReference = fju.userGuid ?? ""
            journalEntry.fireJournalUserInfo = fju
        } else {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm")
            var predicate = NSPredicate.init()
            predicate = NSPredicate(format: "arcFormCampaignGuid = %@",masterGuid)
            fetchRequest.predicate = predicate
            let sectionSortDescriptor = NSSortDescriptor(key: "cStartDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            var count = 0
            do {
                let fetched = try context.fetch(fetchRequest) as! [ARCrossForm]
                count = fetched.count
                count = count+1
                if fetched.count != 0 {
                    for arc:ARCrossForm in fetched {
                        if arc.arcLocationAvailable {
                            location = true
                            masterLocation = (arc.arcLocation as! CLLocation)
                            address = arc.arcLocationAddress ?? ""
                            apartment = arc.arcLocationAptMobile ?? ""
                            city = arc.arcLocationCity ?? ""
                            state = arc.arcLocaitonState ?? ""
                            zip = arc.arcLocationZip ?? ""
                        }
                        if let j = arc.journalGuid {
                            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal")
                            fetchRequest.predicate = NSPredicate(format: "fjpJGuidForReference == %@", j)
                            do {
                                let fetchedRequest = try context.fetch(fetchRequest) as! [Journal]
                                for journal:Journal in fetchedRequest {
                                    let dateFormatter = DateFormatter()
                                    let incidentDate = Date()
                                    dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                                    let timeStamp = dateFormatter.string(from: incidentDate)
                                    var name = ""
                                    let user = "\(fju.firstName ?? "") \(fju.lastName ?? "")"
                                    if let campaign = arc.campaignName {
                                        name = campaign
                                    }
                                    let note:String = journal.journalSummary as! String
                                    let summary = "\(note)\n\nTime Stamp: \(timeStamp)\nARC Smoke Alarm Form: \(name)  \(count) entered by \(user)"
                                    journal.journalSummary = summary as NSObject
                                }
                            }  catch let error as NSError {
                                let nserror = error
                                let error = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
                                print("newARCFormModalTVC line 299 \(error)")
                                
                            }
                        }
                    }
                }
            }   catch let error as NSError {
                let nserror = error
                let errorMessage = "NewARCFormModalTVC addNewARCForm(_ sender:Any) Unresolved error \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
            newARCForm.cStartDate = Date()
            newARCForm.arcCreationDate = Date()
            newARCForm.arcModDate = Date()
            newARCForm.arcBackup = false;
            let guid:String = guidForARCForm()
            newARCForm.arcFormGuid = guid
            newARCForm.arcFormCampaignGuid = masterGuid
            newARCForm.arcMaster = masterOrNot
            newARCForm.campaignName = campaignName
            newARCForm.campaign = true
            newARCForm.campaignCount = Int64(count)
            newARCForm.cComplete = true
            
            newARCForm.reviewFEPlan = false
            newARCForm.createFEPlan = false
            newARCForm.residentContactInfo = false
            newARCForm.localHazard = false
            if location {
                newARCForm.arcLocationAvailable = true
                newARCForm.arcLocationAddress = address
                newARCForm.arcLocationAptMobile = apartment
                newARCForm.arcLocationCity = city
                newARCForm.arcLocaitonState = state
                newARCForm.arcLocationZip = zip
                newARCForm.arcLocation = masterLocation
            } else {
                newARCForm.arcLocationAvailable = false
                newARCForm.arcLocation = nil
            }
            
        }
        newARCForm.fireJournalUserDetail = fju
        fju.fireJournalUserARCFormDetail = newARCForm
        
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewArcFormModalTVC merge that"])
            }
        }  catch let error as NSError {
            let nserror = error
            let errorMessage = "NewARCFormModalTVC addNewARCForm(_ sender:Any) Unresolved error \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        print("here is the newARCForm \(String(describing: newARCForm))")
        //        delegate?.newARCFormCreated!(date: Date(), objectID: newARCForm.objectID)
        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:fjKNEW_ARCFORM_CREATED),
                object: nil,
                userInfo: ["objectID":newARCForm.objectID, "date":newARCForm.cStartDate ?? Date(),"arcFormGuid":newARCForm.arcFormGuid ?? guidForARCForm()])
        //        countForMaster(master: masterGuid)
        let objectID = newARCForm.objectID
        DispatchQueue.main.async {
            nc.post(name:Notification.Name(rawValue:FJkARCFORM_NEW_TO_LIST),
                    object: nil,
                    userInfo: ["objectID": objectID])
        }
        DispatchQueue.main.async {
            nc.post(name:Notification.Name(rawValue:FJkCKNewARCrossCreated),
                    object: nil,
                    userInfo: ["objectID": objectID])
        }
        
        dismiss(animated: true, completion: nil)
        delegate?.theARCFormCancelled!()
    }
    
    @objc func cancelNewARCForm(_ sender:Any) {
        dismiss(animated: true, completion: nil)
        delegate?.theARCFormCancelled!()
    }
    
    func guidForARCForm()->String {
        let resourceDate = Date()
        var uuidA:String = NSUUID().uuidString.lowercased()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: resourceDate)
        uuidA = uuidA+dateFrom
        let uuidA1 = "40."+uuidA
        return uuidA1
    }
    
//    ARCSegmentCellDelegate
    func arcTypeChosen(type: Int) {
        if type == 0 {
            masterOrNot = true
            theCellsTwo()
        } else {
            masterOrNot = false
            theCellsThree()
        }
        tableView.reloadData()
    }
    
//  NewCampaignCellDelegate
    func newCampaignCreated(campaign: String) {
        campaignName = campaign
        masterOrNot = true
        addNewARCForm(self)
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
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            cell.contentView.backgroundColor = UIColor(patternImage: UIImage(named:"header")!)
        }
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellHeader = Bundle.main.loadNibNamed("CellHeader", owner: self, options: nil)?.first as! CellHeader
        cellHeader.backgroundV.backgroundColor = UIColor.fjColor.emsBlue
        let headerTitle = ""
        cellHeader.titleHeader.text = headerTitle
        cellHeader.delegate = self
        return cellHeader
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type:CellBody = cells[indexPath.row]
        let cellType:CellType = type.type["type"]!
        switch cellType {
        case .header:
            return 100
        case .textField:
            return 88
        case .textWAccessory:
            return 60
        case .textArea:
//            return 160
            if Device.IS_IPHONE {
                return 450
            } else {
                return 390
            }
        case .label:
            return 60
        case .segment:
            return 135
        default:
            return 44
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type:CellBody = cells[indexPath.row]
        let cellType:CellType = type.type["type"]!
        let value1:String = type.fType["fValue1"]!
        var value2 = ""
        if let test2:String = type.fType["fValue2"] {
            value2 = test2
        }
        var objectID:NSManagedObjectID? = nil
        if type.objID["objectID"] != nil {
            objectID = type.objID["objectID"] as? NSManagedObjectID
        }
        switch cellType {
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormHeaderCell", for: indexPath) as! FormHeaderCell
            cell.formTitleL.text = value1
            return cell
        case .textArea:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ARCTextViewCell", for: indexPath) as! ARCTextViewCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARCOpeningParagraphCell", for: indexPath) as! ARCOpeningParagraphCell
//            cell.notesTV.text = value2
//            cell.notesTV.isEditable = false
//            cell.titleL.text = value1
            return cell
        case .segment:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARCSegmentCell", for: indexPath) as! ARCSegmentCell
            cell.delegate = self
            return cell
        case .textWAccessory:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionLabelCell", for: indexPath) as! SectionLabelCell
            cell.titleBackgroundV.backgroundColor = UIColor.fjColor.emsBlue
            cell.titleL.text = value1
            return cell
        case .label:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseCampaignCell", for: indexPath) as! ChooseCampaignCell
            cell.campaignNameL.text = value1
            cell.objectID = objectID
            cell.guid = value2
            return cell
        case .textField:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewCampaignCell", for: indexPath) as! NewCampaignCell
            cell.delegate = self
            cell.campaignTitleL.text = value1
            cell.campaignNameTF.text = value2
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch row {
        case 0, 1, 2 : break
        default:
           let cellChecked = tableView.cellForRow(at: indexPath) as! ChooseCampaignCell
            masterGuid = cellChecked.guid
            masterObjectID = cellChecked.objectID
            campaignName = cellChecked.campaignNameL.text ?? ""
            masterOrNot = false
            addNewARCForm(self)  
        }
    }
    
}
