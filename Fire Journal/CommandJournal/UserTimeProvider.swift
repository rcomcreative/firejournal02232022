//
//  UserTimeProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 2/22/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class UserTimeProvider: NSObject, NSFetchedResultsControllerDelegate {
    
    var fjUserTime: UserTime!
    let calendar = Calendar.current
    
    private var fetchedResultsController: NSFetchedResultsController<UserTime>? = nil
    var _fetchedResultsController: NSFetchedResultsController<UserTime> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    deinit {
        print("IncidentProvider is being deinitialized")
    }
    
    var fetchedObjects: [UserTime] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    private(set) var persistentContainer: NSPersistentContainer
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getTheShift(_ context: NSManagedObjectContext, _ guid: String) -> [UserTime]? {
        let fetchRequest: NSFetchRequest<UserTime> = UserTime.fetchRequest()

        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K == %@","userTimeGuid", guid)
        var predicate2 = NSPredicate.init()

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        
        let sectionSortDescriptor = NSSortDescriptor(key: "userStartShiftTime", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("UserTimeProvider line 61 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
    func getLastCompleteShift(_ context: NSManagedObjectContext) -> [UserTime]? {
        let fetchRequest: NSFetchRequest<UserTime> = UserTime.fetchRequest()

        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K == %@","shiftCompleted", NSNumber(value: true ))
        

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "userStartShiftTime", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("UserTimeProvider line 87 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
    func getLastShiftNotCompleted(_ context: NSManagedObjectContext) -> [UserTime]? {
        
        let fetchRequest: NSFetchRequest<UserTime> = UserTime.fetchRequest()

        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K == %@","shiftCompleted", NSNumber(value: false ))
//        var predicate2 = NSPredicate.init()
//        predicate2 = NSPredicate(format: "startShiftPlatoon == NULL")
        var predicate3 = NSPredicate.init()
        predicate3 = NSPredicate(format: "%K != %@","userTimeGuid", "")

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate3])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "userStartShiftTime", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("UserTimeProvider line 115 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
    func getTheLastCompletedShift(_ context: NSManagedObjectContext) -> [UserTime]? {
        let fetchRequest: NSFetchRequest<UserTime> = UserTime.fetchRequest()

        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "shiftCompleted == %@", NSNumber(value: true ))

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "userStartShiftTime", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("UserTimeProvider line 115 Fetch Error: \(error.localizedDescription)")
        }
        return fetchedObjects
    }
    
}
