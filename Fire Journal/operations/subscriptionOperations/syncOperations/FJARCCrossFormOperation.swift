//
//  FJARCrossFormOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/16/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit


class FJARCCrossFormLoader: FJOperation {

    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjARCFormA = [ARCrossForm]()
    var fjARCForm: ARCrossForm!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid = ""
    
    var theUser: FireJournalUser!
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserContext: NSManagedObjectContext!
    
    var theUserTimeA = [UserTime]()
    
    lazy var userTimeProvider: UserTimeProvider = {
        let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userTimeContext: NSManagedObjectContext!
    
    init(_ context: NSManagedObjectContext, ckArray: [CKRecord]) {
        self.context = context
        self.ckRecordA = ckArray
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    deinit {
        nc.removeObserver(NSNotification.Name.NSManagedObjectContextDidSave)
    }
    
    override func main() {
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector: #selector(checkTheThread), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.bkgrdContext)
        
        executing(true)
        
        let count = theCounter()
        getTheUser()
        getTheUserTime()
        
        if count == 0 {
            chooseNewWithGuid {
                saveToCD()
            }
        } else {
            chooseNewOrUpdate {
                saveToCD()
            }
        }
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
    }
    
    func getTheUser() {
        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
        guard let users = theUserProvider.getTheUser(theUserContext) else {
            return
        }
        let aUser = users.last
        if let id = aUser?.objectID {
            theUser = bkgrdContext.object(with: id) as? FireJournalUser
        }
    }
    
    
    
    func getTheUserTime() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserTime" )
        do {
            theUserTimeA = try bkgrdContext.fetch(fetchRequest) as! [UserTime]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            fjARCFormA = try bkgrdContext.fetch(fetchRequest) as! [ARCrossForm]
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {

        for record in ckRecordA  {
                    newARCrossFormFromCloud(ckRecord: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid = record["arcFormGuid"] as? String  {
                let result = fjARCFormA.filter { $0.arcFormGuid == guid }
                if result.isEmpty {
                    newARCrossFormFromCloud(ckRecord: record)
                } else {
                    fjARCForm = result.last
                    updateARCrossFormFromCioud(fjARCrossRecord: record, fjuARCForm: fjARCForm )
                }
            }
        }
        completion()
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    fileprivate func saveToCD() {
        
        do {
            try self.bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJARCROSS FORM Operation here"])
            }
            DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                 object: nil,
                                 userInfo: ["recordEntity":TheEntities.fjICS214ActivityLog])
                
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            let nserror = error
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                             object: nil,
                             userInfo: ["recordEntity":TheEntities.fjICS214ActivityLog])
                
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
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
    
    private func newARCrossFormFromCloud(ckRecord: CKRecord)->Void {
        
        let fjARCrossRecord = ckRecord
        
        let fjuARCForm = ARCrossForm(context: bkgrdContext)
        
        //     MARK: -INTEGERS
        if let campaignCount = fjARCrossRecord["campaignCount"] as? Int64 {
        fjuARCForm.campaignCount = campaignCount
        }
        //     MARK: -Strings
        if let adminName = fjARCrossRecord["adminName"] as? String {
            fjuARCForm.adminName = adminName
        }
        if let arcFormCampaignGuid = fjARCrossRecord["arcFormCampaignGuid"] as? String {
            fjuARCForm.arcFormCampaignGuid = arcFormCampaignGuid
        }
        if let arcFormGuid = fjARCrossRecord["arcFormGuid"] as? String {
            fjuARCForm.arcFormGuid = arcFormGuid
        }
        if let arcLocaitonState = fjARCrossRecord["arcLocaitonState"] as? String {
            fjuARCForm.arcLocaitonState = arcLocaitonState
        }
        if let arcLocationAddress = fjARCrossRecord["arcLocationAddress"] as? String {
            fjuARCForm.arcLocationAddress = arcLocationAddress
        }
        if let arcLocationAptMobile = fjARCrossRecord["arcLocationAptMobile"] as? String {
            fjuARCForm.arcLocationAptMobile = arcLocationAptMobile
        }
        if let arcLocationCity = fjARCrossRecord["arcLocationCity"] as? String {
            fjuARCForm.arcLocationCity = arcLocationCity
        }
        if let arcLocationZip = fjARCrossRecord["arcLocationZip"] as? String {
            fjuARCForm.arcLocationZip = arcLocationZip
        }
        if let campaignName = fjARCrossRecord["campaignName"] as? String {
            fjuARCForm.campaignName = campaignName
        }
        if let fjUserGuid = fjARCrossRecord["fjUserGuid"] as? String {
            fjuARCForm.fjUserGuid = fjUserGuid
        }
        if let hazard = fjARCrossRecord["hazard"] as? String {
            fjuARCForm.hazard = hazard
        }
        if let ia17Under = fjARCrossRecord["ia17Under"] as? String {
            fjuARCForm.ia17Under = ia17Under
        }
        if let ia65Over = fjARCrossRecord["ia65Over"] as? String {
            fjuARCForm.ia65Over = ia65Over
        }
        if let iaDisability = fjARCrossRecord["iaDisability"] as? String {
            fjuARCForm.iaDisability = iaDisability
        }
        if let iaNotes = fjARCrossRecord["iaNotes"] as? String {
            fjuARCForm.iaNotes = iaNotes
        }
        if let iaNumPeople = fjARCrossRecord["iaNumPeople"] as? String {
            fjuARCForm.iaNumPeople = iaNumPeople
        }
        if let iaPrexistingSA = fjARCrossRecord["iaPrexistingSA"] as? String {
            fjuARCForm.iaPrexistingSA = iaPrexistingSA
        }
        if let iaVets = fjARCrossRecord["iaVets"] as? String {
            fjuARCForm.iaVets = iaVets
        }
        if let iaWorkingSA = fjARCrossRecord["iaWorkingSA"] as? String {
            fjuARCForm.iaWorkingSA = iaWorkingSA
        }
        if let installerName = fjARCrossRecord["installerName"] as? String {
            fjuARCForm.installerName = installerName
        }
        if let journalGuid = fjARCrossRecord["journalGuid"] as? String {
            fjuARCForm.journalGuid = journalGuid
        }
        if let localPartner = fjARCrossRecord["localPartner"] as? String {
            fjuARCForm.localPartner = localPartner
        }
        if let nationalPartner = fjARCrossRecord["nationalPartner"] as? String {
            fjuARCForm.nationalPartner = nationalPartner
        }
        if let numBatteries = fjARCrossRecord["numBatteries"] as? String {
            fjuARCForm.numBatteries = numBatteries
        }
        if let numBedShaker = fjARCrossRecord["numBedShaker"] as? String {
            fjuARCForm.numBedShaker = numBedShaker
        }
        if let numNewSA = fjARCrossRecord["numNewSA"] as? String {
            fjuARCForm.numNewSA = numNewSA
        }
        if let option1 = fjARCrossRecord["option1"] as? String {
            fjuARCForm.option1 = option1
        }
        if let option2 = fjARCrossRecord["option2"] as? String {
            fjuARCForm.option2 = option2
        }
        if let residentCellNum = fjARCrossRecord["residentCellNum"] as? String {
            fjuARCForm.residentCellNum = residentCellNum
        }
        if let residentEmail = fjARCrossRecord["residentEmail"] as? String {
            fjuARCForm.residentEmail = residentEmail
        }
        if let residentName = fjARCrossRecord["residentName"] as? String {
            fjuARCForm.residentName = residentName
        }
        if let residentOtherPhone = fjARCrossRecord["residentOtherPhone"]  as? String {
            fjuARCForm.residentOtherPhone = residentOtherPhone
        }
        //     MARK: -BOOL
        if let arcBackup = fjARCrossRecord["arcBackup"] as? Bool {
            fjuARCForm.arcBackup = arcBackup
        }
        if let arcLocationAvailable = fjARCrossRecord["arcLocationAvailable"] as? Bool {
            fjuARCForm.arcLocationAvailable = arcLocationAvailable
        }
        if let arcMaster = fjARCrossRecord["arcMaster"] as? Bool {
            fjuARCForm.arcMaster = arcMaster
        }
        if let campaign = fjARCrossRecord["campaign"] as? Bool {
            fjuARCForm.campaign = campaign
        }
        if let cComplete = fjARCrossRecord["cComplete"] as? Bool {
            fjuARCForm.cComplete = cComplete
        }
        if let createFEPlan = fjARCrossRecord["createFEPlan"] as? Bool {
            fjuARCForm.createFEPlan = createFEPlan
        }
        if let installerSigend = fjARCrossRecord["installerSigend"] as? Bool {
            fjuARCForm.installerSigend = installerSigend
        }
        if let localHazard = fjARCrossRecord["localHazard"] as? Bool {
            fjuARCForm.localHazard = localHazard
        }
        if let residentContactInfo = fjARCrossRecord["residentContactInfo"] as? Bool {
            fjuARCForm.residentContactInfo = residentContactInfo
        }
        if let residentSigned = fjARCrossRecord["residentSigned"] as? Bool {
            fjuARCForm.residentSigned = residentSigned
        }
        if let reviewFEPlan = fjARCrossRecord["reviewFEPlan"] as? Bool {
            fjuARCForm.reviewFEPlan = reviewFEPlan
        }
        //     MARK: -DATE
        if let adminDate = fjARCrossRecord["adminDate"] as? Date {
            fjuARCForm.adminDate = adminDate
        }
        if let createDate = fjARCrossRecord["arcCreationDate"] as? Date {
            fjuARCForm.arcCreationDate = createDate
        }
        if let modDate = fjARCrossRecord["arcModDate"] as? Date {
            fjuARCForm.arcModDate = modDate
        }
        if let endDate = fjARCrossRecord["cEndDate"] as? Date {
            fjuARCForm.cEndDate = endDate
        }
        if let startDate = fjARCrossRecord["cStartDate"] as? Date {
            fjuARCForm.cStartDate = startDate
        }
        if let installerDate = fjARCrossRecord["installerDate"] as? Date {
            fjuARCForm.installerDate = installerDate
        }
        if let residentSignDate = fjARCrossRecord["residentSigDate"] as? Date {
            fjuARCForm.residentSigDate = residentSignDate
        }
        //     MARK: -ASSETS
        // TODO: -signatures
        if let installerSig = fjARCrossRecord["installerSigend"] as? Bool {
            if installerSig {
                guard let asset: CKAsset = fjARCrossRecord["installerSignature"] else { return }
                    fjuARCForm.installerSignature = imageDataFromCloudKit(asset: asset )
             }
        }
        if let residentSig: Bool = fjARCrossRecord["residentSigned"] as? Bool {
             if residentSig {
                guard let asset: CKAsset = fjARCrossRecord["residentSignature"] else { return }
                 fjuARCForm.residentSignature = imageDataFromCloudKit(asset: asset )
             }
        }
        
        //     MARK: -TRANSFORM
        /// arcLocation archived with secureCodeing
        
        if let location = fjARCrossRecord["arcLocation"] as? CLLocation {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                fjuARCForm.arcLocationSC = data as NSObject
            } catch {
                print("got an error here")
            }
        }
        
        if let userTimeGuid = fjARCrossRecord["userTimeGuid"] as? String {
            fjuARCForm.userTimeGuid = userTimeGuid
            if !theUserTimeA.isEmpty {
                let result = theUserTimeA.filter { $0.userTimeGuid == userTimeGuid }
                if !result.isEmpty {
                    let theUserTime = result.last
                    fjuARCForm.userTime = theUserTime
                }
            }
        }
        
        if theUser != nil {
            fjuARCForm.fireJournalUserDetail = theUser
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjARCrossRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuARCForm.arcFormCKR = data as NSObject
        
    }
    
    func updateARCrossFormFromCioud( fjARCrossRecord: CKRecord, fjuARCForm: ARCrossForm) {
        
            //     MARK: -INTEGERS
            if let campaignCount = fjARCrossRecord["campaignCount"] as? Int64 {
            fjuARCForm.campaignCount = campaignCount
            }
            //     MARK: -Strings
            if let adminName = fjARCrossRecord["adminName"] as? String {
                fjuARCForm.adminName = adminName
            }
            if let arcFormCampaignGuid = fjARCrossRecord["arcFormCampaignGuid"] as? String {
                fjuARCForm.arcFormCampaignGuid = arcFormCampaignGuid
            }
            if let arcFormGuid = fjARCrossRecord["arcFormGuid"] as? String {
                fjuARCForm.arcFormGuid = arcFormGuid
            }
            if let arcLocaitonState = fjARCrossRecord["arcLocaitonState"] as? String {
                fjuARCForm.arcLocaitonState = arcLocaitonState
            }
            if let arcLocationAddress = fjARCrossRecord["arcLocationAddress"] as? String {
                fjuARCForm.arcLocationAddress = arcLocationAddress
            }
            if let arcLocationAptMobile = fjARCrossRecord["arcLocationAptMobile"] as? String {
                fjuARCForm.arcLocationAptMobile = arcLocationAptMobile
            }
            if let arcLocationCity = fjARCrossRecord["arcLocationCity"] as? String {
                fjuARCForm.arcLocationCity = arcLocationCity
            }
            if let arcLocationZip = fjARCrossRecord["arcLocationZip"] as? String {
                fjuARCForm.arcLocationZip = arcLocationZip
            }
            if let campaignName = fjARCrossRecord["campaignName"] as? String {
                fjuARCForm.campaignName = campaignName
            }
            if let fjUserGuid = fjARCrossRecord["fjUserGuid"] as? String {
                fjuARCForm.fjUserGuid = fjUserGuid
            }
            if let hazard = fjARCrossRecord["hazard"] as? String {
                fjuARCForm.hazard = hazard
            }
            if let ia17Under = fjARCrossRecord["ia17Under"] as? String {
                fjuARCForm.ia17Under = ia17Under
            }
            if let ia65Over = fjARCrossRecord["ia65Over"] as? String {
                fjuARCForm.ia65Over = ia65Over
            }
            if let iaDisability = fjARCrossRecord["iaDisability"] as? String {
                fjuARCForm.iaDisability = iaDisability
            }
            if let iaNotes = fjARCrossRecord["iaNotes"] as? String {
                fjuARCForm.iaNotes = iaNotes
            }
            if let iaNumPeople = fjARCrossRecord["iaNumPeople"] as? String {
                fjuARCForm.iaNumPeople = iaNumPeople
            }
            if let iaPrexistingSA = fjARCrossRecord["iaPrexistingSA"] as? String {
                fjuARCForm.iaPrexistingSA = iaPrexistingSA
            }
            if let iaVets = fjARCrossRecord["iaVets"] as? String {
                fjuARCForm.iaVets = iaVets
            }
            if let iaWorkingSA = fjARCrossRecord["iaWorkingSA"] as? String {
                fjuARCForm.iaWorkingSA = iaWorkingSA
            }
            if let installerName = fjARCrossRecord["installerName"] as? String {
                fjuARCForm.installerName = installerName
            }
            if let journalGuid = fjARCrossRecord["journalGuid"] as? String {
                fjuARCForm.journalGuid = journalGuid
            }
            if let localPartner = fjARCrossRecord["localPartner"] as? String {
                fjuARCForm.localPartner = localPartner
            }
            if let nationalPartner = fjARCrossRecord["nationalPartner"] as? String {
                fjuARCForm.nationalPartner = nationalPartner
            }
            if let numBatteries = fjARCrossRecord["numBatteries"] as? String {
                fjuARCForm.numBatteries = numBatteries
            }
            if let numBedShaker = fjARCrossRecord["numBedShaker"] as? String {
                fjuARCForm.numBedShaker = numBedShaker
            }
            if let numNewSA = fjARCrossRecord["numNewSA"] as? String {
                fjuARCForm.numNewSA = numNewSA
            }
            if let option1 = fjARCrossRecord["option1"] as? String {
                fjuARCForm.option1 = option1
            }
            if let option2 = fjARCrossRecord["option2"] as? String {
                fjuARCForm.option2 = option2
            }
            if let residentCellNum = fjARCrossRecord["residentCellNum"] as? String {
                fjuARCForm.residentCellNum = residentCellNum
            }
            if let residentEmail = fjARCrossRecord["residentEmail"] as? String {
                fjuARCForm.residentEmail = residentEmail
            }
            if let residentName = fjARCrossRecord["residentName"] as? String {
                fjuARCForm.residentName = residentName
            }
            if let residentOtherPhone = fjARCrossRecord["residentOtherPhone"]  as? String {
                fjuARCForm.residentOtherPhone = residentOtherPhone
            }
            //     MARK: -BOOL
            if let arcBackup = fjARCrossRecord["arcBackup"] as? Bool {
                fjuARCForm.arcBackup = arcBackup
            }
            if let arcLocationAvailable = fjARCrossRecord["arcLocationAvailable"] as? Bool {
                fjuARCForm.arcLocationAvailable = arcLocationAvailable
            }
            if let arcMaster = fjARCrossRecord["arcMaster"] as? Bool {
                fjuARCForm.arcMaster = arcMaster
            }
            if let campaign = fjARCrossRecord["campaign"] as? Bool {
                fjuARCForm.campaign = campaign
            }
            if let cComplete = fjARCrossRecord["cComplete"] as? Bool {
                fjuARCForm.cComplete = cComplete
            }
            if let createFEPlan = fjARCrossRecord["createFEPlan"] as? Bool {
                fjuARCForm.createFEPlan = createFEPlan
            }
            if let installerSigend = fjARCrossRecord["installerSigend"] as? Bool {
                fjuARCForm.installerSigend = installerSigend
            }
            if let localHazard = fjARCrossRecord["localHazard"] as? Bool {
                fjuARCForm.localHazard = localHazard
            }
            if let residentContactInfo = fjARCrossRecord["residentContactInfo"] as? Bool {
                fjuARCForm.residentContactInfo = residentContactInfo
            }
            if let residentSigned = fjARCrossRecord["residentSigned"] as? Bool {
                fjuARCForm.residentSigned = residentSigned
            }
            if let reviewFEPlan = fjARCrossRecord["reviewFEPlan"] as? Bool {
                fjuARCForm.reviewFEPlan = reviewFEPlan
            }
            //     MARK: -DATE
            if let adminDate = fjARCrossRecord["adminDate"] as? Date {
                fjuARCForm.adminDate = adminDate
            }
            if let createDate = fjARCrossRecord["arcCreationDate"] as? Date {
                fjuARCForm.arcCreationDate = createDate
            }
            if let modDate = fjARCrossRecord["arcModDate"] as? Date {
                fjuARCForm.arcModDate = modDate
            }
            if let endDate = fjARCrossRecord["cEndDate"] as? Date {
                fjuARCForm.cEndDate = endDate
            }
            if let startDate = fjARCrossRecord["cStartDate"] as? Date {
                fjuARCForm.cStartDate = startDate
            }
            if let installerDate = fjARCrossRecord["installerDate"] as? Date {
                fjuARCForm.installerDate = installerDate
            }
            if let residentSignDate = fjARCrossRecord["residentSigDate"] as? Date {
                fjuARCForm.residentSigDate = residentSignDate
            }
            //     MARK: -ASSETS
            // TODO: -signatures
            if let installerSig = fjARCrossRecord["installerSigend"] as? Bool {
                if installerSig {
                    guard let asset: CKAsset = fjARCrossRecord["installerSignature"] else { return }
                        fjuARCForm.installerSignature = imageDataFromCloudKit(asset: asset )
                 }
            }
            if let residentSig: Bool = fjARCrossRecord["residentSigned"] as? Bool {
                 if residentSig {
                    guard let asset: CKAsset = fjARCrossRecord["residentSignature"] else { return }
                     fjuARCForm.residentSignature = imageDataFromCloudKit(asset: asset )
                 }
            }
            
            //     MARK: -TRANSFORM
            /// arcLocation archived with secureCodeing
            
            if let location = fjARCrossRecord["arcLocation"] as? CLLocation {
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                    fjuARCForm.arcLocationSC = data as NSObject
                } catch {
                    print("got an error here")
                }
            }
            
            if let userTimeGuid = fjARCrossRecord["userTimeGuid"] as? String {
                fjuARCForm.userTimeGuid = userTimeGuid
                if !theUserTimeA.isEmpty {
                    let result = theUserTimeA.filter { $0.userTimeGuid == userTimeGuid }
                    if !result.isEmpty {
                        let theUserTime = result.last
                        fjuARCForm.userTime = theUserTime
                    }
                }
            }
            
            if theUser != nil {
                fjuARCForm.fireJournalUserDetail = theUser
            }
            
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            fjARCrossRecord.encodeSystemFields(with: coder)
            let data = coder.encodedData
            fjuARCForm.arcFormCKR = data as NSObject
        
    }
    
    func imageDataFromCloudKit(asset: CKAsset) -> Data {
        var data: Data!
        do {
            data = try Data(contentsOf: asset.fileURL!)
            return data
        } catch {
            print("error in return image f")
        }
        return data
    }
    
}
