//
//  UserFDIDProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/12/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class UserFDIDProvider: NSObject {
    
    let nc = NotificationCenter.default
    var context: NSManagedObjectContext!
    var theLocation: FCLocation!
    
    private(set) var persistentContainer: NSPersistentContainer
    var buildFromFDIDPlist: BuildFromFDIDPlist!
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getAllUserFDIDs(context: NSManagedObjectContext) -> [UserFDID]? {
        
        self.context = context
        var fdids = [UserFDID]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDID" )
        let sectionSortDescriptor = NSSortDescriptor(key: "fdidNumber", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [UserFDID]
            if !fetched.isEmpty {
                for fdid in fetched {
                    fdids.append(fdid)
                }
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        return fdids
    }
    
    func getTheFDIDForCityState(context: NSManagedObjectContext, userID: NSManagedObjectID) -> [UserFDID]? {
        self.context = context
        var fdids = [UserFDID]()
        let user = self.context.object(with: userID) as! FireJournalUser
        
        var theCity: String = ""
        var theState: String = ""
        if user.theLocation != nil {
            theLocation = user.theLocation
            if let city = theLocation.city {
                theCity = city
            }
            if let state = theLocation.state {
                theState = state
            }
        } else {
            if let city = user.fireStationCity {
                theCity = city
            }
            if let state = user.fireStationState {
                theState = state
            }
        }
        
        var predicate = NSPredicate.init()
        var predicate2 = NSPredicate.init()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFDID" )
        predicate = NSPredicate(format: "%K = %@", "hqState", theState)
        let prefix = theCity.prefix(4)
        predicate2 = NSPredicate(format: "%K BEGINSWITH[cd] %@","hqCity", prefix as CVarArg)
         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
        fetchRequest.predicate = predicateCan
        
        let sectionSortDescriptor = NSSortDescriptor(key: "fdidNumber", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetched = try self.context.fetch(fetchRequest) as! [UserFDID]
            if !fetched.isEmpty {
                for fdid in fetched {
                    fdids.append(fdid)
                }
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        return fdids
    }
    
    func buildTheFDIDs(theGuidDate: Date, backgroundContext: NSManagedObjectContext ) -> [UserFDID]? {
        self.context = backgroundContext
        var fdids = [UserFDID]()
        buildFromFDIDPlist = BuildFromFDIDPlist.init()
        let fdidA = buildFromFDIDPlist.fdids
        for afdid in fdidA {
            let theFDID = afdid.fdid
            let fdid = UserFDID(context: backgroundContext)
            let guidDate = GuidFormatter(date: theGuidDate)
            let guid = guidDate.formatGuid()
            let theGuid = "76."+guid
            fdid.fdidGuid = theGuid
            fdid.fireDepartmentName = theFDID.department
            fdid.fdidNumber = theFDID.fdid
            fdid.hqCity = theFDID.city
            fdid.hqState = theFDID.state
            fdids.append(fdid)
        }
        do {
            try self.context.save()
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "UserFDIDProvicer saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        backgroundContext.reset()
        return fdids
    }
    
}
