//
//  LocalIncidentProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class LocalIncidentProvider: NSObject {
    
    let nc = NotificationCenter.default
    
    private(set) var persistentContainer: NSPersistentContainer
    var buildFromLocalIncidentType: BuildFromLocalIncidentType!
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getAllLocalIncidentTypes(context: NSManagedObjectContext) -> [UserLocalIncidentType]? {
        var localIncidentTypes = [UserLocalIncidentType]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserLocalIncidentType" )
        let sectionSortDescriptor = NSSortDescriptor(key: "localIncidentTypeName", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [UserLocalIncidentType]
            if !fetched.isEmpty {
                for localIncidentType in fetched {
                    localIncidentTypes.append(localIncidentType)
                }
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        return localIncidentTypes
    }
    
    func buildLocalIncidentType(theGuidDate: Date, backgroundContext: NSManagedObjectContext ) -> [UserLocalIncidentType] {
        var theLocalIncidentTypes = [UserLocalIncidentType]()
        buildFromLocalIncidentType = BuildFromLocalIncidentType.init()
        let localIncidentTypesA = buildFromLocalIncidentType.localIncidents
        for localIncidentTypes in localIncidentTypesA {
                let guidDate = GuidFormatter.init(date: theGuidDate)
                let guid = guidDate.formatGuid()
                let theGuid = "52."+guid
            if let local = localIncidentTypes.localIncident {
            let localIncident = UserLocalIncidentType(context: backgroundContext)
                localIncident.localIncidentGuid = theGuid
                localIncident.localIncidentTypeName = local.localIncident
                localIncident.localIncidentTypeModDate = theGuidDate
                theLocalIncidentTypes.append(localIncident)
            }
        }
        do {
            try backgroundContext.save()
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "LocalIncidentType saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        backgroundContext.reset()
        return theLocalIncidentTypes
    }
    
}
