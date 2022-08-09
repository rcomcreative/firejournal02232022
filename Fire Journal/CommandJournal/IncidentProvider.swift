//
//  IncidentProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/22/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//
import UIKit
import CoreData
import CloudKit

class IncidentProvider: NSObject, NSFetchedResultsControllerDelegate {
    
    var fjUserTime: UserTime!
    let calendar = Calendar.init(identifier: .gregorian)
    
    var month: String = ""
    var day: String = ""
    var year: String = ""
    var hour: String = ""
    var minute: String = ""
    
    var firstDate: Date!
    var endDate: Date!
    
    var yearCInt: Int!
    var monthCInt: Int!
    
    
    var ckRecord: CKRecord!
    var theIncidentTagCKRecords = [CKRecord]()
    var theIncidentTag: IncidentTags!
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    var context: NSManagedObjectContext!
    let nc = NotificationCenter.default
    
    private var fetchedResultsController: NSFetchedResultsController<Incident>? = nil
    var _fetchedResultsController: NSFetchedResultsController<Incident> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    var fetchedObjects: [Incident] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    private(set) var persistentContainer: NSPersistentContainer
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.privateDatabase = myContainer.privateCloudDatabase
        super.init()
    }
    
    deinit {
        nc.removeObserver(NSNotification.Name.NSManagedObjectContextDidSave)
        print("IncidentProvider is being deinitialized")
    }
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func getTodaysIncidents(context: NSManagedObjectContext, userTime: UserTime ) -> [Incident]? {
        self.context = context
        var theIncidents = [Incident]()
        theIncidents = buildIncidentsWithUserTime(userTime)
//        if let startDate = userTime.userStartShiftTime {
//            _ = buildTheDay(startDate)
//            if let completeDate = userTime.userEndShiftTime {
//             _ = buildTheEndDate(completeDate)
//            }
//            if endDate == nil {
//                endDate = Date()
//            }
//            _ = getTheDaysIncidents(firstDate, endDate, context: self.context)
//            theIncidents = fetchedObjects
//        } else {
//            return nil
//        }
        return theIncidents
    }
    
    private func buildIncidentsWithUserTime(_ theUserTime: UserTime) -> [Incident]{
        guard let incidents = theUserTime.incident?.allObjects as? [Incident] else {
            return [Incident]()
        }
        let theIncidents = incidents.sorted { $0.incidentCreationDate! > $1.incidentCreationDate! }
        return theIncidents
    }
    
        /// Build the end shift date from UserTime.usereEndShifttime
        /// - Parameter theCompleteDate: theEndShiftDate date
        /// - Returns: date to compare for incidents of shift
    private func buildTheEndDate(_ theCompleteDate: Date) -> Date {
        
        let theComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: theCompleteDate)
        let m = theComponents.month!
        let y = theComponents.year!
        let d = theComponents.day!
        let h = theComponents.hour!
        let min = theComponents.minute!
        
        month = m < 10 ? "0\(m)" : String(m)
        day = d < 10 ? "0\(d)" : String(d)
        year = String(y)
        hour = String(h)
        minute = String(min)
        
//        let firstDay = "2020-05-27T23:59:00+0000"
        let firstDay = "\(year)-\(month)-\(day)T\(hour):\(minute):00+0000"
        let dateFormatter = ISO8601DateFormatter()
        endDate = dateFormatter.date(from: firstDay)
        return endDate
        
    }
    
        /// Build the start of the shift date from UserTime.userStartShifttime
        /// - Parameter theNewShiftDate: date
        /// - Returns: date to find all incidents dates greater than date returned
    private func buildTheDay(_ theNewShiftDate: Date ) -> Date {
       
        let theComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: theNewShiftDate)
        let m = theComponents.month!
        let y = theComponents.year!
        let d = theComponents.day!
        let h = theComponents.hour!
        let min = theComponents.minute!
        
        month = m < 10 ? "0\(m)" : String(m)
        day = d < 10 ? "0\(d)" : String(d)
        year = String(y)
        hour = String(h)
        minute = String(min)
        
        let firstDay = "\(year)-\(month)-\(day)T\(hour):\(minute):00+0000"
//        let firstDay = "2020-05-27T17:20:00+0000"
        let dateFormatter = ISO8601DateFormatter()
        firstDate = dateFormatter.date(from: firstDay)
        return firstDate
        
    }
    
    func getAllIncidents(_ context: NSManagedObjectContext) -> [Incident]? {
        let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()

        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "fjpIncGuidForReference != %@", "")
        var predicate2 = NSPredicate.init()
        predicate2 = NSPredicate(format: "(%K == nil) OR (%K.length == 0)","ics214MasterGuid", "ics214MasterGuid" )

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("IncidentProvider line 172 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
        /// fetch all incidents that were entered for shift after userStartShiftTime and userEndShiftTime
        /// - Parameters:
        ///   - theDate: userTime.userStartShiftTime
        ///   - context: backgroundContext
        /// - Returns: returns a list of incidents
    func getTheDaysIncidents(_ theDate: Date,_ theEndDate: Date, context: NSManagedObjectContext) -> [Incident]? {
        self.context = context
        let fetchRequest: NSFetchRequest<Incident> = Incident.fetchRequest()

//        var predicate = NSPredicate.init()
//        predicate = NSPredicate(format: "%K != %@","incidentDateSearch","")
        var predicate1 = NSPredicate.init()
        let start: NSDate = theDate as NSDate
        let end: NSDate = NSDate()
        predicate1 = NSPredicate(format: "%K >= %@ && %K <= %@", "incidentCreationDate", start, "incidentCreationDate", end)

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate1])
//        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("TodaysIncidentsForDashboard line 92 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
    func theIncidentTagsToCloud(_ context: NSManagedObjectContext, _ objectIDs: [NSManagedObjectID], completionHandler: ( @escaping ( _ theTags: [CKRecord]) -> Void )) {
        
        self.context = context
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.context)
        
        self.theIncidentTagCKRecords.removeAll()
        for objectID in objectIDs {
            
            self.theIncidentTag = nil
            self.ckRecord = nil
            
            self.theIncidentTag = self.context.object(with: objectID) as? IncidentTags
            if let ckr = self.theIncidentTag.incidentTagCKR {
                guard let  archivedData = ckr as? Data else { return }
                do {
                    let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                    self.ckRecord = CKRecord(coder: unarchiver)
                    self.ckRecord["theEntity"] = "IncidenTags"
                    if let tag = self.theIncidentTag.incidentTag {
                    self.ckRecord["incidentTag"] = tag
                    }
                    if let incidentGuid = self.theIncidentTag.incidentGuid {
                    self.ckRecord["incidentGuid"] = incidentGuid
                    }
                    if let guid = self.theIncidentTag.guid {
                        self.ckRecord["guid"] = guid.uuidString
                    }
                    if let incidentReference = self.theIncidentTag.incidentReference {
                        self.ckRecord["incidentReference"] = incidentReference
                    }
                } catch {
                    print("nothing here ")
                }
            } else {
                if let guid = self.theIncidentTag.guid {
                    let theGuid = guid.uuidString
                    let recordName = theGuid
                    let theIncidentTagRZ = CKRecordZone.init(zoneName: "FireJournalShare")
                    let theIncidentTagRID = CKRecord.ID(recordName: recordName, zoneID: theIncidentTagRZ.zoneID)
                    self.ckRecord = CKRecord.init(recordType: "IncidentTags", recordID: theIncidentTagRID)
                    let theIncidentTagRef = CKRecord.Reference(recordID: theIncidentTagRID, action: .deleteSelf)
                    self.ckRecord["theEntity"] = "IncidentTags"
                    if let tag = self.theIncidentTag.incidentTag {
                    self.ckRecord["incidentTag"] = tag
                    }
                    if let incidentGuid = self.theIncidentTag.incidentGuid {
                    self.ckRecord["incidentGuid"] = incidentGuid
                    }
                    if let guid = self.theIncidentTag.guid {
                        self.ckRecord["guid"] = guid.uuidString
                    }
                    if let incidentReference = self.theIncidentTag.incidentReference {
                        self.ckRecord["incidentReference"] = incidentReference
                    }
                    
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: theIncidentTagRef, requiringSecureCoding: true)
                        self.theIncidentTag.incidentTagReference = data as NSObject
                        
                    } catch {
                        print("journalTagsReference to data failed line 514 Incident+Custom")
                    }
                    
                    let coder = NSKeyedArchiver(requiringSecureCoding: true)
                    self.ckRecord.encodeSystemFields(with: coder)
                    let data = coder.encodedData
                    self.theIncidentTag.incidentTagCKR = data as NSObject
                    
                }
            }

            self.theIncidentTagCKRecords.append(ckRecord)
            
        }
           
        let modifyCKOperation = CKModifyRecordsOperation.init(recordsToSave: theIncidentTagCKRecords, recordIDsToDelete: nil)
        modifyCKOperation.savePolicy = .changedKeys
        modifyCKOperation.modifyRecordsResultBlock = { [unowned self] result in
            switch result {
            case .success(_):
                
                do {
                    try self.context.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.context,userInfo:["info":"promotionTags save merge that"])
                    }
                } catch let error as NSError {
                    let theError: String = error.localizedDescription
                    let error = "There was an error in saving " + theError
                    print(error)
                }
                
                completionHandler(self.theIncidentTagCKRecords)
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(self.theIncidentTagCKRecords)
                    let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                    print("here is the incidentTags operation error \(error)")
                }
            }
        }
        
        privateDatabase.add(modifyCKOperation)
            
    }
    
    
}
