//
//  UserAttendeesProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/14/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class UserAttendeesProvider: NSObject, NSFetchedResultsControllerDelegate {
    
    private(set) var persistentContainer: NSPersistentContainer
    var ckRecord: CKRecord!
    var theUserAttendees: UserAttendees!
    var theUserAttendeeA = [UserAttendees]()
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    var context: NSManagedObjectContext!
    let nc = NotificationCenter.default
    var theUserAttendeesR: CKRecord!
    var theUserAttendeesA = [String]()
    let userAttendeeSyncOperation = UserAttendeeSyncOperation()
    
    private var fetchedResultsController: NSFetchedResultsController<UserAttendees>? = nil
    var _fetchedResultsController: NSFetchedResultsController<UserAttendees> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    deinit {
        print("UserAttendees is being deinitialized")
    }
    
    var fetchedObjects: [UserAttendees] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.privateDatabase = myContainer.privateCloudDatabase
        super.init()
    }
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func isUserAttendeePartOfCD(_ guid: String, _ context: NSManagedObjectContext) -> [UserAttendees]? {
        
        self.context = context
        
        let fetchRequest: NSFetchRequest<UserAttendees> = UserAttendees.fetchRequest()

        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K == %@","attendeeGuid", guid)

         let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "attendee", ascending: true)
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
    
    func getUserAttendeesCKRecord(_ userAttendeesGuid: String, _ userAttendeesSync: UserAttendeeSyncOperation,  _ context: NSManagedObjectContext) {
        
        self.context = context
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let predicate2 = NSPredicate(format: "attendeeGuid == %@", userAttendeesGuid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2])
        let sort = NSSortDescriptor(key: "attendeeModDate", ascending: false)
        let query = CKQuery.init(recordType: "UserAttendees", predicate: predicateCan)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        var userAttendeeCKA = [CKRecord]()
        operation.recordMatchedBlock = { recordid, result in
            switch result {
            case .success(let record):
                userAttendeeCKA.append(record)
            case .failure(let error):
                print("error on retrieving status \(error)")
            }
        }
        operation.queryResultBlock = { [unowned self] result in
            switch result {
            case .success(_):
                if !userAttendeeCKA.isEmpty {
                    for ckRecord in userAttendeeCKA {
                        self.theUserAttendees = UserAttendees(context: self.context)
                        buildUserAttendeesFromCKRecord(ckRecord, theUserAttendees, self.context) {
                            print(self.theUserAttendees as Any)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    
                    let error = "\(String(describing: error)):\(String(describing: error.localizedDescription))"
                    print("here is the status operation error \(error)")
                }
            }
        }
        
        privateDatabase.add(operation)
    }
    
    func buildUserAttendeesFromCKRecord(_ ckRecord: CKRecord, _ theUserAttendees: UserAttendees, _ context: NSManagedObjectContext, completionHandler: (() -> Void)? = nil) {
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        self.context = context
        self.ckRecord = ckRecord
        self.theUserAttendees = theUserAttendees
        
        self.theUserAttendees.attendeeBackUp = true
        if let attendeeGuid = self.ckRecord["attendeeGuid"] as? String {
            self.theUserAttendees.attendeeGuid = attendeeGuid
        }
        if let attendee = self.ckRecord["attendee"] as? String {
            self.theUserAttendees.attendee = attendee
        }
        if let attendeeEmail = self.ckRecord["attendeeEmail"] as? String {
            self.theUserAttendees.attendeeEmail = attendeeEmail
        }
        if let attendeePhone = self.ckRecord["attendeePhone"] as? String {
            self.theUserAttendees.attendeePhone = attendeePhone
        }
        if let attendeeHomeAgency = self.ckRecord["attendeeHomeAgency"] as? String {
            self.theUserAttendees.attendeeHomeAgency = attendeeHomeAgency
        }
        if let attendeeICSPosition = self.ckRecord["attendeeICSPosition"] as? String {
            self.theUserAttendees.attendeeICSPosition = attendeeICSPosition
        }
                
        if let attendeeApparatus = self.ckRecord["attendeeApparatus"] as? String {
            self.theUserAttendees.attendeeApparatus = attendeeApparatus
        }
        if let attendeeAssignment = self.ckRecord["attendeeAssignment"] as? String {
            self.theUserAttendees.attendeeAssignment = attendeeAssignment
        }
        if let attendeeModDate = self.ckRecord["attendeeModDate"] as? Date {
            self.theUserAttendees.attendeeModDate = attendeeModDate
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        self.ckRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.theUserAttendees.fjUserAttendeeCKR = data as NSObject
        
        theUserAttendeeA.append(self.theUserAttendees)
        
        saveTheSingleCD() {_ in
            completionHandler?()
        }
    }
    
    private func saveTheSingleCD(withCompletion completion: @escaping (String) -> Void) {
        if self.context != nil {
            do {
                try self.context?.save()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Incident Saved"])
                    print("project we have saved to the cloud")
                }
                completion("Success")
            } catch {
                let nserror = error as NSError
                
                let error = "The UserAttendeesProvider context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
                print(error)
                completion("Error")
            }
        }
    }
    
}
