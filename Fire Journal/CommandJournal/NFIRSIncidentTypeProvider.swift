//
//  NFIRSIncidentTypeProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/16/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class NFIRSIncidentTypeProvider: NSObject, NSFetchedResultsControllerDelegate {
    
    private var fetchedResultsController: NSFetchedResultsController<NFIRSIncidentType>? = nil
    var _fetchedResultsController: NSFetchedResultsController<NFIRSIncidentType> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    deinit {
        print("IncidentProvider is being deinitialized")
    }
    
    var fetchedObjects: [NFIRSIncidentType] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    private(set) var persistentContainer: NSPersistentContainer
    var buildFromNFIRSIncidentType: BuildFromNFIRSIncidentType!

    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getAllNFIRSIncidentType(_ context: NSManagedObjectContext) -> [NFIRSIncidentType]? {
        var theNFIRSIncidentTypes = [NFIRSIncidentType]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSIncidentType" )
        let sectionSortDescriptor = NSSortDescriptor(key: "incidentTypeName", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [NFIRSIncidentType]
            if !fetched.isEmpty {
                for incidentType in fetched {
                    theNFIRSIncidentTypes.append(incidentType)
                }
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return theNFIRSIncidentTypes
    }
    
    func buildTheNFIRSIncidentTypes(theGuidDate: Date, backgroundContext: NSManagedObjectContext)  -> [NFIRSIncidentType] {
        var incidentTypes = [NFIRSIncidentType]()
        buildFromNFIRSIncidentType = BuildFromNFIRSIncidentType.init()
        let nfirsA = buildFromNFIRSIncidentType.nfirsIncidentTypes
        for nfirs in nfirsA {
            let guidDate = GuidFormatter.init(date: theGuidDate)
            let guid = guidDate.formatGuid()
            let theGuid = "54."+guid
            if let theNFIRS = nfirs.nfirsIncidentTypes {
                let incidentType = NFIRSIncidentType(context: backgroundContext)
                incidentType.incidentTypeGuid = theGuid
                incidentType.displayOrder = Int64(theNFIRS.displayOrder)
                incidentType.incidentTypeNumber = theNFIRS.incidentTypeNumber
                incidentType.incidentTypeName = theNFIRS.incidentTypeName
                incidentTypes.append(incidentType)
            }
        }
        do {
            try backgroundContext.save()
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "IncidentEdit saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
        backgroundContext.reset()
        return incidentTypes
    }

    
}
