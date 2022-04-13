    //
    //  UserFromCloudOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 4/9/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import Foundation
import UIKit
import CoreData
import CloudKit

class UserFromCloudOperation: FJOperation {
    
    let context: NSManagedObjectContext!
    var privateDatabase:CKDatabase!
    var fireJournalUsersA = [FireJournalUser]()
    var ckRecordA = [CKRecord]()
    var ckRecord: CKRecord!
    var count: Int = 0
    var stop: Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    var task: UIBackgroundTaskIdentifier = .invalid
    var bkgrndTask: BkgrndTask?
    var fju: FireJournalUser!
    let nc = NotificationCenter.default
    
    init(_ context: NSManagedObjectContext, database: CKDatabase) {
        self.context = context
        self.privateDatabase = database
        bkgrndTask = BkgrndTask.init(bkgrndTask: task)
        bkgrndTask?.operation = "FireJournalUserOperation"
        bkgrndTask?.registerBackgroundTask()
        super.init()
    }
    
    override func main() {
        
        guard isCancelled == false else {
            self.userDefaults.set(false, forKey: FJkFJUSERSavedToCoreDataFromCloud)
            self.bkgrndTask?.endBackgroundTask()
            self.executing(false)
            self.finish(true)
            print("UserFromCloudOperation is done save")
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        DispatchQueue.main.async {
            self.userDefaults.set(false, forKey: FJkFJUSERSavedToCoreDataFromCloud)
        }
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.context)
        executing(true)
        
        getTheData() {
            self.saveTheUser()
        }
        
        guard isCancelled == false else {
            self.userDefaults.set(false, forKey: FJkFJUSERSavedToCoreDataFromCloud)
            self.bkgrndTask?.endBackgroundTask()
            self.executing(false)
            self.finish(true)
            print("UserFromCloudOperation is done save")
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
    }
    
    
        /// Grab all from FireJournalUser that might exist
        /// - Parameter completionHandler: when operation is complete CKRecord will be used to build FireJournalUser
    private func getTheData(completionHandler: ( @escaping () -> Void)) {
        
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
                if newUsersRecordsA.count > 0 {
                    self.ckRecord = newUsersRecordsA.last!
                    completionHandler()
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
        
    }
    
        /// If CKRecord exists - save it to fireJournalUser else cancel operation
    private func saveTheUser() {
        
        if ckRecord != nil {
            self.fju = FireJournalUser(context: context)
            self.fju.displayOrder = ckRecord["displayOrder"]
            self.fju.userGuid = ckRecord["userGuid"]
            self.fju.firstName = ckRecord["firstName"]
            self.fju.lastName = ckRecord["lastName"]
            
            self.fju.activeReceiptExpirationDate = ckRecord["activeReceiptExpirationDate"] as? Date
            self.fju.activeReceiptProductIdentifier = ckRecord["activeReceiptProductIdentifier"]
            self.fju.activeReceiptTransactionIdentifier = ckRecord["activeReceiptTransactionIdentifier"]
            
            if ckRecord["assignmentDefault"] ?? false {
                self.fju.apparatusDefault = true
            } else {
                self.fju.apparatusDefault = false
            }
            self.fju.apparatusGuid = ckRecord["apparatusGuid"]
            self.fju.apparatusOvertimeGuid = ckRecord["apparatusOvertimeGuid"]
            if ckRecord["assignmentDefault"] ?? false {
                self.fju.assignmentDefault = true
            } else {
                self.fju.assignmentDefault = false
            }
            self.fju.assignmentGuid = ckRecord["assignmentGuid"]
            self.fju.assignmentOvertimeGuid = ckRecord["assignmentOvertimeGuid"]
            self.fju.battalion = ckRecord["battalion"]
            self.fju.cnIdentifier = ckRecord["cnIdentifier"]
            if ckRecord["crewDefault"] ?? false {
                self.fju.crewDefault = true
            } else {
                self.fju.crewDefault = false
            }
            self.fju.crewOvertime = ckRecord["crewOvertime"]
            self.fju.crewOvertimeGuid = ckRecord["crewOvertimeGuid"]
            self.fju.crewOvertimeName = ckRecord["crewOvertimeName"]
            self.fju.deafultCrewName = ckRecord["deafultCrewName"]
            self.fju.defaultCrew = ckRecord["defaultCrew"]
            self.fju.defaultCrewGuid = ckRecord["defaultCrewGuid"]
            self.fju.defaultResources = ckRecord["defaultResources"]
            self.fju.defaultResourcesName = ckRecord["defaultResourcesName"]
            self.fju.division = ckRecord["division"]
            self.fju.emailAddress = ckRecord["emailAddress"]
            self.fju.fdid = ckRecord["fdid"]
            self.fju.fireDepartment = ckRecord["fireDepartment"]
            self.fju.fireDistrict = ckRecord["fireDistrict"]
            if ckRecord["fireJournalUserShift"] != nil {
                self.fju.fireJournalUserShift = ckRecord["fireJournalUserShift"] as! Int64
            } else {
                self.fju.fireJournalUserShift = 0
            }
            self.fju.fireStation = ckRecord["fireStation"]
            self.fju.fireStationAddress = ckRecord["fireStationAddress"]
            self.fju.fireStationAddressTwo = ckRecord["fireStationAddressTwo"]
            self.fju.fireStationCity = ckRecord["fireStationCity"]
            var fdDefaultB: Bool = false
            if ckRecord["fireStationDefault"] != nil {
                let fdDefault: NSNumber = ckRecord["fireStationDefault"] as! NSNumber
                if fdDefault == 1 {
                    fdDefaultB = true
                }
            }
            self.fju.fireStationDefault = fdDefaultB
            self.fju.fireStationGuid = ckRecord["fireStationGuid"]
            self.fju.fireStationOvertimeGuid = ckRecord["ireStationOvertimeGuid"]
            self.fju.fireStationState = ckRecord["fireStationState"]
            self.fju.fireStationStreetName = ckRecord["fireStationStreetName"]
            self.fju.fireStationStreetNumber = ckRecord["fireStationStreetNumber"]
            self.fju.fireStationWebSite = ckRecord["fireStationWebSite"]
            self.fju.fireStationZipCode = ckRecord["fireStationZipCode"]
            self.fju.fjpUserBackedUp = ckRecord["fjpUserBackedUp"] as? NSNumber
            self.fju.fjpUserModDate = ckRecord["fjpUserModDate"] as? Date
            self.fju.fjpUserSearchDate = ckRecord["fjpUserSearchDate"] as? Date
            self.fju.initialApparatus = ckRecord["initialApparatus"]
            self.fju.initialAssignment = ckRecord["initialAssignment"]
            self.fju.middleName = ckRecord["middleName"]
            self.fju.mobileNumber = ckRecord["mobileNumber"]
            self.fju.password = ckRecord["password"]
            self.fju.platoon = ckRecord["platoon"]
            var pDefaultB: Bool = false
            if ckRecord["platoonDefault"] != nil {
                let pDefault = ckRecord["platoonDefault"] as! NSNumber
                if pDefault == 1 {
                    pDefaultB = true
                }
            }
            self.fju.platoonDefault = pDefaultB
            self.fju.platoonGuid = ckRecord["platoonGuid"]
            self.fju.platoonOverTimeGuid = ckRecord["platoonOverTimeGuid"]
            self.fju.rank = ckRecord["rank"]
            var rDefaultB: Bool = false
            if ckRecord["resourcesDefault"] != nil {
                let rDefault = ckRecord["resourcesDefault"] as! NSNumber
                if rDefault == 1 {
                    rDefaultB = true
                }
            }
            self.fju.resourcesDefault = rDefaultB
            self.fju.resourcesGuid = ckRecord["resourcesGuid"]
            self.fju.resourcesOvertimeGuid = ckRecord["resourcesOvertimeGuid"]
            self.fju.resourcesOvertimeName = ckRecord["resourcesOvertimeName"]
            let ssDefaultB: Bool = false
            self.fju.shiftStatusAMorOver = ssDefaultB
            let subDefaultB: Bool = false
            self.fju.subscriptionAccount = subDefaultB
            self.fju.tempApparatus = ckRecord["tempApparatus"]
            self.fju.tempAssignment = ckRecord["tempAssignment"]
            self.fju.tempFireStation = ckRecord["tempFireStation"]
            self.fju.tempPlatoon = ckRecord["tempPlatoon"]
            self.fju.tempResources = ckRecord["tempResources"]
            self.fju.user = ckRecord["user"]
            if ckRecord["userName"] != "" {
                self.fju.userName = ckRecord["userName"]
            } else {
                var fName = ""
                var lName = ""
                if let first:String = ckRecord["firstName"] {
                    fName = first
                }
                if let last:String = ckRecord["lastName"] {
                    lName = last
                }
                self.fju.userName = "\(fName) \(lName)"
            }
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            ckRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            self.fju.fjuCKR = data as NSObject
            
            self.saveToCD()
            
        }  else {
            
            DispatchQueue.main.async {
                
                self.nc.post(name:Notification.Name(rawValue:FJkLOADUSERITMESCALLED),
                        object: nil,
                        userInfo: ["ckRecordType":CKRecordsToLoad.fJkCKRFireJournalUser])
                self.userDefaults.set(false, forKey: FJkFJUSERSavedToCoreDataFromCloud)
                self.bkgrndTask?.endBackgroundTask()
                self.executing(false)
                self.finish(true)
                print("FireJournalUserOperation is done")
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                
            }
        }
        
    }
    
    
        /// the context is from the persistantStore newBackgroundContext
    fileprivate func saveToCD() {
        do {
            try self.context.save()
            
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context, userInfo:["info":"User From Cloud Operation here saving to context"])
                
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue: FJkLOADUSERITMESCALLED),
                        object: nil,
                        userInfo: ["ckRecordType": CKRecordsToLoad.fJkCKRFireJournalUser])
                self.userDefaults.set(true, forKey: FJkFJUSERSavedToCoreDataFromCloud)
                self.bkgrndTask?.endBackgroundTask()
                self.executing(false)
                self.finish(true)
                print("UserFromCloudOperation is done save")
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            let error = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
            print(error)
            DispatchQueue.main.async {
                self.userDefaults.set(false, forKey: FJkFJUSERSavedToCoreDataFromCloud)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                self.bkgrndTask?.endBackgroundTask()
                self.executing(false)
                self.finish(true)
            }
            
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
