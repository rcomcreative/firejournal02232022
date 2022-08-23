    //
    //  ICS214Provider.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 7/12/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import CoreData
import CloudKit

class ICS214Provider: NSObject, NSFetchedResultsControllerDelegate  {
    
    private(set) var persistentContainer: NSPersistentContainer
    var ckRecord: CKRecord!
    var theICS214: ICS214Form!
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    var context: NSManagedObjectContext!
    let nc = NotificationCenter.default
    var theICS214R: CKRecord!
    let calendar = Calendar.current
    
    private var fetchedResultsController: NSFetchedResultsController<ICS214Form>? = nil
    var _fetchedResultsController: NSFetchedResultsController<ICS214Form> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    deinit {
        print("ICS214Provider is being deinitialized")
    }
    
    var fetchedObjects: [ICS214Form] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.privateDatabase = myContainer.privateCloudDatabase
        super.init()
    }
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func determineTheICS214Image(type: TypeOfForm) -> String {
        var imageName: String = ""
        switch type {
        case .incidentForm:
            imageName = "ICS_214_Form_LOCAL_INCIDENT"
        case .strikeForceForm:
            imageName = "ICS214FormSTRIKETEAM"
        case .femaTaskForceForm:
            imageName = "ICS214FormFEMA"
        case .otherForm:
            imageName = "ICS214FormOTHER"
        }
        return imageName
    }
    
    func determineTheICS214EffortType(type: TypeOfForm) -> String {
        var effortType: String = ""
        switch type {
        case .incidentForm:
            effortType = "Local Incident"
        case .strikeForceForm:
            effortType = "String Team"
        case .femaTaskForceForm:
            effortType = "FEMA Task Force"
        case .otherForm:
            effortType = "Other"
        }
        return effortType
    }
    
    func determineTheICS214StringDate(theDate: Date) -> String {
        var aDate: String = ""
        let theComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: theDate)
        let m = theComponents.month!
        let y = theComponents.year!
        let d = theComponents.day!
        let h = theComponents.hour!
        let min = theComponents.minute!
        
        let month = m < 10 ? "0\(m)" : String(m)
        let day = d < 10 ? "0\(d)" : String(d)
        let year = String(y)
        let hour = h < 10 ? "0\(h)" : String(h)
        let minute = min < 10 ? "0\(min)" : String(min)
        aDate = month + "/" + day + "/" + year + " " + hour + ":" + minute + "HR"
        return aDate
    }
    
    func determineICS214TypeFromString(theType: String) -> TypeOfForm {
        
        var typeOfForm: TypeOfForm!
        if theType == "incidentForm" {
            typeOfForm = TypeOfForm.incidentForm
        } else if theType == "femaTaskForceForm" {
            typeOfForm = TypeOfForm.femaTaskForceForm
        } else if theType == "strikeForceForm" {
            typeOfForm = TypeOfForm.strikeForceForm
        } else if theType == "otherForm" {
            typeOfForm = TypeOfForm.otherForm
        } else {
            typeOfForm = TypeOfForm.incidentForm
        }
        
        return typeOfForm
    }
    
    func getTheInCompleteMasterICS214(_ context: NSManagedObjectContext) -> [ICS214Form]? {
        let fetchRequest: NSFetchRequest<ICS214Form> = ICS214Form.fetchRequest()

        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "ics214EffortMaster == %@", NSNumber(value: true ))
        var predicate2 = NSPredicate.init()
        predicate2 = NSPredicate(format: "ics214Completed == %@", NSNumber(value: false ))

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("ICS214Provider line 115 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
    func getTheMasterListICS214(_ context: NSManagedObjectContext, thetype: TypeOfForm) -> [ICS214Form]? {
        let fetchRequest: NSFetchRequest<ICS214Form> = ICS214Form.fetchRequest()

        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "ics214EffortMaster == %@", NSNumber(value: true ))
        var predicate2 = NSPredicate.init()
        predicate2 = NSPredicate(format: "ics214Completed == %@", NSNumber(value: false ))
        var predicate3 = NSPredicate.init()
        switch thetype {
        case .incidentForm:
            predicate3 = NSPredicate(format: "ics214Effort == %@", "incidentForm")
        case .strikeForceForm:
            predicate3 = NSPredicate(format: "ics214Effort == %@", "strikeForceForm")
        case .femaTaskForceForm:
            predicate3 = NSPredicate(format: "ics214Effort == %@", "femaTaskForceForm")
        case .otherForm:
            predicate3 = NSPredicate(format: "ics214Effort == %@", "otherForm")
        }

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2,predicate3])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214FromTime", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("ICS214Provider line 115 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
    func singleICSFromTheCloud(ckRecord: CKRecord, dateFormatter: DateFormatter,_ ics214: ICS214Form, _ context: NSManagedObjectContext, completionHandler: (() -> Void)? = nil) {
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        self.context = context
        self.theICS214R = ckRecord
        self.theICS214 = ics214
        
        self.theICS214.ics214Count = theICS214R["ics214Count"] ?? 0
        
        
            // MARK: -BOOLEANS
        
        self.theICS214.ics214BackedUp = true
        
        
        if let ics214Completed = theICS214R["ics214Completed"]as? Double {
            self.theICS214.ics214Completed  = Bool(truncating: ics214Completed as NSNumber)
        }
        
        if let ics214EffortMaster = theICS214R["ics214EffortMaster"]as? Double {
            self.theICS214.ics214EffortMaster  = Bool(truncating: ics214EffortMaster as NSNumber)
        }
        
        if let ics214SignatureAdded = theICS214R["ics214SignatureAdded"]as? Double {
            self.theICS214.ics214SignatureAdded  = Bool(truncating: ics214SignatureAdded as NSNumber)
        }
        
        if let ics214Updated = theICS214R["ics214Updated"]as? Double {
            self.theICS214.ics214Updated  = Bool(truncating: ics214Updated as NSNumber)
        }
        
        
            // MARK: -Dates
        if let comp = theICS214R["ics214CompletionDate"] as? Date {
            self.theICS214.ics214CompletionDate = comp
        }
        if let from = theICS214R["ics214FromTime"] as? Date {
            self.theICS214.ics214FromTime = from
        }
        if let modDate = theICS214R["ics214ModDate"] as? Date {
            self.theICS214.ics214ModDate = modDate
        }
        if let sigDate = theICS214R["ics214SignatureDate"] as? Date {
            self.theICS214.ics214SignatureDate = sigDate
        }
        if let toTime = theICS214R["ics214ToTime"] as? Date {
            self.theICS214.ics214ToTime = toTime
        }
        if let lat = theICS214R["ics214Latitude"] as? String {
            self.theICS214.ics214Latitude = lat
        }
        if let long = theICS214R["ics214Longitude"] as? String  {
            self.theICS214.ics214Longitude = long
        }
            // MARK: -Asset
        if self.theICS214.ics214SignatureAdded {
            if theICS214R["ics214Signature"] as? CKAsset != nil {
                self.theICS214.ics214Signature = imageDataFromCloudKit(asset: theICS214R["ics214Signature"]!)
            }
        }
            // MARK: -Strings
        if let effort = theICS214R["ics214Effort"] as? String  {
            self.theICS214.ics214Effort = effort
        }
        if let guid = theICS214R["ics214Guid"] as? String  {
            self.theICS214.ics214Guid = guid
        }
        if let position = theICS214R["ics214ICSPosition"] as? String  {
            self.theICS214.ics214ICSPosition = position
        }
        if let incName = theICS214R["ics214IncidentName"] as? String  {
            self.theICS214.ics214IncidentName = incName
        }
        if let incNum = theICS214R["ics214LocalIncidentNumber"] as? String  {
            self.theICS214.ics214LocalIncidentNumber = incNum
        }
        if let masterGuid = theICS214R["ics214MasterGuid"] as? String  {
            self.theICS214.ics214MasterGuid = masterGuid
        }
        if let positionType = theICS214R["ics214PositionType"]  as? String  {
            self.theICS214.ics214PositionType = positionType
        }
        if let teamName = theICS214R["ics214TeamName"] as? String  {
            self.theICS214.ics214TeamName = teamName
        }
        if let userName = theICS214R["ics214UserName"] as? String  {
            self.theICS214.ics214UserName = userName
        }
        if let homeAgency = theICS214R["ics241HomeAgency"] as? String  {
            self.theICS214.ics241HomeAgency = homeAgency
        }
        if let preparedPosition = theICS214R["icsPreparedPosition"] as? String  {
            self.theICS214.icsPreparedPosition = preparedPosition
        }
        if let preparedName = theICS214R["icsPreparfedName"] as? String  {
            self.theICS214.icsPreparfedName = preparedName
        }
        if let incGuid = theICS214R["incidentGuid"] as? String  {
            self.theICS214.incidentGuid = incGuid
        }
        if let journalGuid = theICS214R["journalGuid"] as? String  {
            self.theICS214.journalGuid = journalGuid
        }
        
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        theICS214R.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.theICS214.ics214CKR = data as NSObject
        
        saveTheSingleCD() {_ in
            completionHandler?()
        }
        
    }
    
    func imageDataFromCloudKit(asset: CKAsset) -> Data {
        var data: Data!
        do {
            data = try Data(contentsOf: asset.fileURL!)
            return data
        } catch {
            print("error in return image f")
        }
        return data
    }
    
    private func saveTheSingleCD(withCompletion completion: @escaping (String) -> Void) {
        if self.context != nil {
            do {
                try self.context?.save()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Incident Saved"])
                    print("project we have saved to the cloud")
                }
                completion("Success")
            } catch {
                let nserror = error as NSError
                
                let error = "The ProjectProvider context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
                print(error)
                completion("Error")
            }
        }
    }
    
    
    
}
