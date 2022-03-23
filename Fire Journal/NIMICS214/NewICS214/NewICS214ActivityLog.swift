//
//  NewICS214ActivityLog.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/29/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NewICS214ActivityLog: NSObject , NSFetchedResultsControllerDelegate {

//    MARK: -PROPERTIES-
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var thread:Thread!
    let ics214Guid: String!
    
    let nc = NotificationCenter.default
    var objectID: NSManagedObjectID? = nil
    var ics214: ICS214Form!
    let calendar = Calendar.current
    
//    MARK: -FetchResultsController-
    private var fetchedResultsController: NSFetchedResultsController<ICS214ActivityLog>? = nil
    private var _fetchedResultsController: NSFetchedResultsController<ICS214ActivityLog> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    private var fetchedObjects: [ICS214ActivityLog] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func makeBckGround()->NSManagedObjectContext {
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        let bkgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgroundContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        return bkgroundContext
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
//        guard !Thread.isMainThread else { fatalError("must be called in background!")}
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    init(guid: String, object: NSManagedObjectID) {
        self.ics214Guid = guid
        self.objectID = object
        super.init()
        self.thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        self.bkgrdContext = self.makeBckGround()
        self.ics214 = self.bkgrdContext.object(with: self.objectID!) as? ICS214Form
    }
    
    func getTheSet() -> [ICS214ActivityLog] {
        let logs = ics214.ics214ActivityDetail as! Set<ICS214ActivityLog>
        var logArray = [ICS214ActivityLog]()
        for log in logs {
            logArray.append(log)
        }
        return logArray
    }
    
    func getTheLogs() ->[ICS214ActivityLog] {
        let fetchRequest: NSFetchRequest<ICS214ActivityLog> = ICS214ActivityLog.fetchRequest()
                var predicate = NSPredicate.init()
                predicate = NSPredicate(format: "%K = %@","ics214Guid", ics214Guid)
                 let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                fetchRequest.predicate = predicateCan
                fetchRequest.fetchBatchSize = 20
                let sectionSortDescriptor = NSSortDescriptor(key: "ics214Guid", ascending: true)
                let sortDescriptors = [sectionSortDescriptor]
                fetchRequest.sortDescriptors = sortDescriptors
                
                
                let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                aFetchedResultsController.delegate = self
                fetchedResultsController = aFetchedResultsController
                do {
                    try fetchedResultsController?.performFetch()
                } catch let error as NSError {
                    print("NewICS21ActivityLog line 52 Fetch Error: \(error.localizedDescription)")
                }
        return fetchedObjects
    }
    
    func createNewICS214ActivityLog(logString: String, date: Date, completion: ([ICS214ActivityLog]) -> () ) {
        var uuidA:String = NSUUID().uuidString.lowercased()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: date)
        uuidA = uuidA+dateFrom
        let logGuid = "81."+uuidA
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        let dateString = dateFormatter.string(from:date)
        let icsS214ActivityLog = ICS214ActivityLog.init(entity: NSEntityDescription.entity(forEntityName: "ICS214ActivityLog", in: context)!, insertInto: bkgrdContext)
        icsS214ActivityLog.ics214ActivityGuid = logGuid
        icsS214ActivityLog.ics214Guid = self.ics214Guid
        icsS214ActivityLog.ics214AcivityModDate = date
        icsS214ActivityLog.ics214ActivityCreationDate = date
        icsS214ActivityLog.ics214ActivityBackedUp = false
        icsS214ActivityLog.ics214ActivityDate = date
        icsS214ActivityLog.ics214ActivityLog = logString
        icsS214ActivityLog.ics214ActivityStringDate = dateString
        ics214.addToIcs214ActivityDetail(icsS214ActivityLog)
        ics214.ics214ModDate = Date()
        ics214.ics214BackedUp = false
        saveToCDForActivityLog(guid: logGuid)
        completion(fetchedObjects)
    }
    
    func saveToCDForActivityLog(guid:String) {
        do {
            try bkgrdContext.save()
            print("NewICS214ActtivyLog The context was saved")
            _ = getTheLogs()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NewICS214ActivityLog merge that"])
            }
            DispatchQueue.main.async {
                let objectID = self.getTheLastSavedICS214ActivtyLog(guid: guid)
                print("Going to Activity Log Cloud")
                self.nc.post(name: Notification.Name(rawValue: FJkNEWICS214ACTIVITYLOG_TOCLOUDKIT),
                             object: nil, userInfo: ["objectID":objectID])
            }
        } catch {
            let nserror = error as NSError
            print("NewICS214ActtivyLog The context was unable to save due to \(nserror.localizedDescription) user Info: \(nserror.userInfo)")
        }
    }
    
    private func getTheLastSavedICS214ActivtyLog(guid: String)->NSManagedObjectID {
        var objectID: NSManagedObjectID!
        let fetchRequest: NSFetchRequest<ICS214ActivityLog> = ICS214ActivityLog.fetchRequest()
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214ActivityCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 1
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) 
            let ics214ActivityLog = fetched.last
            objectID = ics214ActivityLog?.objectID
            return objectID
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return objectID
    }

}
