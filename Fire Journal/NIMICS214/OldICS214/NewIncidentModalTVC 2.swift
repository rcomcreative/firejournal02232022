//
//  NewIncidentModalTVC.swift
//  ARCForm
//
//  Created by DuRand Jones on 11/1/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation


struct IncidentStructure {
    var incidentNumber: String?
    var incidentDate: Date?
    var incidentEmergency: String?
    var incidentType: String?
    var incidentImageName: String?
    var incidentLocalType: String?
    var incidentNFIRSType: String?
    var incidentLocation: CLLocation?
    var incidentLocationType: String?
    var incidentStreetType: String?
    var incidentStreetPrefix: String?
    var incidentStreetNum: String?
    var incidentStreetName: String?
    var incidentCity: String?
    var incidentState: String?
    var incidentZip: String?
}

protocol NewIncidentModalDelegate: AnyObject {
    func newIncidentCancelButtonTapped()
    func newIncidentCreated(objectId:NSManagedObjectID)
}

class NewIncidentModalTVC: UITableViewController, IncidentIndicatorCellDelegate, IncidentSingleEntryDelegate, IncidentTypeDelegate, IncidentEmergencyDelegate, IncidentLocationDelegate, FormDatePickerCellDelegate, IncidentDatesDelegate,NewIncidentDetailDelegate,CLLocationManagerDelegate,NewIncidentMapDelegate {
    
    func theMapCancelButtonTapped() {
        
    }
    
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
    
    
    
    var incidentStructure: IncidentStructure!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let nc = NotificationCenter.default
    
    var showPicker: Bool = false
    var pickerDate: Date?
    var sendingEntity: String = ""
    var sendingAttribute: String = ""
    var incidentForm:Incident!
    
    var city:String = ""
    var state:String = ""
    var streetNum:String = ""
    var streetName:String = ""
    var zip:String = ""
    
    var locationManager:CLLocationManager!
    var fju:FireJournalUser!
    var alertUp: Bool = false
    
    
    let cDP = CellParts.init(cellAttributes:  ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.pickerDateCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c1 = CellParts.init(cellAttributes: ["Header":"INCIDENT NUMBER:" , "Field1":"123" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentSingleEntryCell], vType: ["Value1":ValueType.fjKIncidentFormNumber,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c2 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentDatesCell], vType: ["Value1":ValueType.fjKIncidentDate,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c3 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentDateInputCell], vType: ["Value1":ValueType.fjKIncidentDateInput,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c4 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentEmergencyCell], vType: ["Value1":ValueType.fjKIncidentEmergency,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c5 = CellParts.init(cellAttributes: ["Header":"INCIDENT TYPE" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentTypeCell], vType: ["Value1":ValueType.fjKIncidentType,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c6 = CellParts.init(cellAttributes: ["Header":"LOCAL INCIDENT TYPE" , "Field1":"Brush Fire" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentIndicatorCell], vType: ["Value1":ValueType.fjKIncidentLocalType,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c7 = CellParts.init(cellAttributes: ["Header":"NFIRS INCIDENT TYPE" , "Field1":"100 Fire, other" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentIndicatorCell], vType: ["Value1":ValueType.fjKIncidentNFIRSType,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c8 = CellParts.init(cellAttributes: ["Header":"LOCATION" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentLocationButtonCell], vType: ["Value1":ValueType.fjKIncidentLocationButtons,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c9 = CellParts.init(cellAttributes: ["Header":"ADDRESS" , "Field1":"123 1st Ave" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentSingleEntryCell], vType: ["Value1":ValueType.fjKIncidentStreetNumAndName,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c10 = CellParts.init(cellAttributes: ["Header":"CITY" , "Field1":"Los Angeles" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentSingleEntryCell], vType: ["Value1":ValueType.fjKIncidentCity,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c11 = CellParts.init(cellAttributes: ["Header":"STATE" , "Field1":"CA" , "Field2":"ZIP", "Field3":"90808","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentDoubleEntryCell], vType: ["Value1":ValueType.fjKIncidentStateAndZip,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c12 = CellParts.init(cellAttributes: ["Header":"LOCATION TYPE" , "Field1":"Street Address" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentIndicatorCell], vType: ["Value1":ValueType.fjKIncidentLocationType,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c13 = CellParts.init(cellAttributes: ["Header":"STREET TYPE" , "Field1":"AVE Avenue" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentIndicatorCell], vType: ["Value1":ValueType.fjKIncidentStreetType,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let c14 = CellParts.init(cellAttributes: ["Header":"STREET PREFIX" , "Field1":"North" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.IncidentIndicatorCell], vType: ["Value1":ValueType.fjKIncidentStreetPrefix,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    
    var cells = [CellParts]()
    weak var delegate: NewIncidentModalDelegate? = nil
    var user:String?
    var icsPosition:String?
    var icsAgency:String?
    
    @IBAction func unwindToNewIncidentModal(segue:UIStoryboardSegue) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        incidentStructure = IncidentStructure.init()
        incidentStructure.incidentType = "Fire"
        incidentStructure.incidentImageName = "10112017IconSet__fire"
        incidentStructure.incidentEmergency = "Emergency"
        incidentForm = Incident.init(entity: NSEntityDescription.entity(forEntityName: "Incident", in: context)!, insertInto: context)
        cells = [c1,c2,c3,cDP,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14]
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewIncident(_:)))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelNewIncident(_:)))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = cancel
        
        let backgroundImage = UIImage(named: "headerBar2")
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        tableView.register(UINib(nibName: "FormDatePickerCell", bundle: nil), forCellReuseIdentifier: "FormDatePickerCell")
        tableView.register(UINib(nibName: "IncidentDateInputCell", bundle: nil), forCellReuseIdentifier: "IncidentDateInputCell")
        tableView.register(UINib(nibName: "IncidentDatesCell", bundle: nil), forCellReuseIdentifier: "IncidentDatesCell")
        tableView.register(UINib(nibName: "IncidentDoubleEntryCell", bundle: nil), forCellReuseIdentifier: "IncidentDoubleEntryCell")
        tableView.register(UINib(nibName: "IncidentEmergencyCell", bundle: nil), forCellReuseIdentifier: "IncidentEmergencyCell")
        tableView.register(UINib(nibName: "IncidentIndicatorCell", bundle: nil), forCellReuseIdentifier: "IncidentIndicatorCell")
        tableView.register(UINib(nibName: "IncidentLocationButtonCell", bundle: nil), forCellReuseIdentifier: "IncidentLocationButtonCell")
        tableView.register(UINib(nibName: "IncidentSingleEntryCell", bundle: nil), forCellReuseIdentifier: "IncidentSingleEntryCell")
        tableView.register(UINib(nibName: "IncidentTypeCell", bundle: nil), forCellReuseIdentifier: "IncidentTypeCell")
        incidentStructure.incidentEmergency = "Emergency"
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }

    
    @objc func cancelNewIncident(_ sender:Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addNewIncident(_ sender:Any) {
        let userRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser")
        do {
            let userFetched = try context.fetch(userRequest) as! [FireJournalUser]
            if userFetched.count != 0 {
                fju = userFetched.last!
            }
        } catch let error as NSError {
            print("NewIncidentModalTVC line 142 Fetch Error: \(error.localizedDescription)")
        }
        if incidentStructure.incidentNumber != "" {
            incidentForm.incidentNumber = incidentStructure.incidentNumber
            if fju != nil {
                if let userGuid = fju.userGuid {
                    incidentForm.fjpUserReference = userGuid
                }
            }
            incidentForm.incidentBackedUp = false
            let incidentCreateDate:Date?
            if incidentStructure.incidentDate == nil {
                let inDate = Date()
                incidentForm.incidentModDate = inDate
                incidentForm.fjpIncidentDateSearch = inDate
                incidentForm.fjpIncidentModifiedDate = inDate
                incidentForm.incidentCreationDate = inDate
                incidentCreateDate = inDate
            } else {
                incidentForm.incidentModDate = incidentStructure.incidentDate
                incidentForm.fjpIncidentDateSearch = incidentStructure.incidentDate
                incidentForm.fjpIncidentModifiedDate = incidentStructure.incidentDate
                incidentForm.incidentCreationDate = incidentStructure.incidentDate
                incidentCreateDate = incidentStructure.incidentDate
            }
            
            var uuidA:String = NSUUID().uuidString.lowercased()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
            let dateFrom = dateFormatter.string(from: incidentCreateDate!)
            uuidA = uuidA+dateFrom
            let uuidA1 = "02."+uuidA
            
            incidentForm.fjpIncGuidForReference = uuidA1
            
            if incidentStructure.incidentType == "" {
                incidentStructure.incidentType = "Fire"
            }
            incidentForm.situationIncidentImage = incidentStructure.incidentType
            if incidentStructure.incidentImageName == nil {
                incidentForm.incidentEntryTypeImageName = "10112017IconSet__fire"
            } else {
                incidentForm.incidentEntryTypeImageName = incidentStructure.incidentImageName
            }
            
            dateFormatter.dateFormat = "D"
            let dayOfYear = dateFormatter.string(from: incidentStructure.incidentDate!)
            if let day = Int(dayOfYear) {
            incidentForm.incidentDayOfYear = NSNumber(value:day)
            }
            
//            MARK: -LOCATION-
            /// incidentLocation archived with secureCoding
            if incidentStructure.incidentLocation != nil {
                if let location = incidentStructure.incidentLocation {
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                        incidentForm.incidentLocationSC = data as NSObject
                    } catch {
                        print("got an error here")
                    }
                }
            }
            incidentForm.incidentStreetNumber = incidentStructure.incidentStreetNum
            incidentForm.incidentStreetHyway = incidentStructure.incidentStreetName
            incidentForm.incidentZipCode = incidentStructure.incidentZip
            
            let incidentLocal = IncidentLocal.init(entity: NSEntityDescription.entity(forEntityName: "IncidentLocal", in: context)!, insertInto: context)
            incidentLocal.incidentLocalType = incidentStructure.incidentLocalType
            incidentLocal.incidentLocalInfo = incidentForm
            
            let incidentNFIRS = IncidentNFIRS.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRS", in: context)!, insertInto: context)
            var nfirs = ""
            nfirs = incidentStructure.incidentNFIRSType!
            if nfirs != "" {
                let nfirsNum = nfirs.prefix(3)
                let nfirsText = nfirs.dropFirst(4)
                let number:String! = String(describing: nfirsNum)
                let text:String! = String(describing:nfirsText)
                incidentNFIRS.incidentTypeNumberNFRIS = "\(number!)"
                incidentNFIRS.incidentTypeTextNFRIS = "\(text!)"
            }
//            MARK: -STRING-
            incidentNFIRS.incidentLocation = incidentStructure.incidentLocationType
            incidentNFIRS.incidentNFIRSInfo = incidentForm
            
            let incidentAddress = IncidentAddress.init(entity: NSEntityDescription.entity(forEntityName: "IncidentAddress", in: context)!, insertInto: context)
            incidentAddress.prefix = incidentStructure.incidentStreetPrefix
            incidentAddress.streetType = incidentStructure.incidentStreetType
            incidentAddress.incidentAddressInfo = incidentForm
            
            let incidentNotes = IncidentNotes.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNotes", in: context)!, insertInto: context)
            incidentNotes.incidentNote = ""
            incidentNotes.incidentNotesInfo = incidentForm
            
            let incidentTimer = IncidentTimer.init(entity: NSEntityDescription.entity(forEntityName: "IncidentTimer", in: context)!, insertInto: context)
            if incidentStructure.incidentDate != nil {
                incidentTimer.incidentAlarmDateTime = incidentStructure.incidentDate
                let incidentDate = incidentStructure.incidentDate
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "YYYY"
                incidentTimer.incidentAlarmYear = dateFormatter.string(from:incidentDate!)
                dateFormatter2.dateFormat = "MM"
                incidentTimer.incidentAlarmMonth = dateFormatter.string(from:incidentDate!)
                dateFormatter2.dateFormat = "dd"
                incidentTimer.incidentAlarmDay = dateFormatter.string(from:incidentDate!)
                dateFormatter2.dateFormat = "HH"
                incidentTimer.incidentAlarmHours = dateFormatter.string(from:incidentDate!)
                dateFormatter2.dateFormat = "mm"
                incidentTimer.incidentAlarmMinutes = dateFormatter.string(from:incidentDate!)
                dateFormatter2.dateFormat = "EEEE MMM dd,YYYY HH:mm:ss"
                incidentTimer.incidentAlarmCombinedDate = dateFormatter.string(from:incidentDate!)
            }
            incidentTimer.incidentTimerInfo = incidentForm
            
            let incidentNFIRSKSec = IncidentNFIRSKSec.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSKSec", in: context)!, insertInto: context)
            incidentNFIRSKSec.incidentNFIRSKSecInto = incidentForm
            
            let incidentNFIRSsecL = IncidentNFIRSsecL.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSsecL", in: context)!, insertInto: context)
            incidentNFIRSsecL.sectionLInfo = incidentForm
            
            let incidentNFIRSsecM = IncidentNFIRSsecM.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSsecM", in: context)!, insertInto: context)
            incidentNFIRSsecM.sectionMInfo = incidentForm
            
            let actionsTaken = ActionsTaken.init(entity: NSEntityDescription.entity(forEntityName: "ActionsTaken", in: context)!, insertInto: context)
            actionsTaken.actionsTakenInfo = incidentForm
            
            let nfirsSections = NFIRSSections.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSSections", in: context)!, insertInto: context)
            nfirsSections.sectionA = false
            nfirsSections.sectionB = false
            nfirsSections.sectionC = true
            nfirsSections.sectionD = false
            nfirsSections.sectionE = false
            nfirsSections.sectionF = false
            nfirsSections.sectionG = false
            nfirsSections.sectionH = false
            nfirsSections.sectionI = false
            nfirsSections.sectionJ = false
            nfirsSections.sectionK = false
            nfirsSections.sectionL = false
            nfirsSections.sectionM = false
            
            nfirsSections.formSections = incidentForm
            
            incidentForm.fireJournalUserIncInfo = fju
            
            let journal = Journal.init(entity: NSEntityDescription.entity(forEntityName: "Journal", in: context)!, insertInto: context)
            journal.journalCreationDate = incidentForm.incidentModDate
            journal.fjpUserReference = fju.userGuid
            journal.fjpIncReference = incidentForm.fjpIncGuidForReference
            let incidentNum = incidentForm.incidentNumber
            dateFormatter.dateFormat = "EEEE MMM dd,YYYY HH:mm:ss"
            let inDate = dateFormatter.string(from:incidentForm.incidentModDate!)
            journal.journalHeader = "Incident Number:\(incidentNum ?? "") \(inDate)"
            journal.journalEntryTypeImageName = incidentForm.incidentType
            journal.journalEntryType = incidentForm.incidentType
            let uuidA2 = "01."+uuidA
            journal.fjpJGuidForReference = uuidA2
            dateFormatter.dateFormat = "MM/dd/YYYY"
            let formatedDate = dateFormatter.string(from: incidentForm.incidentModDate!)
            journal.journalMMDDYYYY = formatedDate
            journal.journalTempApparatus = fju.tempApparatus;
            journal.journalTempAssignment = fju.tempAssignment;
            journal.journalTempFireStation = fju.tempFireStation;
            journal.journalTempPlatoon = fju.tempPlatoon;
            journal.journalBackedUp = false
            journal.journalStreetNumber = incidentForm.incidentStreetNumber;
            journal.journalStreetName = incidentForm.incidentStreetHyway;
            journal.journalZip = incidentForm.incidentZipCode;
            journal.journalPhotoTaken = false;
            journal.fireJournalUserInfo = fju
            journal.incidentDetails = incidentForm
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214 NEW Incident merge that"])
                }
            } catch let error as NSError {
                print("NewIncidentModalTVC line 301 Fetch Error: \(error.localizedDescription)")
            }
//            print("here is the incident \(incidentForm)")
            delegate?.newIncidentCreated(objectId: incidentForm.objectID)
            dismiss(animated: true, completion: nil)
        }
        
//        print("here is incidentForm \(incidentForm)")
    }
    
    func selectedTextToReturnWithType(entity: String, selected: String) {
        if entity == "UserLocalIncidentType" {
            incidentStructure.incidentLocalType = selected
        } else if entity == "NFIRSIncidentType" {
            incidentStructure.incidentNFIRSType = selected
        } else if entity == "NFIRSLocation" {
            incidentStructure.incidentLocationType = selected
        } else if entity == "NFIRSStreetType" {
            incidentStructure.incidentStreetType = selected
        } else if entity == "NFIRSStreetPrefix" {
            incidentStructure.incidentStreetPrefix = selected
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type:CellParts = cells[indexPath.row]
        let cellType:FormType = type.type["Type"]!
        switch cellType {
        case .IncidentSingleEntryCell:
            return 44
        case .IncidentIndicatorCell:
            return 44
        case .pickerDateCell:
            if(showPicker) {
                return  132
            } else {
                return 0
            }
        case .IncidentDateInputCell:
            return 44
        case .IncidentDatesCell:
            return 44
        case .IncidentDoubleEntryCell:
            return 44
        case .IncidentEmergencyCell:
            return 44
        case .IncidentLocationButtonCell:
            return 44
        case .IncidentTypeCell:
            return 44
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let type:CellParts = cells[indexPath.row]
        let cellType:FormType = type.type["Type"]!
        let header:String = type.cellAttributes["Header"]!
        let field1:String = type.cellAttributes["Field1"]!
        let field2:String = type.cellAttributes["Field2"]!
        let field3:String = type.cellAttributes["Field3"]!
        let valueType:ValueType = type.vType["Value1"]!
        
        switch cellType {
        case .IncidentSingleEntryCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentSingleEntryCell", for: indexPath) as! IncidentSingleEntryCell
            switch valueType {
            case .fjKIncidentFormNumber:
                cell.type = valueType
                cell.incidentTitleL.text = header
                if incidentStructure.incidentNumber != "" {
                    cell.incidentInputTF.text = incidentStructure.incidentNumber
                } else {
                cell.incidentInputTF.placeholder = field1
                }
            case .fjKIncidentStreetNumAndName:
                cell.incidentTitleL.text = header
                if streetNum != "" && streetName != "" {
                    cell.incidentInputTF.text = "\(streetNum) \(streetName)"
                } else {
                    cell.incidentInputTF.placeholder = field1
                }
                cell.type = valueType
            case .fjKIncidentCity:
                cell.incidentTitleL.text = header
                if city != "" {
                    cell.incidentInputTF.text = city
                } else {
                    cell.incidentInputTF.placeholder = field1
                }
                cell.type = valueType
            default:
                break
            }
            cell.delegate = self
            return cell
        case .IncidentIndicatorCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentIndicatorCell", for: indexPath) as! IncidentIndicatorCell
            cell.delegate = self
            cell.incidentInputTF.isUserInteractionEnabled = false
            switch valueType {
            case .fjKIncidentLocalType:
                cell.incidentTitleL.text = header
                if incidentStructure.incidentLocalType != nil {
                    cell.incidentInputTF.text = incidentStructure.incidentLocalType
                } else {
                    cell.incidentInputTF.placeholder = field1
                }
                cell.type = valueType
            case .fjKIncidentNFIRSType:
                cell.incidentTitleL.text = header
                if incidentStructure.incidentNFIRSType != nil {
                    cell.incidentInputTF.text = incidentStructure.incidentNFIRSType
                } else {
                    cell.incidentInputTF.placeholder = field1
                }
                cell.type = valueType
            case .fjKIncidentLocationType:
                cell.incidentTitleL.text = header
                if incidentStructure.incidentLocationType != nil {
                    cell.incidentInputTF.text = incidentStructure.incidentLocationType
                } else {
                    cell.incidentInputTF.placeholder = field1
                }
                cell.type = valueType
            case .fjKIncidentStreetType:
                cell.incidentTitleL.text = header
                if incidentStructure.incidentStreetType != nil {
                    cell.incidentInputTF.text = incidentStructure.incidentStreetType
                } else {
                    cell.incidentInputTF.placeholder = field1
                }
                cell.type = valueType
            case .fjKIncidentStreetPrefix:
                cell.incidentTitleL.text = header
                if incidentStructure.incidentStreetPrefix != nil {
                    cell.incidentInputTF.text = incidentStructure.incidentStreetPrefix
                } else {
                    cell.incidentInputTF.placeholder = field1
                }
                cell.type = valueType
            default:
                break
            }
            return cell
        case .IncidentDoubleEntryCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentDoubleEntryCell", for: indexPath) as! IncidentDoubleEntryCell
            cell.incidentOneL.text = header
            cell.incidentTwoL.text = field2
            if state != "" {
                cell.incidentInput1TF.text = state
            } else {
                cell.incidentInput1TF.placeholder = field1
            }
            if zip != "" {
                cell.incidentInput2TF.text = zip
            } else {
                cell.incidentInput2TF.placeholder = field3
            }
            return cell
        case .IncidentLocationButtonCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentLocationButtonCell", for: indexPath) as! IncidentLocationButtonCell
            cell.delegate = self
            return cell
        case .IncidentDatesCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentDatesCell", for: indexPath) as! IncidentDatesCell
            cell.delegate = self
            return cell
        case .IncidentDateInputCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentDateInputCell", for: indexPath) as! IncidentDateInputCell
            var date = Date()
            if pickerDate != nil {
                date = pickerDate!
            } else if incidentStructure.incidentDate != nil {
                date = incidentStructure.incidentDate!
            } else {
                incidentStructure.incidentDate = date
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM"
            let month = dateFormatter.string(from:date)
            dateFormatter.dateFormat = "dd"
            let day = dateFormatter.string(from:date)
            dateFormatter.dateFormat = "YYYY"
            let year = dateFormatter.string(from:date)
            dateFormatter.dateFormat = "HH"
            let hour = dateFormatter.string(from:date)
            dateFormatter.dateFormat = "mm"
            let minute = dateFormatter.string(from:date)
            cell.monthInputL.text = month
            cell.dayInputL.text = day
            cell.yearInputL.text = year
            cell.hourInputL.text = hour
            cell.minuteInputL.text = minute
            pickerDate = date
            cell.type = valueType
            return cell
        case .IncidentEmergencyCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentEmergencyCell", for: indexPath) as! IncidentEmergencyCell
            cell.delegate = self
            return cell
        case .IncidentTypeCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentTypeCell", for: indexPath) as! IncidentTypeCell
            cell.delegate = self
            return cell
        case .pickerDateCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormDatePickerCell", for: indexPath) as! FormDatePickerCell
            cell.delegate = self
            cell.type = false
            cell.activity = "Incident"
            if !showPicker {
                cell.isHidden = true
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            return cell
        }
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let int = indexPath.row
        switch int {
        case 6:
            sendingEntity = "UserLocalIncidentType"
            sendingAttribute = "localIncidentTypeName"
            let segue = "IncidentDetailSegue"
            performSegue(withIdentifier: segue, sender: self)
        case 7:
            sendingEntity = "NFIRSIncidentType"
            sendingAttribute = "incidentTypeName"
            let segue = "IncidentDetailSegue"
            performSegue(withIdentifier: segue, sender: self)
        case 12:
            sendingEntity = "NFIRSLocation"
            sendingAttribute = "location"
            let segue = "IncidentDetailSegue"
            performSegue(withIdentifier: segue, sender: self)
        case 13:
            sendingEntity = "NFIRSStreetType"
            sendingAttribute = "streetType"
            let segue = "IncidentDetailSegue"
            performSegue(withIdentifier: segue, sender: self)
        case 14:
            sendingEntity = "NFIRSStreetPrefix"
            sendingAttribute = "streetPrefix"
            let segue = "IncidentDetailSegue"
            performSegue(withIdentifier: segue, sender: self)
        default:
            break;
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IncidentDetailSegue" {
            let detailTV:NewIncidentDetailTVC = segue.destination as! NewIncidentDetailTVC
            detailTV.delegate = self
            detailTV.entity = sendingEntity
            detailTV.attribute = sendingAttribute
            print("\(detailTV.attribute) and sending \(sendingAttribute)")
        } else if segue.identifier == "incidentMapSegue" {
            let detailMapTV:NewIncidentMapVC = segue.destination as! NewIncidentMapVC
            detailMapTV.delegate = self
        }
        sendingAttribute = ""
        sendingAttribute = ""
    }
    /// protocol actions
    ///
    /// - Parameter emergency: <#emergency description#>
    func emergencyTapped(emergency: String) {
        self.resignFirstResponder()
        incidentStructure.incidentEmergency = emergency
    }
    
    func theTextFieldOnIncidentSingleEntryEndedEditing(type: ValueType, input: String) {
        switch type {
        case .fjKIncidentFormNumber:
            incidentStructure.incidentNumber = input
        default:
            break
        }
    }
    
    func theIncidentTypeChosen(type: Int) {
        
        self.resignFirstResponder()
        var event:String = ""
        var imageName:String = ""
        switch type {
        case 0:
            event = "Fire"
            imageName = "10112017IconSet__fire"
        case 1:
            event = "EMS"
            imageName = "10112017IconSet__ems"
        case 2:
            event = "Rescue"
            imageName = "10112017IconSet__rescue"
        default:
            break
        }
        incidentStructure.incidentType = event
        incidentStructure.incidentImageName = imageName
    }
    
    func localationTapped() {
        self.resignFirstResponder()
        determineLocation()
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
                self.incidentStructure.incidentCity = self.city
                self.streetNum = "\(pm.subThoroughfare!)"
                self.incidentStructure.incidentStreetNum = self.streetNum
                self.streetName = "\(pm.thoroughfare!)"
                self.incidentStructure.incidentStreetName = self.streetName
                self.state = "\(pm.administrativeArea!)"
                self.incidentStructure.incidentState = self.state
                self.zip = "\(pm.postalCode!)"
                self.incidentStructure.incidentZip = self.zip
                self.incidentStructure.incidentLocation = userLocation
                self.tableView.reloadData()
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    
    func mapCallTapped() {
        self.resignFirstResponder()
        let segue = "incidentMapSegue"
        performSegue(withIdentifier: segue, sender: self)
    }
    
    func theMapLocationHasBeenChosen(location: CLLocation) {
        self.incidentStructure.incidentLocation = location
        print("here is the location \(location)")
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if placemarks?.count != 0 {
                let pm = placemarks![0]
                print(pm.locality!)
                self.city = "\(pm.locality!)"
                self.incidentStructure.incidentCity = self.city
                self.streetNum = "\(pm.subThoroughfare!)"
                self.incidentStructure.incidentStreetNum = self.streetNum
                self.streetName = "\(pm.thoroughfare!)"
                self.incidentStructure.incidentStreetName = self.streetName
                self.state = "\(pm.administrativeArea!)"
                self.incidentStructure.incidentState = self.state
                self.zip = "\(pm.postalCode!)"
                self.incidentStructure.incidentZip = self.zip
                self.incidentStructure.incidentLocation = location
                self.tableView.reloadData()
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func indicatorTextFieldFilled(type: ValueType, input: String) {
        self.resignFirstResponder()
        print("here is the indicator text added")
    }
    
    
    func chosenIncidentDate(date: Date) {
        print("here is the date \(date)")
        pickerDate = date
        incidentStructure.incidentDate = date
        showPicker = false
        tableView.reloadData()
    }
    
    func theIncidentDateButtonTapped() {
        self.resignFirstResponder()
        if showPicker {
            showPicker = false
        } else {
            showPicker = true
        }
        tableView.reloadData()
    }
}
