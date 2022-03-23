//
//  FireJournalUser+ExtensionsFetch.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/11/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension FireJournalUser {
    /*
     func getTheFireJournalUser()->Int {
         var count: Int = 0
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
         var predicate = NSPredicate.init()
         predicate = NSPredicate(format: "%K != %@", "userGuid", "")
         let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
         let sortDescriptors = [sectionSortDescriptor]
         fetchRequest.sortDescriptors = sortDescriptors
         
         fetchRequest.predicate = predicate
         fetchRequest.fetchBatchSize = 20
         
         do {
             let fetched = try self.managedObjectContext?.fetch(fetchRequest) as! [FireJournalUser]
             if fetched.isEmpty {
                 count = 0
             } else {
                 fju = (self.fetched.last as? FireJournalUser)!
                 count = 1
             }
         } catch let error as NSError {
             // failure
             print("Fetch failed: \(error.localizedDescription)")
         }
         return count
     }
     */
}
