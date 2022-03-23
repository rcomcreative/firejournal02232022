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
    var fjARCForm:ARCrossForm!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    
    init(_ context: NSManagedObjectContext, ckArray: [CKRecord]) {
        self.context = context
        self.ckRecordA = ckArray
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        
        //        MARK: -FJOperation operation-
        operation = "FJARCCrossFormLoader"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        executing(true)
        
        let count = theCounter()
        
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
    
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm" )
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
//        ckRecordA = Array(Set(ckRecordA))
        var stringResult = [String]()
        var ckResult = [CKRecord]()
        for record in ckRecordA {
            if stringResult.isEmpty {
                let guid: String = record["arcFormGuid"] ?? ""
                stringResult.append(guid)
                ckResult.append(record)
            }
            let guid: String = record["arcFormGuid"] ?? ""
            let result = stringResult.filter( { $0 == guid })
            if result.isEmpty {
                stringResult.append(guid)
                ckResult.append(record)
            }
        }
        
        for record in ckResult  {
            if let guid:String = record["arcFormGuid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newARCrossFormFromCloud(ckRecord: record)
                }
            }
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["arcFormGuid"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newARCrossFormFromCloud(ckRecord: record)
                } else {
//                    fjARCForm.updateARCrossFormFromTheCloud(ckRecord: record)
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
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"FJARCROSS FORM Operation here"])
            }
            DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                 object: nil,
                                 userInfo: ["recordEntity":TheEntities.fjAttendee])
                
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
                             userInfo: ["recordEntity":TheEntities.fjAttendee])
                
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
    
    private func theCount(guid: String)->Int {
        let attribute = "arcFormGuid"
        let entity = "ARCrossForm"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            fjARCFormA = try context.fetch(fetchRequest) as! [ARCrossForm]
            fjARCForm = fjARCFormA.last
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    private func newARCrossFormFromCloud(ckRecord: CKRecord)->Void {
        let fjARCrossRecord = ckRecord
        
        let fjuARCForm = ARCrossForm.init(entity: NSEntityDescription.entity(forEntityName: "ARCrossForm", in: bkgrdContext)!, insertInto: bkgrdContext)
        
        //     MARK: -INTEGERS
        fjuARCForm.campaignCount = fjARCrossRecord["campaignCount"] ?? 0
        //     MARK: -Strings
        if let adminName:String = fjARCrossRecord["adminName"] {
            fjuARCForm.adminName = adminName
        }
        if let arcFormCampaignGuid:String = fjARCrossRecord["arcFormCampaignGuid"] {
            fjuARCForm.arcFormCampaignGuid = arcFormCampaignGuid
        }
        if let arcFormGuid:String = fjARCrossRecord["arcFormGuid"] {
            fjuARCForm.arcFormGuid = arcFormGuid
        }
        if let arcLocaitonState:String = fjARCrossRecord["arcLocaitonState"] {
            fjuARCForm.arcLocaitonState = arcLocaitonState
        }
        if let arcLocationAddress:String = fjARCrossRecord["arcLocationAddress"] {
            fjuARCForm.arcLocationAddress = arcLocationAddress
        }
        if let arcLocationAptMobile:String = fjARCrossRecord["arcLocationAptMobile"] {
            fjuARCForm.arcLocationAptMobile = arcLocationAptMobile
        }
        if let arcLocationCity:String = fjARCrossRecord["arcLocationCity"] {
            fjuARCForm.arcLocationCity = arcLocationCity
        }
        if let arcLocationZip:String = fjARCrossRecord["arcLocationZip"] {
            fjuARCForm.arcLocationZip = arcLocationZip
        }
        if let campaignName:String = fjARCrossRecord["campaignName"] {
            fjuARCForm.campaignName = campaignName
        }
        if let fjUserGuid:String = fjARCrossRecord["fjUserGuid"] {
            fjuARCForm.fjUserGuid = fjUserGuid
        }
        if let hazard:String = fjARCrossRecord["hazard"] {
            fjuARCForm.hazard = hazard
        }
        if let ia17Under:String = fjARCrossRecord["ia17Under"] {
            fjuARCForm.ia17Under = ia17Under
        }
        if let ia65Over:String = fjARCrossRecord["ia65Over"] {
            fjuARCForm.ia65Over = ia65Over
        }
        if let iaDisability:String = fjARCrossRecord["iaDisability"] {
            fjuARCForm.iaDisability = iaDisability
        }
        if let iaNotes:String = fjARCrossRecord["iaNotes"] {
            fjuARCForm.iaNotes = iaNotes
        }
        if let iaNumPeople:String = fjARCrossRecord["iaNumPeople"] {
            fjuARCForm.iaNumPeople = iaNumPeople
        }
        if let iaPrexistingSA:String = fjARCrossRecord["iaPrexistingSA"] {
            fjuARCForm.iaPrexistingSA = iaPrexistingSA
        }
        if let iaVets:String = fjARCrossRecord["iaVets"] {
            fjuARCForm.iaVets = iaVets
        }
        if let iaWorkingSA:String = fjARCrossRecord["iaWorkingSA"] {
            fjuARCForm.iaWorkingSA = iaWorkingSA
        }
        if let installerName:String = fjARCrossRecord["installerName"] {
            fjuARCForm.installerName = installerName
        }
        if let journalGuid:String = fjARCrossRecord["journalGuid"] {
            fjuARCForm.journalGuid = journalGuid
        }
        if let localPartner:String = fjARCrossRecord["localPartner"] {
            fjuARCForm.localPartner = localPartner
        }
        if let nationalPartner:String = fjARCrossRecord["nationalPartner"] {
            fjuARCForm.nationalPartner = nationalPartner
        }
        if let numBatteries:String = fjARCrossRecord["numBatteries"] {
            fjuARCForm.numBatteries = numBatteries
        }
        if let numBedShaker:String = fjARCrossRecord["numBedShaker"] {
            fjuARCForm.numBedShaker = numBedShaker
        }
        if let numNewSA:String = fjARCrossRecord["numNewSA"] {
            fjuARCForm.numNewSA = numNewSA
        }
        if let option1:String = fjARCrossRecord["option1"] {
            fjuARCForm.option1 = option1
        }
        if let option2:String = fjARCrossRecord["option2"] {
            fjuARCForm.option2 = option2
        }
        if let residentCellNum:String = fjARCrossRecord["residentCellNum"] {
            fjuARCForm.residentCellNum = residentCellNum
        }
        if let residentEmail:String = fjARCrossRecord["residentEmail"]{
            fjuARCForm.residentEmail = residentEmail
        }
        if let residentName:String = fjARCrossRecord["residentName"] {
            fjuARCForm.residentName = residentName
        }
        if let residentOtherPhone:String = fjARCrossRecord["residentOtherPhone"] {
            fjuARCForm.residentOtherPhone = residentOtherPhone
        }
        //     MARK: -BOOL
        if fjARCrossRecord["arcBackup"] ?? false {
            fjuARCForm.arcBackup = true
        } else {
            fjuARCForm.arcBackup = false
        }
        if fjARCrossRecord["arcLocationAvailable"] ?? false {
            fjuARCForm.arcLocationAvailable = true
        } else {
            fjuARCForm.arcLocationAvailable = false
        }
        if fjARCrossRecord["arcMaster"] ?? false {
            fjuARCForm.arcMaster = true
        } else {
            fjuARCForm.arcMaster = false
        }
        if fjARCrossRecord["campaign"] ?? false {
            fjuARCForm.campaign = true
        } else {
            fjuARCForm.campaign = false
        }
        if fjARCrossRecord["cComplete"] ?? false {
            fjuARCForm.cComplete = true
        } else {
            fjuARCForm.cComplete = false
        }
        if fjARCrossRecord["createFEPlan"] ?? false {
            fjuARCForm.createFEPlan = true
        } else {
            fjuARCForm.createFEPlan = false
        }
        if fjARCrossRecord["installerSigend"] ?? false {
            fjuARCForm.installerSigend = true
        } else {
            fjuARCForm.installerSigend = false
        }
        if fjARCrossRecord["localHazard"] ?? false {
            fjuARCForm.localHazard = true
        } else {
            fjuARCForm.localHazard = false
        }
        if fjARCrossRecord["residentContactInfo"] ?? false {
            fjuARCForm.residentContactInfo = true
        } else {
            fjuARCForm.residentContactInfo = false
        }
        if fjARCrossRecord["residentSigned"] ?? false {
            fjuARCForm.residentSigned = true
        } else {
            fjuARCForm.residentSigned = false
        }
        if fjARCrossRecord["reviewFEPlan"] ?? false {
            fjuARCForm.reviewFEPlan = true
        } else {
            fjuARCForm.reviewFEPlan = false
        }
        //     MARK: -DATE
        if let adminDate:Date = fjARCrossRecord["adminDate"] {
            fjuARCForm.adminDate = adminDate
        }
        if let createDate:Date = fjARCrossRecord["arcCreationDate"] {
            fjuARCForm.arcCreationDate = createDate
        }
        if let modDate:Date = fjARCrossRecord["arcModDate"] {
            fjuARCForm.arcModDate = modDate
        }
        if let endDate:Date = fjARCrossRecord["cEndDate"] {
            fjuARCForm.cEndDate = endDate
        }
        if let startDate:Date = fjARCrossRecord["cStartDate"] {
            fjuARCForm.cStartDate = startDate
        }
        if let installerDate:Date = fjARCrossRecord["installerDate"] {
            fjuARCForm.installerDate = installerDate
        }
        if let residentSignDate:Date = fjARCrossRecord["residentSigDate"] {
            fjuARCForm.residentSigDate = residentSignDate
        }
        //     MARK: -ASSETS
        // TODO: -signatures
        let installerSig: Bool = fjARCrossRecord["installerSigend"] ?? false
        if installerSig {
            guard let asset: CKAsset = fjARCrossRecord["installerSignature"] else { return }
                fjuARCForm.installerSignature = imageDataFromCloudKit(asset: asset )
         }
         let residentSig: Bool = fjARCrossRecord["residentSigned"] ?? false
         if residentSig {
            guard let asset: CKAsset = fjARCrossRecord["residentSignature"] else { return }
             fjuARCForm.residentSignature = imageDataFromCloudKit(asset: asset )
         }
        
        //     MARK: -TRANSFORM
        /// arcLocation archived with secureCodeing
        if fjARCrossRecord["arcLocation"] != nil {
            let location = fjARCrossRecord["arcLocation"] as! CLLocation
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                fjuARCForm.arcLocationSC = data as NSObject
            } catch {
                print("got an error here")
            }
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjARCrossRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuARCForm.arcFormCKR = data as NSObject
        print("fjuARCForm set for save from record guid \(fjuARCForm.arcFormGuid ?? "no guid")")
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
    
    
    
    fileprivate func saveTheCD() {
        do {
            try self.bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"FJARCROSS FORM Operation here"])
            }
            print("ARCrossForm+CustomAdditions.swift we have saved from the cloud")
        } catch {
            
            let nserror = error as NSError
            
            let errorMessage = "ARCrossForm+CustomAdditions saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    
}
