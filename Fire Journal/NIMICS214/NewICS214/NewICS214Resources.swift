//
//  NewICS214Resources.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/26/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NewICS214Resources: NSObject , NSFetchedResultsControllerDelegate {
    
    //    MARK: -PROPERTIES-
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var thread:Thread!
    let ics214Guid: String!
    
    let nc = NotificationCenter.default
    var objectID: NSManagedObjectID? = nil
    var ics214: ICS214Form!
    
    //    MARK: -FetchResultsController-
    private var fetchedResultsController: NSFetchedResultsController<ICS214Personnel>? = nil
    private var _fetchedResultsController: NSFetchedResultsController<ICS214Personnel> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    private var fetchedObjects: [ICS214Personnel] {
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
//        guard !Thread.isMainThread else { fatalError("must be called in background!")}
        super.init()
        self.thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        self.bkgrdContext = self.makeBckGround()
        self.ics214 = self.bkgrdContext.object(with: self.objectID!) as? ICS214Form
    }
    
    func getTheResources() ->[ICS214Personnel] {
        let fetchRequest: NSFetchRequest<ICS214Personnel> = ICS214Personnel.fetchRequest()
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K = %@","ics214Guid", ics214Guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        let sectionSortDescriptor = NSSortDescriptor(key: "ics214Guid", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: bkgrdContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("NewICS214Resources line 52 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
    func getTheAttendees()->[UserAttendees] {
        _ = getTheResources()
        var guid = [String]()
        var attendees = [UserAttendees]()
        var theCrew = [UserAttendees]()
        if fetchedObjects.isEmpty {
            
        } else {
            for attendee in fetchedObjects {
                guid.append(attendee.userAttendeeGuid ?? "")
            }
            if !guid.isEmpty {
                for theGuid in guid {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees")
                    var predicate = NSPredicate.init()
                    predicate = NSPredicate(format: "%K = %@","attendeeGuid", theGuid)
                    let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
                    fetchRequest.predicate = predicateCan
                    fetchRequest.fetchBatchSize = 1
                    let sectionSortDescriptor = NSSortDescriptor(key: "attendee", ascending: false)
                    let sortDescriptors = [sectionSortDescriptor]
                    fetchRequest.sortDescriptors = sortDescriptors
                    do {
                        attendees = try bkgrdContext.fetch(fetchRequest) as! [UserAttendees]
                        if attendees.isEmpty {} else {
                            let crew = attendees.last!
                            theCrew.append(crew)
                        }
                    }  catch {
                        let nserror = error as NSError
                        let errorMessage = "NewICS214Resources getTheAttendees line 81 Unresolved error \(nserror), \(nserror.userInfo)"
                        print(errorMessage)
                    }
                }
            }
        }
        return theCrew
    }
    
    func createICS214Personnel(guid2: String) {
        let result = fetchedObjects.filter { $0.userAttendeeGuid == guid2 }
        if result.isEmpty {
            let fjuICS214Personnel = ICS214Personnel.init(entity: NSEntityDescription.entity(forEntityName: "ICS214Personnel", in: context)!, insertInto: bkgrdContext)
            fjuICS214Personnel.ics214Guid = self.ics214Guid
            var uuidA:String = NSUUID().uuidString.lowercased()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
            let resourceDate = Date()
            let dateFrom = dateFormatter.string(from: resourceDate)
            uuidA = uuidA+dateFrom
            let uuidA1 = "80."+uuidA
            fjuICS214Personnel.ics214PersonelGuid = uuidA1
            fjuICS214Personnel.userAttendeeGuid = guid2
            ics214.addToIcs214PersonneDetail(fjuICS214Personnel)
            saveToCDForPersonnel(guid: uuidA1)
        }
    }
    
    func saveToCDForPersonnel(guid:String) {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NewICS214Resources merge that"])
            }
            DispatchQueue.main.async {
                let objectID = self.getTheLastSavedICS214Personnel(guid: guid)
                self.nc.post(name: Notification.Name(rawValue: FJkNEWICS214PERSONNEL_TOCLOUDKIT),
                             object: nil, userInfo: ["objectID":objectID])
            }
        } catch {
            let nserror = error as NSError
            print("NewICS214Resources The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
    }
    
    private func getTheLastSavedICS214Personnel(guid: String)->NSManagedObjectID {
        var objectID: NSManagedObjectID!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Personnel" )
        let predicate = NSPredicate(format: "%K = nil", "ics214PersonnelCKR")
        let predicate2 = NSPredicate(format: "%K == %@", "ics214PersonelGuid", guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 1
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [ICS214Personnel]
            let ics214Personnel = fetched.last
            objectID = ics214Personnel?.objectID
            return objectID
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return objectID
    }
    
    
}
