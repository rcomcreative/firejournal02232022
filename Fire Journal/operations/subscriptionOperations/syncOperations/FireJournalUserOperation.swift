//
//  FireJournalUserOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/16/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit



class FireJournalUserLoader: FJOperation {
    
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread! 
    var privateDatabase:CKDatabase!
    var fireJournalUsersA = [FireJournalUser]()
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    var task : UIBackgroundTaskIdentifier = .invalid
    var bkgrndTask: BkgrndTask?
    var fju: FireJournalUser!
    let nc = NotificationCenter.default
    
    
    init(_ context: NSManagedObjectContext,database: CKDatabase) {
        self.context = context
        self.privateDatabase = database
        super.init()
    }
    
    deinit {
        nc.removeObserver(NSNotification.Name.NSManagedObjectContextDidSave)
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        DispatchQueue.main.async {
            self.userDefaults.set(false, forKey: FJkFJUSERSavedToCoreDataFromCloud)
        }
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        executing(true)
        
//        let reach = userDefaults.bool(forKey: FJkInternetConnectionAvailable)
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        let sort = NSSortDescriptor(key: "fjpUserModDate", ascending: false)
        let query = CKQuery.init(recordType: "FireJournalUser", predicate: predicateCan)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1
        
        var newUsersRecordsA = [CKRecord]()
        
        operation.recordFetchedBlock = { record in
                newUsersRecordsA.append(record)
        }
        
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            if error == nil {
                if newUsersRecordsA.count>0 {
                    let record:CKRecord = newUsersRecordsA.last!
                    self.saveTheUser(record: record)
                }
            }
            DispatchQueue.main.async {
                if error == nil {
                    print("no errors here!")
                } else {
                    let error = "\(String(describing: error)):\(String(describing: error?.localizedDescription))"
                    print("here is the firejournaluseroperaiton error \(error)")
                }
            }
            
        }
        
        privateDatabase.add(operation)
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        
    }
    
    fileprivate func saveTheUser(record:CKRecord) {
        
//        let guid:String = record["userGuid"] ?? ""
        if counter == 0 {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
            let predicate = NSPredicate(format: "%K = %i", "displayOrder", 0)
            fetchRequest.predicate = predicate
            var count = 0
            do {
                count = try context.count(for:fetchRequest)
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                count = 0
            }
            
            if count == 0 {
                fju = FireJournalUser(context: context)
                fju.displayOrder = record["displayOrder"]
                fju.userGuid = record["userGuid"]
                fju.firstName = record["firstName"]
                fju.lastName = record["lastName"]
                
                fju.activeReceiptExpirationDate = record["activeReceiptExpirationDate"] as? Date
                fju.activeReceiptProductIdentifier = record["activeReceiptProductIdentifier"]
                fju.activeReceiptTransactionIdentifier = record["activeReceiptTransactionIdentifier"]

                if record["assignmentDefault"] ?? false {
                fju.apparatusDefault = true
                } else {
                    fju.apparatusDefault = false
                }
                fju.apparatusGuid = record["apparatusGuid"]
                fju.apparatusOvertimeGuid = record["apparatusOvertimeGuid"]
                if record["assignmentDefault"] ?? false {
                fju.assignmentDefault = true
                } else {
                fju.assignmentDefault = false
                }
                fju.assignmentGuid = record["assignmentGuid"]
                fju.assignmentOvertimeGuid = record["assignmentOvertimeGuid"]
                fju.battalion = record["battalion"]
                fju.cnIdentifier = record["cnIdentifier"]
                if record["crewDefault"] ?? false {
                fju.crewDefault = true
                } else {
                    fju.crewDefault = false
                }
                fju.crewOvertime = record["crewOvertime"]
                fju.crewOvertimeGuid = record["crewOvertimeGuid"]
                fju.crewOvertimeName = record["crewOvertimeName"]
                fju.deafultCrewName = record["deafultCrewName"]
                fju.defaultCrew = record["defaultCrew"]
                fju.defaultCrewGuid = record["defaultCrewGuid"]
                fju.defaultResources = record["defaultResources"]
                fju.defaultResourcesName = record["defaultResourcesName"]
                fju.division = record["division"]
                fju.emailAddress = record["emailAddress"]
                fju.fdid = record["fdid"]
                fju.fireDepartment = record["fireDepartment"]
                fju.fireDistrict = record["fireDistrict"]
                if record["fireJournalUserShift"] != nil {
                    fju.fireJournalUserShift = record["fireJournalUserShift"] as! Int64
                } else {
                    fju.fireJournalUserShift = 0
                }
                fju.fireStation = record["fireStation"]
                fju.fireStationAddress = record["fireStationAddress"]
                fju.fireStationAddressTwo = record["fireStationAddressTwo"]
                fju.fireStationCity = record["fireStationCity"]
                var fdDefaultB: Bool = false
                if record["fireStationDefault"] != nil {
                    let fdDefault: NSNumber = record["fireStationDefault"] as! NSNumber
                    if fdDefault == 1 {
                        fdDefaultB = true
                    }
                }
                fju.fireStationDefault = fdDefaultB
                fju.fireStationGuid = record["fireStationGuid"]
                fju.fireStationOvertimeGuid = record["ireStationOvertimeGuid"]
                fju.fireStationState = record["fireStationState"]
                fju.fireStationStreetName = record["fireStationStreetName"]
                fju.fireStationStreetNumber = record["fireStationStreetNumber"]
                fju.fireStationWebSite = record["fireStationWebSite"]
                fju.fireStationZipCode = record["fireStationZipCode"]
                fju.fjpUserBackedUp = record["fjpUserBackedUp"] as? NSNumber
                fju.fjpUserModDate = record["fjpUserModDate"] as? Date
                fju.fjpUserSearchDate = record["fjpUserSearchDate"] as? Date
                fju.initialApparatus = record["initialApparatus"]
                fju.initialAssignment = record["initialAssignment"]
                fju.middleName = record["middleName"]
                fju.mobileNumber = record["mobileNumber"]
                fju.password = record["password"]
                fju.platoon = record["platoon"]
                var pDefaultB: Bool = false
                if record["platoonDefault"] != nil {
                    let pDefault = record["platoonDefault"] as! NSNumber
                    if pDefault == 1 {
                        pDefaultB = true
                    }
                }
                fju.platoonDefault = pDefaultB
                fju.platoonGuid = record["platoonGuid"]
                fju.platoonOverTimeGuid = record["platoonOverTimeGuid"]
                fju.rank = record["rank"]
                var rDefaultB: Bool = false
                if record["resourcesDefault"] != nil {
                    let rDefault = record["resourcesDefault"] as! NSNumber
                    if rDefault == 1 {
                        rDefaultB = true
                    }
                }
                fju.resourcesDefault = rDefaultB
                fju.resourcesGuid = record["resourcesGuid"]
                fju.resourcesOvertimeGuid = record["resourcesOvertimeGuid"]
                fju.resourcesOvertimeName = record["resourcesOvertimeName"]
                let ssDefaultB: Bool = false
                fju.shiftStatusAMorOver = ssDefaultB
                let subDefaultB: Bool = false
                fju.subscriptionAccount = subDefaultB
                fju.tempApparatus = record["tempApparatus"]
                fju.tempAssignment = record["tempAssignment"]
                fju.tempFireStation = record["tempFireStation"]
                fju.tempPlatoon = record["tempPlatoon"]
                fju.tempResources = record["tempResources"]
                fju.user = record["user"]
                if record["userName"] != "" {
                    fju.userName = record["userName"]
                } else {
                    var fName = ""
                    var lName = ""
                    if let first:String = record["firstName"] {
                        fName = first
                    }
                    if let last:String = record["lastName"] {
                        lName = last
                    }
                    fju.userName = "\(fName) \(lName)"
                }
                let coder = NSKeyedArchiver(requiringSecureCoding: true)
                record.encodeSystemFields(with: coder)
                let data = coder.encodedData
                fju.fjuCKR = data as NSObject
                saveToCD()
            }
        } else {
            
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkLOADUSERITMESCALLED),
                        object: nil,
                        userInfo: ["ckRecordType":CKRecordsToLoad.fJkCKRFireJournalUser])
                self.userDefaults.set(false, forKey: FJkFJUSERSavedToCoreDataFromCloud)
                self.executing(false)
                self.finish(true)
                self.bkgrndTask?.endBackgroundTask()
                print("FireJournalUserOperation is done")
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
        
        counter = 1
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"FJU Operation here saving to context"])
                
            }
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkLOADUSERITMESCALLED),
                        object: nil,
                        userInfo: ["ckRecordType": CKRecordsToLoad.fJkCKRFireJournalUser])
                self.userDefaults.set(true, forKey: FJkFJUSERSavedToCoreDataFromCloud)
                self.executing(false)
                self.finish(true)
                print("FireJournalUserOperation is done save")
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            let error = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
            print(error)
            DispatchQueue.main.async {
                self.userDefaults.set(false, forKey: FJkFJUSERSavedToCoreDataFromCloud)
                self.executing(false)
                self.finish(true)
            }
            
        }
    }
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageData" )
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
}
