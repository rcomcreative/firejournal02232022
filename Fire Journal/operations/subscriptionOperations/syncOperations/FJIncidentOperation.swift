    //
    //  FJIncidentOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 11/16/18.
    //  Copyright © 2020 PureCommand, LLC. All rights reserved.
    //

import Foundation
import UIKit
import CoreData
import CloudKit


class FJIncidentLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var fjIncidentA = [Incident]()
    var fjIncident: Incident!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    
    var theUser: FireJournalUser!
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserContext: NSManagedObjectContext!
    
    init(_ context: NSManagedObjectContext, ckArray: [CKRecord]) {
        self.context = context
        self.ckRecordA = ckArray
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        
            //        MARK: -FJOperation operation-
        operation = "FJIncidentLoader"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        thread = Thread(target:self, selector:#selector(checkTheThread), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.bkgrdContext)
        executing(true)
        
        let count = theCounter()
        
        getTheUser()
        
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
            finish(true)
            return
        }
        
    }
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident" )
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            fjIncidentA = try bkgrdContext.fetch(fetchRequest) as! [Incident]
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            newIncidentFromCloud(record: record)
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["fjpIncGuidForReference"] {
                let result = fjIncidentA.filter { $0.fjpIncGuidForReference == guid }
                if result.isEmpty {
                    newIncidentFromCloud(record: record)
                } else {
                    fjIncident = result.last
                    updateIncidentFromCloud(fjIncidentR: record, fjuIncident: fjIncident)
                }
            }
        }
        completion()
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
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
    
    func updateIncidentFromCloud(fjIncidentR: CKRecord, fjuIncident: Incident ) {
        
        if let formType = fjIncidentR["formType"] as? String {
            fjuIncident.formType = formType
        }
        if let fjpIncGuidForReference = fjIncidentR["fjpIncGuidForReference"] as? String {
            fjuIncident.fjpIncGuidForReference = fjpIncGuidForReference
        }
        if let incidentCreationDate = fjIncidentR["incidentCreationDate"] as? Date {
            fjuIncident.incidentCreationDate = incidentCreationDate
        }
        if let incidentDate = fjIncidentR["incidentDate"] as? String {
            fjuIncident.incidentDate = incidentDate
        }
        if let incidentDateSearch = fjIncidentR["incidentDateSearch"] as? String {
            fjuIncident.incidentDateSearch = incidentDateSearch
        }
        if let incidentDayOfWeek = fjIncidentR["incidentDayOfWeek"] as? String {
            fjuIncident.incidentDayOfWeek = incidentDayOfWeek
        }
        if let incidentDayOfYear = fjIncidentR["incidentDayOfYear"] as? Double {
            fjuIncident.incidentDayOfYear = incidentDayOfYear as NSNumber
        }
        if let incidentEntryTypeImageName = fjIncidentR["incidentEntryTypeImageName"] as? String {
            fjuIncident.incidentEntryTypeImageName = incidentEntryTypeImageName
        }
        if let incidentModDate = fjIncidentR["incidentModDate"] as? Date {
            fjuIncident.incidentModDate = incidentModDate
        }
        
        if let fjpIncGuidForReference = fjIncidentR["fjpIncGuidForReference"] as? String {
            fjuIncident.fjpIncGuidForReference = fjpIncGuidForReference
        }
        
            //        MARK: -FCLOCATION-
            /// incidentLocaiton archived with secureCoding
        if fjuIncident.theLocation != nil {
            if let theIncidentLocation = fjuIncident.theLocation {
                if let incidentModDate = fjIncidentR["incidentModDate"] as? Date {
                    theIncidentLocation.modDate = incidentModDate
                }
                if let fjpIncGuidForReference = fjIncidentR["fjpIncGuidForReference"] as? String {
                    theIncidentLocation.incidentGuid = fjpIncGuidForReference
                }
                if fjIncidentR["incidentLocation"] != nil {
                    let location = fjIncidentR["incidentLocation"] as! CLLocation
                    theIncidentLocation.location = location
                    theIncidentLocation.latitude = location.coordinate.latitude
                    theIncidentLocation.longitude = location.coordinate.longitude
                }
                if let appSuiteRoom = fjIncidentR["appSuiteRoom"] as? String {
                    theIncidentLocation.appSuite = appSuiteRoom
                }
                if let censusTract = fjIncidentR["censusTract"] as? String {
                    theIncidentLocation.censusTract = censusTract
                }
                if let city = fjIncidentR["city"] as? String {
                    theIncidentLocation.city = city
                }
                if let crossStreet = fjIncidentR["crossStreet"] as? String {
                    theIncidentLocation.crossStreet = crossStreet
                }
                if let incidentState = fjIncidentR["state"] as? String {
                    theIncidentLocation.state = incidentState
                }
                if let prefix = fjIncidentR["prefix"] as? String {
                    theIncidentLocation.prefix = prefix
                }
                if let streetHighway = fjIncidentR["streetHighway"] as? String {
                    theIncidentLocation.streetName = streetHighway
                }
                if let streetNumber = fjIncidentR["streetNumber"] as? String {
                    theIncidentLocation.streetNumber = streetNumber
                }
                if let streetType = fjIncidentR["streetType"] as? String {
                    theIncidentLocation.streetType = streetType
                }
                if let suffix = fjIncidentR["suffix"] as? String {
                    theIncidentLocation.suffix = suffix
                }
                if let zip = fjIncidentR["zip"] as? String {
                    theIncidentLocation.zip = zip
                }
            }
        }
        
        if let incidentNFIRSCompleted = fjIncidentR["incidentNFIRSCompleted"] as? Double {
            fjuIncident.incidentNFIRSCompleted = incidentNFIRSCompleted as NSNumber
        }
        if let incidentNFIRSCompletedDate = fjIncidentR["incidentNFIRSCompletedDate"] as? Date {
            fjuIncident.incidentNFIRSCompletedDate = incidentNFIRSCompletedDate
        }
        if let incidentNFIRSDataComplete = fjIncidentR["incidentNFIRSDataComplete"] as? Double {
            fjuIncident.incidentNFIRSDataComplete = incidentNFIRSDataComplete as NSNumber
        }
        if let incidentNFIRSDataDate = fjIncidentR["incidentNFIRSDataDate"] as? String {
            fjuIncident.incidentNFIRSDataDate = incidentNFIRSDataDate
        }
        if let incidentNFIRSDataSaved = fjIncidentR["incidentNFIRSDataSaved"] as? String {
            fjuIncident.incidentNFIRSDataSaved = incidentNFIRSDataSaved
        }
        if let incidentNumber = fjIncidentR["incidentNumber"] as? String {
            fjuIncident.incidentNumber = incidentNumber
        }
        if let incidentPhotoTaken = fjIncidentR["incidentPhotoTaken"] as? Double {
            fjuIncident.incidentPhotoTaken = incidentPhotoTaken as NSNumber
        }
        if let locationAvailable = fjIncidentR["locationAvailable"] as? Double {
            if locationAvailable == 1 {
                fjuIncident.locationAvailable = true
            } else {
                fjuIncident.locationAvailable = false
            }
        }
        if let incidentTagsAvailable = fjIncidentR["incidentTagsAvailable"] as? Double {
            if incidentTagsAvailable == 1 {
                fjuIncident.incidentTagsAvailable = true
            } else {
                fjuIncident.incidentTagsAvailable = false
            }
        }
        if let incidentSearchDate = fjIncidentR["incidentSearchDate"] as? String {
            fjuIncident.incidentSearchDate = incidentSearchDate
        }
        if let incidentStreetHyway = fjIncidentR["incidentStreetHyway"] as? String {
            fjuIncident.incidentStreetHyway = incidentStreetHyway
        }
        if let incidentStreetNumber = fjIncidentR["incidentStreetNumber"] as? String {
            fjuIncident.incidentStreetNumber = incidentStreetNumber
        }
        if let incidentTime = fjIncidentR["incidentTime"] as? String {
            fjuIncident.incidentTime = incidentTime
        }
        if let incidentType = fjIncidentR["incidentType"] as? String {
            fjuIncident.incidentType = incidentType
        }
        if let incidentZipCode = fjIncidentR["incidentZipCode"] as? String {
            fjuIncident.incidentZipCode = incidentZipCode
        }
        if let incidentZipPlus4 = fjIncidentR["incidentZipPlus4"] as? String {
            fjuIncident.incidentZipPlus4 = incidentZipPlus4
        }
        if let situationIncidentImage = fjIncidentR["situationIncidentImage"] as? String {
            fjuIncident.situationIncidentImage = situationIncidentImage
        }
        if let tempIncidentApparatus = fjIncidentR["tempIncidentApparatus"] as? String {
            fjuIncident.tempIncidentApparatus = tempIncidentApparatus
        }
        if let tempIncidentAssignment = fjIncidentR["tempIncidentAssignment"] as? String {
            fjuIncident.tempIncidentAssignment = tempIncidentAssignment
        }
        if let tempIncidentFireStation = fjIncidentR["tempIncidentFireStation"] as? String {
            fjuIncident.tempIncidentFireStation = tempIncidentFireStation
        }
        if let tempIncidentPlatoon = fjIncidentR["tempIncidentPlatoon"] as? String {
            fjuIncident.tempIncidentPlatoon = tempIncidentPlatoon
        }
        if let arsonInvestigation = fjIncidentR["arsonInvestigation"] as? Bool {
            fjuIncident.arsonInvestigation = arsonInvestigation
        }
        
        let fjuSections = NFIRSSections(context: bkgrdContext)
        if let sectionA = fjIncidentR["sectionA"] as? Bool {
            fjuSections.sectionA = sectionA
        }
        if let sectionB = fjIncidentR["sectionB"] as? Bool {
            fjuSections.sectionB = sectionB
        }
        if let sectionC = fjIncidentR["sectionC"] as? Bool {
            fjuSections.sectionC = sectionC
        }
        if let sectionD = fjIncidentR["sectionD"] as? Bool {
            fjuSections.sectionD = sectionD
        }
        if let sectionE = fjIncidentR["sectionE"] as? Bool {
            fjuSections.sectionE = sectionE
        }
        if let sectionF = fjIncidentR["sectionF"] as? Bool {
            fjuSections.sectionF = sectionF
        }
        if let sectionG = fjIncidentR["sectionG"] as? Bool {
            fjuSections.sectionG = sectionG
        }
        if let sectionH = fjIncidentR["sectionH"] as? Bool {
            fjuSections.sectionH = sectionH
        }
        if let sectionI = fjIncidentR["sectionI"] as? Bool {
            fjuSections.sectionI = sectionI
        }
        if let sectionJ = fjIncidentR["sectionJ"] as? Bool {
            fjuSections.sectionJ = sectionJ
        }
        if let sectionK = fjIncidentR["sectionK"] as? Bool {
            fjuSections.sectionK = sectionK
        }
        if let sectionL = fjIncidentR["sectionL"] as? Bool {
            fjuSections.sectionL = sectionL
        }
        if let sectionM = fjIncidentR["sectionM"] as? Bool {
            fjuSections.sectionM = sectionM
        }
        fjuIncident.formDetails = fjuSections
        
        let fjIncidentAddress = IncidentAddress(context: bkgrdContext)
        if let appSuiteRoom = fjIncidentR["appSuiteRoom"] as? String {
            fjIncidentAddress.appSuiteRoom = appSuiteRoom
        }
        if let censusTract = fjIncidentR["censusTract"] as? String {
            fjIncidentAddress.censusTract = censusTract
        }
        if let censusTract2 = fjIncidentR["censusTract2"] as? String {
            fjIncidentAddress.censusTract2 = censusTract2
        }
        if let city = fjIncidentR["city"] as? String {
            fjIncidentAddress.city = city
        }
        if let crossStreet = fjIncidentR["crossStreet"] as? String {
            fjIncidentAddress.crossStreet = crossStreet
        }
        if let incidentState = fjIncidentR["incidentState"] as? String {
            fjIncidentAddress.incidentState = incidentState
        }
        if let prefix = fjIncidentR["prefix"] as? String {
            fjIncidentAddress.prefix = prefix
        }
        if let stagingAddress = fjIncidentR["stagingAddress"] as? String {
            fjIncidentAddress.stagingAddress = stagingAddress
        }
        if let streetHighway = fjIncidentR["streetHighway"] as? String {
            fjIncidentAddress.streetHighway = streetHighway
        }
        if let streetNumber = fjIncidentR["streetNumber"] as? String {
            fjIncidentAddress.streetNumber = streetNumber
        }
        if let streetType = fjIncidentR["streetType"] as? String {
            fjIncidentAddress.streetType = streetType
        }
        if let suffix = fjIncidentR["suffix"] as? String {
            fjIncidentAddress.suffix = suffix
        }
        if let zip = fjIncidentR["zip"] as? String {
            fjIncidentAddress.zip = zip
        }
        if let zipPlus4 = fjIncidentR["zipPlus4"] as? String {
            fjIncidentAddress.zipPlus4 = zipPlus4
        }
        fjuIncident.incidentAddressDetails = fjIncidentAddress
        
            //MARK: -incidentLocal-
        let fjIncidentLocal = IncidentLocal(context: bkgrdContext)
        if let incidentBattalion = fjIncidentR["incidentBattalion"] as? String {
            fjIncidentLocal.incidentBattalion = incidentBattalion
        }
        if let incidentDivision = fjIncidentR["incidentDivision"] as? String {
            fjIncidentLocal.incidentDivision = incidentDivision
        }
        if let incidentFireDistrict = fjIncidentR["incidentFireDistrict"] as? String {
            fjIncidentLocal.incidentFireDistrict = incidentFireDistrict
        }
        if let incidentLocalType = fjIncidentR["incidentLocalType"] as? String {
            fjIncidentLocal.incidentLocalType = incidentLocalType
        }
        fjuIncident.incidentLocalDetails = fjIncidentLocal
        
            //MARK: -incidentMap-
        let fjIncidentMap = IncidentMap(context: bkgrdContext)
        if let incidentLatitude = fjIncidentR["incidentLatitude"] as? String {
            fjIncidentMap.incidentLatitude = incidentLatitude
        }
        if let incidentLongitude = fjIncidentR["incidentLongitude"] as? String {
            fjIncidentMap.incidentLongitude = incidentLongitude
        }
        if let stagingLatitude = fjIncidentR["stagingLatitude"] as? String {
            fjIncidentMap.stagingLatitude = stagingLatitude
        }
        if let stagingLongitude = fjIncidentR["stagingLongitude"] as? String {
            fjIncidentMap.stagingLongitude = stagingLongitude
        }
        fjuIncident.incidentMapDetails = fjIncidentMap
        
            //MARK: -IncidentNFIRS-
        let fjIncidentNFIRS = IncidentNFIRS(context: bkgrdContext)
        if let fireStationState = fjIncidentR["fireStationState"] as? String {
            fjIncidentNFIRS.fireStationState = fireStationState
        }
        if let incidentActionsTakenAdditionalThree = fjIncidentR["incidentActionsTakenAdditionalThree"] as? String {
            fjIncidentNFIRS.incidentActionsTakenAdditionalThree = incidentActionsTakenAdditionalThree
        }
        if let incidentActionsTakenAdditionalTwo = fjIncidentR["incidentActionsTakenAdditionalTwo"] as? String {
            fjIncidentNFIRS.incidentActionsTakenAdditionalTwo = incidentActionsTakenAdditionalTwo
        }
        if let incidentActionsTakenPrimary = fjIncidentR["incidentActionsTakenPrimary"] as? String {
            fjIncidentNFIRS.incidentActionsTakenPrimary = incidentActionsTakenPrimary
        }
        if let incidentAidGiven = fjIncidentR["incidentAidGiven"] as? String {
            fjIncidentNFIRS.incidentAidGiven = incidentAidGiven
        }
        if let incidentAidGivenFDID = fjIncidentR["incidentAidGivenFDID"] as? String {
            fjIncidentNFIRS.incidentAidGivenFDID = incidentAidGivenFDID
        }
        if let incidentAidGivenIncidentNumber = fjIncidentR["incidentAidGivenIncidentNumber"] as? String {
            fjIncidentNFIRS.incidentAidGivenIncidentNumber = incidentAidGivenIncidentNumber
        }
        if let incidentAidGivenNone = fjIncidentR["incidentAidGivenNone"] as? Double {
            fjIncidentNFIRS.incidentAidGivenNone = incidentAidGivenNone as NSNumber
        }
        if let incidentAidGivenState = fjIncidentR["incidentAidGivenState"] as? String {
            fjIncidentNFIRS.incidentAidGivenState = incidentAidGivenState
        }
        if let incidentCasualtiesCivilianDeaths = fjIncidentR["incidentCasualtiesCivilianDeaths"] as? String {
            fjIncidentNFIRS.incidentCasualtiesCivilianDeaths = incidentCasualtiesCivilianDeaths
        }
        if let incidentCasualtiesCivilianInjuries = fjIncidentR["incidentCasualtiesCivilianInjuries"] as? String {
            fjIncidentNFIRS.incidentCasualtiesCivilianInjuries = incidentCasualtiesCivilianInjuries
        }
        if let incidentCasualtiesFireDeaths = fjIncidentR["incidentCasualtiesFireDeaths"] as? String {
            fjIncidentNFIRS.incidentCasualtiesFireDeaths = incidentCasualtiesFireDeaths
        }
        if let incidentCasualtiesFireInjuries = fjIncidentR["incidentCasualtiesFireInjuries"] as? String {
            fjIncidentNFIRS.incidentCasualtiesFireInjuries = incidentCasualtiesFireInjuries
        }
        if let incidentCasualtiesNone = fjIncidentR["incidentCasualtiesNone"] as? Bool {
            fjIncidentNFIRS.incidentCasualtiesNone = incidentCasualtiesNone
        }
        if let incidentCasualtiesServiceDeaths = fjIncidentR["incidentCasualtiesServiceDeaths"] as? String {
            fjIncidentNFIRS.incidentCasualtiesServiceDeaths = incidentCasualtiesServiceDeaths
        }
        if let incidentCasualtitesServideInjuries = fjIncidentR["incidentCasualtitesServideInjuries"] as? String {
            fjIncidentNFIRS.incidentCasualtitesServideInjuries = incidentCasualtitesServideInjuries
        }
        if let incidentDetectorChosen = fjIncidentR["incidentDetectorChosen"] as? String {
            fjIncidentNFIRS.incidentDetectorChosen = incidentDetectorChosen
        }
        if let incidentExposure = fjIncidentR["incidentExposure"] as? String {
            fjIncidentNFIRS.incidentExposure = incidentExposure
        }
        if let incidentFDID = fjIncidentR["incidentFDID"] as? String {
            fjIncidentNFIRS.incidentFDID = incidentFDID
        }
        if let incidentFDID1 = fjIncidentR["incidentFDID1"] as? String {
            fjIncidentNFIRS.incidentFDID1 = incidentFDID1
        }
        if let incidentFireStation = fjIncidentR["incidentFireStation"] as? String {
            fjIncidentNFIRS.incidentFireStation = incidentFireStation
        }
        if let incidentHazMat = fjIncidentR["incidentHazMat"] as? String {
            fjIncidentNFIRS.incidentHazMat = incidentHazMat
        }
        if let incidentHazMatNone = fjIncidentR["incidentHazMatNone"] as? Bool {
            fjIncidentNFIRS.incidentHazMatNone = incidentHazMatNone
        }
            //        MARK: -STRING-
        if let incidentNFIRSLocation = fjIncidentR["incidentNFIRSLocation"] as? String {
            fjIncidentNFIRS.incidentLocation = incidentNFIRSLocation
        }
        if let incidentPlatoon = fjIncidentR["incidentPlatoon"] as? String {
            fjIncidentNFIRS.incidentPlatoon = incidentPlatoon
        }
        if let incidentPropertyNone = fjIncidentR["incidentPropertyNone"] as? Double {
            fjIncidentNFIRS.incidentPropertyNone = incidentPropertyNone as NSNumber
        }
        if let incidentPropertyOutside = fjIncidentR["incidentPropertyOutside"] as? String {
            fjIncidentNFIRS.incidentPropertyOutside = incidentPropertyOutside
        }
        if let incidentPropertyOutsideNumber = fjIncidentR["incidentPropertyOutsideNumber"] as? String {
            fjIncidentNFIRS.incidentPropertyOutsideNumber = incidentPropertyOutsideNumber
        }
        if let incidentPropertyStructure = fjIncidentR["incidentPropertyStructure"] as? String {
            fjIncidentNFIRS.incidentPropertyStructure = incidentPropertyStructure
        }
        if let incidentPropertyStructureNumber = fjIncidentR["incidentPropertyStructureNumber"] as? String {
            fjIncidentNFIRS.incidentPropertyStructureNumber = incidentPropertyStructureNumber
        }
        if let incidentPropertyUse = fjIncidentR["incidentPropertyUse"] as? String {
            fjIncidentNFIRS.incidentPropertyUse = incidentPropertyUse
        }
        if let incidentPropertyUseNone = fjIncidentR["incidentPropertyUseNone"] as? String {
            fjIncidentNFIRS.incidentPropertyUseNone = incidentPropertyUseNone
        }
        if let incidentPropertyUseNumber = fjIncidentR["incidentPropertyUseNumber"] as? String {
            fjIncidentNFIRS.incidentPropertyUseNumber = incidentPropertyUseNumber
        }
        if let incidentResourceCheck = fjIncidentR["incidentResourceCheck"]  as? Double {
            fjIncidentNFIRS.incidentResourceCheck = incidentResourceCheck  as NSNumber
        }
        if let incidentResourcesEMSApparatus = fjIncidentR["incidentResourcesEMSApparatus"] as? String {
            fjIncidentNFIRS.incidentResourcesEMSApparatus = incidentResourcesEMSApparatus
        }
        if let incidentResourcesEMSPersonnel = fjIncidentR["incidentResourcesEMSPersonnel"] as? String {
            fjIncidentNFIRS.incidentResourcesEMSPersonnel = incidentResourcesEMSPersonnel
        }
        if let incidentResourcesOtherApparatus = fjIncidentR["incidentResourcesOtherApparatus"] as? String {
            fjIncidentNFIRS.incidentResourcesOtherApparatus = incidentResourcesOtherApparatus
        }
        if let incidentResourcesOtherPersonnel = fjIncidentR["incidentResourcesOtherPersonnel"] as? String {
            fjIncidentNFIRS.incidentResourcesOtherPersonnel = incidentResourcesOtherPersonnel
        }
        if let incidentResourcesSuppressionPersonnel = fjIncidentR["incidentResourcesSuppressionPersonnel"] as? String {
            fjIncidentNFIRS.incidentResourcesSuppressionPersonnel = incidentResourcesSuppressionPersonnel
        }
        if let incidentResourcesSupressionApparatus = fjIncidentR["incidentResourcesSupressionApparatus"] as? String {
            fjIncidentNFIRS.incidentResourcesSupressionApparatus = incidentResourcesSupressionApparatus
        }
        if let incidentTypeNumberNFRIS = fjIncidentR["incidentTypeNumberNFRIS"] as? String {
            fjIncidentNFIRS.incidentTypeNumberNFRIS = incidentTypeNumberNFRIS
        }
        if let incidentTypeTextNFRIS = fjIncidentR["incidentTypeTextNFRIS"] as? String {
            fjIncidentNFIRS.incidentTypeTextNFRIS = incidentTypeTextNFRIS
        }
        if let lossesContentDollars = fjIncidentR["lossesContentDollars"] as? String {
            fjIncidentNFIRS.lossesContentDollars = lossesContentDollars
        }
        if let lossesContentNone = fjIncidentR["lossesContentNone"] as? Bool {
            fjIncidentNFIRS.lossesContentNone = lossesContentNone
        }
        if let lossesPropertyDollars = fjIncidentR["lossesPropertyDollars"] as? String {
            fjIncidentNFIRS.lossesPropertyDollars = lossesPropertyDollars
        }
        if let lossesPropertyNone = fjIncidentR["lossesPropertyNone"] as? Bool {
            fjIncidentNFIRS.lossesPropertyNone = lossesPropertyNone
        }
        if let mixedUsePropertyNone = fjIncidentR["mixedUsePropertyNone"] as? Bool {
            fjIncidentNFIRS.mixedUsePropertyNone = mixedUsePropertyNone
        }
        if let mixedUsePropertyType = fjIncidentR["mixedUsePropertyType"] as? String {
            fjIncidentNFIRS.mixedUsePropertyType = mixedUsePropertyType
        }
        if let nfirsChangeDescription = fjIncidentR["nfirsChangeDescription"] as? String {
            fjIncidentNFIRS.nfirsChangeDescription = nfirsChangeDescription
        }
        if let nfirsSectionOneSegment = fjIncidentR["nfirsSectionOneSegment"] as? String {
            fjIncidentNFIRS.nfirsSectionOneSegment = nfirsSectionOneSegment
        }
        if let propertyUseNone = fjIncidentR["propertyUseNone"] as? Bool {
            fjIncidentNFIRS.propertyUseNone = propertyUseNone
        }
        if let resourceCountsIncludeAidReceived = fjIncidentR["resourceCountsIncludeAidReceived"] as? Bool {
            fjIncidentNFIRS.resourceCountsIncludeAidReceived = resourceCountsIncludeAidReceived
        }
        if let shiftAlarm = fjIncidentR["shiftAlarm"] as? String {
            fjIncidentNFIRS.shiftAlarm = shiftAlarm
        }
        if let shiftDistrict = fjIncidentR["shiftDistrict"] as? String {
            fjIncidentNFIRS.shiftDistrict = shiftDistrict
        }
        if let shiftOrPlatoon = fjIncidentR["shiftOrPlatoon"]  as? String {
            fjIncidentNFIRS.shiftOrPlatoon = shiftOrPlatoon
        }
        if let skipSectionF = fjIncidentR["skipSectionF"] as? Bool {
            fjIncidentNFIRS.skipSectionF = skipSectionF
        }
        if let specialStudyID = fjIncidentR["specialStudyID"] as? String {
            fjIncidentNFIRS.specialStudyID = specialStudyID
        }
        if let specialStudyValue = fjIncidentR["specialStudyValue"] as? String {
            fjIncidentNFIRS.specialStudyValue = specialStudyValue
        }
        if let valueContentDollars = fjIncidentR["valueContentDollars"] as? String {
            fjIncidentNFIRS.valueContentDollars = valueContentDollars
        }
        if let valueContentsNone = fjIncidentR["valueContentsNone"] as? Bool {
            fjIncidentNFIRS.valueContentsNone = valueContentsNone
        }
        if let valuePropertyDollars = fjIncidentR["valuePropertyDollars"] as? String {
            fjIncidentNFIRS.valuePropertyDollars = valuePropertyDollars
        }
        if let valuePropertyNone = fjIncidentR["valuePropertyNone"] as? Bool {
            fjIncidentNFIRS.valuePropertyNone = valuePropertyNone
        }
        fjuIncident.incidentNFIRSDetails = fjIncidentNFIRS
        
            // TODO: -CompletedModules-
            // MARK: -IncidentNFIRSKSec-
        let fjIncidentNFIRSKSec = IncidentNFIRSKSec(context: bkgrdContext)
        if let kOwnerAptSuiteRoom = fjIncidentR["kOwnerAptSuiteRoom"] as? String {
            fjIncidentNFIRSKSec.kOwnerAptSuiteRoom = kOwnerAptSuiteRoom
        }
        if let kOwnerAreaCode = fjIncidentR["kOwnerAreaCode"] as? String {
            fjIncidentNFIRSKSec.kOwnerAreaCode = kOwnerAreaCode
        }
        if let kOwnerBusinessName = fjIncidentR["kOwnerBusinessName"] as? String {
            fjIncidentNFIRSKSec.kOwnerBusinessName = kOwnerBusinessName
        }
        if let kOwnerCheckBox = fjIncidentR["kOwnerCheckBox"] as? Bool {
            fjIncidentNFIRSKSec.kOwnerCheckBox = kOwnerCheckBox
        }
        if let kOwnerCity = fjIncidentR["kOwnerCity"] as? String {
            fjIncidentNFIRSKSec.kOwnerCity = kOwnerCity
        }
        if let kOwnerFirstName = fjIncidentR["kOwnerFirstName"] as? String {
            fjIncidentNFIRSKSec.kOwnerFirstName = kOwnerFirstName
        }
        if let kOwnerLastName = fjIncidentR["kOwnerLastName"] as? String {
            fjIncidentNFIRSKSec.kOwnerLastName = kOwnerLastName
        }
        if let kOwnerMI = fjIncidentR["kOwnerMI"] as? String {
            fjIncidentNFIRSKSec.kOwnerMI = kOwnerMI
        }
        if let kOwnerNamePrefix = fjIncidentR["kOwnerNamePrefix"] as? String {
            fjIncidentNFIRSKSec.kOwnerNamePrefix = kOwnerNamePrefix
        }
        if let kOwnerNameSuffix = fjIncidentR["kOwnerNameSuffix"] as? String {
            fjIncidentNFIRSKSec.kOwnerNameSuffix = kOwnerNameSuffix
        }
        if let kOwnerPhoneLastFour = fjIncidentR["kOwnerPhoneLastFour"] as? String {
            fjIncidentNFIRSKSec.kOwnerPhoneLastFour = kOwnerPhoneLastFour
        }
        if let kOwnerPhonePrefix = fjIncidentR["kOwnerPhonePrefix"] as? String {
            fjIncidentNFIRSKSec.kOwnerPhonePrefix = kOwnerPhonePrefix
        }
        if let kOwnerPOBox = fjIncidentR["kOwnerPOBox"] as? String {
            fjIncidentNFIRSKSec.kOwnerPOBox = kOwnerPOBox
        }
        if let kOwnerSameAsPerson = fjIncidentR["kOwnerSameAsPerson"] as? Bool {
            fjIncidentNFIRSKSec.kOwnerSameAsPerson = kOwnerSameAsPerson
        }
        if let kOwnerState = fjIncidentR["kOwnerState"] as? String {
            fjIncidentNFIRSKSec.kOwnerState = kOwnerState
        }
        if let kOwnerStreetHyway = fjIncidentR["kOwnerStreetHyway"] as? String {
            fjIncidentNFIRSKSec.kOwnerStreetHyway = kOwnerStreetHyway
        }
        if let kOwnerStreetNumber = fjIncidentR["kOwnerStreetNumber"] as? String {
            fjIncidentNFIRSKSec.kOwnerStreetNumber = kOwnerStreetNumber
        }
        if let kOwnerStreetPrefix = fjIncidentR["kOwnerStreetPrefix"] as? String {
            fjIncidentNFIRSKSec.kOwnerStreetPrefix = kOwnerStreetPrefix
        }
        if let kOwnerStreetSuffix = fjIncidentR["kOwnerStreetSuffix"] as? String {
            fjIncidentNFIRSKSec.kOwnerStreetSuffix = kOwnerStreetSuffix
        }
        if let kOwnerStreetType = fjIncidentR["kOwnerStreetType"] as? String {
            fjIncidentNFIRSKSec.kOwnerStreetType = kOwnerStreetType
        }
        if let kOwnerZip = fjIncidentR["kOwnerZip"] as? String {
            fjIncidentNFIRSKSec.kOwnerZip = kOwnerZip
        }
        if let kOwnerZipPlusFour = fjIncidentR["kOwnerZipPlusFour"] as? String {
            fjIncidentNFIRSKSec.kOwnerZipPlusFour = kOwnerZipPlusFour
        }
        if let kPersonAppSuiteRoom = fjIncidentR["kPersonAppSuiteRoom"] as? String {
            fjIncidentNFIRSKSec.kPersonAppSuiteRoom = kPersonAppSuiteRoom
        }
        if let kPersonAreaCode = fjIncidentR["kPersonAreaCode"] as? String {
            fjIncidentNFIRSKSec.kPersonAreaCode = kPersonAreaCode
        }
        if let kPersonBusinessName = fjIncidentR["kPersonBusinessName"] as? String {
            fjIncidentNFIRSKSec.kPersonBusinessName = kPersonBusinessName
        }
        if let kPersonCheckBox = fjIncidentR["kPersonCheckBox"] as? Bool {
            fjIncidentNFIRSKSec.kPersonCheckBox = kPersonCheckBox
        }
        if let kPersonCity = fjIncidentR["kPersonCity"] as? String {
            fjIncidentNFIRSKSec.kPersonCity = kPersonCity
        }
        if let kPersonFirstName = fjIncidentR["kPersonFirstName"] as? String {
            fjIncidentNFIRSKSec.kPersonFirstName = kPersonFirstName
        }
        if let kPersonGender = fjIncidentR["kPersonGender"] as? String {
            fjIncidentNFIRSKSec.kPersonGender = kPersonGender
        }
        if let kPersonLastName = fjIncidentR["kPersonLastName"] as? String {
            fjIncidentNFIRSKSec.kPersonLastName = kPersonLastName
        }
        if let kPersonMI = fjIncidentR["kPersonMI"] as? String {
            fjIncidentNFIRSKSec.kPersonMI = kPersonMI
        }
        if let kPersonMoreThanOne = fjIncidentR["kPersonMoreThanOne"] as? Bool {
            fjIncidentNFIRSKSec.kPersonMoreThanOne = kPersonMoreThanOne
        }
        if let kPersonNameSuffix = fjIncidentR["kPersonNameSuffix"] as? String {
            fjIncidentNFIRSKSec.kPersonNameSuffix = kPersonNameSuffix
        }
        if let kPersonPhoneLastFour = fjIncidentR["kPersonPhoneLastFour"] as? String {
            fjIncidentNFIRSKSec.kPersonPhoneLastFour = kPersonPhoneLastFour
        }
        if let kPersonPhonePrefix = fjIncidentR["kPersonPhonePrefix"] as? String {
            fjIncidentNFIRSKSec.kPersonPhonePrefix = kPersonPhonePrefix
        }
        if let kPersonPOBox = fjIncidentR["kPersonPOBox"] as? String {
            fjIncidentNFIRSKSec.kPersonPOBox = kPersonPOBox
        }
        if let kPersonPrefix = fjIncidentR["kPersonPrefix"] as? String {
            fjIncidentNFIRSKSec.kPersonPrefix = kPersonPrefix
        }
        if let kPersonState = fjIncidentR["kPersonState"] as? String {
            fjIncidentNFIRSKSec.kPersonState = kPersonState
        }
        if let kPersonStreetHyway = fjIncidentR["kPersonStreetHyway"] as? String {
            fjIncidentNFIRSKSec.kPersonStreetHyway = kPersonStreetHyway
        }
        if let kPersonStreetNum = fjIncidentR["kPersonStreetNum"] as? String {
            fjIncidentNFIRSKSec.kPersonStreetNum = kPersonStreetNum
        }
        if let kPersonStreetSuffix = fjIncidentR["kPersonStreetSuffix"] as? String {
            fjIncidentNFIRSKSec.kPersonStreetSuffix = kPersonStreetSuffix
        }
        if let kPersonStreetType = fjIncidentR["kPersonStreetType"] as? String {
            fjIncidentNFIRSKSec.kPersonStreetType = kPersonStreetType
        }
        if let kPersonZipCode = fjIncidentR["kPersonZipCode"] as? String {
            fjIncidentNFIRSKSec.kPersonZipCode = kPersonZipCode
        }
        if let kPersonZipPlus4 = fjIncidentR["kPersonZipPlus4"] as? String {
            fjIncidentNFIRSKSec.kPersonZipPlus4 = kPersonZipPlus4
        }
        fjuIncident.incidentNFIRSKSecDetails = fjIncidentNFIRSKSec
        
            // TODO: -REQUIREDMODULES
            // MARK: -IncidentNFIRSsecL-
        let fjIncidentNFIRSsecL = IncidentNFIRSsecL(context: bkgrdContext)
        if let lRemarks = fjIncidentR["incidentNFIRSSecLNotes"] as? String {
            fjIncidentNFIRSsecL.lRemarks = lRemarks as NSObject
        }
        if let moreRemarks = fjIncidentR["incidentNFIRSSecLMoreRemarks"] as? Bool {
            fjIncidentNFIRSsecL.moreRemarks = moreRemarks
        }
        fjuIncident.sectionLDetails = fjIncidentNFIRSsecL
        
            // MARK: -IncidentNFIRSsecM-
        let fjIncidentNFIRSsecM = IncidentNFIRSsecM(context: bkgrdContext)
        if let memberAssignment = fjIncidentR["memberAssignment"] as? String {
            fjIncidentNFIRSsecM.memberAssignment = memberAssignment
        }
        if let memberDate = fjIncidentR["memberDate"] as? Date {
            fjIncidentNFIRSsecM.memberDate = memberDate
        }
        if let memberMakingReportID = fjIncidentR["memberMakingReportID"] as? String {
            fjIncidentNFIRSsecM.memberMakingReportID = memberMakingReportID
        }
        if let memberRankPosition = fjIncidentR["memberRankPosition"] as? String {
            fjIncidentNFIRSsecM.memberRankPosition = memberRankPosition
        }
        if let memberSameAsOfficer = fjIncidentR["memberSameAsOfficer"] as? Bool {
            fjIncidentNFIRSsecM.memberSameAsOfficer = memberSameAsOfficer
        }
        if let officerAssignment = fjIncidentR["officerAssignment"] as? String {
            fjIncidentNFIRSsecM.officerAssignment = officerAssignment
        }
        if let officerDate = fjIncidentR["officerDate"] as? Date {
            fjIncidentNFIRSsecM.officerDate = officerDate
        }
        if let officerInChargeID = fjIncidentR["officerInChargeID"] as? String {
            fjIncidentNFIRSsecM.officerInChargeID = officerInChargeID
        }
        if let officerRankPosition = fjIncidentR["officerRankPosition"] as? String {
            fjIncidentNFIRSsecM.officerRankPosition = officerRankPosition
        }
        if let signatureMember = fjIncidentR["signatureMember"] as? String {
            fjIncidentNFIRSsecM.signatureMember = signatureMember
        }
        if let signatureOfficer = fjIncidentR["signatureOfficer"] as? String {
            fjIncidentNFIRSsecM.signatureOfficer = signatureOfficer
        }
        if let memberSigned = fjIncidentR["memberSigned"] as? Bool {
            fjIncidentNFIRSsecM.memberSigned = memberSigned
        }
        if let officeSigned = fjIncidentR["officerSigned"] as? Bool {
            fjIncidentNFIRSsecM.officeSigned = officeSigned
        }
            // TODO: -SIGNATURE CONVERSION-
        
        fjuIncident.sectionMDetails = fjIncidentNFIRSsecM
        
            // MARK: -IncidentNotes-
        let fjIncidentNotes = IncidentNotes(context: bkgrdContext)
        if let incidentSummaryNotesSC = fjIncidentR["incidentSummaryNotes"] as? NSObject {
            fjIncidentNotes.incidentSummaryNotesSC = incidentSummaryNotesSC
        }
        if let note = fjIncidentR["incidentNote"] as? String {
            fjIncidentNotes.incidentNote = note
        }
        fjuIncident.incidentNotesDetails = fjIncidentNotes
        
            // TODO: -IncidentResources-
            // MARK: -IncidentTimer-
        let fjIncidentTimer = IncidentTimer(context: bkgrdContext)
        if let arrivalSameDate = fjIncidentR["arrivalSameDate"] as? Bool {
            fjIncidentTimer.arrivalSameDate = arrivalSameDate
        }
        if let controlledSameDate = fjIncidentR["controlledSameDate"] as? Bool {
            fjIncidentTimer.controlledSameDate = controlledSameDate
        }
        if let incidentAlarmCombinedDate = fjIncidentR["incidentAlarmCombinedDate"] as? String {
            fjIncidentTimer.incidentAlarmCombinedDate = incidentAlarmCombinedDate
        }
        if let incidentAlarmDateTime = fjIncidentR["incidentAlarmDateTime"] as? Date {
            fjIncidentTimer.incidentAlarmDateTime = incidentAlarmDateTime
        }
        if let incidentAlarmDay = fjIncidentR["incidentAlarmDay"] as? String {
            fjIncidentTimer.incidentAlarmDay = incidentAlarmDay
        }
        if let incidentAlarmHours = fjIncidentR["incidentAlarmHours"] as? String {
            fjIncidentTimer.incidentAlarmHours = incidentAlarmHours
        }
        if let incidentAlarmMinutes = fjIncidentR["incidentAlarmMinutes"] as? String {
            fjIncidentTimer.incidentAlarmMinutes = incidentAlarmMinutes
        }
        if let incidentAlarmMonth = fjIncidentR["incidentAlarmMonth"] as? String {
            fjIncidentTimer.incidentAlarmMonth = incidentAlarmMonth
        }
        if let incidentAlarmNotes = fjIncidentR["incidentAlarmNotes"] as? String {
            fjIncidentTimer.incidentAlarmNotes = incidentAlarmNotes as NSObject
        }
        if let incidentAlarmYear = fjIncidentR["incidentAlarmYear"] as? String {
            fjIncidentTimer.incidentAlarmYear = incidentAlarmYear
        }
        if let incidentArrivalCombinedDate = fjIncidentR["incidentArrivalCombinedDate"] as? String {
            fjIncidentTimer.incidentArrivalCombinedDate = incidentArrivalCombinedDate
        }
        if let incidentArrivalDateTime = fjIncidentR["incidentArrivalDateTime"] as? Date {
            fjIncidentTimer.incidentArrivalDateTime = incidentArrivalDateTime
        }
        if let incidentArrivalDay = fjIncidentR["incidentArrivalDay"] as? String {
            fjIncidentTimer.incidentArrivalDay = incidentArrivalDay
        }
        if let incidentArrivalHours = fjIncidentR["incidentArrivalHours"] as? String {
            fjIncidentTimer.incidentArrivalHours = incidentArrivalHours
        }
        if let incidentArrivalMinutes = fjIncidentR["incidentArrivalMinutes"] as? String {
            fjIncidentTimer.incidentArrivalMinutes = incidentArrivalMinutes
        }
        if let incidentArrivalMonth = fjIncidentR["incidentArrivalMonth"] as? String {
            fjIncidentTimer.incidentArrivalMonth = incidentArrivalMonth
        }
        if let incidentArrivalNotes = fjIncidentR["incidentArrivalNotes"] as? String {
            fjIncidentTimer.incidentArrivalNotes = incidentArrivalNotes as NSObject
        }
        if let incidentArrivalYear = fjIncidentR["incidentArrivalYear"] as? String {
            fjIncidentTimer.incidentArrivalYear = incidentArrivalYear
        }
        if let incidentArrivalYear = fjIncidentR["incidentArrivalYear"] as? String {
            fjIncidentTimer.incidentArrivalYear = incidentArrivalYear
        }
        if let incidentControlDateTime =  fjIncidentR["incidentControlDateTime"] as? Date {
            fjIncidentTimer.incidentControlDateTime =  incidentControlDateTime
        }
        if let incidentControlledDay = fjIncidentR["incidentControlledDay"] as? String {
            fjIncidentTimer.incidentControlledDay = incidentControlledDay
        }
        if let incidentControlledHours = fjIncidentR["incidentControlledHours"] as? String {
            fjIncidentTimer.incidentControlledHours = incidentControlledHours
        }
        if let incidentControlledMinutes = fjIncidentR["incidentControlledMinutes"] as? String {
            fjIncidentTimer.incidentControlledMinutes = incidentControlledMinutes
        }
        if let incidentControlledMonth = fjIncidentR["incidentControlledMonth"] as? String {
            fjIncidentTimer.incidentControlledMonth = incidentControlledMonth
        }
        if let incidentControlledNotes = fjIncidentR["incidentControlledNotes"] as? String {
            fjIncidentTimer.incidentControlledNotes = incidentControlledNotes as NSObject
        }
        if let incidentControlledYear = fjIncidentR["incidentControlledYear"] as? String {
            fjIncidentTimer.incidentControlledYear = incidentControlledYear
        }
        if let incidentElapsedTime = fjIncidentR["incidentElapsedTime"] as? String {
            fjIncidentTimer.incidentElapsedTime = incidentElapsedTime
        }
        if let incidentLastUnitCalledCombinedDate = fjIncidentR["incidentLastUnitCalledCombinedDate"] as? String {
            fjIncidentTimer.incidentLastUnitCalledCombinedDate = incidentLastUnitCalledCombinedDate
        }
        if let incidentLastUnitDateTime = fjIncidentR["incidentLastUnitDateTime"] as? Date {
            fjIncidentTimer.incidentLastUnitDateTime = incidentLastUnitDateTime
        }
        if let incidentLastUnitCalledDay = fjIncidentR["incidentLastUnitCalledDay"] as? String {
            fjIncidentTimer.incidentLastUnitCalledDay = incidentLastUnitCalledDay
        }
        if let incidentLastUnitCalledHours = fjIncidentR["incidentLastUnitCalledHours"] as? String {
            fjIncidentTimer.incidentLastUnitCalledHours = incidentLastUnitCalledHours
        }
        if let incidentLastUnitCalledMinutes = fjIncidentR["incidentLastUnitCalledMinutes"] as? String {
            fjIncidentTimer.incidentLastUnitCalledMinutes = incidentLastUnitCalledMinutes
        }
        if let incidentLastUnitCalledMonth = fjIncidentR["incidentLastUnitCalledMonth"] as? String {
            fjIncidentTimer.incidentLastUnitCalledMonth = incidentLastUnitCalledMonth
        }
        if let incidentLastUnitCalledYear = fjIncidentR["incidentLastUnitCalledYear"] as? String {
            fjIncidentTimer.incidentLastUnitCalledYear = incidentLastUnitCalledYear
        }
        if let incidentLastUnitClearedNotes = fjIncidentR["incidentLastUnitClearedNotes"] as? String {
            fjIncidentTimer.incidentLastUnitClearedNotes = incidentLastUnitClearedNotes as NSObject
        }
        if let incidentStartClockCombinedDate = fjIncidentR["incidentStartClockCombinedDate"] as? String {
            fjIncidentTimer.incidentStartClockCombinedDate = incidentStartClockCombinedDate
        }
        if let incidentStartClockDateTime = fjIncidentR["incidentStartClockDateTime"] as? Date {
            fjIncidentTimer.incidentStartClockDateTime = incidentStartClockDateTime
        }
        if let incidentStartClockDay = fjIncidentR["incidentStartClockDay"] as? String {
            fjIncidentTimer.incidentStartClockDay = incidentStartClockDay
        }
        if let incidentStartClockHours = fjIncidentR["incidentStartClockHours"] as? String {
            fjIncidentTimer.incidentStartClockHours = incidentStartClockHours
        }
        if let incidentStartClockMinutes = fjIncidentR["incidentStartClockMinutes"] as? String {
            fjIncidentTimer.incidentStartClockMinutes = incidentStartClockMinutes
        }
        if let incidentStartClockMonth = fjIncidentR["incidentStartClockMonth"] as? String {
            fjIncidentTimer.incidentStartClockMonth = incidentStartClockMonth
        }
        if let incidentStartClockSeconds = fjIncidentR["incidentStartClockSeconds"] as? String {
            fjIncidentTimer.incidentStartClockSeconds = incidentStartClockSeconds
        }
        if let incidentStartClockYear = fjIncidentR["incidentStartClockYear"] as? String {
            fjIncidentTimer.incidentStartClockYear = incidentStartClockYear
        }
        if let incidentStopClockCombinedDate = fjIncidentR["incidentStopClockCombinedDate"]  as? String {
            fjIncidentTimer.incidentStopClockCombinedDate = incidentStopClockCombinedDate
        }
        if let incidentStopClockDateTime = fjIncidentR["incidentStopClockDateTime"] as? Date {
            fjIncidentTimer.incidentStopClockDateTime = incidentStopClockDateTime
        }
        if let incidentStopClockDay = fjIncidentR["incidentStopClockDay"] as? String {
            fjIncidentTimer.incidentStopClockDay = incidentStopClockDay
        }
        if let incidentStopClockHours = fjIncidentR["incidentStopClockHours"] as? String {
            fjIncidentTimer.incidentStopClockHours = incidentStopClockHours
        }
        if let incidentStopClockMinutes = fjIncidentR["incidentStopClockMinutes"] as? String {
            fjIncidentTimer.incidentStopClockMinutes = incidentStopClockMinutes
        }
        if let incidentStopClockMonth = fjIncidentR["incidentStopClockMonth"] as? String {
            fjIncidentTimer.incidentStopClockMonth = incidentStopClockMonth
        }
        if let incidentStopClockSeconds = fjIncidentR["incidentStopClockSeconds"] as? String {
            fjIncidentTimer.incidentStopClockSeconds = incidentStopClockSeconds
        }
        if let incidentStopClockYear = fjIncidentR["incidentStopClockYear"] as? String {
            fjIncidentTimer.incidentStopClockYear = incidentStopClockYear
        }
        if let lastUnitSameDate = fjIncidentR["lastUnitSameDate"] as? Bool {
            fjIncidentTimer.lastUnitSameDate = lastUnitSameDate
        }
        fjuIncident.incidentTimerDetails = fjIncidentTimer
        
            // MARK: -ActionsTaken-
        let fjActionsTaken = ActionsTaken(context: bkgrdContext)
        if let additionalThree = fjIncidentR["additionalThree"] as? String {
            fjActionsTaken.additionalThree = additionalThree
        }
        if let additionalThreeNumber = fjIncidentR["additionalThreeNumber"] as? String {
            fjActionsTaken.additionalThreeNumber = additionalThreeNumber
        }
        if let additionalTwo = fjIncidentR["additionalTwo"] as? String {
            fjActionsTaken.additionalTwo = additionalTwo
        }
        if let additionalTwoNumber = fjIncidentR["additionalTwoNumber"] as? String {
            fjActionsTaken.additionalTwoNumber = additionalTwoNumber
        }
        if let primaryAction = fjIncidentR["primaryAction"] as? String {
            fjActionsTaken.primaryAction = primaryAction
        }
        if let primaryActionNumber = fjIncidentR["primaryActionNumber"] as? String {
            fjActionsTaken.primaryActionNumber = primaryActionNumber
        }
        fjuIncident.actionsTakenDetails = fjActionsTaken
        
            // TODO: -IncidentTeam, IncidentTags, UserCrew
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjIncidentR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuIncident.fjIncidentCKR = data as NSObject
        
        if fjuIncident.fireJournalUserIncInfo == nil {
            if theUser != nil {
                theUser.addToFireJournalUserIncDetails(fjuIncident)
            }
        }
        
    }
    
//    MARK: -NEW INCIDENT FROM CLOUD-
    private func newIncidentFromCloud(record: CKRecord)->Void {
        
        let fjIncidentR = record
        let fjuIncident = Incident(context: bkgrdContext)
        
        if let formType = fjIncidentR["formType"] as? String {
            fjuIncident.formType = formType
        }
        if let incidentCreationDate = fjIncidentR["incidentCreationDate"] as? Date {
            fjuIncident.incidentCreationDate = incidentCreationDate
        }
        if let incidentDate = fjIncidentR["incidentDate"] as? String {
            fjuIncident.incidentDate = incidentDate
        }
        if let incidentDateSearch = fjIncidentR["incidentDateSearch"] as? String {
            fjuIncident.incidentDateSearch = incidentDateSearch
        }
        if let incidentDayOfWeek = fjIncidentR["incidentDayOfWeek"] as? String {
            fjuIncident.incidentDayOfWeek = incidentDayOfWeek
        }
        if let incidentDayOfYear = fjIncidentR["incidentDayOfYear"] as? Double {
            fjuIncident.incidentDayOfYear = incidentDayOfYear as NSNumber
        }
        if let incidentEntryTypeImageName = fjIncidentR["incidentEntryTypeImageName"] as? String {
            fjuIncident.incidentEntryTypeImageName = incidentEntryTypeImageName
        }
        
            //        MARK: -FCLOCATION-
            /// incidentLocaiton archived with secureCoding
        let theIncidentLocation = FCLocation(context: bkgrdContext)
        theIncidentLocation.guid = UUID()
        if let incidentModDate = fjIncidentR["incidentModDate"] as? Date {
            fjuIncident.incidentModDate = incidentModDate
            theIncidentLocation.modDate = incidentModDate
        }
        if let fjpIncGuidForReference = fjIncidentR["fjpIncGuidForReference"] as? String {
            fjuIncident.fjpIncGuidForReference = fjpIncGuidForReference
            theIncidentLocation.incidentGuid = fjuIncident.fjpIncGuidForReference
        }
        theIncidentLocation.incident = fjuIncident
        if fjIncidentR["incidentLocation"] != nil {
            let location = fjIncidentR["incidentLocation"] as! CLLocation
            theIncidentLocation.location = location
            theIncidentLocation.latitude = location.coordinate.latitude
            theIncidentLocation.longitude = location.coordinate.longitude
        }
        if let appSuiteRoom = fjIncidentR["appSuiteRoom"] as? String {
            theIncidentLocation.appSuite = appSuiteRoom
        }
        if let censusTract = fjIncidentR["censusTract"] as? String {
            theIncidentLocation.censusTract = censusTract
        }
        if let city = fjIncidentR["city"] as? String {
            theIncidentLocation.city = city
        }
        if let crossStreet = fjIncidentR["crossStreet"] as? String {
            theIncidentLocation.crossStreet = crossStreet
        }
        if let incidentState = fjIncidentR["state"] as? String {
            theIncidentLocation.state = incidentState
        }
        if let prefix = fjIncidentR["prefix"] as? String {
            theIncidentLocation.prefix = prefix
        }
        if let streetHighway = fjIncidentR["streetHighway"] as? String {
            theIncidentLocation.streetName = streetHighway
        }
        if let streetNumber = fjIncidentR["streetNumber"] as? String {
            theIncidentLocation.streetNumber = streetNumber
        }
        if let streetType = fjIncidentR["streetType"] as? String {
            theIncidentLocation.streetType = streetType
        }
        if let suffix = fjIncidentR["suffix"] as? String {
            theIncidentLocation.suffix = suffix
        }
        if let zip = fjIncidentR["zip"] as? String {
            theIncidentLocation.zip = zip
        }
       
        if let incidentNFIRSCompleted = fjIncidentR["incidentNFIRSCompleted"] as? Double {
            fjuIncident.incidentNFIRSCompleted = incidentNFIRSCompleted as NSNumber
        }
        if let incidentNFIRSCompletedDate = fjIncidentR["incidentNFIRSCompletedDate"] as? Date {
            fjuIncident.incidentNFIRSCompletedDate = incidentNFIRSCompletedDate
        }
        if let incidentNFIRSDataComplete = fjIncidentR["incidentNFIRSDataComplete"] as? Double {
            fjuIncident.incidentNFIRSDataComplete = incidentNFIRSDataComplete as NSNumber
        }
        if let incidentNFIRSDataDate = fjIncidentR["incidentNFIRSDataDate"] as? String {
            fjuIncident.incidentNFIRSDataDate = incidentNFIRSDataDate
        }
        if let incidentNFIRSDataSaved = fjIncidentR["incidentNFIRSDataSaved"] as? String {
            fjuIncident.incidentNFIRSDataSaved = incidentNFIRSDataSaved
        }
        if let incidentNumber = fjIncidentR["incidentNumber"] as? String {
            fjuIncident.incidentNumber = incidentNumber
        }
        if let incidentPhotoTaken = fjIncidentR["incidentPhotoTaken"] as? Double {
            fjuIncident.incidentPhotoTaken = incidentPhotoTaken as NSNumber
        }
        if let locationAvailable = fjIncidentR["locationAvailable"] as? Double {
            if locationAvailable == 1 {
                fjuIncident.locationAvailable = true
            } else {
                fjuIncident.locationAvailable = false
            }
        }
        if let incidentTagsAvailable = fjIncidentR["incidentTagsAvailable"] as? Double {
            if incidentTagsAvailable == 1 {
                fjuIncident.incidentTagsAvailable = true
            } else {
                fjuIncident.incidentTagsAvailable = false
            }
        }
        if let incidentSearchDate = fjIncidentR["incidentSearchDate"] as? String {
            fjuIncident.incidentSearchDate = incidentSearchDate
        }
        if let incidentStreetHyway = fjIncidentR["incidentStreetHyway"] as? String {
            fjuIncident.incidentStreetHyway = incidentStreetHyway
        }
        if let incidentStreetNumber = fjIncidentR["incidentStreetNumber"] as? String {
            fjuIncident.incidentStreetNumber = incidentStreetNumber
        }
        if let incidentTime = fjIncidentR["incidentTime"] as? String {
            fjuIncident.incidentTime = incidentTime
        }
        if let incidentType = fjIncidentR["incidentType"] as? String {
            fjuIncident.incidentType = incidentType
        }
        if let incidentZipCode = fjIncidentR["incidentZipCode"] as? String {
            fjuIncident.incidentZipCode = incidentZipCode
        }
        if let incidentZipPlus4 = fjIncidentR["incidentZipPlus4"] as? String {
            fjuIncident.incidentZipPlus4 = incidentZipPlus4
        }
        if let situationIncidentImage = fjIncidentR["situationIncidentImage"] as? String {
            fjuIncident.situationIncidentImage = situationIncidentImage
        }
        if let tempIncidentApparatus = fjIncidentR["tempIncidentApparatus"] as? String {
            fjuIncident.tempIncidentApparatus = tempIncidentApparatus
        }
        if let tempIncidentAssignment = fjIncidentR["tempIncidentAssignment"] as? String {
            fjuIncident.tempIncidentAssignment = tempIncidentAssignment
        }
        if let tempIncidentFireStation = fjIncidentR["tempIncidentFireStation"] as? String {
            fjuIncident.tempIncidentFireStation = tempIncidentFireStation
        }
        if let tempIncidentPlatoon = fjIncidentR["tempIncidentPlatoon"] as? String {
            fjuIncident.tempIncidentPlatoon = tempIncidentPlatoon
        }
        if let arsonInvestigation = fjIncidentR["arsonInvestigation"] as? Bool {
            fjuIncident.arsonInvestigation = arsonInvestigation
        }
        
        let fjuSections = NFIRSSections(context: bkgrdContext)
        if let sectionA = fjIncidentR["sectionA"] as? Bool {
            fjuSections.sectionA = sectionA
        }
        if let sectionB = fjIncidentR["sectionB"] as? Bool {
            fjuSections.sectionB = sectionB
        }
        if let sectionC = fjIncidentR["sectionC"] as? Bool {
            fjuSections.sectionC = sectionC
        }
        if let sectionD = fjIncidentR["sectionD"] as? Bool {
            fjuSections.sectionD = sectionD
        }
        if let sectionE = fjIncidentR["sectionE"] as? Bool {
            fjuSections.sectionE = sectionE
        }
        if let sectionF = fjIncidentR["sectionF"] as? Bool {
            fjuSections.sectionF = sectionF
        }
        if let sectionG = fjIncidentR["sectionG"] as? Bool {
            fjuSections.sectionG = sectionG
        }
        if let sectionH = fjIncidentR["sectionH"] as? Bool {
            fjuSections.sectionH = sectionH
        }
        if let sectionI = fjIncidentR["sectionI"] as? Bool {
            fjuSections.sectionI = sectionI
        }
        if let sectionJ = fjIncidentR["sectionJ"] as? Bool {
            fjuSections.sectionJ = sectionJ
        }
        if let sectionK = fjIncidentR["sectionK"] as? Bool {
            fjuSections.sectionK = sectionK
        }
        if let sectionL = fjIncidentR["sectionL"] as? Bool {
            fjuSections.sectionL = sectionL
        }
        if let sectionM = fjIncidentR["sectionM"] as? Bool {
            fjuSections.sectionM = sectionM
        }
        fjuIncident.formDetails = fjuSections
        
        let fjIncidentAddress = IncidentAddress(context: bkgrdContext)
        if let appSuiteRoom = fjIncidentR["appSuiteRoom"] as? String {
            fjIncidentAddress.appSuiteRoom = appSuiteRoom
        }
        if let censusTract = fjIncidentR["censusTract"] as? String {
            fjIncidentAddress.censusTract = censusTract
        }
        if let censusTract2 = fjIncidentR["censusTract2"] as? String {
            fjIncidentAddress.censusTract2 = censusTract2
        }
        if let city = fjIncidentR["city"] as? String {
            fjIncidentAddress.city = city
        }
        if let crossStreet = fjIncidentR["crossStreet"] as? String {
            fjIncidentAddress.crossStreet = crossStreet
        }
        if let incidentState = fjIncidentR["incidentState"] as? String {
            fjIncidentAddress.incidentState = incidentState
        }
        if let prefix = fjIncidentR["prefix"] as? String {
            fjIncidentAddress.prefix = prefix
        }
        if let stagingAddress = fjIncidentR["stagingAddress"] as? String {
            fjIncidentAddress.stagingAddress = stagingAddress
        }
        if let streetHighway = fjIncidentR["streetHighway"] as? String {
            fjIncidentAddress.streetHighway = streetHighway
        }
        if let streetNumber = fjIncidentR["streetNumber"] as? String {
            fjIncidentAddress.streetNumber = streetNumber
        }
        if let streetType = fjIncidentR["streetType"] as? String {
            fjIncidentAddress.streetType = streetType
        }
        if let suffix = fjIncidentR["suffix"] as? String {
            fjIncidentAddress.suffix = suffix
        }
        if let zip = fjIncidentR["zip"] as? String {
            fjIncidentAddress.zip = zip
        }
        if let zipPlus4 = fjIncidentR["zipPlus4"] as? String {
            fjIncidentAddress.zipPlus4 = zipPlus4
        }
        fjuIncident.incidentAddressDetails = fjIncidentAddress
        
            //MARK: -incidentLocal-
        let fjIncidentLocal = IncidentLocal(context: bkgrdContext)
        if let incidentBattalion = fjIncidentR["incidentBattalion"] as? String {
            fjIncidentLocal.incidentBattalion = incidentBattalion
        }
        if let incidentDivision = fjIncidentR["incidentDivision"] as? String {
            fjIncidentLocal.incidentDivision = incidentDivision
        }
        if let incidentFireDistrict = fjIncidentR["incidentFireDistrict"] as? String {
            fjIncidentLocal.incidentFireDistrict = incidentFireDistrict
        }
        if let incidentLocalType = fjIncidentR["incidentLocalType"] as? String {
            fjIncidentLocal.incidentLocalType = incidentLocalType
        }
        fjuIncident.incidentLocalDetails = fjIncidentLocal
        
            //MARK: -incidentMap-
        let fjIncidentMap = IncidentMap(context: bkgrdContext)
        if let incidentLatitude = fjIncidentR["incidentLatitude"] as? String {
            fjIncidentMap.incidentLatitude = incidentLatitude
        }
        if let incidentLongitude = fjIncidentR["incidentLongitude"] as? String {
            fjIncidentMap.incidentLongitude = incidentLongitude
        }
        if let stagingLatitude = fjIncidentR["stagingLatitude"] as? String {
            fjIncidentMap.stagingLatitude = stagingLatitude
        }
        if let stagingLongitude = fjIncidentR["stagingLongitude"] as? String {
            fjIncidentMap.stagingLongitude = stagingLongitude
        }
        fjuIncident.incidentMapDetails = fjIncidentMap
        
            //MARK: -IncidentNFIRS-
        let fjIncidentNFIRS = IncidentNFIRS(context: bkgrdContext)
        if let fireStationState = fjIncidentR["fireStationState"] as? String {
            fjIncidentNFIRS.fireStationState = fireStationState
        }
        if let incidentActionsTakenAdditionalThree = fjIncidentR["incidentActionsTakenAdditionalThree"] as? String {
            fjIncidentNFIRS.incidentActionsTakenAdditionalThree = incidentActionsTakenAdditionalThree
        }
        if let incidentActionsTakenAdditionalTwo = fjIncidentR["incidentActionsTakenAdditionalTwo"] as? String {
            fjIncidentNFIRS.incidentActionsTakenAdditionalTwo = incidentActionsTakenAdditionalTwo
        }
        if let incidentActionsTakenPrimary = fjIncidentR["incidentActionsTakenPrimary"] as? String {
            fjIncidentNFIRS.incidentActionsTakenPrimary = incidentActionsTakenPrimary
        }
        if let incidentAidGiven = fjIncidentR["incidentAidGiven"] as? String {
            fjIncidentNFIRS.incidentAidGiven = incidentAidGiven
        }
        if let incidentAidGivenFDID = fjIncidentR["incidentAidGivenFDID"] as? String {
            fjIncidentNFIRS.incidentAidGivenFDID = incidentAidGivenFDID
        }
        if let incidentAidGivenIncidentNumber = fjIncidentR["incidentAidGivenIncidentNumber"] as? String {
            fjIncidentNFIRS.incidentAidGivenIncidentNumber = incidentAidGivenIncidentNumber
        }
        if let incidentAidGivenNone = fjIncidentR["incidentAidGivenNone"] as? Double {
            fjIncidentNFIRS.incidentAidGivenNone = incidentAidGivenNone as NSNumber
        }
        if let incidentAidGivenState = fjIncidentR["incidentAidGivenState"] as? String {
            fjIncidentNFIRS.incidentAidGivenState = incidentAidGivenState
        }
        if let incidentCasualtiesCivilianDeaths = fjIncidentR["incidentCasualtiesCivilianDeaths"] as? String {
            fjIncidentNFIRS.incidentCasualtiesCivilianDeaths = incidentCasualtiesCivilianDeaths
        }
        if let incidentCasualtiesCivilianInjuries = fjIncidentR["incidentCasualtiesCivilianInjuries"] as? String {
            fjIncidentNFIRS.incidentCasualtiesCivilianInjuries = incidentCasualtiesCivilianInjuries
        }
        if let incidentCasualtiesFireDeaths = fjIncidentR["incidentCasualtiesFireDeaths"] as? String {
            fjIncidentNFIRS.incidentCasualtiesFireDeaths = incidentCasualtiesFireDeaths
        }
        if let incidentCasualtiesFireInjuries = fjIncidentR["incidentCasualtiesFireInjuries"] as? String {
            fjIncidentNFIRS.incidentCasualtiesFireInjuries = incidentCasualtiesFireInjuries
        }
        if let incidentCasualtiesNone = fjIncidentR["incidentCasualtiesNone"] as? Bool {
            fjIncidentNFIRS.incidentCasualtiesNone = incidentCasualtiesNone
        }
        if let incidentCasualtiesServiceDeaths = fjIncidentR["incidentCasualtiesServiceDeaths"] as? String {
            fjIncidentNFIRS.incidentCasualtiesServiceDeaths = incidentCasualtiesServiceDeaths
        }
        if let incidentCasualtitesServideInjuries = fjIncidentR["incidentCasualtitesServideInjuries"] as? String {
            fjIncidentNFIRS.incidentCasualtitesServideInjuries = incidentCasualtitesServideInjuries
        }
        if let incidentDetectorChosen = fjIncidentR["incidentDetectorChosen"] as? String {
            fjIncidentNFIRS.incidentDetectorChosen = incidentDetectorChosen
        }
        if let incidentExposure = fjIncidentR["incidentExposure"] as? String {
            fjIncidentNFIRS.incidentExposure = incidentExposure
        }
        if let incidentFDID = fjIncidentR["incidentFDID"] as? String {
            fjIncidentNFIRS.incidentFDID = incidentFDID
        }
        if let incidentFDID1 = fjIncidentR["incidentFDID1"] as? String {
            fjIncidentNFIRS.incidentFDID1 = incidentFDID1
        }
        if let incidentFireStation = fjIncidentR["incidentFireStation"] as? String {
            fjIncidentNFIRS.incidentFireStation = incidentFireStation
        }
        if let incidentHazMat = fjIncidentR["incidentHazMat"] as? String {
            fjIncidentNFIRS.incidentHazMat = incidentHazMat
        }
        if let incidentHazMatNone = fjIncidentR["incidentHazMatNone"] as? Bool {
            fjIncidentNFIRS.incidentHazMatNone = incidentHazMatNone
        }
            //        MARK: -STRING-
        if let incidentNFIRSLocation = fjIncidentR["incidentNFIRSLocation"] as? String {
            fjIncidentNFIRS.incidentLocation = incidentNFIRSLocation
        }
        if let incidentPlatoon = fjIncidentR["incidentPlatoon"] as? String {
            fjIncidentNFIRS.incidentPlatoon = incidentPlatoon
        }
        if let incidentPropertyNone = fjIncidentR["incidentPropertyNone"] as? Double {
            fjIncidentNFIRS.incidentPropertyNone = incidentPropertyNone as NSNumber
        }
        if let incidentPropertyOutside = fjIncidentR["incidentPropertyOutside"] as? String {
            fjIncidentNFIRS.incidentPropertyOutside = incidentPropertyOutside
        }
        if let incidentPropertyOutsideNumber = fjIncidentR["incidentPropertyOutsideNumber"] as? String {
            fjIncidentNFIRS.incidentPropertyOutsideNumber = incidentPropertyOutsideNumber
        }
        if let incidentPropertyStructure = fjIncidentR["incidentPropertyStructure"] as? String {
            fjIncidentNFIRS.incidentPropertyStructure = incidentPropertyStructure
        }
        if let incidentPropertyStructureNumber = fjIncidentR["incidentPropertyStructureNumber"] as? String {
            fjIncidentNFIRS.incidentPropertyStructureNumber = incidentPropertyStructureNumber
        }
        if let incidentPropertyUse = fjIncidentR["incidentPropertyUse"] as? String {
            fjIncidentNFIRS.incidentPropertyUse = incidentPropertyUse
        }
        if let incidentPropertyUseNone = fjIncidentR["incidentPropertyUseNone"] as? String {
            fjIncidentNFIRS.incidentPropertyUseNone = incidentPropertyUseNone
        }
        if let incidentPropertyUseNumber = fjIncidentR["incidentPropertyUseNumber"] as? String {
            fjIncidentNFIRS.incidentPropertyUseNumber = incidentPropertyUseNumber
        }
        if let incidentResourceCheck = fjIncidentR["incidentResourceCheck"]  as? Double {
            fjIncidentNFIRS.incidentResourceCheck = incidentResourceCheck  as NSNumber
        }
        if let incidentResourcesEMSApparatus = fjIncidentR["incidentResourcesEMSApparatus"] as? String {
            fjIncidentNFIRS.incidentResourcesEMSApparatus = incidentResourcesEMSApparatus
        }
        if let incidentResourcesEMSPersonnel = fjIncidentR["incidentResourcesEMSPersonnel"] as? String {
            fjIncidentNFIRS.incidentResourcesEMSPersonnel = incidentResourcesEMSPersonnel
        }
        if let incidentResourcesOtherApparatus = fjIncidentR["incidentResourcesOtherApparatus"] as? String {
            fjIncidentNFIRS.incidentResourcesOtherApparatus = incidentResourcesOtherApparatus
        }
        if let incidentResourcesOtherPersonnel = fjIncidentR["incidentResourcesOtherPersonnel"] as? String {
            fjIncidentNFIRS.incidentResourcesOtherPersonnel = incidentResourcesOtherPersonnel
        }
        if let incidentResourcesSuppressionPersonnel = fjIncidentR["incidentResourcesSuppressionPersonnel"] as? String {
            fjIncidentNFIRS.incidentResourcesSuppressionPersonnel = incidentResourcesSuppressionPersonnel
        }
        if let incidentResourcesSupressionApparatus = fjIncidentR["incidentResourcesSupressionApparatus"] as? String {
            fjIncidentNFIRS.incidentResourcesSupressionApparatus = incidentResourcesSupressionApparatus
        }
        if let incidentTypeNumberNFRIS = fjIncidentR["incidentTypeNumberNFRIS"] as? String {
            fjIncidentNFIRS.incidentTypeNumberNFRIS = incidentTypeNumberNFRIS
        }
        if let incidentTypeTextNFRIS = fjIncidentR["incidentTypeTextNFRIS"] as? String {
            fjIncidentNFIRS.incidentTypeTextNFRIS = incidentTypeTextNFRIS
        }
        if let lossesContentDollars = fjIncidentR["lossesContentDollars"] as? String {
            fjIncidentNFIRS.lossesContentDollars = lossesContentDollars
        }
        if let lossesContentNone = fjIncidentR["lossesContentNone"] as? Bool {
            fjIncidentNFIRS.lossesContentNone = lossesContentNone
        }
        if let lossesPropertyDollars = fjIncidentR["lossesPropertyDollars"] as? String {
            fjIncidentNFIRS.lossesPropertyDollars = lossesPropertyDollars
        }
        if let lossesPropertyNone = fjIncidentR["lossesPropertyNone"] as? Bool {
            fjIncidentNFIRS.lossesPropertyNone = lossesPropertyNone
        }
        if let mixedUsePropertyNone = fjIncidentR["mixedUsePropertyNone"] as? Bool {
            fjIncidentNFIRS.mixedUsePropertyNone = mixedUsePropertyNone
        }
        if let mixedUsePropertyType = fjIncidentR["mixedUsePropertyType"] as? String {
            fjIncidentNFIRS.mixedUsePropertyType = mixedUsePropertyType
        }
        if let nfirsChangeDescription = fjIncidentR["nfirsChangeDescription"] as? String {
            fjIncidentNFIRS.nfirsChangeDescription = nfirsChangeDescription
        }
        if let nfirsSectionOneSegment = fjIncidentR["nfirsSectionOneSegment"] as? String {
            fjIncidentNFIRS.nfirsSectionOneSegment = nfirsSectionOneSegment
        }
        if let propertyUseNone = fjIncidentR["propertyUseNone"] as? Bool {
            fjIncidentNFIRS.propertyUseNone = propertyUseNone
        }
        if let resourceCountsIncludeAidReceived = fjIncidentR["resourceCountsIncludeAidReceived"] as? Bool {
            fjIncidentNFIRS.resourceCountsIncludeAidReceived = resourceCountsIncludeAidReceived
        }
        if let shiftAlarm = fjIncidentR["shiftAlarm"] as? String {
            fjIncidentNFIRS.shiftAlarm = shiftAlarm
        }
        if let shiftDistrict = fjIncidentR["shiftDistrict"] as? String {
            fjIncidentNFIRS.shiftDistrict = shiftDistrict
        }
        if let shiftOrPlatoon = fjIncidentR["shiftOrPlatoon"]  as? String {
            fjIncidentNFIRS.shiftOrPlatoon = shiftOrPlatoon
        }
        if let skipSectionF = fjIncidentR["skipSectionF"] as? Bool {
            fjIncidentNFIRS.skipSectionF = skipSectionF
        }
        if let specialStudyID = fjIncidentR["specialStudyID"] as? String {
            fjIncidentNFIRS.specialStudyID = specialStudyID
        }
        if let specialStudyValue = fjIncidentR["specialStudyValue"] as? String {
            fjIncidentNFIRS.specialStudyValue = specialStudyValue
        }
        if let valueContentDollars = fjIncidentR["valueContentDollars"] as? String {
            fjIncidentNFIRS.valueContentDollars = valueContentDollars
        }
        if let valueContentsNone = fjIncidentR["valueContentsNone"] as? Bool {
            fjIncidentNFIRS.valueContentsNone = valueContentsNone
        }
        if let valuePropertyDollars = fjIncidentR["valuePropertyDollars"] as? String {
            fjIncidentNFIRS.valuePropertyDollars = valuePropertyDollars
        }
        if let valuePropertyNone = fjIncidentR["valuePropertyNone"] as? Bool {
            fjIncidentNFIRS.valuePropertyNone = valuePropertyNone
        }
        fjuIncident.incidentNFIRSDetails = fjIncidentNFIRS
        
            // TODO: -CompletedModules-
            // MARK: -IncidentNFIRSKSec-
        let fjIncidentNFIRSKSec = IncidentNFIRSKSec(context: bkgrdContext)
        if let kOwnerAptSuiteRoom = fjIncidentR["kOwnerAptSuiteRoom"] as? String {
            fjIncidentNFIRSKSec.kOwnerAptSuiteRoom = kOwnerAptSuiteRoom
        }
        if let kOwnerAreaCode = fjIncidentR["kOwnerAreaCode"] as? String {
            fjIncidentNFIRSKSec.kOwnerAreaCode = kOwnerAreaCode
        }
        if let kOwnerBusinessName = fjIncidentR["kOwnerBusinessName"] as? String {
            fjIncidentNFIRSKSec.kOwnerBusinessName = kOwnerBusinessName
        }
        if let kOwnerCheckBox = fjIncidentR["kOwnerCheckBox"] as? Bool {
            fjIncidentNFIRSKSec.kOwnerCheckBox = kOwnerCheckBox
        }
        if let kOwnerCity = fjIncidentR["kOwnerCity"] as? String {
            fjIncidentNFIRSKSec.kOwnerCity = kOwnerCity
        }
        if let kOwnerFirstName = fjIncidentR["kOwnerFirstName"] as? String {
            fjIncidentNFIRSKSec.kOwnerFirstName = kOwnerFirstName
        }
        if let kOwnerLastName = fjIncidentR["kOwnerLastName"] as? String {
            fjIncidentNFIRSKSec.kOwnerLastName = kOwnerLastName
        }
        if let kOwnerMI = fjIncidentR["kOwnerMI"] as? String {
            fjIncidentNFIRSKSec.kOwnerMI = kOwnerMI
        }
        if let kOwnerNamePrefix = fjIncidentR["kOwnerNamePrefix"] as? String {
            fjIncidentNFIRSKSec.kOwnerNamePrefix = kOwnerNamePrefix
        }
        if let kOwnerNameSuffix = fjIncidentR["kOwnerNameSuffix"] as? String {
            fjIncidentNFIRSKSec.kOwnerNameSuffix = kOwnerNameSuffix
        }
        if let kOwnerPhoneLastFour = fjIncidentR["kOwnerPhoneLastFour"] as? String {
            fjIncidentNFIRSKSec.kOwnerPhoneLastFour = kOwnerPhoneLastFour
        }
        if let kOwnerPhonePrefix = fjIncidentR["kOwnerPhonePrefix"] as? String {
            fjIncidentNFIRSKSec.kOwnerPhonePrefix = kOwnerPhonePrefix
        }
        if let kOwnerPOBox = fjIncidentR["kOwnerPOBox"] as? String {
            fjIncidentNFIRSKSec.kOwnerPOBox = kOwnerPOBox
        }
        if let kOwnerSameAsPerson = fjIncidentR["kOwnerSameAsPerson"] as? Bool {
            fjIncidentNFIRSKSec.kOwnerSameAsPerson = kOwnerSameAsPerson
        }
        if let kOwnerState = fjIncidentR["kOwnerState"] as? String {
            fjIncidentNFIRSKSec.kOwnerState = kOwnerState
        }
        if let kOwnerStreetHyway = fjIncidentR["kOwnerStreetHyway"] as? String {
            fjIncidentNFIRSKSec.kOwnerStreetHyway = kOwnerStreetHyway
        }
        if let kOwnerStreetNumber = fjIncidentR["kOwnerStreetNumber"] as? String {
            fjIncidentNFIRSKSec.kOwnerStreetNumber = kOwnerStreetNumber
        }
        if let kOwnerStreetPrefix = fjIncidentR["kOwnerStreetPrefix"] as? String {
            fjIncidentNFIRSKSec.kOwnerStreetPrefix = kOwnerStreetPrefix
        }
        if let kOwnerStreetSuffix = fjIncidentR["kOwnerStreetSuffix"] as? String {
            fjIncidentNFIRSKSec.kOwnerStreetSuffix = kOwnerStreetSuffix
        }
        if let kOwnerStreetType = fjIncidentR["kOwnerStreetType"] as? String {
            fjIncidentNFIRSKSec.kOwnerStreetType = kOwnerStreetType
        }
        if let kOwnerZip = fjIncidentR["kOwnerZip"] as? String {
            fjIncidentNFIRSKSec.kOwnerZip = kOwnerZip
        }
        if let kOwnerZipPlusFour = fjIncidentR["kOwnerZipPlusFour"] as? String {
            fjIncidentNFIRSKSec.kOwnerZipPlusFour = kOwnerZipPlusFour
        }
        if let kPersonAppSuiteRoom = fjIncidentR["kPersonAppSuiteRoom"] as? String {
            fjIncidentNFIRSKSec.kPersonAppSuiteRoom = kPersonAppSuiteRoom
        }
        if let kPersonAreaCode = fjIncidentR["kPersonAreaCode"] as? String {
            fjIncidentNFIRSKSec.kPersonAreaCode = kPersonAreaCode
        }
        if let kPersonBusinessName = fjIncidentR["kPersonBusinessName"] as? String {
            fjIncidentNFIRSKSec.kPersonBusinessName = kPersonBusinessName
        }
        if let kPersonCheckBox = fjIncidentR["kPersonCheckBox"] as? Bool {
            fjIncidentNFIRSKSec.kPersonCheckBox = kPersonCheckBox
        }
        if let kPersonCity = fjIncidentR["kPersonCity"] as? String {
            fjIncidentNFIRSKSec.kPersonCity = kPersonCity
        }
        if let kPersonFirstName = fjIncidentR["kPersonFirstName"] as? String {
            fjIncidentNFIRSKSec.kPersonFirstName = kPersonFirstName
        }
        if let kPersonGender = fjIncidentR["kPersonGender"] as? String {
            fjIncidentNFIRSKSec.kPersonGender = kPersonGender
        }
        if let kPersonLastName = fjIncidentR["kPersonLastName"] as? String {
            fjIncidentNFIRSKSec.kPersonLastName = kPersonLastName
        }
        if let kPersonMI = fjIncidentR["kPersonMI"] as? String {
            fjIncidentNFIRSKSec.kPersonMI = kPersonMI
        }
        if let kPersonMoreThanOne = fjIncidentR["kPersonMoreThanOne"] as? Bool {
            fjIncidentNFIRSKSec.kPersonMoreThanOne = kPersonMoreThanOne
        }
        if let kPersonNameSuffix = fjIncidentR["kPersonNameSuffix"] as? String {
            fjIncidentNFIRSKSec.kPersonNameSuffix = kPersonNameSuffix
        }
        if let kPersonPhoneLastFour = fjIncidentR["kPersonPhoneLastFour"] as? String {
            fjIncidentNFIRSKSec.kPersonPhoneLastFour = kPersonPhoneLastFour
        }
        if let kPersonPhonePrefix = fjIncidentR["kPersonPhonePrefix"] as? String {
            fjIncidentNFIRSKSec.kPersonPhonePrefix = kPersonPhonePrefix
        }
        if let kPersonPOBox = fjIncidentR["kPersonPOBox"] as? String {
            fjIncidentNFIRSKSec.kPersonPOBox = kPersonPOBox
        }
        if let kPersonPrefix = fjIncidentR["kPersonPrefix"] as? String {
            fjIncidentNFIRSKSec.kPersonPrefix = kPersonPrefix
        }
        if let kPersonState = fjIncidentR["kPersonState"] as? String {
            fjIncidentNFIRSKSec.kPersonState = kPersonState
        }
        if let kPersonStreetHyway = fjIncidentR["kPersonStreetHyway"] as? String {
            fjIncidentNFIRSKSec.kPersonStreetHyway = kPersonStreetHyway
        }
        if let kPersonStreetNum = fjIncidentR["kPersonStreetNum"] as? String {
            fjIncidentNFIRSKSec.kPersonStreetNum = kPersonStreetNum
        }
        if let kPersonStreetSuffix = fjIncidentR["kPersonStreetSuffix"] as? String {
            fjIncidentNFIRSKSec.kPersonStreetSuffix = kPersonStreetSuffix
        }
        if let kPersonStreetType = fjIncidentR["kPersonStreetType"] as? String {
            fjIncidentNFIRSKSec.kPersonStreetType = kPersonStreetType
        }
        if let kPersonZipCode = fjIncidentR["kPersonZipCode"] as? String {
            fjIncidentNFIRSKSec.kPersonZipCode = kPersonZipCode
        }
        if let kPersonZipPlus4 = fjIncidentR["kPersonZipPlus4"] as? String {
            fjIncidentNFIRSKSec.kPersonZipPlus4 = kPersonZipPlus4
        }
        fjuIncident.incidentNFIRSKSecDetails = fjIncidentNFIRSKSec
        
            // TODO: -REQUIREDMODULES
            // MARK: -IncidentNFIRSsecL-
        let fjIncidentNFIRSsecL = IncidentNFIRSsecL(context: bkgrdContext)
        if let lRemarks = fjIncidentR["incidentNFIRSSecLNotes"] as? String {
            fjIncidentNFIRSsecL.lRemarks = lRemarks as NSObject
        }
        if let moreRemarks = fjIncidentR["incidentNFIRSSecLMoreRemarks"] as? Bool {
            fjIncidentNFIRSsecL.moreRemarks = moreRemarks
        }
        fjuIncident.sectionLDetails = fjIncidentNFIRSsecL
        
            // MARK: -IncidentNFIRSsecM-
        let fjIncidentNFIRSsecM = IncidentNFIRSsecM(context: bkgrdContext)
        if let memberAssignment = fjIncidentR["memberAssignment"] as? String {
            fjIncidentNFIRSsecM.memberAssignment = memberAssignment
        }
        if let memberDate = fjIncidentR["memberDate"] as? Date {
            fjIncidentNFIRSsecM.memberDate = memberDate
        }
        if let memberMakingReportID = fjIncidentR["memberMakingReportID"] as? String {
            fjIncidentNFIRSsecM.memberMakingReportID = memberMakingReportID
        }
        if let memberRankPosition = fjIncidentR["memberRankPosition"] as? String {
            fjIncidentNFIRSsecM.memberRankPosition = memberRankPosition
        }
        if let memberSameAsOfficer = fjIncidentR["memberSameAsOfficer"] as? Bool {
            fjIncidentNFIRSsecM.memberSameAsOfficer = memberSameAsOfficer
        }
        if let officerAssignment = fjIncidentR["officerAssignment"] as? String {
            fjIncidentNFIRSsecM.officerAssignment = officerAssignment
        }
        if let officerDate = fjIncidentR["officerDate"] as? Date {
            fjIncidentNFIRSsecM.officerDate = officerDate
        }
        if let officerInChargeID = fjIncidentR["officerInChargeID"] as? String {
            fjIncidentNFIRSsecM.officerInChargeID = officerInChargeID
        }
        if let officerRankPosition = fjIncidentR["officerRankPosition"] as? String {
            fjIncidentNFIRSsecM.officerRankPosition = officerRankPosition
        }
        if let signatureMember = fjIncidentR["signatureMember"] as? String {
            fjIncidentNFIRSsecM.signatureMember = signatureMember
        }
        if let signatureOfficer = fjIncidentR["signatureOfficer"] as? String {
            fjIncidentNFIRSsecM.signatureOfficer = signatureOfficer
        }
        if let memberSigned = fjIncidentR["memberSigned"] as? Bool {
            fjIncidentNFIRSsecM.memberSigned = memberSigned
        }
        if let officeSigned = fjIncidentR["officerSigned"] as? Bool {
            fjIncidentNFIRSsecM.officeSigned = officeSigned
        }
            // TODO: -SIGNATURE CONVERSION-
        
        fjuIncident.sectionMDetails = fjIncidentNFIRSsecM
        
            // MARK: -IncidentNotes-
        let fjIncidentNotes = IncidentNotes(context: bkgrdContext)
        if let incidentSummaryNotesSC = fjIncidentR["incidentSummaryNotes"] as? NSObject {
            fjIncidentNotes.incidentSummaryNotesSC = incidentSummaryNotesSC
        }
        if let note = fjIncidentR["incidentNote"] as? String {
            fjIncidentNotes.incidentNote = note
        }
        fjuIncident.incidentNotesDetails = fjIncidentNotes
        
            // TODO: -IncidentResources-
            // MARK: -IncidentTimer-
        let fjIncidentTimer = IncidentTimer(context: bkgrdContext)
        if let arrivalSameDate = fjIncidentR["arrivalSameDate"] as? Bool {
            fjIncidentTimer.arrivalSameDate = arrivalSameDate
        }
        if let controlledSameDate = fjIncidentR["controlledSameDate"] as? Bool {
            fjIncidentTimer.controlledSameDate = controlledSameDate
        }
        if let incidentAlarmCombinedDate = fjIncidentR["incidentAlarmCombinedDate"] as? String {
            fjIncidentTimer.incidentAlarmCombinedDate = incidentAlarmCombinedDate
        }
        if let incidentAlarmDateTime = fjIncidentR["incidentAlarmDateTime"] as? Date {
            fjIncidentTimer.incidentAlarmDateTime = incidentAlarmDateTime
        }
        if let incidentAlarmDay = fjIncidentR["incidentAlarmDay"] as? String {
            fjIncidentTimer.incidentAlarmDay = incidentAlarmDay
        }
        if let incidentAlarmHours = fjIncidentR["incidentAlarmHours"] as? String {
            fjIncidentTimer.incidentAlarmHours = incidentAlarmHours
        }
        if let incidentAlarmMinutes = fjIncidentR["incidentAlarmMinutes"] as? String {
            fjIncidentTimer.incidentAlarmMinutes = incidentAlarmMinutes
        }
        if let incidentAlarmMonth = fjIncidentR["incidentAlarmMonth"] as? String {
            fjIncidentTimer.incidentAlarmMonth = incidentAlarmMonth
        }
        if let incidentAlarmNotes = fjIncidentR["incidentAlarmNotes"] as? String {
            fjIncidentTimer.incidentAlarmNotes = incidentAlarmNotes as NSObject
        }
        if let incidentAlarmYear = fjIncidentR["incidentAlarmYear"] as? String {
            fjIncidentTimer.incidentAlarmYear = incidentAlarmYear
        }
        if let incidentArrivalCombinedDate = fjIncidentR["incidentArrivalCombinedDate"] as? String {
            fjIncidentTimer.incidentArrivalCombinedDate = incidentArrivalCombinedDate
        }
        if let incidentArrivalDateTime = fjIncidentR["incidentArrivalDateTime"] as? Date {
            fjIncidentTimer.incidentArrivalDateTime = incidentArrivalDateTime
        }
        if let incidentArrivalDay = fjIncidentR["incidentArrivalDay"] as? String {
            fjIncidentTimer.incidentArrivalDay = incidentArrivalDay
        }
        if let incidentArrivalHours = fjIncidentR["incidentArrivalHours"] as? String {
            fjIncidentTimer.incidentArrivalHours = incidentArrivalHours
        }
        if let incidentArrivalMinutes = fjIncidentR["incidentArrivalMinutes"] as? String {
            fjIncidentTimer.incidentArrivalMinutes = incidentArrivalMinutes
        }
        if let incidentArrivalMonth = fjIncidentR["incidentArrivalMonth"] as? String {
            fjIncidentTimer.incidentArrivalMonth = incidentArrivalMonth
        }
        if let incidentArrivalNotes = fjIncidentR["incidentArrivalNotes"] as? String {
            fjIncidentTimer.incidentArrivalNotes = incidentArrivalNotes as NSObject
        }
        if let incidentArrivalYear = fjIncidentR["incidentArrivalYear"] as? String {
            fjIncidentTimer.incidentArrivalYear = incidentArrivalYear
        }
        if let incidentArrivalYear = fjIncidentR["incidentArrivalYear"] as? String {
            fjIncidentTimer.incidentArrivalYear = incidentArrivalYear
        }
        if let incidentControlDateTime =  fjIncidentR["incidentControlDateTime"] as? Date {
            fjIncidentTimer.incidentControlDateTime =  incidentControlDateTime
        }
        if let incidentControlledDay = fjIncidentR["incidentControlledDay"] as? String {
            fjIncidentTimer.incidentControlledDay = incidentControlledDay
        }
        if let incidentControlledHours = fjIncidentR["incidentControlledHours"] as? String {
            fjIncidentTimer.incidentControlledHours = incidentControlledHours
        }
        if let incidentControlledMinutes = fjIncidentR["incidentControlledMinutes"] as? String {
            fjIncidentTimer.incidentControlledMinutes = incidentControlledMinutes
        }
        if let incidentControlledMonth = fjIncidentR["incidentControlledMonth"] as? String {
            fjIncidentTimer.incidentControlledMonth = incidentControlledMonth
        }
        if let incidentControlledNotes = fjIncidentR["incidentControlledNotes"] as? String {
            fjIncidentTimer.incidentControlledNotes = incidentControlledNotes as NSObject
        }
        if let incidentControlledYear = fjIncidentR["incidentControlledYear"] as? String {
            fjIncidentTimer.incidentControlledYear = incidentControlledYear
        }
        if let incidentElapsedTime = fjIncidentR["incidentElapsedTime"] as? String {
            fjIncidentTimer.incidentElapsedTime = incidentElapsedTime
        }
        if let incidentLastUnitCalledCombinedDate = fjIncidentR["incidentLastUnitCalledCombinedDate"] as? String {
            fjIncidentTimer.incidentLastUnitCalledCombinedDate = incidentLastUnitCalledCombinedDate
        }
        if let incidentLastUnitDateTime = fjIncidentR["incidentLastUnitDateTime"] as? Date {
            fjIncidentTimer.incidentLastUnitDateTime = incidentLastUnitDateTime
        }
        if let incidentLastUnitCalledDay = fjIncidentR["incidentLastUnitCalledDay"] as? String {
            fjIncidentTimer.incidentLastUnitCalledDay = incidentLastUnitCalledDay
        }
        if let incidentLastUnitCalledHours = fjIncidentR["incidentLastUnitCalledHours"] as? String {
            fjIncidentTimer.incidentLastUnitCalledHours = incidentLastUnitCalledHours
        }
        if let incidentLastUnitCalledMinutes = fjIncidentR["incidentLastUnitCalledMinutes"] as? String {
            fjIncidentTimer.incidentLastUnitCalledMinutes = incidentLastUnitCalledMinutes
        }
        if let incidentLastUnitCalledMonth = fjIncidentR["incidentLastUnitCalledMonth"] as? String {
            fjIncidentTimer.incidentLastUnitCalledMonth = incidentLastUnitCalledMonth
        }
        if let incidentLastUnitCalledYear = fjIncidentR["incidentLastUnitCalledYear"] as? String {
            fjIncidentTimer.incidentLastUnitCalledYear = incidentLastUnitCalledYear
        }
        if let incidentLastUnitClearedNotes = fjIncidentR["incidentLastUnitClearedNotes"] as? String {
            fjIncidentTimer.incidentLastUnitClearedNotes = incidentLastUnitClearedNotes as NSObject
        }
        if let incidentStartClockCombinedDate = fjIncidentR["incidentStartClockCombinedDate"] as? String {
            fjIncidentTimer.incidentStartClockCombinedDate = incidentStartClockCombinedDate
        }
        if let incidentStartClockDateTime = fjIncidentR["incidentStartClockDateTime"] as? Date {
            fjIncidentTimer.incidentStartClockDateTime = incidentStartClockDateTime
        }
        if let incidentStartClockDay = fjIncidentR["incidentStartClockDay"] as? String {
            fjIncidentTimer.incidentStartClockDay = incidentStartClockDay
        }
        if let incidentStartClockHours = fjIncidentR["incidentStartClockHours"] as? String {
            fjIncidentTimer.incidentStartClockHours = incidentStartClockHours
        }
        if let incidentStartClockMinutes = fjIncidentR["incidentStartClockMinutes"] as? String {
            fjIncidentTimer.incidentStartClockMinutes = incidentStartClockMinutes
        }
        if let incidentStartClockMonth = fjIncidentR["incidentStartClockMonth"] as? String {
            fjIncidentTimer.incidentStartClockMonth = incidentStartClockMonth
        }
        if let incidentStartClockSeconds = fjIncidentR["incidentStartClockSeconds"] as? String {
            fjIncidentTimer.incidentStartClockSeconds = incidentStartClockSeconds
        }
        if let incidentStartClockYear = fjIncidentR["incidentStartClockYear"] as? String {
            fjIncidentTimer.incidentStartClockYear = incidentStartClockYear
        }
        if let incidentStopClockCombinedDate = fjIncidentR["incidentStopClockCombinedDate"]  as? String {
            fjIncidentTimer.incidentStopClockCombinedDate = incidentStopClockCombinedDate
        }
        if let incidentStopClockDateTime = fjIncidentR["incidentStopClockDateTime"] as? Date {
            fjIncidentTimer.incidentStopClockDateTime = incidentStopClockDateTime
        }
        if let incidentStopClockDay = fjIncidentR["incidentStopClockDay"] as? String {
            fjIncidentTimer.incidentStopClockDay = incidentStopClockDay
        }
        if let incidentStopClockHours = fjIncidentR["incidentStopClockHours"] as? String {
            fjIncidentTimer.incidentStopClockHours = incidentStopClockHours
        }
        if let incidentStopClockMinutes = fjIncidentR["incidentStopClockMinutes"] as? String {
            fjIncidentTimer.incidentStopClockMinutes = incidentStopClockMinutes
        }
        if let incidentStopClockMonth = fjIncidentR["incidentStopClockMonth"] as? String {
            fjIncidentTimer.incidentStopClockMonth = incidentStopClockMonth
        }
        if let incidentStopClockSeconds = fjIncidentR["incidentStopClockSeconds"] as? String {
            fjIncidentTimer.incidentStopClockSeconds = incidentStopClockSeconds
        }
        if let incidentStopClockYear = fjIncidentR["incidentStopClockYear"] as? String {
            fjIncidentTimer.incidentStopClockYear = incidentStopClockYear
        }
        if let lastUnitSameDate = fjIncidentR["lastUnitSameDate"] as? Bool {
            fjIncidentTimer.lastUnitSameDate = lastUnitSameDate
        }
        fjuIncident.incidentTimerDetails = fjIncidentTimer
        
            // MARK: -ActionsTaken-
        let fjActionsTaken = ActionsTaken(context: bkgrdContext)
        if let additionalThree = fjIncidentR["additionalThree"] as? String {
            fjActionsTaken.additionalThree = additionalThree
        }
        if let additionalThreeNumber = fjIncidentR["additionalThreeNumber"] as? String {
            fjActionsTaken.additionalThreeNumber = additionalThreeNumber
        }
        if let additionalTwo = fjIncidentR["additionalTwo"] as? String {
            fjActionsTaken.additionalTwo = additionalTwo
        }
        if let additionalTwoNumber = fjIncidentR["additionalTwoNumber"] as? String {
            fjActionsTaken.additionalTwoNumber = additionalTwoNumber
        }
        if let primaryAction = fjIncidentR["primaryAction"] as? String {
            fjActionsTaken.primaryAction = primaryAction
        }
        if let primaryActionNumber = fjIncidentR["primaryActionNumber"] as? String {
            fjActionsTaken.primaryActionNumber = primaryActionNumber
        }
        fjuIncident.actionsTakenDetails = fjActionsTaken
        
            // TODO: -IncidentTeam, IncidentTags, UserCrew
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjIncidentR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        fjuIncident.fjIncidentCKR = data as NSObject
        
        if theUser != nil {
            theUser.addToFireJournalUserIncDetails(fjuIncident)
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try self.bkgrdContext.save()
            
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.bkgrdContext ,userInfo:["info":"FJIncidentOperation here"])
            }
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                             object: nil,
                             userInfo: ["recordEntity":TheEntities.fjJournal])
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            let nserror = error
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
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
        let attribute = "fjpIncGuidForReference"
        let entity = "Incident"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate])
        fetchRequest.predicate = predicateCan
        do {
            let count = try bkgrdContext.count(for:fetchRequest)
            fjIncidentA = try bkgrdContext.fetch(fetchRequest) as! [Incident]
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
}
