//
//  ARCFormProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/14/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class ARCFormProvider: NSObject, NSFetchedResultsControllerDelegate {
    
    private(set) var persistentContainer: NSPersistentContainer
    var ckRecord: CKRecord!
    var theARCrossForm: ARCrossForm!
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase: CKDatabase!
    var context: NSManagedObjectContext!
    let nc = NotificationCenter.default
    var arcCKRecord: CKRecord!
    
    private var fetchedResultsController: NSFetchedResultsController<ARCrossForm>? = nil
    var _fetchedResultsController: NSFetchedResultsController<ARCrossForm> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    deinit {
        print("ARCrossForm is being deinitialized")
    }
    
    var fetchedObjects: [ARCrossForm] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.privateDatabase = myContainer.privateCloudDatabase
        super.init()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func singleARCrossFromTheCloud(ckRecord: CKRecord, dateFormatter: DateFormatter,_ arCrossForm: ARCrossForm, _ context: NSManagedObjectContext, completionHandler: (() -> Void)? = nil) {
        
        self.arcCKRecord = ckRecord
        self.theARCrossForm = arCrossForm
        self.context = context
        
        if let admin =  self.arcCKRecord["adminName"] as? String {
                   self.theARCrossForm.adminName = admin
               }
               if let guid = self.arcCKRecord["arcFormCampaignGuid"] as? String {
                   self.theARCrossForm.arcFormCampaignGuid  = guid
               }
               if let guid = self.arcCKRecord["arcFormGuid"] as? String {
                   self.theARCrossForm.arcFormGuid  = guid
               }
               if let address = self.arcCKRecord["arcLocationAddress"] as? String {
                   self.theARCrossForm.arcLocationAddress = address
               }
               if let apt = self.arcCKRecord["arcLocationAptMobile"] as? String {
                   self.theARCrossForm.arcLocationAptMobile = apt
               }
               if let city = self.arcCKRecord["arcLocationCity"] as? String {
                   self.theARCrossForm.arcLocationCity = city
               }
               if let lat = self.arcCKRecord["arcLocationLatitude"] as? String {
                   self.theARCrossForm.arcLocationLatitude = lat
               }
               if let long = self.arcCKRecord["arcLocationLongitude"] as? String {
                   self.theARCrossForm.arcLocationLongitude = long
               }
               if let state = self.arcCKRecord["arcLocaitonState"] as? String{
                   self.theARCrossForm.arcLocaitonState = state
               }
               if let street = self.arcCKRecord["arcLocationStreetName"] as? String {
                   self.theARCrossForm.arcLocationStreetName = street
               }
               if let num = self.arcCKRecord["arcLocationStreetNum"] as? String {
                   self.theARCrossForm.arcLocationStreetNum = num
               }
               if let zip = self.arcCKRecord["arcLocationZip"] as? String {
                   self.theARCrossForm.arcLocationZip = zip
               }
               if let portal = self.arcCKRecord["arcPortalSystem"] as? String {
                   self.theARCrossForm.arcPortalSystem = portal
               }
               if let name = self.arcCKRecord["campaignName"] as? String {
                   self.theARCrossForm.campaignName = name
               }
               if let residence = self.arcCKRecord["campaignResidenceType"] as? String {
                   self.theARCrossForm.campaignResidenceType = residence
               }
               if let guid = self.arcCKRecord["fjUserGuid"] as? String {
                   self.theARCrossForm.fjUserGuid = guid
               }
               if let hazard = self.arcCKRecord["hazard"] as? String {
                   self.theARCrossForm.hazard = hazard
               }
               if let ia17 = self.arcCKRecord["ia17Under"] as? String {
                   self.theARCrossForm.ia17Under = ia17
               }
               if let ia65 = self.arcCKRecord["ia65Over"] as? String {
                   self.theARCrossForm.ia65Over = ia65
               }
               if let how = self.arcCKRecord["iaHowOldSA"] as? String {
                   self.theARCrossForm.iaHowOldSA = how
               }
               if let note = self.arcCKRecord["iaNotes"] as? String {
                   self.theARCrossForm.iaNotes = note
               }
               if let num = self.arcCKRecord["iaNumPeople"] as? String {
                   self.theARCrossForm.iaNumPeople = num
               }
               if let pre = self.arcCKRecord["iaPrexistingSA"] as? String {
                   self.theARCrossForm.iaPrexistingSA = pre
               }
               if let vet = self.arcCKRecord["iaVets"] as? String {
                   self.theARCrossForm.iaVets = vet
               }
               if let work = self.arcCKRecord["iaWorkingSA"] as? String {
                   self.theARCrossForm.iaWorkingSA = work
               }
               if let disability = self.arcCKRecord["iaDisability"] as? String {
                   self.theARCrossForm.iaDisability = disability
               }
               if let installer = self.arcCKRecord["installerName"] as? String {
                   self.theARCrossForm.installerName = installer
               }
               if let jGuid = self.arcCKRecord["journalGuid"] as? String {
                   self.theARCrossForm.journalGuid = jGuid
               }
               if let partner = self.arcCKRecord["localPartner"] as? String {
                   self.theARCrossForm.localPartner = partner
               }
               if let national = self.arcCKRecord["nationalPartner"] as? String {
                   self.theARCrossForm.nationalPartner = national
               }
               if let batteries = self.arcCKRecord["numBatteries"] as? String {
                   self.theARCrossForm.numBatteries = batteries
               }
               if let shaker = self.arcCKRecord["numBedShaker"] as? String {
                   self.theARCrossForm.numBedShaker = shaker
               }
               if let detector = self.arcCKRecord["numC02detectors"] as? String {
                   self.theARCrossForm.numC02detectors = detector
               }
               if let new = self.arcCKRecord["numNewSA"] as? String {
                   self.theARCrossForm.numNewSA = new
               }
               if let option = self.arcCKRecord["option1"] as? String {
                   self.theARCrossForm.option1 = option
               }
               if let optionTwo = self.arcCKRecord["option2"] as? String {
                   self.theARCrossForm.option2 = optionTwo
               }
               if let cell = self.arcCKRecord["residentCellNum"] as? String {
                   self.theARCrossForm.residentCellNum = cell
               }
               if let email = self.arcCKRecord["residentEmail"] as? String {
                   self.theARCrossForm.residentEmail = email
               }
               if let name = self.arcCKRecord["residentName"] as? String {
                   self.theARCrossForm.residentName = name
               }
               if let phone = self.arcCKRecord["residentOtherPhone"] as? String {
                   self.theARCrossForm.residentOtherPhone = phone
               }
               
               //        MARK: -ARC dates-
               if let admin = self.arcCKRecord["adminDate"] as? Date {
                   self.theARCrossForm.adminDate = admin
               }
               if let creation = self.arcCKRecord["arcCreationDate"] as? Date {
                   self.theARCrossForm.arcCreationDate = creation
               }
               if let mod = self.arcCKRecord["arcModDate"] as? Date {
                   self.theARCrossForm.arcModDate = mod
               }
               if let end = self.arcCKRecord["cEndDate"] as? Date {
                   self.theARCrossForm.cEndDate = end
               }
               if let start = self.arcCKRecord["cStartDate"] as? Date {
                   self.theARCrossForm.cStartDate = start
               }
               if let install = self.arcCKRecord["installerDate"] as? Date {
                   self.theARCrossForm.installerDate = install
               }
               if let sign = self.arcCKRecord["residentSigDate"] as? Date {
                   self.theARCrossForm.residentSigDate = sign
               }
               
               //        MARK: -ARC Bool Values-
               self.theARCrossForm.arcBackup = true
        
        
        if let arcLocationAvailable = self.arcCKRecord["arcLocationAvailable"] as? Double {
            self.theARCrossForm.arcLocationAvailable  = Bool(truncating: arcLocationAvailable as NSNumber)
        }
        if let arcMaster = self.arcCKRecord["arcMaster"] as? Double {
            self.theARCrossForm.arcMaster  = Bool(truncating: arcMaster as NSNumber)
        }
        if let campaign = self.arcCKRecord["campaign"] as? Double {
            self.theARCrossForm.campaign  = Bool(truncating: campaign as NSNumber)
        }
        if let cComplete = self.arcCKRecord["cComplete"] as? Double {
            self.theARCrossForm.cComplete  = Bool(truncating: cComplete as NSNumber)
        }
        if let createFEPlan = self.arcCKRecord["createFEPlan"] as? Double {
            self.theARCrossForm.createFEPlan  = Bool(truncating: createFEPlan as NSNumber)
        }
        if let installerSigend = self.arcCKRecord["installerSigend"] as? Double {
            self.theARCrossForm.installerSigend  = Bool(truncating: installerSigend as NSNumber)
        }
        if let localHazard = self.arcCKRecord["localHazard"] as? Double {
            self.theARCrossForm.localHazard  = Bool(truncating: localHazard as NSNumber)
        }
        if let receiveSPM = self.arcCKRecord["receiveSPM"] as? Double {
            self.theARCrossForm.receiveSPM  = Bool(truncating: receiveSPM as NSNumber)
        }
        if let recieveEP = self.arcCKRecord["recieveEP"] as? Double {
            self.theARCrossForm.recieveEP  = Bool(truncating: recieveEP as NSNumber)
        }
        if let residentContactInfo = self.arcCKRecord["residentContactInfo"] as? Double {
            self.theARCrossForm.residentContactInfo  = Bool(truncating: residentContactInfo as NSNumber)
        }
        if let residentSigned = self.arcCKRecord["residentSigned"] as? Double {
            self.theARCrossForm.residentSigned  = Bool(truncating: residentSigned as NSNumber)
        }
        if let reviewFEPlan = self.arcCKRecord["reviewFEPlan"] as? Double {
            self.theARCrossForm.reviewFEPlan  = Bool(truncating: reviewFEPlan as NSNumber)
        }
               
               //        MARK: - ARC ASSETS-
               if self.theARCrossForm.installerSigend {
                   if let data: CKAsset = self.arcCKRecord["installerSignature"] {
                       self.theARCrossForm.installerSignature = imageDataFromCloudKit(asset: data)
                   }
               }
               if self.theARCrossForm.residentSigned {
                   if let data: CKAsset = self.arcCKRecord["residentSignature"] {
                       self.theARCrossForm.residentSignature = imageDataFromCloudKit(asset: data)
                   }
               }
               
               //        MARK: -INTEGER-
               if self.arcCKRecord["campaignCount"] != nil {
                   self.theARCrossForm.campaignCount = self.arcCKRecord["campaignCount"] as! Int64
               }
               //        MARK: -LOCATION-
               if self.arcCKRecord["arcLocation"] != nil {
                   let location = self.arcCKRecord["arcLocation"] as! CLLocation
                   do {
                       let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                       self.theARCrossForm.arcLocationSC = data as NSObject
                   } catch {
                       print("got an error here")
                   }
               }
               
               
               
               //                MARK: -Save encoded ckrecord-
               let coder = NSKeyedArchiver(requiringSecureCoding: true)
               arcCKRecord.encodeSystemFields(with: coder)
               let data = coder.encodedData
               self.theARCrossForm.arcFormCKR = data as NSObject
        
        saveTheSingleCD() {_ in
            completionHandler?()
        }
        
    }
    
        //    MARK: -Image from CloudKit to CoreData
        /// Take CKAsset from CloudKit -signature, move it to Data
        /// - Parameter asset: CKAsset
        /// - Returns: Data object
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
    
    
    private func saveTheSingleCD(withCompletion completion: @escaping (String) -> Void) {
        if self.context != nil {
            do {
                try self.context?.save()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ARCrossForm Saved"])
                    print("project we have saved to the cloud")
                }
                completion("Success")
            } catch {
                let nserror = error as NSError
                
                let error = "The ARCrossFormProvider context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
                print(error)
                completion("Error")
            }
        }
    }
    
}
