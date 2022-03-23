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
    var fjIncident:Incident!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordGuid:String = ""
    var fju:FireJournalUser?
    
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
            finish(true)
            return
        }
        
    }
    
    func theCounter()->Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Incident" )
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func chooseNewWithGuid(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["fjpIncGuidForReference"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newIncidentFromCloud(record: record)
                }
            }
        }
        completion()
    }
    
    func chooseNewOrUpdate(withCompletion completion: () -> Void ) {
        for record in ckRecordA {
            if let guid:String = record["fjpIncGuidForReference"] {
                recordGuid = guid
                count = theCount(guid: recordGuid)
                if count == 0 {
                    newIncidentFromCloud(record: record)
                } else {
//                    fjIncident.updateIncidentFromCloud(ckRecord: record)
                }
            }
        }
        completion()
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    private func getTheDetailData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        fetchRequest.fetchBatchSize = 1
        
        do {
            let fetched = try bkgrdContext.fetch(fetchRequest) as! [FireJournalUser]
            if fetched.isEmpty {
                print("no user available")
            } else {
                fju = fetched.last
                if let ckr = fju?.fjuCKR {
                guard let archivedData = ckr as? Data else { return  }
                    do {
                        let unarchiver = try NSKeyedUnarchiver.init(forReadingFrom: archivedData)
                        let ckRecord = CKRecord(coder: unarchiver)
                        let fjuRID = ckRecord?.recordID
                        _ = CKRecord.Reference(recordID: fjuRID!, action: .deleteSelf)
                    } catch {
                        print("couldn't unarchive file")
                    }
                }
            }
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    private func newIncidentFromCloud(record: CKRecord)->Void {
        let fjIncidentR = record
        let fjuIncident = Incident.init(entity: NSEntityDescription.entity(forEntityName: "Incident", in: bkgrdContext)!, insertInto: bkgrdContext)
        fjuIncident.formType = fjIncidentR["formType"]
        fjuIncident.fjpIncGuidForReference = fjIncidentR["fjpIncGuidForReference"]
//        fjuIncident.fireJournalUserIncInfo =
        fjuIncident.incidentCreationDate = fjIncidentR["incidentCreationDate"]
        fjuIncident.incidentDate = fjIncidentR["incidentDate"]
        fjuIncident.incidentDateSearch = fjIncidentR["incidentDateSearch"]
        fjuIncident.incidentDayOfWeek = fjIncidentR["incidentDayOfWeek"]
        fjuIncident.incidentDayOfYear = fjIncidentR["incidentDayOfYear"]
        fjuIncident.incidentEntryTypeImageName = fjIncidentR["incidentEntryTypeImageName"]
        
        //        MARK: -LOCATION-
        /// incidentLocaiton archived with secureCoding
        if fjIncidentR["incidentLocation"] != nil {
            let location = fjIncidentR["incidentLocation"] as! CLLocation
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                fjuIncident.incidentLocationSC = data as NSObject
            } catch {
                print("got an error here")
            }
        }
        
        fjuIncident.incidentModDate = fjIncidentR["incidentModDate"] as? Date
        fjuIncident.incidentNFIRSCompleted = fjIncidentR["incidentNFIRSCompleted"]
        fjuIncident.incidentNFIRSCompletedDate = fjIncidentR["incidentNFIRSCompletedDate"] as? Date
        fjuIncident.incidentNFIRSDataComplete = fjIncidentR["incidentNFIRSDataComplete"]
        fjuIncident.incidentNFIRSDataDate = fjIncidentR["incidentNFIRSDataDate"]
        fjuIncident.incidentNFIRSDataSaved = fjIncidentR["incidentNFIRSDataSaved"]
        fjuIncident.incidentNumber = fjIncidentR["incidentNumber"]
        fjuIncident.incidentPhotoTaken = fjIncidentR["incidentPhotoTaken"]
        fjuIncident.incidentSearchDate = fjIncidentR["incidentSearchDate"]
        fjuIncident.incidentStreetHyway = fjIncidentR["incidentStreetHyway"]
        fjuIncident.incidentStreetNumber = fjIncidentR["incidentStreetNumber"]
        fjuIncident.incidentTime = fjIncidentR["incidentTime"]
        fjuIncident.incidentType = fjIncidentR["incidentType"]
        fjuIncident.incidentZipCode = fjIncidentR["incidentZipCode"]
        fjuIncident.incidentZipPlus4 = fjIncidentR["incidentZipPlus4"]
        fjuIncident.situationIncidentImage = fjIncidentR["situationIncidentImage"]
        fjuIncident.tempIncidentApparatus = fjIncidentR["tempIncidentApparatus"]
        fjuIncident.tempIncidentAssignment = fjIncidentR["tempIncidentAssignment"]
        fjuIncident.tempIncidentFireStation = fjIncidentR["tempIncidentFireStation"]
        fjuIncident.tempIncidentPlatoon = fjIncidentR["tempIncidentPlatoon"]
        fjuIncident.arsonInvestigation = fjIncidentR["arsonInvestigation"] as? Bool ?? false
        
        let fjuSections = NFIRSSections.init(entity: NSEntityDescription.entity(forEntityName: "NFIRSSections", in: bkgrdContext)!, insertInto: bkgrdContext)
        fjuSections.sectionA = fjIncidentR["sectionA"] as? Bool ?? false
        fjuSections.sectionB = fjIncidentR["sectionB"] as? Bool ?? false
        fjuSections.sectionC = fjIncidentR["sectionC"] as? Bool ?? false
        fjuSections.sectionD = fjIncidentR["sectionD"] as? Bool ?? false
        fjuSections.sectionE = fjIncidentR["sectionE"] as? Bool ?? false
        fjuSections.sectionF = fjIncidentR["sectionF"] as? Bool ?? false
        fjuSections.sectionG = fjIncidentR["sectionG"] as? Bool ?? false
        fjuSections.sectionH = fjIncidentR["sectionH"] as? Bool ?? false
        fjuSections.sectionI = fjIncidentR["sectionI"] as? Bool ?? false
        fjuSections.sectionJ = fjIncidentR["sectionK"] as? Bool ?? false
        fjuSections.sectionL = fjIncidentR["sectionL"] as? Bool ?? false
        fjuSections.sectionM = fjIncidentR["sectionM"] as? Bool ?? false
        fjuIncident.formDetails = fjuSections
        
        let fjIncidentAddress = IncidentAddress.init(entity: NSEntityDescription.entity(forEntityName: "IncidentAddress", in: bkgrdContext)!, insertInto: bkgrdContext)
        fjIncidentAddress.appSuiteRoom = fjIncidentR["appSuiteRoom"]
        fjIncidentAddress.censusTract = fjIncidentR["censusTract"]
        fjIncidentAddress.censusTract2 = fjIncidentR["censusTract2"]
        fjIncidentAddress.city = fjIncidentR["city"]
        fjIncidentAddress.crossStreet = fjIncidentR["crossStreet"]
        fjIncidentAddress.incidentState = fjIncidentR["incidentState"]
        fjIncidentAddress.prefix = fjIncidentR["prefix"]
        fjIncidentAddress.stagingAddress = fjIncidentR["stagingAddress"]
        fjIncidentAddress.streetHighway = fjIncidentR["streetHighway"]
        fjIncidentAddress.streetNumber = fjIncidentR["streetNumber"]
        fjIncidentAddress.streetType = fjIncidentR["streetType"]
        fjIncidentAddress.suffix = fjIncidentR["suffix"]
        fjIncidentAddress.zip = fjIncidentR["zip"]
        fjIncidentAddress.zipPlus4 = fjIncidentR["zipPlus4"]
        fjuIncident.incidentAddressDetails = fjIncidentAddress
        
        //MARK: -incidentLocal-
        let fjIncidentLocal = IncidentLocal.init(entity: NSEntityDescription.entity(forEntityName: "IncidentLocal", in: bkgrdContext)!, insertInto: bkgrdContext)
        fjIncidentLocal.incidentBattalion = fjIncidentR["incidentBattalion"]
        fjIncidentLocal.incidentDivision = fjIncidentR["incidentDivision"]
        fjIncidentLocal.incidentFireDistrict = fjIncidentR["incidentFireDistrict"]
        fjIncidentLocal.incidentLocalType = fjIncidentR["incidentLocalType"]
        fjuIncident.incidentLocalDetails = fjIncidentLocal
        
        //MARK: -incidentMap-
        let fjIncidentMap = IncidentMap.init(entity: NSEntityDescription.entity(forEntityName: "IncidentMap", in: bkgrdContext)!, insertInto: bkgrdContext)
        fjIncidentMap.incidentLatitude = fjIncidentR["incidentLatitude"]
        fjIncidentMap.incidentLongitude = fjIncidentR["incidentLongitude"]
        fjIncidentMap.stagingLatitude = fjIncidentR["stagingLatitude"]
        fjIncidentMap.stagingLongitude = fjIncidentR["stagingLongitude"]
        fjuIncident.incidentMapDetails = fjIncidentMap
        
        //MARK: -IncidentNFIRS-
        let fjIncidentNFIRS = IncidentNFIRS.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRS", in: bkgrdContext)!, insertInto: bkgrdContext)
        fjIncidentNFIRS.fireStationState = fjIncidentR["fireStationState"]
        fjIncidentNFIRS.incidentActionsTakenAdditionalThree = fjIncidentR["incidentActionsTakenAdditionalThree"]
        fjIncidentNFIRS.incidentActionsTakenAdditionalTwo = fjIncidentR["incidentActionsTakenAdditionalTwo"]
        fjIncidentNFIRS.incidentActionsTakenPrimary = fjIncidentR["incidentActionsTakenPrimary"]
        fjIncidentNFIRS.incidentAidGiven = fjIncidentR["incidentAidGiven"]
        fjIncidentNFIRS.incidentAidGivenFDID = fjIncidentR["incidentAidGivenFDID"]
        fjIncidentNFIRS.incidentAidGivenIncidentNumber = fjIncidentR["incidentAidGivenIncidentNumber"]
        fjIncidentNFIRS.incidentAidGivenNone = fjIncidentR["incidentAidGivenNone"]
        fjIncidentNFIRS.incidentAidGivenState = fjIncidentR["incidentAidGivenState"]
        fjIncidentNFIRS.incidentCasualtiesCivilianDeaths = fjIncidentR["incidentCasualtiesCivilianDeaths"]
        fjIncidentNFIRS.incidentCasualtiesCivilianInjuries = fjIncidentR["incidentCasualtiesCivilianInjuries"]
        fjIncidentNFIRS.incidentCasualtiesFireDeaths = fjIncidentR["incidentCasualtiesFireDeaths"]
        fjIncidentNFIRS.incidentCasualtiesFireInjuries = fjIncidentR["incidentCasualtiesFireInjuries"]
        fjIncidentNFIRS.incidentCasualtiesNone = fjIncidentR["incidentCasualtiesNone"] as? Bool ?? false
            fjIncidentNFIRS.incidentCasualtiesServiceDeaths = fjIncidentR["incidentCasualtiesServiceDeaths"]
            fjIncidentNFIRS.incidentCasualtitesServideInjuries = fjIncidentR["incidentCasualtitesServideInjuries"]
            fjIncidentNFIRS.incidentDetectorChosen = fjIncidentR["incidentDetectorChosen"]
            fjIncidentNFIRS.incidentExposure = fjIncidentR["incidentExposure"]
            fjIncidentNFIRS.incidentFDID = fjIncidentR["incidentFDID"]
            fjIncidentNFIRS.incidentFDID1 = fjIncidentR["incidentFDID1"]
            fjIncidentNFIRS.incidentFireStation = fjIncidentR["incidentFireStation"]
            fjIncidentNFIRS.incidentHazMat = fjIncidentR["incidentHazMat"]
            fjIncidentNFIRS.incidentHazMatNone = fjIncidentR["incidentHazMatNone"] as? Bool ?? false
//        MARK: -STRING-
            fjIncidentNFIRS.incidentLocation = fjIncidentR["incidentNFIRSLocation"]
            fjIncidentNFIRS.incidentPlatoon = fjIncidentR["incidentPlatoon"]
            fjIncidentNFIRS.incidentPropertyNone = fjIncidentR["incidentPropertyNone"]
            fjIncidentNFIRS.incidentPropertyOutside = fjIncidentR["incidentPropertyOutside"]
            fjIncidentNFIRS.incidentPropertyOutsideNumber = fjIncidentR["incidentPropertyOutsideNumber"]
            fjIncidentNFIRS.incidentPropertyStructure = fjIncidentR["incidentPropertyStructure"]
            fjIncidentNFIRS.incidentPropertyStructureNumber = fjIncidentR["incidentPropertyStructureNumber"]
            fjIncidentNFIRS.incidentPropertyUse = fjIncidentR["incidentPropertyUse"]
            fjIncidentNFIRS.incidentPropertyUseNone = fjIncidentR["incidentPropertyUseNone"]
            fjIncidentNFIRS.incidentPropertyUseNumber = fjIncidentR["incidentPropertyUseNumber"]
            fjIncidentNFIRS.incidentResourceCheck = fjIncidentR["incidentResourceCheck"]
            fjIncidentNFIRS.incidentResourcesEMSApparatus = fjIncidentR["incidentResourcesEMSApparatus"]
            fjIncidentNFIRS.incidentResourcesEMSPersonnel = fjIncidentR["incidentResourcesEMSPersonnel"]
            fjIncidentNFIRS.incidentResourcesOtherApparatus = fjIncidentR["incidentResourcesOtherApparatus"]
            fjIncidentNFIRS.incidentResourcesOtherPersonnel = fjIncidentR["incidentResourcesOtherPersonnel"]
            fjIncidentNFIRS.incidentResourcesSuppressionPersonnel = fjIncidentR["incidentResourcesSuppressionPersonnel"]
            fjIncidentNFIRS.incidentResourcesSupressionApparatus = fjIncidentR["incidentResourcesSupressionApparatus"]
            fjIncidentNFIRS.incidentTypeNumberNFRIS = fjIncidentR["incidentTypeNumberNFRIS"]
            fjIncidentNFIRS.incidentTypeTextNFRIS = fjIncidentR["incidentTypeTextNFRIS"]
            fjIncidentNFIRS.lossesContentDollars = fjIncidentR["lossesContentDollars"]
            fjIncidentNFIRS.lossesContentNone = fjIncidentR["lossesContentNone"] as? Bool ?? false
            fjIncidentNFIRS.lossesPropertyDollars = fjIncidentR["lossesPropertyDollars"]
            fjIncidentNFIRS.lossesPropertyNone = fjIncidentR["lossesPropertyNone"] as? Bool ?? false
            fjIncidentNFIRS.mixedUsePropertyNone = fjIncidentR["mixedUsePropertyNone"] as? Bool ?? false
            fjIncidentNFIRS.mixedUsePropertyType = fjIncidentR["mixedUsePropertyType"]
            fjIncidentNFIRS.nfirsChangeDescription = fjIncidentR["nfirsChangeDescription"]
            fjIncidentNFIRS.nfirsSectionOneSegment = fjIncidentR["nfirsSectionOneSegment"]
            fjIncidentNFIRS.propertyUseNone = fjIncidentR["propertyUseNone"] as? Bool ?? false
            fjIncidentNFIRS.resourceCountsIncludeAidReceived = fjIncidentR["resourceCountsIncludeAidReceived"] as? Bool ?? false
            fjIncidentNFIRS.shiftAlarm = fjIncidentR["shiftAlarm"]
            fjIncidentNFIRS.shiftDistrict = fjIncidentR["shiftDistrict"]
            fjIncidentNFIRS.shiftOrPlatoon = fjIncidentR["shiftOrPlatoon"]
            fjIncidentNFIRS.skipSectionF = fjIncidentR["skipSectionF"] as? Bool ?? false
            fjIncidentNFIRS.specialStudyID = fjIncidentR["specialStudyID"]
            fjIncidentNFIRS.specialStudyValue = fjIncidentR["specialStudyValue"]
            fjIncidentNFIRS.valueContentDollars = fjIncidentR["valueContentDollars"]
            fjIncidentNFIRS.valueContentsNone = fjIncidentR["valueContentsNone"] as? Bool ?? false
            fjIncidentNFIRS.valuePropertyDollars = fjIncidentR["valuePropertyDollars"]
            fjIncidentNFIRS.valuePropertyNone = fjIncidentR["valuePropertyNone"] as? Bool ?? false
            fjuIncident.incidentNFIRSDetails = fjIncidentNFIRS
            
            // TODO: -CompletedModules-
            // MARK: -IncidentNFIRSKSec-
            let fjIncidentNFIRSKSec = IncidentNFIRSKSec.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSKSec", in: bkgrdContext)!, insertInto: bkgrdContext)
            fjIncidentNFIRSKSec.kOwnerAptSuiteRoom = fjIncidentR["kOwnerAptSuiteRoom"]
            fjIncidentNFIRSKSec.kOwnerAreaCode = fjIncidentR["kOwnerAreaCode"]
            fjIncidentNFIRSKSec.kOwnerBusinessName = fjIncidentR["kOwnerBusinessName"]
            fjIncidentNFIRSKSec.kOwnerCheckBox = fjIncidentR["kOwnerCheckBox"] as? Bool ?? false
            fjIncidentNFIRSKSec.kOwnerCity = fjIncidentR["kOwnerCity"]
            fjIncidentNFIRSKSec.kOwnerFirstName = fjIncidentR["kOwnerFirstName"]
            fjIncidentNFIRSKSec.kOwnerLastName = fjIncidentR["kOwnerLastName"]
            fjIncidentNFIRSKSec.kOwnerMI = fjIncidentR["kOwnerMI"]
            fjIncidentNFIRSKSec.kOwnerNamePrefix = fjIncidentR["kOwnerNamePrefix"]
            fjIncidentNFIRSKSec.kOwnerNameSuffix = fjIncidentR["kOwnerNameSuffix"]
            fjIncidentNFIRSKSec.kOwnerPhoneLastFour = fjIncidentR["kOwnerPhoneLastFour"]
            fjIncidentNFIRSKSec.kOwnerPhonePrefix = fjIncidentR["kOwnerPhonePrefix"]
            fjIncidentNFIRSKSec.kOwnerPOBox = fjIncidentR["kOwnerPOBox"]
            fjIncidentNFIRSKSec.kOwnerSameAsPerson = fjIncidentR["kOwnerSameAsPerson"] as? Bool ?? false
            fjIncidentNFIRSKSec.kOwnerState = fjIncidentR["kOwnerState"]
            fjIncidentNFIRSKSec.kOwnerStreetHyway = fjIncidentR["kOwnerStreetHyway"]
            fjIncidentNFIRSKSec.kOwnerStreetNumber = fjIncidentR["kOwnerStreetNumber"]
            fjIncidentNFIRSKSec.kOwnerStreetPrefix = fjIncidentR["kOwnerStreetPrefix"]
            fjIncidentNFIRSKSec.kOwnerStreetSuffix = fjIncidentR["kOwnerStreetSuffix"]
            fjIncidentNFIRSKSec.kOwnerStreetType = fjIncidentR["kOwnerStreetType"]
            fjIncidentNFIRSKSec.kOwnerZip = fjIncidentR["kOwnerZip"]
            fjIncidentNFIRSKSec.kOwnerZipPlusFour = fjIncidentR["kOwnerZipPlusFour"]
            fjIncidentNFIRSKSec.kPersonAppSuiteRoom = fjIncidentR["kPersonAppSuiteRoom"]
            fjIncidentNFIRSKSec.kPersonAreaCode = fjIncidentR["kPersonAreaCode"]
            fjIncidentNFIRSKSec.kPersonBusinessName = fjIncidentR["kPersonBusinessName"]
            fjIncidentNFIRSKSec.kPersonCheckBox = fjIncidentR["kPersonCheckBox"] as? Bool ?? false
            fjIncidentNFIRSKSec.kPersonCity = fjIncidentR["kPersonCity"]
            fjIncidentNFIRSKSec.kPersonFirstName = fjIncidentR["kPersonFirstName"]
            fjIncidentNFIRSKSec.kPersonGender = fjIncidentR["kPersonGender"]
            fjIncidentNFIRSKSec.kPersonLastName = fjIncidentR["kPersonLastName"]
            fjIncidentNFIRSKSec.kPersonMI = fjIncidentR["kPersonMI"]
            fjIncidentNFIRSKSec.kPersonMoreThanOne = fjIncidentR["kPersonMoreThanOne"] as? Bool ?? false
            fjIncidentNFIRSKSec.kPersonNameSuffix = fjIncidentR["kPersonNameSuffix"]
            fjIncidentNFIRSKSec.kPersonPhoneLastFour = fjIncidentR["kPersonPhoneLastFour"]
            fjIncidentNFIRSKSec.kPersonPhonePrefix = fjIncidentR["kPersonPhonePrefix"]
            fjIncidentNFIRSKSec.kPersonPOBox = fjIncidentR["kPersonPOBox"]
            fjIncidentNFIRSKSec.kPersonPrefix = fjIncidentR["kPersonPrefix"]
            fjIncidentNFIRSKSec.kPersonState = fjIncidentR["kPersonState"]
            fjIncidentNFIRSKSec.kPersonStreetHyway = fjIncidentR["kPersonStreetHyway"]
            fjIncidentNFIRSKSec.kPersonStreetNum = fjIncidentR["kPersonStreetNum"]
            fjIncidentNFIRSKSec.kPersonStreetSuffix = fjIncidentR["kPersonStreetSuffix"]
            fjIncidentNFIRSKSec.kPersonStreetType = fjIncidentR["kPersonStreetType"]
            fjIncidentNFIRSKSec.kPersonZipCode = fjIncidentR["kPersonZipCode"]
            fjIncidentNFIRSKSec.kPersonZipPlus4 = fjIncidentR["kPersonZipPlus4"]
            fjuIncident.incidentNFIRSKSecDetails = fjIncidentNFIRSKSec
            
            // TODO: -REQUIREDMODULES
            // MARK: -IncidentNFIRSsecL-
            let fjIncidentNFIRSsecL = IncidentNFIRSsecL.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSsecL", in: bkgrdContext)!, insertInto: bkgrdContext)
            fjIncidentNFIRSsecL.lRemarks = fjIncidentR["incidentNFIRSSecLNotes"] as? NSObject
            fjIncidentNFIRSsecL.moreRemarks = fjIncidentR["incidentNFIRSSecLMoreRemarks"] as? Bool ?? false
            fjuIncident.sectionLDetails = fjIncidentNFIRSsecL
            
            // MARK: -IncidentNFIRSsecM-
            let fjIncidentNFIRSsecM = IncidentNFIRSsecM.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNFIRSsecM", in: bkgrdContext)!, insertInto: bkgrdContext)
            fjIncidentNFIRSsecM.memberAssignment = fjIncidentR["memberAssignment"]
            fjIncidentNFIRSsecM.memberDate = fjIncidentR["memberDate"]
            fjIncidentNFIRSsecM.memberMakingReportID = fjIncidentR["memberMakingReportID"]
            fjIncidentNFIRSsecM.memberRankPosition = fjIncidentR["memberRankPosition"]
            fjIncidentNFIRSsecM.memberSameAsOfficer = fjIncidentR["memberSameAsOfficer"] as? Bool ?? false
            fjIncidentNFIRSsecM.officerAssignment = fjIncidentR["officerAssignment"]
            fjIncidentNFIRSsecM.officerDate = fjIncidentR["officerDate"]
            fjIncidentNFIRSsecM.officerInChargeID = fjIncidentR["officerInChargeID"]
            fjIncidentNFIRSsecM.officerRankPosition = fjIncidentR["officerRankPosition"]
            fjIncidentNFIRSsecM.signatureMember = fjIncidentR["signatureMember"]
            fjIncidentNFIRSsecM.signatureOfficer = fjIncidentR["signatureOfficer"]
            fjIncidentNFIRSsecM.memberSigned = fjIncidentR["memberSigned"] as? Bool ?? false
            fjIncidentNFIRSsecM.officeSigned = fjIncidentR["officerSigned"] as? Bool ?? false
            // TODO: -SIGNATURE CONVERSION-
            
            fjuIncident.sectionMDetails = fjIncidentNFIRSsecM
            
            // MARK: -IncidentNotes-
            let fjIncidentNotes = IncidentNotes.init(entity: NSEntityDescription.entity(forEntityName: "IncidentNotes", in: bkgrdContext)!, insertInto: bkgrdContext)
            fjIncidentNotes.incidentSummaryNotes = fjIncidentR["incidentSummaryNotes"] as? NSObject
            fjIncidentNotes.incidentNote = fjIncidentR["incidentNote"]
            fjuIncident.incidentNotesDetails = fjIncidentNotes
            
            // TODO: -IncidentResources-
            // MARK: -IncidentTimer-
            let fjIncidentTimer = IncidentTimer.init(entity: NSEntityDescription.entity(forEntityName: "IncidentTimer", in: bkgrdContext)!, insertInto: bkgrdContext)
            fjIncidentTimer.arrivalSameDate = fjIncidentR["arrivalSameDate"] as? Bool ?? false
            fjIncidentTimer.controlledSameDate = fjIncidentR["controlledSameDate"] as? Bool ?? false
            fjIncidentTimer.incidentAlarmCombinedDate = fjIncidentR["incidentAlarmCombinedDate"]
            fjIncidentTimer.incidentAlarmDateTime = fjIncidentR["incidentAlarmDateTime"]
            fjIncidentTimer.incidentAlarmDay = fjIncidentR["incidentAlarmDay"]
            fjIncidentTimer.incidentAlarmHours = fjIncidentR["incidentAlarmHours"]
            fjIncidentTimer.incidentAlarmMinutes = fjIncidentR["incidentAlarmMinutes"]
            fjIncidentTimer.incidentAlarmMonth = fjIncidentR["incidentAlarmMonth"]
            fjIncidentTimer.incidentAlarmNotes = fjIncidentR["incidentAlarmNotes"] as? NSObject
            fjIncidentTimer.incidentAlarmYear = fjIncidentR["incidentAlarmYear"]
            fjIncidentTimer.incidentArrivalCombinedDate = fjIncidentR["incidentArrivalCombinedDate"]
            fjIncidentTimer.incidentArrivalDateTime = fjIncidentR["incidentArrivalDateTime"]
            fjIncidentTimer.incidentArrivalDay = fjIncidentR["incidentArrivalDay"]
            fjIncidentTimer.incidentArrivalHours = fjIncidentR["incidentArrivalHours"]
            fjIncidentTimer.incidentArrivalMinutes = fjIncidentR["incidentArrivalMinutes"]
            fjIncidentTimer.incidentArrivalMonth = fjIncidentR["incidentArrivalMonth"]
            fjIncidentTimer.incidentArrivalNotes = fjIncidentR["incidentArrivalNotes"] as? NSObject
            fjIncidentTimer.incidentArrivalYear = fjIncidentR["incidentArrivalYear"]
            fjIncidentTimer.incidentControlledCombinedDate = fjIncidentR["incidentControlledCombinedDate"]
            fjIncidentTimer.incidentControlDateTime =  fjIncidentR["incidentControlDateTime"]
            fjIncidentTimer.incidentControlledDay = fjIncidentR["incidentControlledDay"]
            fjIncidentTimer.incidentControlledHours = fjIncidentR["incidentControlledHours"]
            fjIncidentTimer.incidentControlledMinutes = fjIncidentR["incidentControlledMinutes"]
            fjIncidentTimer.incidentControlledMonth = fjIncidentR["incidentControlledMonth"]
        fjIncidentTimer.incidentControlledNotes = fjIncidentR["incidentControlledNotes"] as? NSObject
            fjIncidentTimer.incidentControlledYear = fjIncidentR["incidentControlledYear"]
            fjIncidentTimer.incidentElapsedTime = fjIncidentR["incidentElapsedTime"]
            fjIncidentTimer.incidentLastUnitCalledCombinedDate = fjIncidentR["incidentLastUnitCalledCombinedDate"]
            fjIncidentTimer.incidentLastUnitDateTime = fjIncidentR["incidentLastUnitDateTime"]
            fjIncidentTimer.incidentLastUnitCalledDay = fjIncidentR["incidentLastUnitCalledDay"]
            fjIncidentTimer.incidentLastUnitCalledHours = fjIncidentR["incidentLastUnitCalledHours"]
            fjIncidentTimer.incidentLastUnitCalledMinutes = fjIncidentR["incidentLastUnitCalledMinutes"]
            fjIncidentTimer.incidentLastUnitCalledMonth = fjIncidentR["incidentLastUnitCalledMonth"]
            fjIncidentTimer.incidentLastUnitCalledYear = fjIncidentR["incidentLastUnitCalledYear"]
        fjIncidentTimer.incidentLastUnitClearedNotes = fjIncidentR["incidentLastUnitClearedNotes"] as? NSObject
            fjIncidentTimer.incidentStartClockCombinedDate = fjIncidentR["incidentStartClockCombinedDate"]
        fjIncidentTimer.incidentStartClockDateTime = fjIncidentR["incidentStartClockDateTime"]
            fjIncidentTimer.incidentStartClockDay = fjIncidentR["incidentStartClockDay"]
            fjIncidentTimer.incidentStartClockHours = fjIncidentR["incidentStartClockHours"]
            fjIncidentTimer.incidentStartClockMinutes = fjIncidentR["incidentStartClockMinutes"]
            fjIncidentTimer.incidentStartClockMonth = fjIncidentR["incidentStartClockMonth"]
            fjIncidentTimer.incidentStartClockSeconds = fjIncidentR["incidentStartClockSeconds"]
            fjIncidentTimer.incidentStartClockYear = fjIncidentR["incidentStartClockYear"]
            fjIncidentTimer.incidentStopClockCombinedDate = fjIncidentR["incidentStopClockCombinedDate"]
        fjIncidentTimer.incidentStopClockDateTime = fjIncidentR["incidentStopClockDateTime"]
            fjIncidentTimer.incidentStopClockDay = fjIncidentR["incidentStopClockDay"]
            fjIncidentTimer.incidentStopClockHours = fjIncidentR["incidentStopClockHours"]
            fjIncidentTimer.incidentStopClockMinutes = fjIncidentR["incidentStopClockMinutes"]
            fjIncidentTimer.incidentStopClockMonth = fjIncidentR["incidentStopClockMonth"]
            fjIncidentTimer.incidentStopClockSeconds = fjIncidentR["incidentStopClockSeconds"]
            fjIncidentTimer.incidentStopClockYear = fjIncidentR["incidentStopClockYear"]
            fjIncidentTimer.lastUnitSameDate = fjIncidentR["lastUnitSameDate"] as? Bool ?? false
            fjuIncident.incidentTimerDetails = fjIncidentTimer
            
            // MARK: -ActionsTaken-
            let fjActionsTaken = ActionsTaken.init(entity: NSEntityDescription.entity(forEntityName: "ActionsTaken", in: bkgrdContext)!, insertInto: bkgrdContext)
            fjActionsTaken.additionalThree = fjIncidentR["additionalThree"]
            fjActionsTaken.additionalThreeNumber = fjIncidentR["additionalThreeNumber"]
            fjActionsTaken.additionalTwo = fjIncidentR["additionalTwo"]
            fjActionsTaken.additionalTwoNumber = fjIncidentR["additionalTwoNumber"]
            fjActionsTaken.primaryAction = fjIncidentR["primaryAction"]
            fjActionsTaken.primaryActionNumber = fjIncidentR["primaryActionNumber"]
            fjuIncident.actionsTakenDetails = fjActionsTaken
                
                // TODO: -IncidentTeam, IncidentTags, UserCrew
            let coder = NSKeyedArchiver(requiringSecureCoding: true)
            fjIncidentR.encodeSystemFields(with: coder)
            let data = coder.encodedData
            fjuIncident.fjIncidentCKR = data as NSObject
       }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"FJIncidentOperation here"])
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
            let count = try context.count(for:fetchRequest)
            fjIncidentA = try context.fetch(fetchRequest) as! [Incident]
            fjIncident = fjIncidentA.last
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
}
