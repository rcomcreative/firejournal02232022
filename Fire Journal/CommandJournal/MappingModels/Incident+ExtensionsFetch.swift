//
//  Incident+ExtensionsFetch.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/11/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreLocation

extension Incident {
    
    func getTheLastSaved(guid: String) ->NSManagedObjectID {
        var objectID: NSManagedObjectID? = nil
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident" )
         let predicate = NSPredicate(format: "%K = %@", "fjpIncGuidForReference", guid )
         let sectionSortDescriptor = NSSortDescriptor(key: "incidentCreationDate", ascending: true)
         let sortDescriptors = [sectionSortDescriptor]
         fetchRequest.sortDescriptors = sortDescriptors
         fetchRequest.predicate = predicate
         fetchRequest.fetchBatchSize = 1
         do {
             let fetched = try self.managedObjectContext?.fetch(fetchRequest) as! [Incident]
            if !fetched.isEmpty {
                 let incident = fetched.last
                objectID = incident?.objectID
            }
         } catch let error as NSError {
             print("IncidentTVC line 1132 Fetch Error: \(error.localizedDescription)")
         }
        return objectID!
     }
    
}
