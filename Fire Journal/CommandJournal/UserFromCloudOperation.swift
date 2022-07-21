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
import CoreLocation

class UserFromCloudOperation: FJOperation {
    
    lazy var userProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userContext: NSManagedObjectContext!
    
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
    var fju: FireJournalUser!
    var theLocation: FCLocation!
    let nc = NotificationCenter.default
    
    init(_ context: NSManagedObjectContext, database: CKDatabase) {
        self.context = context
        self.privateDatabase = database
        super.init()
        userContext = userProvider.persistentContainer.newBackgroundContext()
    }
    
    override func main() {
        
        guard isCancelled == false else {
            self.userDefaults.set(false, forKey: FJkFJUSERSavedToCoreDataFromCloud)
            self.executing(false)
            self.finish(true)
            print("UserFromCloudOperation is done save")
            self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            return
        }
        
        DispatchQueue.main.async {
            self.userDefaults.set(false, forKey: FJkFJUSERSavedToCoreDataFromCloud)
        }
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.userContext)
        executing(true)
        
        getTheData() {
            self.saveTheUser()
        }
        
        guard isCancelled == false else {
            self.userDefaults.set(false, forKey: FJkFJUSERSavedToCoreDataFromCloud)
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
        
        operation.recordMatchedBlock = { recordid, result in
            switch result {
            case .success(let record):
                newUsersRecordsA.append(record)
            case .failure(let error):
                print("error on retrieving status \(error)")
            }
        }
        
        operation.queryResultBlock = { [unowned self] result in
            switch result {
            case .success(_):
                if !newUsersRecordsA.isEmpty {
                    let theResult = newUsersRecordsA.sorted(by: { return $0.creationDate! < $1.creationDate! })
                    self.ckRecord = theResult.last!
                    completionHandler()
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
    
        /// If CKRecord exists - save it to fireJournalUser else cancel operation
    private func saveTheUser() {
        
        if ckRecord != nil {
            
            self.fju = FireJournalUser(context: self.userContext)
            self.theLocation = FCLocation(context: self.userContext)
            self.fju.theLocation = self.theLocation
            
            if let displayOrder = ckRecord["displayOrder"] as? NSNumber {
                self.fju.displayOrder = displayOrder
            }
            if let fireJournalUserShift = ckRecord["fireJournalUserShift"] as? Int64 {
                self.fju.fireJournalUserShift = fireJournalUserShift
            }
            
            if let apparatusDefault = ckRecord["apparatusDefault"] as? Double {
                self.fju.apparatusDefault  = Bool(truncating: apparatusDefault as NSNumber)
            }
            if let assignmentDefault = ckRecord["assignmentDefault"] as? Double {
                self.fju.assignmentDefault  = Bool(truncating: assignmentDefault as NSNumber)
            }
            if let crewDefault = ckRecord["crewDefault"] as? Double {
                self.fju.crewDefault  = Bool(truncating: crewDefault as NSNumber)
            }
            if let fireStationDefault = ckRecord["fireStationDefault"] as? Double {
                self.fju.fireStationDefault  = Bool(truncating: fireStationDefault as NSNumber)
            }
            if let platoonDefault = ckRecord["platoonDefault"] as? Double {
                self.fju.platoonDefault  = Bool(truncating: platoonDefault as NSNumber)
            }
            if let resourcesDefault = ckRecord["resourcesDefault"] as? Double {
                self.fju.resourcesDefault  = Bool(truncating: resourcesDefault as NSNumber)
            }
            if let shiftStatusAMorOver = ckRecord["shiftStatusAMorOver"] as? Double {
                self.fju.shiftStatusAMorOver  = Bool(truncating: shiftStatusAMorOver as NSNumber)
            }
            if let subscriptionAccount = ckRecord["subscriptionAccount"] as? Double {
                self.fju.subscriptionAccount  = Bool(truncating: subscriptionAccount as NSNumber)
            }
            if let fjpUserBackedUp = ckRecord["fjpUserBackedUp"] as? Double {
                self.fju.fjpUserBackedUp  = fjpUserBackedUp as NSNumber
            }
            
            
            if let fjpUserModDate = ckRecord["fjpUserModDate"] as? Date {
                self.fju.fjpUserModDate = fjpUserModDate
            }
            if let fjpUserSearchDate = ckRecord["fjpUserSearchDate"] as? Date {
                self.fju.fjpUserSearchDate = fjpUserSearchDate
            }
            if let dateHired = ckRecord["dateHired"] as? Date {
            self.fju.dateHired = dateHired
            }
            

            if let userGuid = ckRecord["usarGuid"] as? String {
                self.fju.userGuid = userGuid
                self.theLocation.userGuid = userGuid
            } else {
                self.fju.userGuid = ckRecord.recordID.recordName
                self.theLocation.userGuid = ckRecord.recordID.recordName
            }
            
            var userName: String = ""
            if let first = ckRecord["firstName"] as? String {
            self.fju.firstName = first
            userName = first + " "
            }
            if let lastName = ckRecord["lastName"] as? String {
            self.fju.lastName = lastName
            userName = userName + lastName
            }
            if let usersName = ckRecord["userName"] as? String {
                self.fju.userName = usersName
            } else {
                self.fju.userName = userName
            }
            if let apparatusGuid = ckRecord["apparatusGuid"] as? String {
            self.fju.apparatusGuid = apparatusGuid
            }
            if let assignmentGuid = ckRecord["assignmentGuid"] as? String {
            self.fju.assignmentGuid = assignmentGuid
            }
            if let battalion = ckRecord["battalion"] as? String {
            self.fju.battalion = battalion
            }
            if let cnIdentifier = ckRecord["cnIdentifier"] as? String {
            self.fju.cnIdentifier = cnIdentifier
            }
            if let crewOvertime = ckRecord["crewOvertime"] as? String {
            self.fju.crewOvertime = crewOvertime
            }
            if let crewOvertimeGuid = ckRecord["crewOvertimeGuid"] as? String {
            self.fju.crewOvertimeGuid = crewOvertimeGuid
            }
            if let crewOvertimeName = ckRecord["crewOvertimeName"] as? String {
            self.fju.crewOvertimeName = crewOvertimeName
            }
            if let deafultCrewName = ckRecord["deafultCrewName"] as? String {
            self.fju.deafultCrewName = deafultCrewName
            }
            if let defaultCrew = ckRecord["defaultCrew"] as? String {
            self.fju.defaultCrew = defaultCrew
            }
            if let defaultCrewGuid = ckRecord["defaultCrewGuid"] as? String {
            self.fju.defaultCrewGuid = defaultCrewGuid
            }
            if let defaultResources = ckRecord["defaultResources"] as? String {
            self.fju.defaultResources = defaultResources
            }
            if let defaultResourcesName = ckRecord["defaultResourcesName"] as? String {
            self.fju.defaultResourcesName = defaultResourcesName
            }
            if let division = ckRecord["division"] as? String {
            self.fju.division = division
            }
            if let emailAddress = ckRecord["emailAddress"] as? String {
            self.fju.emailAddress = emailAddress
            }
            if let fdid = ckRecord["fdid"] as? String {
            self.fju.fdid = fdid
            }
            if let fireDepartment = ckRecord["fireDepartment"] as? String {
            self.fju.fireDepartment = fireDepartment
            }
            if let fireDistrict = ckRecord["fireDistrict"] as? String {
            self.fju.fireDistrict = fireDistrict
            }
            if let fireStation = ckRecord["fireStation"] as? String {
            self.fju.fireStation = fireStation
            }
            if let fireStationGuid = ckRecord["fireStationGuid"] as? String {
            self.fju.fireStationGuid = fireStationGuid
            }
            if let fireStationOvertimeGuid = ckRecord["fireStationOvertimeGuid"] as? String {
            self.fju.fireStationOvertimeGuid = fireStationOvertimeGuid
            }
            if let fireStationWebSite = ckRecord["fireStationWebSite"] as? String {
            self.fju.fireStationWebSite = fireStationWebSite
            }
            if let initialApparatus = ckRecord["initialApparatus"] as? String {
            self.fju.initialApparatus = initialApparatus
            }
            if let initialAssignment = ckRecord["initialAssignment"] as? String {
            self.fju.initialAssignment = initialAssignment
            }
            if let middleName = ckRecord["middleName"] as? String {
            self.fju.middleName = middleName
            }
            if let mobileNumber = ckRecord["mobileNumber"] as? String {
            self.fju.mobileNumber = mobileNumber
            }
            if let password = ckRecord["password"] as? String {
            self.fju.password = password
            }
            if let platoon = ckRecord["platoon"] as? String {
            self.fju.platoon = platoon
            }
            if let platoonGuid = ckRecord["platoonGuid"] as? String {
            self.fju.platoonGuid = platoonGuid
            }
            if let platoonOverTimeGuid = ckRecord["platoonOverTimeGuid"] as? String {
            self.fju.platoonOverTimeGuid = platoonOverTimeGuid
            }
            if let rank = ckRecord["rank"] as? String {
            self.fju.rank = rank
            }
            if let resourcesGuid = ckRecord["resourcesGuid"] as? String {
            self.fju.resourcesGuid = resourcesGuid
            }
            if let resourcesOvertimeGuid = ckRecord["resourcesOvertimeGuid"] as? String {
            self.fju.resourcesOvertimeGuid = resourcesOvertimeGuid
            }
            if let resourcesOvertimeName = ckRecord["resourcesOvertimeName"] as? String {
            self.fju.resourcesOvertimeName = resourcesOvertimeName
            }
            if let tempApparatus = ckRecord["tempApparatus"] as? String {
            self.fju.tempApparatus = tempApparatus
            }
            if let tempAssignment = ckRecord["tempAssignment"] as? String {
            self.fju.tempAssignment = tempAssignment
            }
            if let tempFireStation = ckRecord["tempFireStation"] as? String {
            self.fju.tempFireStation = tempFireStation
            }
            if let tempPlatoon = ckRecord["tempPlatoon"] as? String {
            self.fju.tempPlatoon = tempPlatoon
            }
            if let tempResources = ckRecord["tempResources"] as? String {
            self.fju.tempResources = tempResources
            }
            if let user = ckRecord["user"] as? String {
            self.fju.user = user
            }
            
            
            if let location = ckRecord["fjuLocationSC"] as? CLLocation {
                self.theLocation.location = location
                self.theLocation.latitude = location.coordinate.latitude
                self.theLocation.longitude = location.coordinate.longitude
            }
            
            var address: String = ""
            if let streetNumber = ckRecord["fireStationStreetNumber"] as? String {
                address = streetNumber + " "
                self.theLocation.streetNumber = streetNumber
            }
            if let streetName = ckRecord["fireStationStreetName"] as? String {
                address = address + streetName + " "
                self.theLocation.streetName = streetName
            }
            if let fireStationCity = ckRecord["fireStationCity"] as? String {
                address = address + fireStationCity + " "
                self.theLocation.city = fireStationCity
            }
            if let fireStationState = ckRecord["fireStationState"] as? String {
                address = address + fireStationState + " "
                self.theLocation.state = fireStationState
            }
            if let zip = ckRecord["fireStationZipCode"] as? String {
                address = address + zip
                self.theLocation.zip = zip
                self.fju.fireStationAddress = address
            }
            
            if address != "" {
                if self.theLocation.location == nil {
                    let geocoder = CLGeocoder()
                    
                    geocoder.geocodeAddressString(address) {
                        placemarks, error in
                        let placemark = placemarks?.first
                        if let location = placemark?.location {
                            self.theLocation.location = location
                            self.theLocation.latitude = location.coordinate.latitude
                            self.theLocation.longitude = location.coordinate.longitude
                        }
                    }
                }
            }
            
            
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            ckRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            self.fju.fjuCKR = data as NSObject
            
            self.saveToCD()
            
        }  else {
            
            DispatchQueue.main.async {
                
                self.nc.post(name:Notification.Name(rawValue: FJkLOADUSERITMESCALLED),
                        object: nil,
                        userInfo: ["ckRecordType": CKRecordsToLoad.fJkCKRFireJournalUser])
                self.userDefaults.set(false, forKey: FJkFJUSERSavedToCoreDataFromCloud)
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
            try self.userContext.save()
            
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.userContext, userInfo:["info":"User From Cloud Operation here saving to context"])
                
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue: FJkLOADUSERITMESCALLED),
                        object: nil,
                        userInfo: ["ckRecordType": CKRecordsToLoad.fJkCKRFireJournalUser])
                self.userDefaults.set(true, forKey: FJkFJUSERSavedToCoreDataFromCloud)
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
