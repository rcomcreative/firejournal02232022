//
//  NewICS214Campaign.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/16/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NewICS214Campaign: NSObject, NSFetchedResultsControllerDelegate {

//    MARK: -PROPERTIES-
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var bkgrdContext:NSManagedObjectContext!
    var thread:Thread!
    let ics214MasterGuid: String!
    
    let nc = NotificationCenter.default
    var objectID: NSManagedObjectID? = nil
    var ics214: ICS214Form!
    var ics214Campaign = [ICS214Form]()
    let calendar = Calendar.current
    
//    MARK: -FetchResultsController-
    private var fetchedResultsController: NSFetchedResultsController<ICS214Form>? = nil
    private var _fetchedResultsController: NSFetchedResultsController<ICS214Form> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    private var fetchedObjects: [ICS214Form] {
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
    
    init(masterGuid: String, object: NSManagedObjectID) {
        self.ics214MasterGuid = masterGuid
        self.objectID = object
        super.init()
        self.thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        self.bkgrdContext = self.makeBckGround()
        self.ics214 = self.bkgrdContext.object(with: self.objectID!) as? ICS214Form
    }
    
    func getTheCampaign() {
        let fetchRequest: NSFetchRequest<ICS214Form> = ICS214Form.fetchRequest()
                       var predicate = NSPredicate.init()
                       predicate = NSPredicate(format: "%K = %@","ics214MasterGuid", ics214MasterGuid)
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
        if !fetchedObjects.isEmpty {
              ics214Campaign = fetchedObjects
        }
    }
    
    func updateTheCampaign(campaign: Bool, withCompletion completion: () -> Void) {
        for ics214 in ics214Campaign {
            ics214.ics214Completed = campaign
            ics214.ics214ModDate = Date()
            objectID = ics214.objectID
            saveToCD(objectid: objectID!)
        }
        completion()
    }
    
    func saveToCD(objectid: NSManagedObjectID) {
               do {
                   try bkgrdContext.save()
                   DispatchQueue.main.async {
                       self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NewICS214ActivityLog merge that"])
                   }
                   DispatchQueue.main.async {
                       self.nc.post(name: Notification.Name(rawValue: FJkMODIFIEDICS214FORM_TOCLOUDKIT),
                                    object: nil, userInfo: ["objectID":self.objectID as Any])
                   }
               } catch {
                   let nserror = error as NSError
                   print("NewICS214Resources The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
               }
    }
    
}
