//
//  NewICS214ModalTVC.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/28/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation


@objc protocol NewICS214ModalTVCDelegate: AnyObject {

    func theCancelCalledOnNewICS214Modal()
}

struct StreetPrefixed {
    var prefix:String?
    var abbreviation:String?
}

class NewICS214ModalTVC: UITableViewController, FormSegmentCellDelegate, FourSwitchCellDelegate, EffortWithDateDelegate, EffortDelegate, FormDatePickerCellDelegate, CellHeaderCancelSaveDelegate, CLLocationManagerDelegate {
    
    //    MARK: - presentation Delegate
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    
    var prefixes:StreetPrefixed!
    var localIncidents = [] as Array
    var location = [] as Array
    var nfirsStreetTypes = [] as Array
    var streetPrefixes = [] as Array
    var streetPrefixAbbrev = [] as Array
    
    var streetTypes = [] as Array
    var section1:Bool = true
    var firstOrMore:Bool = false
    var formType: Int = 0
    var chosenMasterType: Int = 0
    var incidentOnOrOff:Bool = false
    var turnMasterOn:Bool = false
    var effortType:Bool = false
    var strikeOnOrOff:Bool = false
    var femaOnOrOff:Bool = false
    var otherOnOrOff:Bool = false
    var dateOnOrOff:Bool = false
    var showMap:Bool = false
    var modalCells:Array = [CellParts]()
    var typeOfForm:String = ""
    var fetchedIncident:Array = [Incident]()
    var fetchedICS241:Array = [ICS214Form]()
    var showPicker:Bool = false
    var dateWords:String = ""
    var field8:String = "no"
    var dayOfYear:String = ""
    var masterOrNot:Bool = true
    var showJournal:Bool = false
    
    var guid:String!
    var masterGuid:String!
    var type:TypeOfForm!
    var incidentGuid:String!
    var journalGuid:String!
    var incidentNumber:String!
    var formMaster:String = ""
    var NewICS214TVCSegue = "NewICS214TVCSegue"
    var NewICS214NewIncidentTVCSegue = "NewICS214NewIncidentTVCSegue"
    var incidentObjectID: NSManagedObjectID!
    
    //    MARK: - LOCATION
    
    var currentLocation: CLLocation!
    var locationManager:CLLocationManager!
    var streetNum = ""
    var streetName = ""
    var city = ""
    var stateName = ""
    var zipNum = ""
    var latitude: String = ""
    var longitude: String = ""
    var teamName: String = ""
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let nc = NotificationCenter.default
    
    var alertUp: Bool = false
    
    let p0 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.modalHeader], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let p1 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.paragraphCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let p2 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.formSegmentCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let p3 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.fourSwitchCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let p4 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.efforWithDateCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let p5 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.effortWithoutDateCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])

    let p6 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.theMapCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    
    let p30 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.pickerDateCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    let p41 = CellParts.init(cellAttributes: ["Header":"" , "Field1":"" , "Field2":"", "Field3":"","Field4":"","Value1":"","Value2":"","Value3":"","Value4":"","Value5":""], type: ["Type": FormType.journalMasterCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
    
    weak var delegate: NewICS214ModalTVCDelegate? = nil
    
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214 NEW merge that"])
            }
        } catch {
            let nserror = error as NSError
            
            let errorMessage = "NewICS214ModalTVC saveToCD() save Unresolved error \(nserror)"
            print(errorMessage)
        }
    }
    
    fileprivate func localIncidentsToCD() {
        for localIncidentType in localIncidents {
            let resourceDate = Date()
            var uuidA:String = NSUUID().uuidString.lowercased()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
            let dateFrom = dateFormatter.string(from: resourceDate)
            uuidA = uuidA+dateFrom
            let uuidA1 = "50."+uuidA
            let userLocalIncidentType = UserLocalIncidentType.init(entity: NSEntityDescription.entity(forEntityName: "UserLocalIncidentType", in: context)!, insertInto: context)
            userLocalIncidentType.localIncidentGuid = uuidA1
            userLocalIncidentType.localIncidentTypeName = localIncidentType as? String
            userLocalIncidentType.localIncidentTypeBackUp = 0
            userLocalIncidentType.localIncidentTypeModDate = resourceDate
        }
        
        saveToCD()
        
    }
    
    fileprivate func nfirsLocationToCD() {
        for local in location {
            let resourceDate = Date()
            var uuidA:String = NSUUID().uuidString.lowercased()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
            let dateFrom = dateFormatter.string(from: resourceDate)
            uuidA = uuidA+dateFrom
            let uuidA1 = "51."+uuidA
            let nfirsLocation = NFIRSLocation.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSLocation", in: context)!, insertInto: context)
            nfirsLocation.location = local as? String
            nfirsLocation.locationModDate = resourceDate
            nfirsLocation.locationGuid = uuidA1
            nfirsLocation.locationBackup = false
        }
        saveToCD()
    }
    
    fileprivate func streetPrefixToCD() {
        for streetPre in streetPrefixes {
            let resourceDate = Date()
            var uuidA:String = NSUUID().uuidString.lowercased()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
            let dateFrom = dateFormatter.string(from: resourceDate)
            uuidA = uuidA+dateFrom
            let uuidA1 = "52."+uuidA
            let nfirsStreetPrefix = NFIRSStreetPrefix.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSStreetPrefix", in: context)!, insertInto: context)
            nfirsStreetPrefix.streetPrefix = streetPre as? String
            nfirsStreetPrefix.streetPrefixModDate = resourceDate
            nfirsStreetPrefix.streetPrefixBackup = false
            nfirsStreetPrefix.streetPrefixGuid = uuidA1
        }
        saveToCD()
    }
    
    fileprivate func streetTypeToCD() {
        for streetType in streetTypes {
            let resourceDate = Date()
            var uuidA:String = NSUUID().uuidString.lowercased()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
            let dateFrom = dateFormatter.string(from: resourceDate)
            uuidA = uuidA+dateFrom
            let uuidA1 = "53."+uuidA
            let nfirsStreetType = NFIRSStreetType.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSStreetType", in: context)!, insertInto: context)
            nfirsStreetType.streetType = streetType as? String
            nfirsStreetType.nfirsSTModDate = resourceDate
            nfirsStreetType.nfirsSTBackedUp = false
            nfirsStreetType.streetTypeGuid = uuidA1
        }
        saveToCD()
    }
    
    fileprivate func nfirsIncidentTypeToCD() {
        for incidentType in nfirsStreetTypes {
            let resourceDate = Date()
            var uuidA:String = NSUUID().uuidString.lowercased()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
            let dateFrom = dateFormatter.string(from: resourceDate)
            uuidA = uuidA+dateFrom
            let uuidA1 = "54."+uuidA
            let nfirsIncidentType = NFIRSIncidentType.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSIncidentType", in: context)!, insertInto: context)
            nfirsIncidentType.incidentTypeName = incidentType as? String
            nfirsIncidentType.incidentTypeGuid = uuidA1
            nfirsIncidentType.incidentTypeNameBackup = false
            nfirsIncidentType.incidentTypeNameModDate = resourceDate
        }
        saveToCD()
    }
    
    fileprivate func loadThePlists() {
        var path = Bundle.main.path(forResource: "LocalIncidents", ofType:"plist")
        let dict = NSDictionary(contentsOfFile:path!)
        localIncidents = dict!["LocalIncidents"] as! Array<String>
        path = Bundle.main.path(forResource: "Location", ofType:"plist")
        let dict2 = NSDictionary(contentsOfFile:path!)
        location = dict2!["location"] as! Array<String>
        path = Bundle.main.path(forResource: "NFIRSIncidentType", ofType:"plist")
        let dict3 = NSDictionary(contentsOfFile:path!)
        nfirsStreetTypes = dict3!["incidentTypeName"] as! Array<String>
        path = Bundle.main.path(forResource: "StreetPrefix", ofType:"plist")
        let dict4 = NSDictionary(contentsOfFile:path!)
        streetPrefixes = dict4!["streetPrefix"] as! Array<String>
        streetPrefixAbbrev = dict4!["streetPrefixAbbreviation"] as! Array<String>
        path = Bundle.main.path(forResource: "StreetTypes", ofType:"plist")
        let dict5 = NSDictionary(contentsOfFile:path!)
        streetTypes = dict5!["streetType"] as! Array<String>
        
        localIncidentsToCD()
        nfirsLocationToCD()
        streetPrefixToCD()
        streetTypeToCD()
        nfirsIncidentTypeToCD()
    }
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.IS_IPHONE {
            let frame = self.view.frame
            let height = frame.height - 44
            self.view.frame = CGRect(x: 0, y: 44, width: frame.width, height: height)
            self.tableView = UITableView.init(frame: self.view.frame, style: .grouped)
        }
        roundViews()
        
        modalCells = [p0,p1,p2,p3,p4,p6,p41]
        
        tableView.register(UINib(nibName: "ParagraphCell", bundle: nil), forCellReuseIdentifier: "ParagraphCell")
        tableView.register(UINib(nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: "SegmentCell")
        tableView.register(UINib(nibName: "FourSwitchCell", bundle: nil), forCellReuseIdentifier: "FourSwitchCell")
        tableView.register(UINib(nibName: "EffortWithDateCell", bundle: nil), forCellReuseIdentifier: "EffortWithDateCell")
        tableView.register(UINib(nibName: "EfforWithoutDateCell", bundle: nil), forCellReuseIdentifier: "EfforWithoutDateCell")
        tableView.register(UINib(nibName: "FormDatePickerCell", bundle: nil), forCellReuseIdentifier: "FormDatePickerCell")
        tableView.register(UINib(nibName: "ModalHeaderCell", bundle: nil), forCellReuseIdentifier: "ModalHeaderCell")
        tableView.register(UINib(nibName: "IncidentMasterCell", bundle: nil), forCellReuseIdentifier: "IncidentMasterCell")
        tableView.register(UINib(nibName: "JournalMasterCell", bundle: nil), forCellReuseIdentifier: "JournalMasterCell")
        tableView.register(UINib(nibName: "FormSegmentCell", bundle: nil), forCellReuseIdentifier: "FormSegmentCell")
        tableView.register(UINib(nibName: "EffortSetUpCell", bundle: nil), forCellReuseIdentifier: "EffortSetUpCell")
        
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelNewIncident(_:)))
        navigationItem.leftBarButtonItem = cancel
        
        let backgroundImage = UIImage(named: "headerBar2")
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLocalIncidentType" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "localIncidentTypeName CONTAINS %@","Auto/Bike")
        fetchRequest.predicate = predicate
        do {
            let fetched = try context.fetch(fetchRequest) as! [UserLocalIncidentType]
            if fetched.count == 0 {
                loadThePlists()
            }
        } catch {
            let nserror = error as NSError
            
            let errorMessage = "NewICS214ModalTVC viewDidLoad() fetchRequest \(fetchRequest) Unresolved error \(nserror)"
            
            print(errorMessage)
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fourSwitchContinueTapped(type: String, masterOrMore: Bool) {
        typeOfForm = type
        masterOrNot = masterOrMore
        firstOrMore = false
        let entityType:String = "ICS214Form"
        print(typeOfForm)
        if typeOfForm == TypeOfForm.incidentForm.rawValue {
            incidentOnOrOff = true
        } else if typeOfForm == TypeOfForm.strikeForceForm.rawValue {
            if masterOrMore {
                effortType = true
                showJournal = false
            } else {
                effortType = false
                showJournal = true
                _ = TypeOfForm.strikeForceForm.rawValue
                let teamType = "Strike Team"
                grabAllMasters(entityName: entityType, typeOfForm: teamType)
            }
            strikeOnOrOff = true
        } else if typeOfForm == TypeOfForm.femaTaskForceForm.rawValue {
            if masterOrMore {
                effortType = true
                showJournal = false
            } else {
                effortType = false
                showJournal = true
                _ = TypeOfForm.femaTaskForceForm.rawValue
                let teamType = "FEMA Task Force"
                grabAllMasters(entityName: entityType, typeOfForm: teamType)
            }
            femaOnOrOff = true
        } else if typeOfForm == TypeOfForm.otherForm.rawValue {
            if masterOrMore {
                effortType = true
                showJournal = false
                print(modalCells)
            } else {
                effortType = false
                showJournal = true
                _ = TypeOfForm.otherForm.rawValue
                let teamType = "Other"
                grabAllMasters(entityName: entityType, typeOfForm: teamType)
            }
            otherOnOrOff = true
        }
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func theTimeButtonWasTappedForIncident() {
        let i:Int = modalCells.firstIndex(where: { $0 == p4 })!
        let d:Int = i+1
        modalCells.insert(p30, at:d)
        showPicker = true
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func chosenIncidentDate(date: Date) {
        showPicker = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "D"
        dayOfYear = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MM/dd/YYYY"
        dateWords = dateFormatter.string(from: date)
        field8 = "yes"
        //        print("dayOfYear \(dayOfYear) dateWords \(dateWords)")
        let i:Int = modalCells.firstIndex(where: { $0 == p30 })!
        modalCells.remove(at: i)
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func theSearchButtonTappedNoDate(incidentNum: String) {
        if masterOrNot {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident")
            var predicate = NSPredicate.init()
            if incidentNum != ""{
                predicate = NSPredicate(format: "incidentNumber CONTAINS %@",incidentNum)
            } else {
                predicate = NSPredicate(format: "incidentNumber != %@","")
            }
            fetchRequest.predicate = predicate
            let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            
            do {
                fetchedIncident = try context.fetch(fetchRequest) as! [Incident]
                if fetchedIncident.count != 0 {
                    for incident:Incident in fetchedIncident {
//                        print("here is the incident \(String(describing: incident.incidentNumber)) number")
                        var number = ""
                        var master = ""
                        var guid = ""
                        var streetNum = ""
                        var streetName = ""
                        var zip = ""
                        var imageName = ""
                        var imageType = ""
                        var incidentDate:Date?
                        var isDateHere:String = ""
                        var i10:CellParts!
                        let obID:NSManagedObjectID = incident.objectID
                        if incident.incidentNumber != nil {
                            number = incident.incidentNumber!
                        }
                        if incident.ics214MasterGuid != nil {
                            master = incident.ics214MasterGuid!
                        }
                        if incident.fjpIncGuidForReference != nil {
                            guid = incident.fjpIncGuidForReference!
                        }
                        if incident.incidentStreetNumber != nil {
                            streetNum = incident.incidentStreetNumber!
                        }
                        if incident.incidentStreetHyway != nil {
                            streetName = incident.incidentStreetHyway!
                        }
                        if incident.incidentZipCode != nil {
                            zip = incident.incidentZipCode!
                        }
                        if incident.incidentEntryTypeImageName != nil {
                            imageType = incident.incidentEntryTypeImageName!
                        }
                        if incident.situationIncidentImage != nil {
                            imageName = incident.situationIncidentImage!
                        }
                        let formType = TypeOfForm.incidentForm.rawValue
                        
                        if incident.incidentModDate != nil {
                            incidentDate = incident.incidentModDate! as Date
                            isDateHere = "yes"
                            i10 = CellParts.init(cellAttributes: ["Header":number , "Field1":master , "Field2":guid, "Field3":streetNum,"Field4":streetName,"Value1":zip,"Value2":imageName,"Value3":imageType,"Value4":isDateHere,"Value5":formType,"Value7":number], type: ["Type": FormType.incidentMasterCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":incidentDate!], objID: [ "objectID":obID ])
                        } else {
                            isDateHere = "no"
                            i10 = CellParts.init(cellAttributes: ["Header":number , "Field1":master , "Field2":guid, "Field3":streetNum,"Field4":streetName,"Value1":zip,"Value2":imageName,"Value3":imageType,"Value4":isDateHere,"Value5":formType,"Value7":number], type: ["Type": FormType.incidentMasterCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":obID ])
                        }
                        modalCells.append(i10)
                    }
                    tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                }
            }   catch {
                
                let nserror = error as NSError
                
                let errorMessage = "NewICS214ModalTVC theSearchButtonTappedNoDate() fetchRequest \(fetchRequest) Unresolved error \(nserror)"
                
                print(errorMessage)
                
            }
        } else {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form")
            var predicate = NSPredicate.init()
            predicate = NSPredicate(format: "ics214MasterGuid != %@ && ics214Effort == %@ && ics214EffortMaster == YES && ics214Completed != YES","","Local Incident")
            fetchRequest.predicate = predicate
            
            let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            
            do {
                fetchedICS241 = try context.fetch(fetchRequest) as! [ICS214Form]
                if fetchedICS241.count != 0 {
                    for ics214F:ICS214Form in fetchedICS241 {
//                        let ics214Incident = ics214F.ics214IncidentInfo
                        let ics214ObjID = ics214F.objectID
                        var name = ""
                        var master = ""
                        let masterYes:String = "yes"
                        var guid = ""
                        var fromTime = ""
                        var toTime = ""
                        var imageName = ""
                        teamName = ""
                        var type:String = ""
                        var incidentNumber:String = ""
                        _ = "Local Incident"
                        imageName = "ICS 214 Form LOCAL INCIDENT"
                        type = TypeOfForm.incidentForm.rawValue
                        var isDateHere:String = ""
                        if ics214F.ics214LocalIncidentNumber != nil {
                            incidentNumber = ics214F.ics214LocalIncidentNumber!
                        }
                        if ics214F.ics214IncidentName != nil {
                            name = ics214F.ics214IncidentName!
                        }
                        if ics214F.ics214MasterGuid != nil {
                            master = ics214F.ics214MasterGuid!
                        }
                        if ics214F.incidentGuid != nil {
                            guid = ics214F.incidentGuid!
                        }
                        if ics214F.ics214FromTime != nil {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                            let dateFrom = dateFormatter.string(from: ics214F.ics214FromTime! as Date)
                            fromTime = dateFrom
                        }
                        if ics214F.ics214ToTime != nil {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                            let dateFrom = dateFormatter.string(from: ics214F.ics214ToTime! as Date)
                            toTime = dateFrom
                        }
                        if ics214F.ics214TeamName != nil {
                            teamName = ics214F.ics214TeamName!
                        }
                        
                        var i45:CellParts!
                        isDateHere = "no"
                        i45 = CellParts.init(cellAttributes: ["Header":name , "Field1":master , "Field2":guid, "Field3":fromTime,"Field4":toTime,"Value1":imageName,"Value2":type,"Value3":masterYes,"Value4":isDateHere,"Value5":type,"Value6":teamName,"Value7":incidentNumber], type: ["Type": FormType.incidentMasterCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":ics214ObjID])
                        
                        modalCells.append(i45)
                    }
                    
                    turnMasterOn = true
                    tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                }
            } catch {
                
                let nserror = error as NSError
                
                let errorMessage = "NewICS214ModalTVC theSearchButtonTappedNoDate() fetchRequest \(fetchRequest) Unresolved error \(nserror)"
                
                print(errorMessage)
                
            }
        }
    }
    
    func theSearchButtonTapped(incidentNum: String, incidentDate: Date?) {
        
        if masterOrNot {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "D"
            let searchDayOfYear = dateFormatter.string(from: incidentDate!)
            print(searchDayOfYear)
            var predicate = NSPredicate.init()
            if incidentDate != nil && incidentNum != ""{
                predicate = NSPredicate(format: "incidentNumber CONTAINS %@ && incidentDayOfYear == %@",incidentNum,searchDayOfYear)
            } else if incidentDate != nil && incidentNum == "" {
                predicate = NSPredicate(format: "incidentDayOfYear == %@",searchDayOfYear)
            } else if incidentDate == nil && incidentNum != "" {
                predicate = NSPredicate(format: "incidentNumber CONTAINS %@",incidentNum)
            } else {
                predicate = NSPredicate(format: "incidentNumber != %@","")
            }
            
            fetchRequest.predicate = predicate
            let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            
            do {
                fetchedIncident = try context.fetch(fetchRequest) as! [Incident]
                if fetchedIncident.count != 0 {
                    for incident:Incident in fetchedIncident {
//                        print("here is the incident \(String(describing: incident.incidentNumber)) number")
                        var number = ""
                        var master = ""
                        var guid = ""
                        var streetNum = ""
                        var streetName = ""
                        var zip = ""
                        var imageName = ""
                        var imageType = ""
                        var incidentDate:Date?
                        var isDateHere:String = ""
                        var i10:CellParts!
                        let obID:NSManagedObjectID = incident.objectID
                        if incident.incidentNumber != nil {
                            number = incident.incidentNumber!
                        }
                        if incident.ics214MasterGuid != nil {
                            master = incident.ics214MasterGuid!
                        }
                        if incident.fjpIncGuidForReference != nil {
                            guid = incident.fjpIncGuidForReference!
                        }
                        if incident.incidentStreetNumber != nil {
                            streetNum = incident.incidentStreetNumber!
                        }
                        if incident.incidentStreetHyway != nil {
                            streetName = incident.incidentStreetHyway!
                        }
                        if incident.incidentZipCode != nil {
                            zip = incident.incidentZipCode!
                        }
                        if incident.incidentEntryTypeImageName != nil {
                            imageType = incident.incidentEntryTypeImageName!
                        }
                        if incident.situationIncidentImage != nil {
                            imageName = incident.situationIncidentImage!
                        }
                        let formType = TypeOfForm.incidentForm.rawValue
                        
                        if incident.incidentModDate != nil {
                            incidentDate = incident.incidentModDate! as Date
                            isDateHere = "yes"
                            i10 = CellParts.init(cellAttributes: ["Header":number , "Field1":master , "Field2":guid, "Field3":streetNum,"Field4":streetName,"Value1":zip,"Value2":imageName,"Value3":imageType,"Value4":isDateHere,"Value5":formType], type: ["Type": FormType.incidentMasterCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":incidentDate!], objID: [ "objectID":obID ])
                        } else {
                            isDateHere = "no"
                            i10 = CellParts.init(cellAttributes: ["Header":number , "Field1":master , "Field2":guid, "Field3":streetNum,"Field4":streetName,"Value1":zip,"Value2":imageName,"Value3":imageType,"Value4":isDateHere,"Value5":formType], type: ["Type": FormType.incidentMasterCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":obID ])
                        }
                        modalCells.append(i10)
                    }
                    tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                }
            }   catch {
                
                let nserror = error as NSError
                
                let errorMessage = "NewICS214ModalTVC theSearchButtonTapped() fetchRequest \(fetchRequest) Unresolved error \(nserror)"
                
                print(errorMessage)
            }
        } else {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form")
            var predicate = NSPredicate.init()
            predicate = NSPredicate(format: "ics214MasterGuid != %@ && ics214Effort == %@ && ics214EffortMaster == YES && ics214Completed != YES","","Local Incident")
            fetchRequest.predicate = predicate
            
            
            do {
                fetchedICS241 = try context.fetch(fetchRequest) as! [ICS214Form]
                if fetchedICS241.count != 0 {
                    for ics214F:ICS214Form in fetchedICS241 {
                        var name = ""
                        var master = ""
                        let masterYes:String = "yes"
                        var guid = ""
                        var fromTime = ""
                        var toTime = ""
                        var imageName = ""
                        var teamName = ""
                        var type:String = ""
                        var incidentNumber:String = ""
                        //                        let formType = "Local Incident"
                        imageName = "ICS 214 Form LOCAL INCIDENT"
                        type = TypeOfForm.incidentForm.rawValue
                        var isDateHere:String = ""
                        if ics214F.ics214LocalIncidentNumber != nil {
                            incidentNumber = ics214F.ics214LocalIncidentNumber!
                        }
                        if ics214F.ics214IncidentName != nil {
                            name = ics214F.ics214IncidentName!
                        }
                        if ics214F.ics214MasterGuid != nil {
                            master = ics214F.ics214MasterGuid!
                        }
                        if ics214F.incidentGuid != nil {
                            guid = ics214F.incidentGuid!
                        }
                        if ics214F.ics214FromTime != nil {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                            let dateFrom = dateFormatter.string(from: ics214F.ics214FromTime! as Date)
                            fromTime = dateFrom
                        }
                        if ics214F.ics214ToTime != nil {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                            let dateFrom = dateFormatter.string(from: ics214F.ics214ToTime! as Date)
                            toTime = dateFrom
                        }
                        if ics214F.ics214TeamName != nil {
                            teamName = ics214F.ics214TeamName!
                        }
                        
                        var i45:CellParts!
                        isDateHere = "no"
                        i45 = CellParts.init(cellAttributes: ["Header":name , "Field1":master , "Field2":guid, "Field3":fromTime,"Field4":toTime,"Value1":imageName,"Value2":type,"Value3":masterYes,"Value4":isDateHere,"Value5":type,"Value6":teamName,"Value7":incidentNumber], type: ["Type": FormType.incidentMasterCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":nil ])
                        
                        modalCells.append(i45)
                    }
                    
                    turnMasterOn = true
                    tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                }
            } catch {
                
                let nserror = error as NSError
                
                let errorMessage = "NewICS214ModalTVC theSearchButtonTapped() fetchRequest \(fetchRequest) Unresolved error \(nserror)"
                
                print(errorMessage)
                
            }
        }
        
    }
    
    func grabAllMasters(entityName: String, typeOfForm: String) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName )
        var predicate = NSPredicate.init()
        let master:Bool = true
        predicate = NSPredicate(format: "ics214Effort CONTAINS %@ && ics214EffortMaster == %@  && ics214Completed != YES",typeOfForm,NSNumber(value:master))
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            fetchedICS241 = try context.fetch(fetchRequest) as! [ICS214Form]
            if fetchedICS241.count != 0 {
                for ics214Form:ICS214Form in fetchedICS241 {
                    var name = ""
                    var master = ""
                    let masterYes:String = "yes"
                    var guid = ""
                    var fromTime = ""
                    var toTime = ""
                    var imageName = ""
                    var teamName = ""
                    var type:String = ""
                    if typeOfForm == "FEMA Task Force" {
                        imageName = "ICS214FormFEMA"
                        type = TypeOfForm.femaTaskForceForm.rawValue
                    } else if typeOfForm == "Strike Team" {
                        imageName = "ICS214FormSTRIKETEAM"
                        type = TypeOfForm.strikeForceForm.rawValue
                    } else if typeOfForm == "Other" {
                        imageName = "ICS214FormOTHER"
                        type = TypeOfForm.otherForm.rawValue
                    }
                    
                    var isDateHere:String = ""
                    if ics214Form.ics214IncidentName != nil {
                        name = ics214Form.ics214IncidentName!
                    }
                    if ics214Form.ics214MasterGuid != nil {
                        master = ics214Form.ics214MasterGuid!
                    }
                    if ics214Form.journalGuid != nil {
                        guid = ics214Form.journalGuid!
                    }
                    if ics214Form.ics214FromTime != nil {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                        let dateFrom = dateFormatter.string(from: ics214Form.ics214FromTime! as Date)
                        fromTime = dateFrom
                    }
                    if ics214Form.ics214ToTime != nil {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                        let dateFrom = dateFormatter.string(from: ics214Form.ics214ToTime! as Date)
                        toTime = dateFrom
                    }
                    if ics214Form.ics214TeamName != nil {
                        teamName = ics214Form.ics214TeamName!
                    }
                    
                    let objectID = ics214Form.objectID
                    
                    var i45:CellParts!
                    isDateHere = "no"
                    i45 = CellParts.init(cellAttributes: ["Header":name , "Field1":master , "Field2":guid, "Field3":fromTime,"Field4":toTime,"Value1":imageName,"Value2":type,"Value3":masterYes,"Value4":isDateHere,"Value5":type,"Value6":teamName], type: ["Type": FormType.incidentMasterCell], vType: ["Value1":ValueType.fjKEmpty,"Value2":ValueType.fjKEmpty,"Value3":ValueType.fjKEmpty,"Value4":ValueType.fjKEmpty,"Value5":ValueType.fjKEmpty],dType:["Activity":Date()], objID: [ "objectID":objectID])
                    
                    modalCells.append(i45)
                }
                
                turnMasterOn = true
                tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            }
            
        } catch {
            
            let nserror = error as NSError
            
            let errorMessage = "NewICS214ModalTVC grabAllMasters() fetchRequest \(fetchRequest) Unresolved error \(nserror)"
            
            print(errorMessage)
            
        }
    }
    
    func theNewIncidentButtonTapped() {
        print("hey why are you not responding!?")
//        let storyBoard : UIStoryboard = UIStoryboard(name: "ICS214Form", bundle:nil)
//        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "NewICS214NewIncidentTVC") as! NewICS214NewIncidentTVC
//        modalTVC.delegate = self
//        modalTVC.transitioningDelegate = slideInTransitioningDelgate
//        modalTVC.modalPresentationStyle = .custom
//        self.present(modalTVC, animated: true, completion: nil)
        performSegue(withIdentifier: NewICS214NewIncidentTVCSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == NewICS214TVCSegue {
            let modalTVC:NewICS214TVC = segue.destination as! NewICS214TVC
               modalTVC.delegate = self
               modalTVC.masterOrNot = masterOrNot
               modalTVC.incidentObjId = incidentObjectID
               modalTVC.teamName = teamName
               modalTVC.transitioningDelegate = slideInTransitioningDelgate
           } else if segue.identifier == NewICS214NewIncidentTVCSegue {
                let detailTVC:NewICS214NewIncidentTVC = segue.destination as! NewICS214NewIncidentTVC
                detailTVC.delegate = self
            }
       }
    
    
    
    func newFormWithTwoStrings(type: TypeOfForm, name1: String, name2: String) {
        
    }
    
    func typeChosen(type: Int) {
        section1 = false;
        firstOrMore = true;
        formType = type
        showJournal = false
        if(formType == 1) {
            masterOrNot = false
            tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
        } else {
            masterOrNot = true
            tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowTheForm" {
//
//
//            //                var modalNavigationController:UINavigationController = UINavigationController(rootViewController: modalTVC)
//            //                modalNavigationController.modalPresentationStyle = .formSheet
//            //                modalNavigationController = segue.destination as! UINavigationController
//
//        }
//    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("here is fetch ics \(fetchedICS241.count) \(fetchedICS241)and here is fetchedincident count \(fetchedIncident.count) plus 7")
        
        if fetchedIncident.count == 0 && fetchedICS241.count == 0 {
            if showPicker {
                return 8
            } else {
                return 7
            }
        } else {
            print("here is the count to return \(fetchedIncident.count+fetchedICS241.count+7)")
            return fetchedIncident.count+fetchedICS241.count+7
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
//            cell.contentView.backgroundColor = UIColor(patternImage: UIImage(named:"header")!)
        }
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let type:CellParts = modalCells[indexPath.row]
        let cellType:FormType = type.type["Type"]!
        
        switch cellType {
        case .modalHeader:
            return 100
        case .paragraphCell:
            if section1 {
                if Device.IS_IPHONE {
                    return 480
                } else {
                    return 450
                }
            } else {
                return 0
            }
        case .formSegmentCell:
            if section1 {
                return 135
            } else {
                return 0
            }
        case .fourSwitchCell:
            if firstOrMore {
                if Device.IS_IPHONE {
                    return 660
                } else {
                    return 600
                }
            } else {
                return 0
            }
        case .efforWithDateCell:
            if incidentOnOrOff {
                return 250
            } else {
                return 0
            }
        case .effortWithoutDateCell:
            if masterOrNot {
                if effortType {
                    return 250
                } else {
                    return 0
                }
            } else {
                return 0
            }
        case .effortWithoutDateCellAddress:
            if masterOrNot {
                if effortType {
                    return 200
                } else {
                    return 0
                }
            } else {
                return 0
            }
        case .theMapCell:
            if masterOrNot {
                if effortType {
                   return 700
                } else {
                    return 0
                }
            } else {
                return 0
            }
        case .journalMasterCell:
            if masterOrNot {
                return 0
            } else {
                if showJournal {
                    return 100
                } else {
                    return 0
                }
            }
        case .incidentMasterCell:
            if incidentOnOrOff || turnMasterOn {
                return 66
            } else {
                return 0
            }
        case .pickerDateCell:
            return  215
        default:
            return 44
        }
    }
    
    func findTheLastMaster()->String {
        var formTyped:String = ""
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Form" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "ics214EffortMaster == YES")
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        //        let sortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: false)
        //        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let fetched = try context.fetch(fetchRequest) as! [ICS214Form]
            if fetched.count != 0 {
                let form:ICS214Form = fetched.last!
                if form.ics214Effort != nil {
                    formTyped = form.ics214Effort!
                }
            }
        } catch {
            
            let nserror = error as NSError
            
            let errorMessage = "NewICS214ModalTVC findTheLastMaster() fetchRequest \(fetchRequest) Unresolved error \(nserror)"
            
            print(errorMessage)
            
        }
        return formTyped
    }
    
    //    MARK: -CellHeaderCancelSaveDelegate
    func cellCancelled() {
        delegate?.theCancelCalledOnNewICS214Modal()
    }
    
    func cellSaved() {
        //        <#code#>
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellHeader = Bundle.main.loadNibNamed("CellHeaderCancelSave", owner: self, options: nil)?.first as! CellHeaderCancelSave
        cellHeader.headerTitleL.isHidden = true
        cellHeader.headerTitleL.alpha = 0.0
        cellHeader.saveB.isHidden = true
        cellHeader.saveB.alpha = 0.0
        cellHeader.delegate = self
        return cellHeader
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type:CellParts = modalCells[indexPath.row]
        let cellType:FormType = type.type["Type"]!
        let aDateType:Date = type.dType["Activity"]!
        var objectID:NSManagedObjectID? = nil
        if type.objID["objectID"] != nil {
            objectID = type.objID["objectID"] as? NSManagedObjectID
        }
        let header:String = type.cellAttributes["Header"]!
        let field1:String = type.cellAttributes["Field1"]!
        let field2:String = type.cellAttributes["Field2"]!
        let field3:String = type.cellAttributes["Field3"]!
        let field4:String = type.cellAttributes["Field4"]!
        let field5:String = type.cellAttributes["Value1"]!
        let field6:String = type.cellAttributes["Value4"]!
        let field7:String = type.cellAttributes["Value3"]!
        let field8:String = type.cellAttributes["Value5"]!
        var field9:String = ""
        var field10:String = ""
        if let incidentNumber = type.cellAttributes["Value7"] {
            field10 = incidentNumber
        }
        if let team = type.cellAttributes["Value6"] {
            field9 = team
        }
        let row = indexPath.row
        if field8 != "" {
            print("\(row) here is field 8 \(field8) and here is the type \(cellType)")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        let dateFrom = dateFormatter.string(from: aDateType)
        if !masterOrNot {
            formMaster = findTheLastMaster()
        }
        switch cellType {
        case .modalHeader:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModalHeaderCell", for: indexPath) as! ModalHeaderCell
            return cell
        case .paragraphCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParagraphCell", for: indexPath) as! ParagraphCell
            if !(section1) {
                cell.isHidden = true
            }
            return cell
        case .formSegmentCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormSegmentCell", for: indexPath) as! FormSegmentCell
            cell.delegate = self
            if !(section1) {
                cell.isHidden = true
            }
            return cell
        case .fourSwitchCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FourSwitchCell", for: indexPath) as! FourSwitchCell
            cell.delegate = self
            if !(firstOrMore) {
                cell.isHidden = true
            } else {
                if formType == 1 {
                    cell.masterOrMore = false
                } else {
                    cell.masterOrMore = true
                }
                
                if masterOrNot {
                    cell.localIncidentSwitch.setOn(true, animated: false)
                    cell.strikeTeamSwitch.setOn(false, animated: false)
                    cell.femaTaskForceSwitch.setOn(false, animated:false)
                    cell.otherSwitch.setOn(false, animated: false)
                    cell.localIncidentMasterIV.isHidden = true
                    cell.femaMasterIV.isHidden = true
                    cell.strikeTeamMasterIV.isHidden = true
                    cell.otherMasterIV.isHidden = true
                    cell.instructionL.text = "When you select FIRST FORM, you’ll be able to record a series of ICS-214s as individual operational period journals, all linked to the same incident. Once you “close out” the last operational period for thta incident, Fire Journal will be ready to start another sequence. Note that below you have four different types of deployments to link your ICS-214 to. Select the one that’s appropriate for your deployment."
                } else {
                    cell.localIncidentSwitch.setOn(false, animated: false)
                    cell.strikeTeamSwitch.setOn(false, animated: false)
                    cell.femaTaskForceSwitch.setOn(false, animated:false)
                    cell.otherSwitch.setOn(false, animated: false)
                    cell.localIncidentMasterIV.isHidden = true
                    cell.femaMasterIV.isHidden = true
                    cell.strikeTeamMasterIV.isHidden = true
                    cell.otherMasterIV.isHidden = true
                    cell.instructionL.text = "Remember, you will have the option of sharing completed ICS-214 reports either electronically via PDF, or in print form, both appearing in the standard NIMS form [ Membership required for sharing ]."
                    if formMaster == "FEMA Task Force" {
                        cell.femaMasterIV.isHidden = false
                        cell.femaTaskForceSwitch.setOn(true, animated:false)
                        cell.type = TypeOfForm.femaTaskForceForm.rawValue
                    } else if formMaster == "Local Incident" {
                        cell.localIncidentMasterIV.isHidden = false
                        cell.localIncidentSwitch.setOn(true, animated: false)
                        cell.type = TypeOfForm.incidentForm.rawValue
                    } else if formMaster == "Strike Team" {
                        cell.strikeTeamMasterIV.isHidden = false
                        cell.strikeTeamSwitch.setOn(true, animated: false)
                        cell.type = TypeOfForm.strikeForceForm.rawValue
                    } else if formMaster == "Other" {
                        cell.otherMasterIV.isHidden = false
                        cell.otherSwitch.setOn(true, animated: false)
                        cell.type = TypeOfForm.otherForm.rawValue
                    }
                    cell.masterOrMore = false
                }
            }
            return cell
        case .efforWithDateCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EffortWithDateCell", for: indexPath) as! EffortWithDateCell
            cell.delegate = self
            if !(incidentOnOrOff) {
                cell.isHidden = true
            } else {
                cell.titleL.text = "Local Incident:"
                
                if masterOrNot {
                    cell.instructionL.text = "Click the search button if you would like to see the entire list of Incidents in your app, to choose as the Incident you wish to associate with this Local Incident ICS 214. The list of Incidents are clickable and when tapped will move you forward with that Incident marked as the First Form Local Incident Incident Name. If the Incident hasn't been entered before you can create the Incident before moving forward."
                } else {
                    cell.newIncidentB.isHidden = true
                    cell.instructionL.text = "Click the search button if you would like to see the entire list of First Form Local Incident ICS 214 to associate this additional Local Incident ICS 214 form. The list of Incidents are clickable and when tapped will move you forward with that incident marked as associated with the First Form Local Incident Incident Name."
                }
            }
            dateWords = ""
            return cell
        case .effortWithoutDateCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EfforWithoutDateCell", for: indexPath) as! EfforWithoutDateCell
            cell.delegate = self
            if !(effortType) {
                cell.isHidden = true
            } else {
                if strikeOnOrOff {
                    cell.titleL.text = "Strike Team:"
                    cell.question1L.text = "Name of Strike Team:"
                    cell.question2L.text = "Name of Incident:"
                    cell.type = TypeOfForm.strikeForceForm
                    cell.instructionL.text = "Enter the Strike Team Name and Incident Name to move forward in creating the First Form ICS 214 form."
                }
                if femaOnOrOff {
                    cell.titleL.text = "FEMA Task Force"
                    cell.question1L.text = "Name of FEMA Task Force:"
                    cell.question2L.text = "Name of Event:"
                    cell.type = TypeOfForm.femaTaskForceForm
                    cell.instructionL.text = "Enter the FEMA Task Force Team Name and Name of the FEMA Event to associate with this First Form ICS 214 form."
                }
                if otherOnOrOff {
                    cell.titleL.text = "Other"
                    cell.question1L.text = "Name of Event Type:"
                    cell.question2L.text = "Name of Event:"
                    cell.type = TypeOfForm.otherForm
                    cell.instructionL.text = "Enter the type of event this is and the name of the event you want to associate with this First Form ICS 214 form."
                }
            }
            return cell
        case .journalMasterCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "JournalMasterCell", for: indexPath) as! JournalMasterCell
            if showJournal {
                if strikeOnOrOff {
                    cell.titleL.text = "Choose A Strike Team Master:"
                    cell.instructionL.text = "The list below is a list of All open Master Strike Team Events. Choose one by tapping on it and we'll move forward to creating an additional form associated with this Master Strike Team Event."
                }
                if femaOnOrOff {
                    cell.titleL.text = "Choose A FEMA Task Force Master:"
                    cell.instructionL.text = "The list below is a list of All open Master FEMA Task Force Events. Choose one by tapping on it and we'll move forward to creating an additional form associated with this Master FEMA Task Force Event."
                }
                if otherOnOrOff {
                    cell.titleL.text = "Choose An Other Form Master:"
                    cell.instructionL.text = "The list below is a list of All open Master Other Events. Choose one by tapping on it and we'll move forward to creating an additional form associated with this Master Other Event."
                }
            } else {
                cell.isHidden = true
            }
            return cell
        case .incidentMasterCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncidentMasterCell", for: indexPath) as! IncidentMasterCell
            let row = indexPath.row
            print("HERE IS THE INDEX PATH FOR THE MASTER \(row)")
            if field8 == TypeOfForm.incidentForm.rawValue {
                if !masterOrNot {
                    cell.titleL.text = "Local Incident: \(header)"
                    cell.incidentAddressL.text = "From Time: \(field3)"
                    cell.incidentTimeL.text = "To Time: \(field4)"
                    
                    cell.incidentIV.image = UIImage(named:"ics214")
                    cell.obID = objectID
                    cell.incidentGuid = field2
                    cell.incidentName = header
                    cell.masterGuid = field1
                    if field9 != "" {
                        cell.teamName = field9
                    }
                    if field10 != "" {
                        cell.incidentNumber = field10
                    }
                } else {
                    cell.titleL.text = "Incident #\(field10)"
                    cell.incidentAddressL.text = "Address \(field3) \(field4) \(field5)"
                    if field6 == "yes" {
                        cell.incidentTimeL.text = dateFrom
                    } else {
                        cell.incidentTimeL.text = ""
                    }
                    cell.incidentIV.image = UIImage(named:field7)
                    
                    cell.incidentGuid = field2
                    cell.incidentNumber = header
                    cell.masterGuid = field1
                    cell.obID = objectID
//                    print(cell)
                }
            } else {
                if field8 == TypeOfForm.femaTaskForceForm.rawValue {
                    cell.titleL.text = "Fema: \(header)"
                } else if field8 == TypeOfForm.strikeForceForm.rawValue {
                    cell.titleL.text = "Strike Team: \(header)"
                } else if field8 == TypeOfForm.otherForm.rawValue {
                    cell.titleL.text = "\(header)"
                }

                cell.masterGuid = field1
                cell.obID = objectID
                cell.incidentAddressL.text = "From Time: \(field3)"
                cell.incidentTimeL.text = "To Time: \(field4)"
                
                cell.incidentIV.image = UIImage(named:field5)
                
                cell.incidentGuid = field2
                cell.incidentNumber = header
                cell.masterGuid = field1
                if field9 != "" {
                    cell.teamName = field9
                }
            }
            if field8 == TypeOfForm.femaTaskForceForm.rawValue {
                cell.type = TypeOfForm.femaTaskForceForm
            }else if field8 == TypeOfForm.incidentForm.rawValue {
                cell.type = TypeOfForm.incidentForm
            }else if field8 == TypeOfForm.strikeForceForm.rawValue {
                cell.type = TypeOfForm.strikeForceForm
            }else if field8 == TypeOfForm.otherForm.rawValue {
                cell.type = TypeOfForm.otherForm
            }
            return cell
        case .pickerDateCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormDatePickerCell", for: indexPath) as! FormDatePickerCell
            cell.delegate = self
            cell.type = false
            cell.activity = "Incident"
            return cell
        case .theMapCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EffortSetUpCell", for: indexPath) as! EffortSetUpCell
            if !(effortType) {
                cell.isHidden = true
            } else {
                cell.delegate = self
                cell.titleLabelTwoL.text = "Address"
                if strikeOnOrOff {
                    cell.titleLabelOne.text = "Strike Team:"
                    cell.questionOneL.text = "Name of Strike Team:"
                    cell.questionTwoL.text = "Name of Incident:"
                    cell.type = TypeOfForm.strikeForceForm
                    cell.descriptionTV.text = "Enter the Strike Team Name and Incident Name to move forward in creating the First Form ICS 214 form."
                }
                if femaOnOrOff {
                    cell.titleLabelOne.text = "FEMA Task Force"
                    cell.questionOneL.text = "Name of FEMA Task Force:"
                    cell.questionTwoL.text = "Name of Event:"
                    cell.type = TypeOfForm.femaTaskForceForm
                    cell.descriptionTV.text = "Enter the FEMA Task Force Team Name and Name of the FEMA Event to associate with this First Form ICS 214 form."
                }
                if otherOnOrOff {
                    cell.titleLabelOne.text = "Other"
                    cell.questionOneL.text = "Name of Event Type:"
                    cell.questionTwoL.text = "Name of Event:"
                    cell.type = TypeOfForm.otherForm
                    cell.descriptionTV.text = "Enter the type of event this is and the name of the event you want to associate with this First Form ICS 214 form."
                }
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        print("here is the index path selection \(indexPath.row)")
        switch row {
        case 0, 1, 2, 3, 4, 5, 6 : break
        default:
            let cellChecked = tableView.cellForRow(at: indexPath) as! IncidentMasterCell
            guid = cellChecked.incidentGuid!
            masterGuid = cellChecked.masterGuid!
            type = cellChecked.type
            incidentGuid = cellChecked.incidentGuid!
            incidentNumber = cellChecked.incidentNumber
//            let ics214IncidentOjbID = cellChecked.obID
            
            
            
            
            //            let segue = "showNewForm"
            //            performSegue(withIdentifier: segue, sender: self)
            //            print("here is thew guid\(guid)")
            
//            var _:NSManagedObjectID!
            if cellChecked.obID != nil {
                incidentObjectID = cellChecked.obID
                buildTheNewICS214Form(objectID: incidentObjectID,master: masterOrNot)
            }
            
//            modalTVC.incidentObjId = ics214IncidentOjbID
//            if !masterOrNot {
//                modalTVC.masterGuid = masterGuid!
//                modalTVC.incidentGuid = incidentGuid!
//            }
//            if journalGuid != nil {
//                modalTVC.journalGuid = journalGuid!
//            }
//
//            var formType:String = ""
//            var name:String = ""
//
//            if type == TypeOfForm.incidentForm {
//                formType = "Local Incident"
//                if cellChecked.incidentName != nil {
//                    name = cellChecked.incidentName!
//                }
//            } else if type == TypeOfForm.femaTaskForceForm {
//                formType = "FEMA Task Force"
//                name = incidentNumber!
//                modalTVC.teamName = cellChecked.teamName!
//                if guid != nil {
//                    modalTVC.journalGuid = guid
//                }
//            } else if type == TypeOfForm.strikeForceForm {
//                formType = "Strike Team"
//                name = incidentNumber!
//                modalTVC.teamName = cellChecked.teamName!
//                if guid != nil {
//                    modalTVC.journalGuid = guid
//                }
//            } else if type == TypeOfForm.otherForm {
//                formType = "Other"
//                name = incidentNumber!
//                modalTVC.teamName = cellChecked.teamName!
//                if guid != nil {
//                    modalTVC.journalGuid = guid
//                }
//            }
//            modalTVC.incidentNumber = incidentNumber
//            modalTVC.incidentName = name
//            modalTVC.formType = formType
//            modalTVC.masterOrNot = masterOrNot
//            if incidentGuid != nil {
//                modalTVC.incidentGuid = incidentGuid
//            }
//
//            modalTVC.delegate = self
//            modalTVC.titled = "\(formType) ICS 214 Form"
            break
        }
    }
    
    func buildTheNewICS214Form(objectID: NSManagedObjectID,master: Bool) {
//        let storyBoard : UIStoryboard = UIStoryboard(name: "ICS214Form", bundle:nil)
//        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "NewICS214TVC") as! NewICS214TVC
//        modalTVC.delegate = self
//        modalTVC.masterOrNot = master
//        modalTVC.incidentObjId = objectID
//        modalTVC.teamName = teamName
//        modalTVC.transitioningDelegate = slideInTransitioningDelgate
//        modalTVC.modalPresentationStyle = .custom
//        self.present(modalTVC, animated: true, completion: nil)
        performSegue(withIdentifier: NewICS214TVCSegue, sender: self)
    }
    
}

extension NewICS214ModalTVC: NewICS214Delegate {
    
    func theICS214FormCancelled() {
//        nc.post(name:Notification.Name(rawValue:notificationKeyICS4), object: nil)
        delegate?.theCancelCalledOnNewICS214Modal()
    }
    
}
