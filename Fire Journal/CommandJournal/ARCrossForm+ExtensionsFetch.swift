//
//  ARCrossForm+ExtensionsFetch.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/17/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

extension ARCrossForm {
    
    func getTheLastSaved(guid: String)-> NSManagedObjectID {
        var objectID: NSManagedObjectID? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm" )
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K == %@" , "arcFormGuid" , guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            let fetched = try self.managedObjectContext?.fetch(fetchRequest) as! [ARCrossForm]
            let arcForm = fetched.last!
            objectID = arcForm.objectID
        } catch let error as NSError {
            print("ARCrossForm+ExtensionFetch line 33 Fetch Error: \(error.localizedDescription)")
        }
        return objectID!
    }
    
}
