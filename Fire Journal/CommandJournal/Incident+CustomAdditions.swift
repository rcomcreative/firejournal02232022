//
//  Incident+CustomAdditions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/7/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreLocation

extension Int {
    init(_ bool:Bool) {
        self = bool ? 1 : 0
    }
}

extension Incident {
    
    func newIncidentForCloud()->CKRecord {
//        let journal = self.incidentInfo
//        let user = self.fireJournalUserIncInfo
//        let journalReference:CKRecord.Reference = journal?.aJournalReference as! CKRecord.Reference
//        let userReference:CKRecord.Reference = user?.aFJUReference as! CKRecord.Reference
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "YYYYDDDMMHHmmAAAAAAAA"
//        let dateFormatted = dateFormatter.string(from: self.incidentModDate ?? Date())
//        let inNum = self.incidentNumber ?? ""
//        let name = "Incident #\(inNum) \(dateFormatted)"
        var recordName: String = ""
        if let name = self.fjpIncGuidForReference {
            recordName = name
        } else {
            let iGuidDate = GuidFormatter.init(date:self.incidentCreationDate!)
            let iGuid:String = iGuidDate.formatGuid()
            self.fjpIncGuidForReference = "02."+iGuid
            recordName = "02."+iGuid
        }
        
        let incidentRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjIncidentRID = CKRecord.ID(recordName: recordName, zoneID: incidentRZ.zoneID)
        let fjIncidentR = CKRecord.init(recordType: "Incident", recordID: fjIncidentRID)
        let incidentRef = CKRecord.Reference(recordID: fjIncidentRID, action: .deleteSelf)
        
//        new record
        fjIncidentR["incidentBackedUp"] =  true
        fjIncidentR["theEntity"] = "Incident"
        fjIncidentR["fjpIncGuidForReference"] = self.fjpIncGuidForReference
        fjIncidentR["fjpIncidentDateSearch"] = self.fjpIncidentDateSearch
        fjIncidentR["fjpIncidentModifiedDate"] = self.fjpIncidentModifiedDate
//        fjIncidentR["fjpJournalReference"] = journalReference
//        fjIncidentR["fjpUserReference"] = userReference
        fjIncidentR["formType"] = self.formType
        fjIncidentR["incidentCreationDate"] = self.incidentCreationDate
        fjIncidentR["incidentDate"] = self.incidentDate
        fjIncidentR["incidentDateSearch"] = self.incidentDateSearch
        fjIncidentR["incidentDayOfWeek"] = self.incidentDayOfWeek
        fjIncidentR["incidentDayOfYear"] = self.incidentDayOfYear
        if self.locationAvailable {
            fjIncidentR["locationAvailable"] = 1
        } else {
                fjIncidentR["locationAvailable"] = 0
        }
        if self.incidentTagsAvailable {
            fjIncidentR["incidentTagsAvailable"] = 1
        } else {
                fjIncidentR["incidentTagsAvailable"] = 0
        }
        if self.incidentPhotoTaken != nil {
            if self.incidentPhotoTaken == 1 {
                fjIncidentR["incidentPhotoTaken"] = true
            } else {
                fjIncidentR["incidentPhotoTaken"] = false
            }
        }
        fjIncidentR["incidentEntryTypeImageName"] = self.incidentEntryTypeImageName
        if let location = self.incidentLocation {
            fjIncidentR["incidentLocation"] = location as! CLLocation
        }
        var location:CLLocation!
        if self.incidentLocationSC != nil {
                if let theLocation = self.incidentLocationSC {
                    guard let  archivedData = theLocation as? Data else { return fjIncidentR }
                    do {
                        guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return fjIncidentR }
                        location = unarchivedLocation
                        fjIncidentR["incidentLocation"] = location!
                    } catch {
                        print("error line 72 Incident+CustomAdditions")
                    }
                }
        }
        fjIncidentR["incidentModDate"] = self.incidentModDate
        fjIncidentR["incidentNFIRSCompleted"] = self.incidentNFIRSCompleted
        fjIncidentR["incidentNFIRSCompletedDate"] = self.incidentNFIRSCompletedDate
        fjIncidentR["incidentNFIRSDataComplete"] = self.incidentNFIRSDataComplete
        fjIncidentR["incidentNFIRSDataDate"] = self.incidentNFIRSDataDate
        fjIncidentR["incidentNFIRSDataSaved"] = self.incidentNFIRSDataSaved
        fjIncidentR["incidentNumber"] = self.incidentNumber
        
        fjIncidentR["incidentSearchDate"] = self.incidentSearchDate
        fjIncidentR["incidentStreetHyway"] = self.incidentStreetHyway
        fjIncidentR["incidentStreetNumber"] = self.incidentStreetNumber
        fjIncidentR["incidentTime"] = self.incidentTime
        fjIncidentR["incidentType"] = self.incidentType
        fjIncidentR["incidentZipCode"] = self.incidentZipCode
        fjIncidentR["incidentZipPlus4"] = self.incidentZipPlus4
        fjIncidentR["situationIncidentImage"] = self.situationIncidentImage
        fjIncidentR["tempIncidentApparatus"] = self.tempIncidentApparatus
        fjIncidentR["tempIncidentAssignment"] = self.tempIncidentAssignment
        fjIncidentR["tempIncidentFireStation"] = self.tempIncidentFireStation
        fjIncidentR["tempIncidentPlatoon"] = self.tempIncidentPlatoon
        fjIncidentR["ics214Effort"] = self.ics214Effort
        fjIncidentR["ics214MasterGuid"] = self.ics214MasterGuid
        fjIncidentR["arsonInvestigation"] = Int(self.arsonInvestigation)
        
        let fjuSections = self.formDetails
        fjIncidentR["sectionA"] = Int(fjuSections?.sectionA ?? false)
        fjIncidentR["sectionB"] = Int(fjuSections?.sectionB ?? false)
        fjIncidentR["sectionC"] = Int(fjuSections?.sectionC ?? false)
        fjIncidentR["sectionD"] = Int(fjuSections?.sectionD ?? false)
        fjIncidentR["sectionE"] = Int(fjuSections?.sectionE ?? false)
        fjIncidentR["sectionF"] = Int(fjuSections?.sectionF ?? false)
        fjIncidentR["sectionG"] = Int(fjuSections?.sectionG ?? false)
        fjIncidentR["sectionH"] = Int(fjuSections?.sectionH ?? false)
        fjIncidentR["sectionI"] = Int(fjuSections?.sectionI ?? false)
        fjIncidentR["sectionJ"] = Int(fjuSections?.sectionJ ?? false)
        fjIncidentR["sectionK"] = Int(fjuSections?.sectionK ?? false)
        fjIncidentR["sectionL"] = Int(fjuSections?.sectionL ?? false)
        fjIncidentR["sectionM"] = Int(fjuSections?.sectionM ?? false)
        
        let fjIncidentAddress = self.incidentAddressDetails
        fjIncidentR["appSuiteRoom"] = fjIncidentAddress?.appSuiteRoom
        fjIncidentR["censusTract"] = fjIncidentAddress?.censusTract
        fjIncidentR["censusTract2"] = fjIncidentAddress?.censusTract2
        fjIncidentR["city"] = fjIncidentAddress?.city
        fjIncidentR["crossStreet"] = fjIncidentAddress?.crossStreet
        fjIncidentR["incidentState"] = fjIncidentAddress?.incidentState
        fjIncidentR["prefix"] = fjIncidentAddress?.prefix
        fjIncidentR["stagingAddress"] = fjIncidentAddress?.stagingAddress
        fjIncidentR["streetHighway"] = fjIncidentAddress?.streetHighway
        fjIncidentR["streetNumber"] = fjIncidentAddress?.streetNumber
        fjIncidentR["streetType"] = fjIncidentAddress?.streetType
        fjIncidentR["suffix"] = fjIncidentAddress?.suffix
        fjIncidentR["zip"] = fjIncidentAddress?.zip
        fjIncidentR["zipPlus4"] = fjIncidentAddress?.zipPlus4
        var num = ""
        var street = ""
        var zip = ""
        if let number = fjIncidentAddress?.streetNumber {
            num = number
        }
        if let st = fjIncidentAddress?.streetHighway {
            street = st
        }
        if let zipped = fjIncidentAddress?.zip {
            zip = zipped
        }
        fjIncidentR["aadressForIncident"] = "\(num) \(street) \(zip)"
        
        //MARK: -incidentLocal-
        let fjIncidentLocal = self.incidentLocalDetails
        fjIncidentR["incidentBattalion"] = fjIncidentLocal?.incidentBattalion
        fjIncidentR["incidentDivision"] = fjIncidentLocal?.incidentDivision
        fjIncidentR["incidentFireDistrict"] = fjIncidentLocal?.incidentFireDistrict
        fjIncidentR["incidentLocalType"] = fjIncidentLocal?.incidentLocalType
        
        //MARK: -IncidentMap-
        let fjIncidentMap = self.incidentMapDetails
        fjIncidentR["incidentLatitude"] = fjIncidentMap?.incidentLatitude
        fjIncidentR["incidentLongitude"] = fjIncidentMap?.incidentLongitude
        fjIncidentR["stagingLatitude"] = fjIncidentMap?.stagingLatitude
        fjIncidentR["stagingLongitude"] = fjIncidentMap?.stagingLongitude
        
        // MARK: -IncidentNFIRS-
        let fjIncidentNFIRS = self.incidentNFIRSDetails
        fjIncidentR["fireStationState"] = fjIncidentNFIRS?.fireStationState
        fjIncidentR["incidentActionsTakenAdditionalThree"] = fjIncidentNFIRS?.incidentActionsTakenAdditionalThree
        fjIncidentR["incidentActionsTakenAdditionalTwo"] = fjIncidentNFIRS?.incidentActionsTakenAdditionalTwo
        fjIncidentR["incidentActionsTakenPrimary"] = fjIncidentNFIRS?.incidentActionsTakenPrimary
        fjIncidentR["incidentAidGiven"] = fjIncidentNFIRS?.incidentAidGiven
        fjIncidentR["incidentAidGivenFDID"] = fjIncidentNFIRS?.incidentAidGivenFDID
        fjIncidentR["incidentAidGivenIncidentNumber"] = fjIncidentNFIRS?.incidentAidGivenIncidentNumber
        fjIncidentR["incidentAidGivenNone"] = fjIncidentNFIRS?.incidentAidGivenNone
        fjIncidentR["incidentAidGivenState"] = fjIncidentNFIRS?.incidentAidGivenState
        fjIncidentR["incidentCasualtiesCivilianDeaths"] = fjIncidentNFIRS?.incidentCasualtiesCivilianDeaths
        fjIncidentR["incidentCasualtiesCivilianInjuries"] = fjIncidentNFIRS?.incidentCasualtiesCivilianInjuries
        fjIncidentR["incidentCasualtiesFireDeaths"] = fjIncidentNFIRS?.incidentCasualtiesFireDeaths
        fjIncidentR["incidentCasualtiesFireInjuries"] = fjIncidentNFIRS?.incidentCasualtiesFireInjuries
        fjIncidentR["incidentCasualtiesNone"] = Int(fjIncidentNFIRS?.incidentCasualtiesNone ?? false)
        fjIncidentR["incidentCasualtiesServiceDeaths"] = fjIncidentNFIRS?.incidentCasualtiesServiceDeaths
        fjIncidentR["incidentCasualtitesServideInjuries"] = fjIncidentNFIRS?.incidentCasualtitesServideInjuries
        fjIncidentR["incidentDetectorChosen"] = fjIncidentNFIRS?.incidentDetectorChosen
        fjIncidentR["incidentExposure"] = fjIncidentNFIRS?.incidentExposure
        fjIncidentR["incidentFDID"] = fjIncidentNFIRS?.incidentFDID
        fjIncidentR["incidentFDID1"] = fjIncidentNFIRS?.incidentFDID1
        fjIncidentR["incidentFireStation"] = fjIncidentNFIRS?.incidentFireStation
        fjIncidentR["incidentHazMat"] = fjIncidentNFIRS?.incidentHazMat
        fjIncidentR["incidentHazMatNone"] = Int(fjIncidentNFIRS?.incidentHazMatNone ?? false)
        fjIncidentR["incidentNFIRSLocation"] = fjIncidentNFIRS?.incidentLocation
        fjIncidentR["incidentPlatoon"] = fjIncidentNFIRS?.incidentPlatoon
        fjIncidentR["incidentPropertyNone"] = fjIncidentNFIRS?.incidentPropertyNone
        fjIncidentR["incidentPropertyOutside"] = fjIncidentNFIRS?.incidentPropertyOutside
        fjIncidentR["incidentPropertyOutsideNumber"] = fjIncidentNFIRS?.incidentPropertyOutsideNumber
        fjIncidentR["incidentPropertyStructure"] = fjIncidentNFIRS?.incidentPropertyStructure
        fjIncidentR["incidentPropertyStructureNumber"] = fjIncidentNFIRS?.incidentPropertyStructureNumber
        fjIncidentR["incidentPropertyUse"] = fjIncidentNFIRS?.incidentPropertyUse
        fjIncidentR["incidentPropertyUseNone"] = fjIncidentNFIRS?.incidentPropertyUseNone
        fjIncidentR["incidentPropertyUseNumber"] = fjIncidentNFIRS?.incidentPropertyUseNumber
        fjIncidentR["incidentResourceCheck"] = fjIncidentNFIRS?.incidentResourceCheck
        fjIncidentR["incidentResourcesEMSApparatus"] = fjIncidentNFIRS?.incidentResourcesEMSApparatus
        fjIncidentR["incidentResourcesEMSPersonnel"] = fjIncidentNFIRS?.incidentResourcesEMSPersonnel
        fjIncidentR["incidentResourcesOtherApparatus"] = fjIncidentNFIRS?.incidentResourcesOtherApparatus
        fjIncidentR["incidentResourcesOtherPersonnel"] = fjIncidentNFIRS?.incidentResourcesOtherPersonnel
        fjIncidentR["incidentResourcesSuppressionPersonnel"] = fjIncidentNFIRS?.incidentResourcesSuppressionPersonnel
        fjIncidentR["incidentResourcesSupressionApparatus"] = fjIncidentNFIRS?.incidentResourcesSupressionApparatus
        fjIncidentR["incidentTypeNumberNFRIS"] = fjIncidentNFIRS?.incidentTypeNumberNFRIS
        fjIncidentR["incidentTypeTextNFRIS"] = fjIncidentNFIRS?.incidentTypeTextNFRIS
        fjIncidentR["lossesContentDollars"] = fjIncidentNFIRS?.lossesContentDollars
        fjIncidentR["lossesContentNone"] = Int(fjIncidentNFIRS?.lossesContentNone ?? false)
        fjIncidentR["lossesPropertyDollars"] = fjIncidentNFIRS?.lossesPropertyDollars
        fjIncidentR["lossesPropertyNone"] = Int(fjIncidentNFIRS?.lossesPropertyNone ?? false)
        fjIncidentR["mixedUsePropertyNone"] = Int(fjIncidentNFIRS?.mixedUsePropertyNone ?? false)
        fjIncidentR["mixedUsePropertyType"] = fjIncidentNFIRS?.mixedUsePropertyType
        fjIncidentR["nfirsChangeDescription"] = fjIncidentNFIRS?.nfirsChangeDescription
        fjIncidentR["nfirsSectionOneSegment"] = fjIncidentNFIRS?.nfirsSectionOneSegment
        fjIncidentR["propertyUseNone"] = Int(fjIncidentNFIRS?.propertyUseNone ?? false)
        fjIncidentR["resourceCountsIncludeAidReceived"] = Int(fjIncidentNFIRS?.resourceCountsIncludeAidReceived ?? false)
        fjIncidentR["shiftAlarm"] = fjIncidentNFIRS?.shiftAlarm
        fjIncidentR["shiftDistrict"] = fjIncidentNFIRS?.shiftDistrict
        fjIncidentR["shiftOrPlatoon"] = fjIncidentNFIRS?.shiftOrPlatoon
        fjIncidentR["skipSectionF"] = Int(fjIncidentNFIRS?.skipSectionF ?? false)
        fjIncidentR["specialStudyID"] = fjIncidentNFIRS?.specialStudyID
        fjIncidentR["specialStudyValue"] = fjIncidentNFIRS?.specialStudyValue
        fjIncidentR["valueContentDollars"] = fjIncidentNFIRS?.valueContentDollars
        fjIncidentR["valueContentsNone"] = Int(fjIncidentNFIRS?.valueContentsNone ?? false)
        fjIncidentR["valuePropertyDollars"] = fjIncidentNFIRS?.valuePropertyDollars
        fjIncidentR["valuePropertyNone"] = Int(fjIncidentNFIRS?.valuePropertyNone ?? false)
        
        // TODO: IncidentNFIRSCompMods
        // let fjIncidentNFIRSCompMods = self.completedModulesDetails
        //     NSMutableArray *_compModules = [[NSMutableArray alloc] init]
        //     for(fjIncidentNFIRSCompMods in self.completedModulesDetails){
        //         [_compModules addObject:fjIncidentNFIRSCompMods.completedModules]
        //     }
        //     _nfirsCompleteMods = [_compModules copy]
        //     NSString *compMods = @""
        //     NSString *truncatedCMString = @""
        //     if(!([_nfirsCompleteMods count] == 0)) {
        //         for(NSString *t in _nfirsCompleteMods){
        //             if(![t isEqualToString:@""]){
        //                 compMods = [compMods stringByAppendingString:[NSString stringWithFormat:@"%@,",t]]
        //             }
        //             if([compMods length]>2){
        //                 truncatedCMString = [compMods substringToIndex:[compMods length]-2]
        //             }
        //         }
        //     }
        //     fjIncidentR["incidentCompletedModules"] = truncatedCMString
        
        // MARK: -IncidentNFIRSKSec-
        let fjIncidentNFIRSKSec = self.incidentNFIRSKSecDetails
        fjIncidentR["kOwnerAptSuiteRoom"] = fjIncidentNFIRSKSec?.kOwnerAptSuiteRoom
        fjIncidentR["kOwnerAreaCode"] = fjIncidentNFIRSKSec?.kOwnerAreaCode
        fjIncidentR["kOwnerBusinessName"] = fjIncidentNFIRSKSec?.kOwnerBusinessName
        fjIncidentR["kOwnerCheckBox"] = Int(fjIncidentNFIRSKSec?.kOwnerCheckBox ?? false)
        fjIncidentR["kOwnerCity"] = fjIncidentNFIRSKSec?.kOwnerCity
        fjIncidentR["kOwnerFirstName"] = fjIncidentNFIRSKSec?.kOwnerFirstName
        fjIncidentR["kOwnerLastName"] = fjIncidentNFIRSKSec?.kOwnerLastName
        fjIncidentR["kOwnerMI"] = fjIncidentNFIRSKSec?.kOwnerMI
        fjIncidentR["kOwnerNamePrefix"] = fjIncidentNFIRSKSec?.kOwnerNamePrefix
        fjIncidentR["kOwnerNameSuffix"] = fjIncidentNFIRSKSec?.kOwnerNameSuffix
        fjIncidentR["kOwnerPhoneLastFour"] = fjIncidentNFIRSKSec?.kOwnerPhoneLastFour
        fjIncidentR["kOwnerPhonePrefix"] = fjIncidentNFIRSKSec?.kOwnerPhonePrefix
        fjIncidentR["kOwnerPOBox"] = fjIncidentNFIRSKSec?.kOwnerPOBox
        fjIncidentR["kOwnerSameAsPerson"] = Int(fjIncidentNFIRSKSec?.kOwnerSameAsPerson ?? false)
        fjIncidentR["kOwnerState"] = fjIncidentNFIRSKSec?.kOwnerState
        fjIncidentR["kOwnerStreetHyway"] = fjIncidentNFIRSKSec?.kOwnerStreetHyway
        fjIncidentR["kOwnerStreetNumber"] = fjIncidentNFIRSKSec?.kOwnerStreetNumber
        fjIncidentR["kOwnerStreetPrefix"] = fjIncidentNFIRSKSec?.kOwnerStreetPrefix
        fjIncidentR["kOwnerStreetSuffix"] = fjIncidentNFIRSKSec?.kOwnerStreetSuffix
        fjIncidentR["kOwnerStreetType"] = fjIncidentNFIRSKSec?.kOwnerStreetType
        fjIncidentR["kOwnerZip"] = fjIncidentNFIRSKSec?.kOwnerZip
        fjIncidentR["kOwnerZipPlusFour"] = fjIncidentNFIRSKSec?.kOwnerZipPlusFour
        fjIncidentR["kPersonAppSuiteRoom"] = fjIncidentNFIRSKSec?.kPersonAppSuiteRoom
        fjIncidentR["kPersonAreaCode"] = fjIncidentNFIRSKSec?.kPersonAreaCode
        fjIncidentR["kPersonBusinessName"] = fjIncidentNFIRSKSec?.kPersonBusinessName
        fjIncidentR["kPersonCheckBox"] = Int(fjIncidentNFIRSKSec?.kPersonCheckBox ?? false)
        fjIncidentR["kPersonCity"] = fjIncidentNFIRSKSec?.kPersonCity
        fjIncidentR["kPersonFirstName"] = fjIncidentNFIRSKSec?.kPersonFirstName
        fjIncidentR["kPersonGender"] = fjIncidentNFIRSKSec?.kPersonGender
        fjIncidentR["kPersonLastName"] = fjIncidentNFIRSKSec?.kPersonLastName
        fjIncidentR["kPersonMI"] = fjIncidentNFIRSKSec?.kPersonMI
        fjIncidentR["kPersonMoreThanOne"] = Int(fjIncidentNFIRSKSec?.kPersonMoreThanOne ?? false)
        fjIncidentR["kPersonNameSuffix"] = fjIncidentNFIRSKSec?.kPersonNameSuffix
        fjIncidentR["kPersonPhoneLastFour"] = fjIncidentNFIRSKSec?.kPersonPhoneLastFour
        fjIncidentR["kPersonPhonePrefix"] = fjIncidentNFIRSKSec?.kPersonPhonePrefix
        fjIncidentR["kPersonPOBox"] = fjIncidentNFIRSKSec?.kPersonPOBox
        fjIncidentR["kPersonPrefix"] = fjIncidentNFIRSKSec?.kPersonPrefix
        fjIncidentR["kPersonState"] = fjIncidentNFIRSKSec?.kPersonState
        fjIncidentR["kPersonStreetHyway"] = fjIncidentNFIRSKSec?.kPersonStreetHyway
        fjIncidentR["kPersonStreetNum"] = fjIncidentNFIRSKSec?.kPersonStreetNum
        fjIncidentR["kPersonStreetSuffix"] = fjIncidentNFIRSKSec?.kPersonStreetSuffix
        fjIncidentR["kPersonStreetType"] = fjIncidentNFIRSKSec?.kPersonStreetType
        fjIncidentR["kPersonZipCode"] = fjIncidentNFIRSKSec?.kPersonZipCode
        fjIncidentR["kPersonZipPlus4"] = fjIncidentNFIRSKSec?.kPersonZipPlus4
        
        // TODO: -IncidentNFIRSRequiredModules-
        // IncidentNFIRSRequiredModules *_requiredModules = (IncidentNFIRSRequiredModules *)self.requiredModulesDetails
        //     NSMutableArray *_nfirsRMods = [[NSMutableArray alloc] init]
        //     for(_requiredModules in self.completedModulesDetails){
        //         [_nfirsRMods addObject:_requiredModules.requiredModule]
        //     }
        //     _nfirsRequiredMods = [_nfirsRMods copy]
        //     NSString *reqMods = @""
        //     NSString *truncatedRMString = @""
        //     if(!([_nfirsRequiredMods count] == 0)) {
        //         for(NSString *t in _nfirsRequiredMods){
        //             if(![t isEqualToString:@""]){
        //                 reqMods = [reqMods stringByAppendingString:[NSString stringWithFormat:@"%@,",t]]
        //             }
        //             if([reqMods length]>0){
        //                 truncatedRMString = [reqMods substringToIndex:[reqMods length]-2]
        //             }
        //         }
        //     }
        //     fjIncidentR["incidentRequiredModules"] = truncatedRMString
        
        let fjIncidentNFIRSsecL = self.sectionLDetails
        fjIncidentR["incidentNFIRSSecLNotes"] = fjIncidentNFIRSsecL?.lRemarks as? String
        fjIncidentR["incidentNFIRSSecLMoreRemarks"] = Int(fjIncidentNFIRSsecL?.moreRemarks ?? false)
        
        let fjIncidentNFIRSsecM = self.sectionMDetails
        fjIncidentR["memberAssignment"] = fjIncidentNFIRSsecM?.memberAssignment
        fjIncidentR["memberDate"] = fjIncidentNFIRSsecM?.memberDate
        fjIncidentR["memberMakingReportID"] = fjIncidentNFIRSsecM?.memberMakingReportID
        fjIncidentR["memberRankPosition"] = fjIncidentNFIRSsecM?.memberRankPosition
        fjIncidentR["memberSameAsOfficer"] = Int(fjIncidentNFIRSsecM?.memberSameAsOfficer ?? false)
        fjIncidentR["officerAssignment"] = fjIncidentNFIRSsecM?.officerAssignment
        fjIncidentR["officerDate"] = fjIncidentNFIRSsecM?.officerDate
        fjIncidentR["officerInChargeID"] = fjIncidentNFIRSsecM?.officerInChargeID
        fjIncidentR["officerRankPosition"] = fjIncidentNFIRSsecM?.officerRankPosition
        fjIncidentR["signatureMember"] = fjIncidentNFIRSsecM?.signatureMember
        fjIncidentR["signatureOfficer"] = fjIncidentNFIRSsecM?.signatureOfficer
        // TODO: -OFFICER AND MEMBER SIGNATURE ASSETS
        //    TRANSFORM officerSignature
        // if(fjIncidentNFIRSsecM?.officeSigned) {
        //         fjIncidentR["officerSigned"] = @1
        //         NSData *oSignatureData = nil
        //         oSignatureData = fjIncidentNFIRSsecM?.officerSignature
        //         NSMutableDictionary *oPhotoDictionary = [[NSMutableDictionary alloc] init]
        //         NSString *oPhotoName = @""
        //         NSString *opath = @""
        //         @synchronized (self) {
        //             if(!(oSignatureData == nil)){
        //                 NSDateFormatter *dayOfWeekNumberFormat = [[NSDateFormatter alloc] init]
        //                 [dayOfWeekNumberFormat setDateFormat:@"YYYYDDDHHmmAAAAAAAA"]
        //                 NSString *_displayDayOfTheYear = [dayOfWeekNumberFormat stringFromDate:[NSDate date]]
        //                 UIImage *_signatureImage = [UIImage imageWithData:oSignatureData]
        //                 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
        //                                                                      NSUserDomainMask, YES)
        //                 NSString *documentsDirectory = [paths objectAtIndex:0]
        //                 oPhotoName = @"OfficerSignature"
        //                 opath = [documentsDirectory stringByAppendingPathComponent:
        //                          [NSString stringWithFormat:@"%@_%@.jpg",oPhotoName,_displayDayOfTheYear]]
        //                 if([UIImageJPEGRepresentation(_signatureImage, 1.0) writeToFile:opath atomically:YES]){
        //                     [oPhotoDictionary setObject:oPhotoName forKey:opath]
        //                     NSURL *fileNSUrl = [NSURL fileURLWithPath:opath]
        //                     CKAsset *imageAsset = [[CKAsset alloc] initWithFileURL:fileNSUrl]
        //
        //                     fjIncidentR["officerSignature"] = imageAsset
        //                 }
        //             }
        //         }
        //     } else {
        //         fjIncidentR["officerSigned"] = @0
        //     }
        // //  TRANSFORM memberSignature
        //     if(fjIncidentNFIRSsecM?.memberSigned) {
        //         fjIncidentR["memberSigned"] = @1
        //         NSData *mSignatureData = nil
        //         mSignatureData = fjIncidentNFIRSsecM?.memberSignature
        //         NSMutableDictionary *mPhotoDictionary = [[NSMutableDictionary alloc] init]
        //         NSString *mPhotoName = @""
        //         NSString *mpath = @""
        //         @synchronized (self) {
        //             if(!(mSignatureData == nil)){
        //                 NSDateFormatter *dayOfWeekNumberFormat = [[NSDateFormatter alloc] init]
        //                 [dayOfWeekNumberFormat setDateFormat:@"YYYYDDDHHmmAAAAAAAA"]
        //                 NSString *_displayDayOfTheYear = [dayOfWeekNumberFormat stringFromDate:[NSDate date]]
        //                 UIImage *_signatureImage = [UIImage imageWithData:mSignatureData]
        //                 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
        //                                                                      NSUserDomainMask, YES)
        //                 NSString *documentsDirectory = [paths objectAtIndex:0]
        //                 mPhotoName = @"MemberSignature"
        //                 mpath = [documentsDirectory stringByAppendingPathComponent:
        //                          [NSString stringWithFormat:@"%@_%@.jpg",mPhotoName,_displayDayOfTheYear]]
        //                 if([UIImageJPEGRepresentation(_signatureImage, 1.0) writeToFile:mpath atomically:YES]){
        //                     [mPhotoDictionary setObject:mPhotoName forKey:mpath]
        //                     NSURL *fileNSUrl = [NSURL fileURLWithPath:mpath]
        //                     CKAsset *imageAsset = [[CKAsset alloc] initWithFileURL:fileNSUrl]
        //
        //                     fjIncidentR["memberSignature"] = imageAsset
        //                 }
        //             }
        //         }
        //     } else {
        //         fjIncidentR["memberSigned"] = @0
        //     }
        
        // MARK: -IncidentNotes-
        let fjIncidentNotes = self.incidentNotesDetails
        fjIncidentR["incidentSummaryNotes"] = fjIncidentNotes?.incidentSummaryNotes as? String
        fjIncidentR["incidentNote"] = fjIncidentNotes?.incidentNote
        
        //        MARK: -POV NOTES FOR INCIDENT
        fjIncidentR["fjpPersonalJournalReference"] = self.fjpPersonalJournalReference
        
        //        MARK: -UserFDResources chosen for Incident
        var resourcesName = [String]()
        var customOrNot = [Bool]()
        var resourceType = [Int64]()
        for resources in self.incidentResourceDetails as! Set<IncidentResources> {
            resourcesName.append(resources.incidentResource ?? "")
            customOrNot.append(resources.resourceCustom)
            resourceType.append(resources.resourceType)
        }
        
        fjIncidentR["incidentResources"] = resourcesName
        fjIncidentR["incidentResourcesCustom"] = customOrNot
        fjIncidentR["incidentResourcesType"] = resourceType
        
        
        //        MARK: -IncidentTimer-
        let fjIncidentTimer = self.incidentTimerDetails
        fjIncidentR["arrivalSameDate"] = Int(fjIncidentTimer?.arrivalSameDate ?? false)
        fjIncidentR["controlledSameDate"] = Int(fjIncidentTimer?.controlledSameDate ?? false)
        fjIncidentR["incidentAlarmCombinedDate"] = fjIncidentTimer?.incidentAlarmCombinedDate
        fjIncidentR["incidentAlarmDateTime"] = fjIncidentTimer?.incidentAlarmDateTime
        fjIncidentR["incidentAlarmDay"] = fjIncidentTimer?.incidentAlarmDay
        fjIncidentR["incidentAlarmHours"] = fjIncidentTimer?.incidentAlarmHours
        fjIncidentR["incidentAlarmMinutes"] = fjIncidentTimer?.incidentAlarmMinutes
        fjIncidentR["incidentAlarmMonth"] = fjIncidentTimer?.incidentAlarmMonth
        fjIncidentR["incidentAlarmNotes"] = fjIncidentTimer?.incidentAlarmNotes as? String
        fjIncidentR["incidentAlarmYear"] = fjIncidentTimer?.incidentAlarmYear
        fjIncidentR["incidentArrivalCombinedDate"] = fjIncidentTimer?.incidentArrivalCombinedDate
        fjIncidentR["incidentArrivalDateTime"] = fjIncidentTimer?.incidentArrivalDateTime
        fjIncidentR["incidentArrivalDay"] = fjIncidentTimer?.incidentArrivalDay
        fjIncidentR["incidentArrivalHours"] = fjIncidentTimer?.incidentArrivalHours
        fjIncidentR["incidentArrivalMinutes"] = fjIncidentTimer?.incidentArrivalMinutes
        fjIncidentR["incidentArrivalMonth"] = fjIncidentTimer?.incidentArrivalMonth
        fjIncidentR["incidentArrivalNotes"] = fjIncidentTimer?.incidentArrivalNotes as? String
        fjIncidentR["incidentArrivalYear"] = fjIncidentTimer?.incidentArrivalYear
        fjIncidentR["incidentControlledCombinedDate"] = fjIncidentTimer?.incidentControlledCombinedDate
        fjIncidentR["incidentControlDateTime"] = fjIncidentTimer?.incidentControlDateTime
        fjIncidentR["incidentControlledDay"] = fjIncidentTimer?.incidentControlledDay
        fjIncidentR["incidentControlledHours"] = fjIncidentTimer?.incidentControlledHours
        fjIncidentR["incidentControlledMinutes"] = fjIncidentTimer?.incidentControlledMinutes
        fjIncidentR["incidentControlledMonth"] = fjIncidentTimer?.incidentControlledMonth
        fjIncidentR["incidentControlledNotes"] = fjIncidentTimer?.incidentControlledNotes as? String
        fjIncidentR["incidentControlledYear"] = fjIncidentTimer?.incidentControlledYear
        fjIncidentR["incidentElapsedTime"] = fjIncidentTimer?.incidentElapsedTime
        fjIncidentR["incidentLastUnitCalledCombinedDate"] = fjIncidentTimer?.incidentLastUnitCalledCombinedDate
        fjIncidentR["incidentLastUnitDateTime"] = fjIncidentTimer?.incidentLastUnitDateTime
        fjIncidentR["incidentLastUnitCalledDay"] = fjIncidentTimer?.incidentLastUnitCalledDay
        fjIncidentR["incidentLastUnitCalledHours"] = fjIncidentTimer?.incidentLastUnitCalledHours
        fjIncidentR["incidentLastUnitCalledMinutes"] = fjIncidentTimer?.incidentLastUnitCalledMinutes
        fjIncidentR["incidentLastUnitCalledMonth"] = fjIncidentTimer?.incidentLastUnitCalledMonth
        fjIncidentR["incidentLastUnitCalledYear"] = fjIncidentTimer?.incidentLastUnitCalledYear
        fjIncidentR["incidentLastUnitClearedNotes"] = fjIncidentTimer?.incidentLastUnitClearedNotes as? String
        fjIncidentR["incidentStartClockCombinedDate"] = fjIncidentTimer?.incidentStartClockCombinedDate
        fjIncidentR["incidentStartClockDateTime"] = fjIncidentTimer?.incidentStartClockDateTime
        fjIncidentR["incidentStartClockDay"] = fjIncidentTimer?.incidentStartClockDay
        fjIncidentR["incidentStartClockHours"] = fjIncidentTimer?.incidentStartClockHours
        fjIncidentR["incidentStartClockMinutes"] = fjIncidentTimer?.incidentStartClockMinutes
        fjIncidentR["incidentStartClockMonth"] = fjIncidentTimer?.incidentStartClockMonth
        fjIncidentR["incidentStartClockSeconds"] = fjIncidentTimer?.incidentStartClockSeconds
        fjIncidentR["incidentStartClockYear"] = fjIncidentTimer?.incidentStartClockYear
        fjIncidentR["incidentStopClockCombinedDate"] = fjIncidentTimer?.incidentStopClockCombinedDate
        fjIncidentR["incidentStopCloudDateTime"] = fjIncidentTimer?.incidentStopClockDateTime
        fjIncidentR["incidentStopClockDay"] = fjIncidentTimer?.incidentStopClockDay
        fjIncidentR["incidentStopClockHours"] = fjIncidentTimer?.incidentStopClockHours
        fjIncidentR["incidentStopClockMinutes"] = fjIncidentTimer?.incidentStopClockMinutes
        fjIncidentR["incidentStopClockMonth"] = fjIncidentTimer?.incidentStopClockMonth
        fjIncidentR["incidentStopClockSeconds"] = fjIncidentTimer?.incidentStopClockSeconds
        fjIncidentR["incidentStopClockYear"] = fjIncidentTimer?.incidentStopClockYear
        fjIncidentR["lastUnitSameDate"] = Int(fjIncidentTimer?.lastUnitSameDate ?? false)
        
        //        MARK: -ActionsTaken-
            let fjActionsTaken = self.actionsTakenDetails
        fjIncidentR["additionalThree"] = fjActionsTaken?.additionalThree
        fjIncidentR["additionalThreeNumber"] = fjActionsTaken?.additionalThreeNumber
        fjIncidentR["additionalTwo"] = fjActionsTaken?.additionalTwo
        fjIncidentR["additionalTwoNumber"] = fjActionsTaken?.additionalTwoNumber
        fjIncidentR["primaryAction"] = fjActionsTaken?.primaryAction
        fjIncidentR["primaryActionNumber"] = fjActionsTaken?.primaryActionNumber
            
            // TODO: -IncidentTags, IncidentTeams, Crews
            // IncidentTeam *_incidentTeam = (IncidentTeam *)self.teamMemberDetails
            //     NSMutableArray *team = [[NSMutableArray alloc] init]
            //     for(_incidentTeam in self.teamMemberDetails){
            //         [team addObject:_incidentTeam.teamMember]
            //     }
            //     _teamArray = [team copy]
            //     NSString *teaming = @""
            //     NSString *truncatedTString = @""
            //     if (!([_teamArray count] == 0)) {
            //         for(NSString *t in _teamArray){
            //             if(![t isEqualToString:@""])
            //                 teaming = [teaming stringByAppendingString:[NSString stringWithFormat:@"%@, ",t]]
            //         }
            //         if([teaming length]>2){
            //             truncatedTString = [teaming substringToIndex:[teaming length]-2]
            //         }
            //     }
            //     fjIncidentR["teamMembers"] = truncatedTString
            //
            //     IncidentTags *_incidentTags = (IncidentTags *)self.incidentTagDetails
            //     NSMutableArray *tag = [[NSMutableArray alloc] init]
            //     for(_incidentTags in self.incidentTagDetails){
            //         [tag addObject:_incidentTags.incidentTag]
            //     }
            //     _tagsArray = [tag copy]
            //     NSString *tagging = @""
            //     NSString *truncatedTagString = @""
            //     if (!([_tagsArray count] == 0)) {
            //         for(NSString *t in _tagsArray){
            //             if(![t isEqualToString:@""])
            //                 tagging = [tagging stringByAppendingString:[NSString stringWithFormat:@"%@, ",t]]
            //         }
            //         if([tagging length]>2){
            //             truncatedTagString = [tagging substringToIndex:[tagging length]-2]
            //         }
            //     }
            //     fjIncidentR["incidentTags"] = truncatedTagString
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: incidentRef, requiringSecureCoding: true)
                self.anIncidentReferenceSC = data as NSObject
                
            } catch {
                print("incidentRef to data failed line 514 Incident+Custom")
            }
        
            saveToCD()
//        end record
        return fjIncidentR
        
    }
    
    func updateIncidentFromCloud(ckRecord: CKRecord) {
        let fjIncidentR = ckRecord
        self.formType = fjIncidentR["formType"]
        self.fjpIncGuidForReference = fjIncidentR["fjpIncGuidForReference"]
        self.incidentCreationDate = fjIncidentR["incidentCreationDate"]
        self.incidentDate = fjIncidentR["incidentDate"]
        self.incidentDateSearch = fjIncidentR["incidentDateSearch"]
        self.incidentDayOfWeek = fjIncidentR["incidentDayOfWeek"]
        self.incidentDayOfYear = fjIncidentR["incidentDayOfYear"]
        self.incidentEntryTypeImageName = fjIncidentR["incidentEntryTypeImageName"]
        
        //        MARK: -LOCATION-
        /// incidentLocation archived with secureCoding
        if fjIncidentR["incidentLocation"] != nil {
            let location = fjIncidentR["incidentLocation"] as! CLLocation
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                self.incidentLocationSC = data as NSObject
            } catch {
                print("got an error here")
            }
        }
        
        self.incidentModDate = fjIncidentR["incidentModDate"] as? Date
        self.incidentNFIRSCompleted = fjIncidentR["incidentNFIRSCompleted"] as? NSNumber ?? 0
        self.incidentNFIRSCompletedDate = fjIncidentR["incidentNFIRSCompletedDate"] as? Date
        self.incidentNFIRSDataComplete = fjIncidentR["incidentNFIRSDataComplete"] as? NSNumber ?? 0
        self.incidentNFIRSDataDate = fjIncidentR["incidentNFIRSDataDate"]
        self.incidentNFIRSDataSaved = fjIncidentR["incidentNFIRSDataSaved"]
        self.incidentNumber = fjIncidentR["incidentNumber"]
        self.incidentPhotoTaken = fjIncidentR["incidentPhotoTaken"] as? NSNumber ?? 0
        self.incidentSearchDate = fjIncidentR["incidentSearchDate"]
        self.incidentStreetHyway = fjIncidentR["incidentStreetHyway"]
        self.incidentStreetNumber = fjIncidentR["incidentStreetNumber"]
        self.incidentTime = fjIncidentR["incidentTime"]
        self.incidentType = fjIncidentR["incidentType"]
        self.incidentZipCode = fjIncidentR["incidentZipCode"]
        self.incidentZipPlus4 = fjIncidentR["incidentZipPlus4"]
        self.situationIncidentImage = fjIncidentR["situationIncidentImage"]
        self.tempIncidentApparatus = fjIncidentR["tempIncidentApparatus"]
        self.tempIncidentAssignment = fjIncidentR["tempIncidentAssignment"]
        self.tempIncidentFireStation = fjIncidentR["tempIncidentFireStation"]
        self.tempIncidentPlatoon = fjIncidentR["tempIncidentPlatoon"]
        self.arsonInvestigation = fjIncidentR["arsonInvestigation"] as? Bool ?? false
        
        let fjuSections = self.formDetails
        fjuSections?.sectionA = fjIncidentR["sectionA"] as? Bool ?? false
        fjuSections?.sectionB = fjIncidentR["sectionB"] as? Bool ?? false
        fjuSections?.sectionC = fjIncidentR["sectionC"] as? Bool ?? false
        fjuSections?.sectionD = fjIncidentR["sectionD"] as? Bool ?? false
        fjuSections?.sectionE = fjIncidentR["sectionE"] as? Bool ?? false
        fjuSections?.sectionF = fjIncidentR["sectionF"] as? Bool ?? false
        fjuSections?.sectionG = fjIncidentR["sectionG"] as? Bool ?? false
        fjuSections?.sectionH = fjIncidentR["sectionH"] as? Bool ?? false
        fjuSections?.sectionI = fjIncidentR["sectionI"] as? Bool ?? false
        fjuSections?.sectionJ = fjIncidentR["sectionK"] as? Bool ?? false
        fjuSections?.sectionL = fjIncidentR["sectionL"] as? Bool ?? false
        fjuSections?.sectionM = fjIncidentR["sectionM"] as? Bool ?? false
        self.formDetails = fjuSections
        
        let fjIncidentAddress = self.incidentAddressDetails
        fjIncidentAddress?.appSuiteRoom = fjIncidentR["appSuiteRoom"]
        fjIncidentAddress?.censusTract = fjIncidentR["censusTract"]
        fjIncidentAddress?.censusTract2 = fjIncidentR["censusTract2"]
        fjIncidentAddress?.city = fjIncidentR["city"]
        fjIncidentAddress?.crossStreet = fjIncidentR["crossStreet"]
        fjIncidentAddress?.incidentState = fjIncidentR["incidentState"]
        fjIncidentAddress?.prefix = fjIncidentR["prefix"]
        fjIncidentAddress?.stagingAddress = fjIncidentR["stagingAddress"]
        fjIncidentAddress?.streetHighway = fjIncidentR["streetHighway"]
        fjIncidentAddress?.streetNumber = fjIncidentR["streetNumber"]
        fjIncidentAddress?.streetType = fjIncidentR["streetType"]
        fjIncidentAddress?.suffix = fjIncidentR["suffix"]
        fjIncidentAddress?.zip = fjIncidentR["zip"]
        fjIncidentAddress?.zipPlus4 = fjIncidentR["zipPlus4"]
        self.incidentAddressDetails = fjIncidentAddress
        
        //MARK: -incidentLocal-
        let fjIncidentLocal = self.incidentLocalDetails
        fjIncidentLocal?.incidentBattalion = fjIncidentR["incidentBattalion"]
        fjIncidentLocal?.incidentDivision = fjIncidentR["incidentDivision"]
        fjIncidentLocal?.incidentFireDistrict = fjIncidentR["incidentFireDistrict"]
        fjIncidentLocal?.incidentLocalType = fjIncidentR["incidentLocalType"]
        self.incidentLocalDetails = fjIncidentLocal
        
        //MARK: -incidentMap-
        let fjIncidentMap = self.incidentMapDetails
        fjIncidentMap?.incidentLatitude = fjIncidentR["incidentLatitude"]
        fjIncidentMap?.incidentLongitude = fjIncidentR["incidentLongitude"]
        fjIncidentMap?.stagingLatitude = fjIncidentR["stagingLatitude"]
        fjIncidentMap?.stagingLongitude = fjIncidentR["stagingLongitude"]
        self.incidentMapDetails = fjIncidentMap
        
        //MARK: -IncidentNFIRS-
        let fjIncidentNFIRS = self.incidentNFIRSDetails
        fjIncidentNFIRS?.fireStationState = fjIncidentR["fireStationState"]
        fjIncidentNFIRS?.incidentActionsTakenAdditionalThree = fjIncidentR["incidentActionsTakenAdditionalThree"]
        fjIncidentNFIRS?.incidentActionsTakenAdditionalTwo = fjIncidentR["incidentActionsTakenAdditionalTwo"]
        fjIncidentNFIRS?.incidentActionsTakenPrimary = fjIncidentR["incidentActionsTakenPrimary"]
        fjIncidentNFIRS?.incidentAidGiven = fjIncidentR["incidentAidGiven"]
        fjIncidentNFIRS?.incidentAidGivenFDID = fjIncidentR["incidentAidGivenFDID"]
        fjIncidentNFIRS?.incidentAidGivenIncidentNumber = fjIncidentR["incidentAidGivenIncidentNumber"]
        fjIncidentNFIRS?.incidentAidGivenNone = fjIncidentR["incidentAidGivenNone"]
        fjIncidentNFIRS?.incidentAidGivenState = fjIncidentR["incidentAidGivenState"]
        fjIncidentNFIRS?.incidentCasualtiesCivilianDeaths = fjIncidentR["incidentCasualtiesCivilianDeaths"]
        fjIncidentNFIRS?.incidentCasualtiesCivilianInjuries = fjIncidentR["incidentCasualtiesCivilianInjuries"]
        fjIncidentNFIRS?.incidentCasualtiesFireDeaths = fjIncidentR["incidentCasualtiesFireDeaths"]
        fjIncidentNFIRS?.incidentCasualtiesFireInjuries = fjIncidentR["incidentCasualtiesFireInjuries"]
        fjIncidentNFIRS?.incidentCasualtiesNone = fjIncidentR["incidentCasualtiesNone"] as? Bool ?? false
        fjIncidentNFIRS?.incidentCasualtiesServiceDeaths = fjIncidentR["incidentCasualtiesServiceDeaths"]
        fjIncidentNFIRS?.incidentCasualtitesServideInjuries = fjIncidentR["incidentCasualtitesServideInjuries"]
        fjIncidentNFIRS?.incidentDetectorChosen = fjIncidentR["incidentDetectorChosen"]
        fjIncidentNFIRS?.incidentExposure = fjIncidentR["incidentExposure"]
        fjIncidentNFIRS?.incidentFDID = fjIncidentR["incidentFDID"]
        fjIncidentNFIRS?.incidentFDID1 = fjIncidentR["incidentFDID1"]
        fjIncidentNFIRS?.incidentFireStation = fjIncidentR["incidentFireStation"]
        fjIncidentNFIRS?.incidentHazMat = fjIncidentR["incidentHazMat"]
        fjIncidentNFIRS?.incidentHazMatNone = fjIncidentR["incidentHazMatNone"] as? Bool ?? false
//        MARK: -STRING-
        fjIncidentNFIRS?.incidentLocation = fjIncidentR["incidentNFIRSLocation"]
        fjIncidentNFIRS?.incidentPlatoon = fjIncidentR["incidentPlatoon"]
        fjIncidentNFIRS?.incidentPropertyNone = fjIncidentR["incidentPropertyNone"]
        fjIncidentNFIRS?.incidentPropertyOutside = fjIncidentR["incidentPropertyOutside"]
        fjIncidentNFIRS?.incidentPropertyOutsideNumber = fjIncidentR["incidentPropertyOutsideNumber"]
        fjIncidentNFIRS?.incidentPropertyStructure = fjIncidentR["incidentPropertyStructure"]
        fjIncidentNFIRS?.incidentPropertyStructureNumber = fjIncidentR["incidentPropertyStructureNumber"]
        fjIncidentNFIRS?.incidentPropertyUse = fjIncidentR["incidentPropertyUse"]
        fjIncidentNFIRS?.incidentPropertyUseNone = fjIncidentR["incidentPropertyUseNone"]
        fjIncidentNFIRS?.incidentPropertyUseNumber = fjIncidentR["incidentPropertyUseNumber"]
        fjIncidentNFIRS?.incidentResourceCheck = fjIncidentR["incidentResourceCheck"]
        fjIncidentNFIRS?.incidentResourcesEMSApparatus = fjIncidentR["incidentResourcesEMSApparatus"]
        fjIncidentNFIRS?.incidentResourcesEMSPersonnel = fjIncidentR["incidentResourcesEMSPersonnel"]
        fjIncidentNFIRS?.incidentResourcesOtherApparatus = fjIncidentR["incidentResourcesOtherApparatus"]
        fjIncidentNFIRS?.incidentResourcesOtherPersonnel = fjIncidentR["incidentResourcesOtherPersonnel"]
        fjIncidentNFIRS?.incidentResourcesSuppressionPersonnel = fjIncidentR["incidentResourcesSuppressionPersonnel"]
        fjIncidentNFIRS?.incidentResourcesSupressionApparatus = fjIncidentR["incidentResourcesSupressionApparatus"]
        fjIncidentNFIRS?.incidentTypeNumberNFRIS = fjIncidentR["incidentTypeNumberNFRIS"]
        fjIncidentNFIRS?.incidentTypeTextNFRIS = fjIncidentR["incidentTypeTextNFRIS"]
        fjIncidentNFIRS?.lossesContentDollars = fjIncidentR["lossesContentDollars"]
        fjIncidentNFIRS?.lossesContentNone = fjIncidentR["lossesContentNone"] as? Bool ?? false
        fjIncidentNFIRS?.lossesPropertyDollars = fjIncidentR["lossesPropertyDollars"]
        fjIncidentNFIRS?.lossesPropertyNone = fjIncidentR["lossesPropertyNone"] as? Bool ?? false
        fjIncidentNFIRS?.mixedUsePropertyNone = fjIncidentR["mixedUsePropertyNone"] as? Bool ?? false
        fjIncidentNFIRS?.mixedUsePropertyType = fjIncidentR["mixedUsePropertyType"]
        fjIncidentNFIRS?.nfirsChangeDescription = fjIncidentR["nfirsChangeDescription"]
        fjIncidentNFIRS?.nfirsSectionOneSegment = fjIncidentR["nfirsSectionOneSegment"]
        fjIncidentNFIRS?.propertyUseNone = fjIncidentR["propertyUseNone"] as? Bool ?? false
        fjIncidentNFIRS?.resourceCountsIncludeAidReceived = fjIncidentR["resourceCountsIncludeAidReceived"] as? Bool ?? false
        fjIncidentNFIRS?.shiftAlarm = fjIncidentR["shiftAlarm"]
        fjIncidentNFIRS?.shiftDistrict = fjIncidentR["shiftDistrict"]
        fjIncidentNFIRS?.shiftOrPlatoon = fjIncidentR["shiftOrPlatoon"]
        fjIncidentNFIRS?.skipSectionF = fjIncidentR["skipSectionF"] as? Bool ?? false
        fjIncidentNFIRS?.specialStudyID = fjIncidentR["specialStudyID"]
        fjIncidentNFIRS?.specialStudyValue = fjIncidentR["specialStudyValue"]
        fjIncidentNFIRS?.valueContentDollars = fjIncidentR["valueContentDollars"]
        fjIncidentNFIRS?.valueContentsNone = fjIncidentR["valueContentsNone"] as? Bool ?? false
        fjIncidentNFIRS?.valuePropertyDollars = fjIncidentR["valuePropertyDollars"]
        fjIncidentNFIRS?.valuePropertyNone = fjIncidentR["valuePropertyNone"] as? Bool ?? false
        self.incidentNFIRSDetails = fjIncidentNFIRS
        
        // TODO: -CompletedModules-
        // MARK: -IncidentNFIRSKSec-
        let fjIncidentNFIRSKSec = self.incidentNFIRSKSecDetails
        fjIncidentNFIRSKSec?.kOwnerAptSuiteRoom = fjIncidentR["kOwnerAptSuiteRoom"]
        fjIncidentNFIRSKSec?.kOwnerAreaCode = fjIncidentR["kOwnerAreaCode"]
        fjIncidentNFIRSKSec?.kOwnerBusinessName = fjIncidentR["kOwnerBusinessName"]
        fjIncidentNFIRSKSec?.kOwnerCheckBox = fjIncidentR["kOwnerCheckBox"] as? Bool ?? false
        fjIncidentNFIRSKSec?.kOwnerCity = fjIncidentR["kOwnerCity"]
        fjIncidentNFIRSKSec?.kOwnerFirstName = fjIncidentR["kOwnerFirstName"]
        fjIncidentNFIRSKSec?.kOwnerLastName = fjIncidentR["kOwnerLastName"]
        fjIncidentNFIRSKSec?.kOwnerMI = fjIncidentR["kOwnerMI"]
        fjIncidentNFIRSKSec?.kOwnerNamePrefix = fjIncidentR["kOwnerNamePrefix"]
        fjIncidentNFIRSKSec?.kOwnerNameSuffix = fjIncidentR["kOwnerNameSuffix"]
        fjIncidentNFIRSKSec?.kOwnerPhoneLastFour = fjIncidentR["kOwnerPhoneLastFour"]
        fjIncidentNFIRSKSec?.kOwnerPhonePrefix = fjIncidentR["kOwnerPhonePrefix"]
        fjIncidentNFIRSKSec?.kOwnerPOBox = fjIncidentR["kOwnerPOBox"]
        fjIncidentNFIRSKSec?.kOwnerSameAsPerson = fjIncidentR["kOwnerSameAsPerson"] as? Bool ?? false
        fjIncidentNFIRSKSec?.kOwnerState = fjIncidentR["kOwnerState"]
        fjIncidentNFIRSKSec?.kOwnerStreetHyway = fjIncidentR["kOwnerStreetHyway"]
        fjIncidentNFIRSKSec?.kOwnerStreetNumber = fjIncidentR["kOwnerStreetNumber"]
        fjIncidentNFIRSKSec?.kOwnerStreetPrefix = fjIncidentR["kOwnerStreetPrefix"]
        fjIncidentNFIRSKSec?.kOwnerStreetSuffix = fjIncidentR["kOwnerStreetSuffix"]
        fjIncidentNFIRSKSec?.kOwnerStreetType = fjIncidentR["kOwnerStreetType"]
        fjIncidentNFIRSKSec?.kOwnerZip = fjIncidentR["kOwnerZip"]
        fjIncidentNFIRSKSec?.kOwnerZipPlusFour = fjIncidentR["kOwnerZipPlusFour"]
        fjIncidentNFIRSKSec?.kPersonAppSuiteRoom = fjIncidentR["kPersonAppSuiteRoom"]
        fjIncidentNFIRSKSec?.kPersonAreaCode = fjIncidentR["kPersonAreaCode"]
        fjIncidentNFIRSKSec?.kPersonBusinessName = fjIncidentR["kPersonBusinessName"]
        fjIncidentNFIRSKSec?.kPersonCheckBox = fjIncidentR["kPersonCheckBox"] as? Bool ?? false
        fjIncidentNFIRSKSec?.kPersonCity = fjIncidentR["kPersonCity"]
        fjIncidentNFIRSKSec?.kPersonFirstName = fjIncidentR["kPersonFirstName"]
        fjIncidentNFIRSKSec?.kPersonGender = fjIncidentR["kPersonGender"]
        fjIncidentNFIRSKSec?.kPersonLastName = fjIncidentR["kPersonLastName"]
        fjIncidentNFIRSKSec?.kPersonMI = fjIncidentR["kPersonMI"]
        fjIncidentNFIRSKSec?.kPersonMoreThanOne = fjIncidentR["kPersonMoreThanOne"] as? Bool ?? false
        fjIncidentNFIRSKSec?.kPersonNameSuffix = fjIncidentR["kPersonNameSuffix"]
        fjIncidentNFIRSKSec?.kPersonPhoneLastFour = fjIncidentR["kPersonPhoneLastFour"]
        fjIncidentNFIRSKSec?.kPersonPhonePrefix = fjIncidentR["kPersonPhonePrefix"]
        fjIncidentNFIRSKSec?.kPersonPOBox = fjIncidentR["kPersonPOBox"]
        fjIncidentNFIRSKSec?.kPersonPrefix = fjIncidentR["kPersonPrefix"]
        fjIncidentNFIRSKSec?.kPersonState = fjIncidentR["kPersonState"]
        fjIncidentNFIRSKSec?.kPersonStreetHyway = fjIncidentR["kPersonStreetHyway"]
        fjIncidentNFIRSKSec?.kPersonStreetNum = fjIncidentR["kPersonStreetNum"]
        fjIncidentNFIRSKSec?.kPersonStreetSuffix = fjIncidentR["kPersonStreetSuffix"]
        fjIncidentNFIRSKSec?.kPersonStreetType = fjIncidentR["kPersonStreetType"]
        fjIncidentNFIRSKSec?.kPersonZipCode = fjIncidentR["kPersonZipCode"]
        fjIncidentNFIRSKSec?.kPersonZipPlus4 = fjIncidentR["kPersonZipPlus4"]
        self.incidentNFIRSKSecDetails = fjIncidentNFIRSKSec
        
        // TODO: -REQUIREDMODULES
        // MARK: -IncidentNFIRSsecL-
        let fjIncidentNFIRSsecL = self.sectionLDetails
        fjIncidentNFIRSsecL?.lRemarks = fjIncidentR["incidentNFIRSSecLNotes"] as? NSObject
        fjIncidentNFIRSsecL?.moreRemarks = fjIncidentR["incidentNFIRSSecLMoreRemarks"] as? Bool ?? false
        self.sectionLDetails = fjIncidentNFIRSsecL
        
        // MARK: -IncidentNFIRSsecM-
        let fjIncidentNFIRSsecM = self.sectionMDetails
        fjIncidentNFIRSsecM?.memberAssignment = fjIncidentR["memberAssignment"]
        fjIncidentNFIRSsecM?.memberDate = fjIncidentR["memberDate"]
        fjIncidentNFIRSsecM?.memberMakingReportID = fjIncidentR["memberMakingReportID"]
        fjIncidentNFIRSsecM?.memberRankPosition = fjIncidentR["memberRankPosition"]
        fjIncidentNFIRSsecM?.memberSameAsOfficer = fjIncidentR["memberSameAsOfficer"] as? Bool ?? false
        fjIncidentNFIRSsecM?.officerAssignment = fjIncidentR["officerAssignment"]
        fjIncidentNFIRSsecM?.officerDate = fjIncidentR["officerDate"]
        fjIncidentNFIRSsecM?.officerInChargeID = fjIncidentR["officerInChargeID"]
        fjIncidentNFIRSsecM?.officerRankPosition = fjIncidentR["officerRankPosition"]
        fjIncidentNFIRSsecM?.signatureMember = fjIncidentR["signatureMember"]
        fjIncidentNFIRSsecM?.signatureOfficer = fjIncidentR["signatureOfficer"]
        fjIncidentNFIRSsecM?.memberSigned = fjIncidentR["memberSigned"] as? Bool ?? false
        fjIncidentNFIRSsecM?.officeSigned = fjIncidentR["officerSigned"] as? Bool ?? false
        // TODO: -SIGNATURE CONVERSION-
        
        self.sectionMDetails = fjIncidentNFIRSsecM
        
        // MARK: -IncidentNotes-
        let fjIncidentNotes = self.incidentNotesDetails
        fjIncidentNotes?.incidentSummaryNotes = fjIncidentR["incidentSummaryNotes"] as? NSObject
        fjIncidentNotes?.incidentNote = fjIncidentR["incidentNote"]
        self.incidentNotesDetails = fjIncidentNotes
        
        // TODO: -IncidentResources-
        // MARK: -IncidentTimer-
        let fjIncidentTimer = self.incidentTimerDetails
        fjIncidentTimer?.arrivalSameDate = fjIncidentR["arrivalSameDate"] as? Bool ?? false
        fjIncidentTimer?.controlledSameDate = fjIncidentR["controlledSameDate"] as? Bool ?? false
        fjIncidentTimer?.incidentAlarmCombinedDate = fjIncidentR["incidentAlarmCombinedDate"]
        fjIncidentTimer?.incidentAlarmDateTime = fjIncidentR["incidentAlarmDateTime"]
        fjIncidentTimer?.incidentAlarmDay = fjIncidentR["incidentAlarmDay"]
        fjIncidentTimer?.incidentAlarmHours = fjIncidentR["incidentAlarmHours"]
        fjIncidentTimer?.incidentAlarmMinutes = fjIncidentR["incidentAlarmMinutes"]
        fjIncidentTimer?.incidentAlarmMonth = fjIncidentR["incidentAlarmMonth"]
        fjIncidentTimer?.incidentAlarmNotes = fjIncidentR["incidentAlarmNotes"] as? NSObject
        fjIncidentTimer?.incidentAlarmYear = fjIncidentR["incidentAlarmYear"]
        fjIncidentTimer?.incidentArrivalCombinedDate = fjIncidentR["incidentArrivalCombinedDate"]
        fjIncidentTimer?.incidentArrivalDateTime = fjIncidentR["incidentArrivalDateTime"]
        fjIncidentTimer?.incidentArrivalDay = fjIncidentR["incidentArrivalDay"]
        fjIncidentTimer?.incidentArrivalHours = fjIncidentR["incidentArrivalHours"]
        fjIncidentTimer?.incidentArrivalMinutes = fjIncidentR["incidentArrivalMinutes"]
        fjIncidentTimer?.incidentArrivalMonth = fjIncidentR["incidentArrivalMonth"]
        fjIncidentTimer?.incidentArrivalNotes = fjIncidentR["incidentArrivalNotes"] as? NSObject
        fjIncidentTimer?.incidentArrivalYear = fjIncidentR["incidentArrivalYear"]
        fjIncidentTimer?.incidentControlledCombinedDate = fjIncidentR["incidentControlledCombinedDate"]
        fjIncidentTimer?.incidentControlDateTime =  fjIncidentR["incidentControlDateTime"]
        fjIncidentTimer?.incidentControlledDay = fjIncidentR["incidentControlledDay"]
        fjIncidentTimer?.incidentControlledHours = fjIncidentR["incidentControlledHours"]
        fjIncidentTimer?.incidentControlledMinutes = fjIncidentR["incidentControlledMinutes"]
        fjIncidentTimer?.incidentControlledMonth = fjIncidentR["incidentControlledMonth"]
        fjIncidentTimer?.incidentControlledNotes = fjIncidentR["incidentControlledNotes"] as? NSObject
        fjIncidentTimer?.incidentControlledYear = fjIncidentR["incidentControlledYear"]
        fjIncidentTimer?.incidentElapsedTime = fjIncidentR["incidentElapsedTime"]
        fjIncidentTimer?.incidentLastUnitCalledCombinedDate = fjIncidentR["incidentLastUnitCalledCombinedDate"]
        fjIncidentTimer?.incidentLastUnitDateTime = fjIncidentR["incidentLastUnitDateTime"]
        fjIncidentTimer?.incidentLastUnitCalledDay = fjIncidentR["incidentLastUnitCalledDay"]
        fjIncidentTimer?.incidentLastUnitCalledHours = fjIncidentR["incidentLastUnitCalledHours"]
        fjIncidentTimer?.incidentLastUnitCalledMinutes = fjIncidentR["incidentLastUnitCalledMinutes"]
        fjIncidentTimer?.incidentLastUnitCalledMonth = fjIncidentR["incidentLastUnitCalledMonth"]
        fjIncidentTimer?.incidentLastUnitCalledYear = fjIncidentR["incidentLastUnitCalledYear"]
        fjIncidentTimer?.incidentLastUnitClearedNotes = fjIncidentR["incidentLastUnitClearedNotes"] as? NSObject
        fjIncidentTimer?.incidentStartClockCombinedDate = fjIncidentR["incidentStartClockCombinedDate"]
        fjIncidentTimer?.incidentStartClockDateTime = fjIncidentR["incidentStartClockDateTime"]
        fjIncidentTimer?.incidentStartClockDay = fjIncidentR["incidentStartClockDay"]
        fjIncidentTimer?.incidentStartClockHours = fjIncidentR["incidentStartClockHours"]
        fjIncidentTimer?.incidentStartClockMinutes = fjIncidentR["incidentStartClockMinutes"]
        fjIncidentTimer?.incidentStartClockMonth = fjIncidentR["incidentStartClockMonth"]
        fjIncidentTimer?.incidentStartClockSeconds = fjIncidentR["incidentStartClockSeconds"]
        fjIncidentTimer?.incidentStartClockYear = fjIncidentR["incidentStartClockYear"]
        fjIncidentTimer?.incidentStopClockCombinedDate = fjIncidentR["incidentStopClockCombinedDate"]
        fjIncidentTimer?.incidentStopClockDateTime = fjIncidentR["incidentStopDateTime"]
        fjIncidentTimer?.incidentStopClockDay = fjIncidentR["incidentStopClockDay"]
        fjIncidentTimer?.incidentStopClockHours = fjIncidentR["incidentStopClockHours"]
        fjIncidentTimer?.incidentStopClockMinutes = fjIncidentR["incidentStopClockMinutes"]
        fjIncidentTimer?.incidentStopClockMonth = fjIncidentR["incidentStopClockMonth"]
        fjIncidentTimer?.incidentStopClockSeconds = fjIncidentR["incidentStopClockSeconds"]
        fjIncidentTimer?.incidentStopClockYear = fjIncidentR["incidentStopClockYear"]
        fjIncidentTimer?.lastUnitSameDate = fjIncidentR["lastUnitSameDate"] as? Bool ?? false
        self.incidentTimerDetails = fjIncidentTimer
        
        // MARK: -ActionsTaken-
        let fjActionsTaken = self.actionsTakenDetails
        fjActionsTaken?.additionalThree = fjIncidentR["additionalThree"]
        fjActionsTaken?.additionalThreeNumber = fjIncidentR["additionalThreeNumber"]
        fjActionsTaken?.additionalTwo = fjIncidentR["additionalTwo"]
        fjActionsTaken?.additionalTwoNumber = fjIncidentR["additionalTwoNumber"]
        fjActionsTaken?.primaryAction = fjIncidentR["primaryAction"]
        fjActionsTaken?.primaryActionNumber = fjIncidentR["primaryActionNumber"]
        self.actionsTakenDetails = fjActionsTaken
        
        // TODO: -IncidentTeam, IncidentTags, UserCrew
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjIncidentR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.fjIncidentCKR = data as NSObject
        print("incident number here is self \(self.incidentNumber ?? "no incident number")")
        saveToCD()
    }
    
    
    func modifyIncidentForCloud(ckRecord:CKRecord)->CKRecord {
        let fjIncidentR = ckRecord
        
        fjIncidentR["incidentBackedUp"] =  true
        fjIncidentR["theEntity"] = "Incident"
        fjIncidentR["fjpIncGuidForReference"] = self.fjpIncGuidForReference
        fjIncidentR["fjpIncidentDateSearch"] = self.fjpIncidentDateSearch
        fjIncidentR["fjpIncidentModifiedDate"] = self.fjpIncidentModifiedDate
        //        fjIncidentR["fjpJournalReference"] = journalReference
        //        fjIncidentR["fjpUserReference"] = userReference
        fjIncidentR["formType"] = self.formType
        fjIncidentR["incidentCreationDate"] = self.incidentCreationDate
        fjIncidentR["incidentDate"] = self.incidentDate
        fjIncidentR["incidentDateSearch"] = self.incidentDateSearch
        fjIncidentR["incidentDayOfWeek"] = self.incidentDayOfWeek
        fjIncidentR["incidentDayOfYear"] = self.incidentDayOfYear
        fjIncidentR["incidentEntryTypeImageName"] = self.incidentEntryTypeImageName
        
        if self.locationAvailable {
            fjIncidentR["locationAvailable"] = 1
        } else {
                fjIncidentR["locationAvailable"] = 0
        }
        if self.incidentTagsAvailable {
            fjIncidentR["incidentTagsAvailable"] = 1
        } else {
                fjIncidentR["incidentTagsAvailable"] = 0
        }
        if self.incidentPhotoTaken != nil {
            if self.incidentPhotoTaken == 1 {
                fjIncidentR["incidentPhotoTaken"] = 1
            } else {
                fjIncidentR["incidentPhotoTaken"] = 0
            }
        }
        
        
        var location:CLLocation!
        if self.incidentLocationSC != nil {
                if let theLocation = self.incidentLocationSC {
                    guard let  archivedData = theLocation as? Data else { return fjIncidentR }
                    do {
                        guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return fjIncidentR }
                        location = unarchivedLocation
                        fjIncidentR["incidentLocation"] = location!
                    } catch {
                        print("error line 72 Incident+CustomAdditions")
                    }
                }
        }
        
        fjIncidentR["incidentModDate"] = self.incidentModDate
        fjIncidentR["incidentNFIRSCompleted"] = self.incidentNFIRSCompleted
        fjIncidentR["incidentNFIRSCompletedDate"] = self.incidentNFIRSCompletedDate
        fjIncidentR["incidentNFIRSDataComplete"] = self.incidentNFIRSDataComplete
        fjIncidentR["incidentNFIRSDataDate"] = self.incidentNFIRSDataDate
        fjIncidentR["incidentNFIRSDataSaved"] = self.incidentNFIRSDataSaved
        fjIncidentR["incidentNumber"] = self.incidentNumber
        fjIncidentR["incidentPhotoTaken"] = self.incidentPhotoTaken
        fjIncidentR["incidentSearchDate"] = self.incidentSearchDate
        fjIncidentR["incidentStreetHyway"] = self.incidentStreetHyway
        fjIncidentR["incidentStreetNumber"] = self.incidentStreetNumber
        fjIncidentR["incidentTime"] = self.incidentTime
        fjIncidentR["incidentType"] = self.incidentType
        fjIncidentR["incidentZipCode"] = self.incidentZipCode
        fjIncidentR["incidentZipPlus4"] = self.incidentZipPlus4
        fjIncidentR["situationIncidentImage"] = self.situationIncidentImage
        fjIncidentR["tempIncidentApparatus"] = self.tempIncidentApparatus
        fjIncidentR["tempIncidentAssignment"] = self.tempIncidentAssignment
        fjIncidentR["tempIncidentFireStation"] = self.tempIncidentFireStation
        fjIncidentR["tempIncidentPlatoon"] = self.tempIncidentPlatoon
        fjIncidentR["ics214Effort"] = self.ics214Effort
        fjIncidentR["ics214MasterGuid"] = self.ics214MasterGuid
        fjIncidentR["arsonInvestigation"] = Int(self.arsonInvestigation)
        
        let fjuSections = self.formDetails
        fjIncidentR["sectionA"] = Int(fjuSections?.sectionA ?? false)
        fjIncidentR["sectionB"] = Int(fjuSections?.sectionB ?? false)
        fjIncidentR["sectionC"] = Int(fjuSections?.sectionC ?? false)
        fjIncidentR["sectionD"] = Int(fjuSections?.sectionD ?? false)
        fjIncidentR["sectionE"] = Int(fjuSections?.sectionE ?? false)
        fjIncidentR["sectionF"] = Int(fjuSections?.sectionF ?? false)
        fjIncidentR["sectionG"] = Int(fjuSections?.sectionG ?? false)
        fjIncidentR["sectionH"] = Int(fjuSections?.sectionH ?? false)
        fjIncidentR["sectionI"] = Int(fjuSections?.sectionI ?? false)
        fjIncidentR["sectionJ"] = Int(fjuSections?.sectionJ ?? false)
        fjIncidentR["sectionK"] = Int(fjuSections?.sectionK ?? false)
        fjIncidentR["sectionL"] = Int(fjuSections?.sectionL ?? false)
        fjIncidentR["sectionM"] = Int(fjuSections?.sectionM ?? false)
        
        let fjIncidentAddress = self.incidentAddressDetails
        fjIncidentR["appSuiteRoom"] = fjIncidentAddress?.appSuiteRoom
        fjIncidentR["censusTract"] = fjIncidentAddress?.censusTract
        fjIncidentR["censusTract2"] = fjIncidentAddress?.censusTract2
        fjIncidentR["city"] = fjIncidentAddress?.city
        fjIncidentR["crossStreet"] = fjIncidentAddress?.crossStreet
        fjIncidentR["incidentState"] = fjIncidentAddress?.incidentState
        fjIncidentR["prefix"] = fjIncidentAddress?.prefix
        fjIncidentR["stagingAddress"] = fjIncidentAddress?.stagingAddress
        fjIncidentR["streetHighway"] = fjIncidentAddress?.streetHighway
        fjIncidentR["streetNumber"] = fjIncidentAddress?.streetNumber
        fjIncidentR["streetType"] = fjIncidentAddress?.streetType
        fjIncidentR["suffix"] = fjIncidentAddress?.suffix
        fjIncidentR["zip"] = fjIncidentAddress?.zip
        fjIncidentR["zipPlus4"] = fjIncidentAddress?.zipPlus4
        var num = ""
        var street = ""
        var zip = ""
        if let number = fjIncidentAddress?.streetNumber {
            num = number
        }
        if let st = fjIncidentAddress?.streetHighway {
            street = st
        }
        if let zipped = fjIncidentAddress?.zip {
            zip = zipped
        }
        fjIncidentR["aadressForIncident"] = "\(num) \(street) \(zip)"
        
        //MARK: -incidentLocal-
        let fjIncidentLocal = self.incidentLocalDetails
        fjIncidentR["incidentBattalion"] = fjIncidentLocal?.incidentBattalion
        fjIncidentR["incidentDivision"] = fjIncidentLocal?.incidentDivision
        fjIncidentR["incidentFireDistrict"] = fjIncidentLocal?.incidentFireDistrict
        fjIncidentR["incidentLocalType"] = fjIncidentLocal?.incidentLocalType
        
        //MARK: -IncidentMap-
        let fjIncidentMap = self.incidentMapDetails
        fjIncidentR["incidentLatitude"] = fjIncidentMap?.incidentLatitude
        fjIncidentR["incidentLongitude"] = fjIncidentMap?.incidentLongitude
        fjIncidentR["stagingLatitude"] = fjIncidentMap?.stagingLatitude
        fjIncidentR["stagingLongitude"] = fjIncidentMap?.stagingLongitude
        
        // MARK: -IncidentNFIRS-
        let fjIncidentNFIRS = self.incidentNFIRSDetails
        fjIncidentR["fireStationState"] = fjIncidentNFIRS?.fireStationState
        fjIncidentR["incidentActionsTakenAdditionalThree"] = fjIncidentNFIRS?.incidentActionsTakenAdditionalThree
        fjIncidentR["incidentActionsTakenAdditionalTwo"] = fjIncidentNFIRS?.incidentActionsTakenAdditionalTwo
        fjIncidentR["incidentActionsTakenPrimary"] = fjIncidentNFIRS?.incidentActionsTakenPrimary
        fjIncidentR["incidentAidGiven"] = fjIncidentNFIRS?.incidentAidGiven
        fjIncidentR["incidentAidGivenFDID"] = fjIncidentNFIRS?.incidentAidGivenFDID
        fjIncidentR["incidentAidGivenIncidentNumber"] = fjIncidentNFIRS?.incidentAidGivenIncidentNumber
        fjIncidentR["incidentAidGivenNone"] = fjIncidentNFIRS?.incidentAidGivenNone
        fjIncidentR["incidentAidGivenState"] = fjIncidentNFIRS?.incidentAidGivenState
        fjIncidentR["incidentCasualtiesCivilianDeaths"] = fjIncidentNFIRS?.incidentCasualtiesCivilianDeaths
        fjIncidentR["incidentCasualtiesCivilianInjuries"] = fjIncidentNFIRS?.incidentCasualtiesCivilianInjuries
        fjIncidentR["incidentCasualtiesFireDeaths"] = fjIncidentNFIRS?.incidentCasualtiesFireDeaths
        fjIncidentR["incidentCasualtiesFireInjuries"] = fjIncidentNFIRS?.incidentCasualtiesFireInjuries
        fjIncidentR["incidentCasualtiesNone"] = Int(fjIncidentNFIRS?.incidentCasualtiesNone ?? false)
        fjIncidentR["incidentCasualtiesServiceDeaths"] = fjIncidentNFIRS?.incidentCasualtiesServiceDeaths
        fjIncidentR["incidentCasualtitesServideInjuries"] = fjIncidentNFIRS?.incidentCasualtitesServideInjuries
        fjIncidentR["incidentDetectorChosen"] = fjIncidentNFIRS?.incidentDetectorChosen
        fjIncidentR["incidentExposure"] = fjIncidentNFIRS?.incidentExposure
        fjIncidentR["incidentFDID"] = fjIncidentNFIRS?.incidentFDID
        fjIncidentR["incidentFDID1"] = fjIncidentNFIRS?.incidentFDID1
        fjIncidentR["incidentFireStation"] = fjIncidentNFIRS?.incidentFireStation
        fjIncidentR["incidentHazMat"] = fjIncidentNFIRS?.incidentHazMat
        fjIncidentR["incidentHazMatNone"] = Int(fjIncidentNFIRS?.incidentHazMatNone ?? false)
        fjIncidentR["incidentNFIRSLocation"] = fjIncidentNFIRS?.incidentLocation
        fjIncidentR["incidentPlatoon"] = fjIncidentNFIRS?.incidentPlatoon
        fjIncidentR["incidentPropertyNone"] = fjIncidentNFIRS?.incidentPropertyNone
        fjIncidentR["incidentPropertyOutside"] = fjIncidentNFIRS?.incidentPropertyOutside
        fjIncidentR["incidentPropertyOutsideNumber"] = fjIncidentNFIRS?.incidentPropertyOutsideNumber
        fjIncidentR["incidentPropertyStructure"] = fjIncidentNFIRS?.incidentPropertyStructure
        fjIncidentR["incidentPropertyStructureNumber"] = fjIncidentNFIRS?.incidentPropertyStructureNumber
        fjIncidentR["incidentPropertyUse"] = fjIncidentNFIRS?.incidentPropertyUse
        fjIncidentR["incidentPropertyUseNone"] = fjIncidentNFIRS?.incidentPropertyUseNone
        fjIncidentR["incidentPropertyUseNumber"] = fjIncidentNFIRS?.incidentPropertyUseNumber
        fjIncidentR["incidentResourceCheck"] = fjIncidentNFIRS?.incidentResourceCheck
        fjIncidentR["incidentResourcesEMSApparatus"] = fjIncidentNFIRS?.incidentResourcesEMSApparatus
        fjIncidentR["incidentResourcesEMSPersonnel"] = fjIncidentNFIRS?.incidentResourcesEMSPersonnel
        fjIncidentR["incidentResourcesOtherApparatus"] = fjIncidentNFIRS?.incidentResourcesOtherApparatus
        fjIncidentR["incidentResourcesOtherPersonnel"] = fjIncidentNFIRS?.incidentResourcesOtherPersonnel
        fjIncidentR["incidentResourcesSuppressionPersonnel"] = fjIncidentNFIRS?.incidentResourcesSuppressionPersonnel
        fjIncidentR["incidentResourcesSupressionApparatus"] = fjIncidentNFIRS?.incidentResourcesSupressionApparatus
        fjIncidentR["incidentTypeNumberNFRIS"] = fjIncidentNFIRS?.incidentTypeNumberNFRIS
        fjIncidentR["incidentTypeTextNFRIS"] = fjIncidentNFIRS?.incidentTypeTextNFRIS
        fjIncidentR["lossesContentDollars"] = fjIncidentNFIRS?.lossesContentDollars
        fjIncidentR["lossesContentNone"] = Int(fjIncidentNFIRS?.lossesContentNone ?? false)
        fjIncidentR["lossesPropertyDollars"] = fjIncidentNFIRS?.lossesPropertyDollars
        fjIncidentR["lossesPropertyNone"] = Int(fjIncidentNFIRS?.lossesPropertyNone ?? false)
        fjIncidentR["mixedUsePropertyNone"] = Int(fjIncidentNFIRS?.mixedUsePropertyNone ?? false)
        fjIncidentR["mixedUsePropertyType"] = fjIncidentNFIRS?.mixedUsePropertyType
        fjIncidentR["nfirsChangeDescription"] = fjIncidentNFIRS?.nfirsChangeDescription
        fjIncidentR["nfirsSectionOneSegment"] = fjIncidentNFIRS?.nfirsSectionOneSegment
        fjIncidentR["propertyUseNone"] = Int(fjIncidentNFIRS?.propertyUseNone ?? false)
        fjIncidentR["resourceCountsIncludeAidReceived"] = Int(fjIncidentNFIRS?.resourceCountsIncludeAidReceived ?? false)
        fjIncidentR["shiftAlarm"] = fjIncidentNFIRS?.shiftAlarm
        fjIncidentR["shiftDistrict"] = fjIncidentNFIRS?.shiftDistrict
        fjIncidentR["shiftOrPlatoon"] = fjIncidentNFIRS?.shiftOrPlatoon
        fjIncidentR["skipSectionF"] = Int(fjIncidentNFIRS?.skipSectionF ?? false)
        fjIncidentR["specialStudyID"] = fjIncidentNFIRS?.specialStudyID
        fjIncidentR["specialStudyValue"] = fjIncidentNFIRS?.specialStudyValue
        fjIncidentR["valueContentDollars"] = fjIncidentNFIRS?.valueContentDollars
        fjIncidentR["valueContentsNone"] = Int(fjIncidentNFIRS?.valueContentsNone ?? false)
        fjIncidentR["valuePropertyDollars"] = fjIncidentNFIRS?.valuePropertyDollars
        fjIncidentR["valuePropertyNone"] = Int(fjIncidentNFIRS?.valuePropertyNone ?? false)
        
        // TODO: IncidentNFIRSCompMods
        // let fjIncidentNFIRSCompMods = self.completedModulesDetails
        //     NSMutableArray *_compModules = [[NSMutableArray alloc] init]
        //     for(fjIncidentNFIRSCompMods in self.completedModulesDetails){
        //         [_compModules addObject:fjIncidentNFIRSCompMods.completedModules]
        //     }
        //     _nfirsCompleteMods = [_compModules copy]
        //     NSString *compMods = @""
        //     NSString *truncatedCMString = @""
        //     if(!([_nfirsCompleteMods count] == 0)) {
        //         for(NSString *t in _nfirsCompleteMods){
        //             if(![t isEqualToString:@""]){
        //                 compMods = [compMods stringByAppendingString:[NSString stringWithFormat:@"%@,",t]]
        //             }
        //             if([compMods length]>2){
        //                 truncatedCMString = [compMods substringToIndex:[compMods length]-2]
        //             }
        //         }
        //     }
        //     fjIncidentR["incidentCompletedModules"] = truncatedCMString
        
        // MARK: -IncidentNFIRSKSec-
        let fjIncidentNFIRSKSec = self.incidentNFIRSKSecDetails
        fjIncidentR["kOwnerAptSuiteRoom"] = fjIncidentNFIRSKSec?.kOwnerAptSuiteRoom
        fjIncidentR["kOwnerAreaCode"] = fjIncidentNFIRSKSec?.kOwnerAreaCode
        fjIncidentR["kOwnerBusinessName"] = fjIncidentNFIRSKSec?.kOwnerBusinessName
        fjIncidentR["kOwnerCheckBox"] = Int(fjIncidentNFIRSKSec?.kOwnerCheckBox ?? false)
        fjIncidentR["kOwnerCity"] = fjIncidentNFIRSKSec?.kOwnerCity
        fjIncidentR["kOwnerFirstName"] = fjIncidentNFIRSKSec?.kOwnerFirstName
        fjIncidentR["kOwnerLastName"] = fjIncidentNFIRSKSec?.kOwnerLastName
        fjIncidentR["kOwnerMI"] = fjIncidentNFIRSKSec?.kOwnerMI
        fjIncidentR["kOwnerNamePrefix"] = fjIncidentNFIRSKSec?.kOwnerNamePrefix
        fjIncidentR["kOwnerNameSuffix"] = fjIncidentNFIRSKSec?.kOwnerNameSuffix
        fjIncidentR["kOwnerPhoneLastFour"] = fjIncidentNFIRSKSec?.kOwnerPhoneLastFour
        fjIncidentR["kOwnerPhonePrefix"] = fjIncidentNFIRSKSec?.kOwnerPhonePrefix
        fjIncidentR["kOwnerPOBox"] = fjIncidentNFIRSKSec?.kOwnerPOBox
        fjIncidentR["kOwnerSameAsPerson"] = Int(fjIncidentNFIRSKSec?.kOwnerSameAsPerson ?? false)
        fjIncidentR["kOwnerState"] = fjIncidentNFIRSKSec?.kOwnerState
        fjIncidentR["kOwnerStreetHyway"] = fjIncidentNFIRSKSec?.kOwnerStreetHyway
        fjIncidentR["kOwnerStreetNumber"] = fjIncidentNFIRSKSec?.kOwnerStreetNumber
        fjIncidentR["kOwnerStreetPrefix"] = fjIncidentNFIRSKSec?.kOwnerStreetPrefix
        fjIncidentR["kOwnerStreetSuffix"] = fjIncidentNFIRSKSec?.kOwnerStreetSuffix
        fjIncidentR["kOwnerStreetType"] = fjIncidentNFIRSKSec?.kOwnerStreetType
        fjIncidentR["kOwnerZip"] = fjIncidentNFIRSKSec?.kOwnerZip
        fjIncidentR["kOwnerZipPlusFour"] = fjIncidentNFIRSKSec?.kOwnerZipPlusFour
        fjIncidentR["kPersonAppSuiteRoom"] = fjIncidentNFIRSKSec?.kPersonAppSuiteRoom
        fjIncidentR["kPersonAreaCode"] = fjIncidentNFIRSKSec?.kPersonAreaCode
        fjIncidentR["kPersonBusinessName"] = fjIncidentNFIRSKSec?.kPersonBusinessName
        fjIncidentR["kPersonCheckBox"] = Int(fjIncidentNFIRSKSec?.kPersonCheckBox ?? false)
        fjIncidentR["kPersonCity"] = fjIncidentNFIRSKSec?.kPersonCity
        fjIncidentR["kPersonFirstName"] = fjIncidentNFIRSKSec?.kPersonFirstName
        fjIncidentR["kPersonGender"] = fjIncidentNFIRSKSec?.kPersonGender
        fjIncidentR["kPersonLastName"] = fjIncidentNFIRSKSec?.kPersonLastName
        fjIncidentR["kPersonMI"] = fjIncidentNFIRSKSec?.kPersonMI
        fjIncidentR["kPersonMoreThanOne"] = Int(fjIncidentNFIRSKSec?.kPersonMoreThanOne ?? false)
        fjIncidentR["kPersonNameSuffix"] = fjIncidentNFIRSKSec?.kPersonNameSuffix
        fjIncidentR["kPersonPhoneLastFour"] = fjIncidentNFIRSKSec?.kPersonPhoneLastFour
        fjIncidentR["kPersonPhonePrefix"] = fjIncidentNFIRSKSec?.kPersonPhonePrefix
        fjIncidentR["kPersonPOBox"] = fjIncidentNFIRSKSec?.kPersonPOBox
        fjIncidentR["kPersonPrefix"] = fjIncidentNFIRSKSec?.kPersonPrefix
        fjIncidentR["kPersonState"] = fjIncidentNFIRSKSec?.kPersonState
        fjIncidentR["kPersonStreetHyway"] = fjIncidentNFIRSKSec?.kPersonStreetHyway
        fjIncidentR["kPersonStreetNum"] = fjIncidentNFIRSKSec?.kPersonStreetNum
        fjIncidentR["kPersonStreetSuffix"] = fjIncidentNFIRSKSec?.kPersonStreetSuffix
        fjIncidentR["kPersonStreetType"] = fjIncidentNFIRSKSec?.kPersonStreetType
        fjIncidentR["kPersonZipCode"] = fjIncidentNFIRSKSec?.kPersonZipCode
        fjIncidentR["kPersonZipPlus4"] = fjIncidentNFIRSKSec?.kPersonZipPlus4
        
        // TODO: -IncidentNFIRSRequiredModules-
        // IncidentNFIRSRequiredModules *_requiredModules = (IncidentNFIRSRequiredModules *)self.requiredModulesDetails
        //     NSMutableArray *_nfirsRMods = [[NSMutableArray alloc] init]
        //     for(_requiredModules in self.completedModulesDetails){
        //         [_nfirsRMods addObject:_requiredModules.requiredModule]
        //     }
        //     _nfirsRequiredMods = [_nfirsRMods copy]
        //     NSString *reqMods = @""
        //     NSString *truncatedRMString = @""
        //     if(!([_nfirsRequiredMods count] == 0)) {
        //         for(NSString *t in _nfirsRequiredMods){
        //             if(![t isEqualToString:@""]){
        //                 reqMods = [reqMods stringByAppendingString:[NSString stringWithFormat:@"%@,",t]]
        //             }
        //             if([reqMods length]>0){
        //                 truncatedRMString = [reqMods substringToIndex:[reqMods length]-2]
        //             }
        //         }
        //     }
        //     fjIncidentR["incidentRequiredModules"] = truncatedRMString
        
        let fjIncidentNFIRSsecL = self.sectionLDetails
        fjIncidentR["incidentNFIRSSecLNotes"] = fjIncidentNFIRSsecL?.lRemarks as? String
        fjIncidentR["incidentNFIRSSecLMoreRemarks"] = Int(fjIncidentNFIRSsecL?.moreRemarks ?? false)
        
        let fjIncidentNFIRSsecM = self.sectionMDetails
        fjIncidentR["memberAssignment"] = fjIncidentNFIRSsecM?.memberAssignment
        fjIncidentR["memberDate"] = fjIncidentNFIRSsecM?.memberDate
        fjIncidentR["memberMakingReportID"] = fjIncidentNFIRSsecM?.memberMakingReportID
        fjIncidentR["memberRankPosition"] = fjIncidentNFIRSsecM?.memberRankPosition
        fjIncidentR["memberSameAsOfficer"] = Int(fjIncidentNFIRSsecM?.memberSameAsOfficer ?? false)
        fjIncidentR["officerAssignment"] = fjIncidentNFIRSsecM?.officerAssignment
        fjIncidentR["officerDate"] = fjIncidentNFIRSsecM?.officerDate
        fjIncidentR["officerInChargeID"] = fjIncidentNFIRSsecM?.officerInChargeID
        fjIncidentR["officerRankPosition"] = fjIncidentNFIRSsecM?.officerRankPosition
        fjIncidentR["signatureMember"] = fjIncidentNFIRSsecM?.signatureMember
        fjIncidentR["signatureOfficer"] = fjIncidentNFIRSsecM?.signatureOfficer
        // TODO: -OFFICER AND MEMBER SIGNATURE ASSETS
        //    TRANSFORM officerSignature
        // if(fjIncidentNFIRSsecM?.officeSigned) {
        //         fjIncidentR["officerSigned"] = @1
        //         NSData *oSignatureData = nil
        //         oSignatureData = fjIncidentNFIRSsecM?.officerSignature
        //         NSMutableDictionary *oPhotoDictionary = [[NSMutableDictionary alloc] init]
        //         NSString *oPhotoName = @""
        //         NSString *opath = @""
        //         @synchronized (self) {
        //             if(!(oSignatureData == nil)){
        //                 NSDateFormatter *dayOfWeekNumberFormat = [[NSDateFormatter alloc] init]
        //                 [dayOfWeekNumberFormat setDateFormat:@"YYYYDDDHHmmAAAAAAAA"]
        //                 NSString *_displayDayOfTheYear = [dayOfWeekNumberFormat stringFromDate:[NSDate date]]
        //                 UIImage *_signatureImage = [UIImage imageWithData:oSignatureData]
        //                 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
        //                                                                      NSUserDomainMask, YES)
        //                 NSString *documentsDirectory = [paths objectAtIndex:0]
        //                 oPhotoName = @"OfficerSignature"
        //                 opath = [documentsDirectory stringByAppendingPathComponent:
        //                          [NSString stringWithFormat:@"%@_%@.jpg",oPhotoName,_displayDayOfTheYear]]
        //                 if([UIImageJPEGRepresentation(_signatureImage, 1.0) writeToFile:opath atomically:YES]){
        //                     [oPhotoDictionary setObject:oPhotoName forKey:opath]
        //                     NSURL *fileNSUrl = [NSURL fileURLWithPath:opath]
        //                     CKAsset *imageAsset = [[CKAsset alloc] initWithFileURL:fileNSUrl]
        //
        //                     fjIncidentR["officerSignature"] = imageAsset
        //                 }
        //             }
        //         }
        //     } else {
        //         fjIncidentR["officerSigned"] = @0
        //     }
        // //  TRANSFORM memberSignature
        //     if(fjIncidentNFIRSsecM?.memberSigned) {
        //         fjIncidentR["memberSigned"] = @1
        //         NSData *mSignatureData = nil
        //         mSignatureData = fjIncidentNFIRSsecM?.memberSignature
        //         NSMutableDictionary *mPhotoDictionary = [[NSMutableDictionary alloc] init]
        //         NSString *mPhotoName = @""
        //         NSString *mpath = @""
        //         @synchronized (self) {
        //             if(!(mSignatureData == nil)){
        //                 NSDateFormatter *dayOfWeekNumberFormat = [[NSDateFormatter alloc] init]
        //                 [dayOfWeekNumberFormat setDateFormat:@"YYYYDDDHHmmAAAAAAAA"]
        //                 NSString *_displayDayOfTheYear = [dayOfWeekNumberFormat stringFromDate:[NSDate date]]
        //                 UIImage *_signatureImage = [UIImage imageWithData:mSignatureData]
        //                 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
        //                                                                      NSUserDomainMask, YES)
        //                 NSString *documentsDirectory = [paths objectAtIndex:0]
        //                 mPhotoName = @"MemberSignature"
        //                 mpath = [documentsDirectory stringByAppendingPathComponent:
        //                          [NSString stringWithFormat:@"%@_%@.jpg",mPhotoName,_displayDayOfTheYear]]
        //                 if([UIImageJPEGRepresentation(_signatureImage, 1.0) writeToFile:mpath atomically:YES]){
        //                     [mPhotoDictionary setObject:mPhotoName forKey:mpath]
        //                     NSURL *fileNSUrl = [NSURL fileURLWithPath:mpath]
        //                     CKAsset *imageAsset = [[CKAsset alloc] initWithFileURL:fileNSUrl]
        //
        //                     fjIncidentR["memberSignature"] = imageAsset
        //                 }
        //             }
        //         }
        //     } else {
        //         fjIncidentR["memberSigned"] = @0
        //     }
        
        // MARK: -IncidentNotes-
        let fjIncidentNotes = self.incidentNotesDetails
        fjIncidentR["incidentSummaryNotes"] = fjIncidentNotes?.incidentSummaryNotes as? String
        fjIncidentR["incidentNote"] = fjIncidentNotes?.incidentNote
        
        // TODO: -IncidentResources-
        // IncidentResources *_incidentResources = (IncidentResources *)self.incidentResourceDetails
        //     NSMutableArray *resource = [[NSMutableArray alloc] init]
        //     for(_incidentResources in self.incidentResourceDetails){
        //         [resource addObject:_incidentResources.incidentResource]
        //     }
        //     _resourceArray = [resource copy]
        //     NSString *resourcing = @""
        //     NSString *truncatedRString = @""
        //
        //     if (!([_resourceArray count] == 0)) {
        //         for(NSString *t in _resourceArray){
        //             if(![t isEqualToString:@""])
        //                 resourcing = [resourcing stringByAppendingString:[NSString stringWithFormat:@"%@, ",t]]
        //         }
        //         if([resourcing length]>2){
        //             truncatedRString = [resourcing substringToIndex:[resourcing length]-2]
        //         }
        //     }
        //     fjIncidentR["incidentResource"] = truncatedRString
        
        //        MARK: -IncidentTimer-
        let fjIncidentTimer = self.incidentTimerDetails
        fjIncidentR["arrivalSameDate"] = Int(fjIncidentTimer?.arrivalSameDate ?? false)
        fjIncidentR["controlledSameDate"] = Int(fjIncidentTimer?.controlledSameDate ?? false)
        fjIncidentR["incidentAlarmCombinedDate"] = fjIncidentTimer?.incidentAlarmCombinedDate
        fjIncidentR["incidentAlarmDateTime"] = fjIncidentTimer?.incidentAlarmDateTime
        fjIncidentR["incidentAlarmDay"] = fjIncidentTimer?.incidentAlarmDay
        fjIncidentR["incidentAlarmHours"] = fjIncidentTimer?.incidentAlarmHours
        fjIncidentR["incidentAlarmMinutes"] = fjIncidentTimer?.incidentAlarmMinutes
        fjIncidentR["incidentAlarmMonth"] = fjIncidentTimer?.incidentAlarmMonth
        fjIncidentR["incidentAlarmNotes"] = fjIncidentTimer?.incidentAlarmNotes as? String
        fjIncidentR["incidentAlarmYear"] = fjIncidentTimer?.incidentAlarmYear
        fjIncidentR["incidentArrivalCombinedDate"] = fjIncidentTimer?.incidentArrivalCombinedDate
        fjIncidentR["incidentArrivalDateTime"] = fjIncidentTimer?.incidentArrivalDateTime
        fjIncidentR["incidentArrivalDay"] = fjIncidentTimer?.incidentArrivalDay
        fjIncidentR["incidentArrivalHours"] = fjIncidentTimer?.incidentArrivalHours
        fjIncidentR["incidentArrivalMinutes"] = fjIncidentTimer?.incidentArrivalMinutes
        fjIncidentR["incidentArrivalMonth"] = fjIncidentTimer?.incidentArrivalMonth
        fjIncidentR["incidentArrivalNotes"] = fjIncidentTimer?.incidentArrivalNotes as? String
        fjIncidentR["incidentArrivalYear"] = fjIncidentTimer?.incidentArrivalYear
        fjIncidentR["incidentControlledCombinedDate"] = fjIncidentTimer?.incidentControlledCombinedDate
        fjIncidentR["incidentControlDateTime"] = fjIncidentTimer?.incidentControlDateTime
        fjIncidentR["incidentControlledDay"] = fjIncidentTimer?.incidentControlledDay
        fjIncidentR["incidentControlledHours"] = fjIncidentTimer?.incidentControlledHours
        fjIncidentR["incidentControlledMinutes"] = fjIncidentTimer?.incidentControlledMinutes
        fjIncidentR["incidentControlledMonth"] = fjIncidentTimer?.incidentControlledMonth
        fjIncidentR["incidentControlledNotes"] = fjIncidentTimer?.incidentControlledNotes as? String
        fjIncidentR["incidentControlledYear"] = fjIncidentTimer?.incidentControlledYear
        fjIncidentR["incidentElapsedTime"] = fjIncidentTimer?.incidentElapsedTime
        fjIncidentR["incidentLastUnitCalledCombinedDate"] = fjIncidentTimer?.incidentLastUnitCalledCombinedDate
        fjIncidentR["incidentLastUnitDateTime"] = fjIncidentTimer?.incidentLastUnitDateTime
        fjIncidentR["incidentLastUnitCalledDay"] = fjIncidentTimer?.incidentLastUnitCalledDay
        fjIncidentR["incidentLastUnitCalledHours"] = fjIncidentTimer?.incidentLastUnitCalledHours
        fjIncidentR["incidentLastUnitCalledMinutes"] = fjIncidentTimer?.incidentLastUnitCalledMinutes
        fjIncidentR["incidentLastUnitCalledMonth"] = fjIncidentTimer?.incidentLastUnitCalledMonth
        fjIncidentR["incidentLastUnitCalledYear"] = fjIncidentTimer?.incidentLastUnitCalledYear
        fjIncidentR["incidentLastUnitClearedNotes"] = fjIncidentTimer?.incidentLastUnitClearedNotes as? String
        fjIncidentR["incidentStartClockCombinedDate"] = fjIncidentTimer?.incidentStartClockCombinedDate
        fjIncidentR["incidentStartClockDateTime"] = fjIncidentTimer?.incidentStartClockDateTime
        fjIncidentR["incidentStartClockDay"] = fjIncidentTimer?.incidentStartClockDay
        fjIncidentR["incidentStartClockHours"] = fjIncidentTimer?.incidentStartClockHours
        fjIncidentR["incidentStartClockMinutes"] = fjIncidentTimer?.incidentStartClockMinutes
        fjIncidentR["incidentStartClockMonth"] = fjIncidentTimer?.incidentStartClockMonth
        fjIncidentR["incidentStartClockSeconds"] = fjIncidentTimer?.incidentStartClockSeconds
        fjIncidentR["incidentStartClockYear"] = fjIncidentTimer?.incidentStartClockYear
        fjIncidentR["incidentStopClockCombinedDate"] = fjIncidentTimer?.incidentStopClockCombinedDate
        fjIncidentR["incidentStopClockDateTime"] = fjIncidentTimer?.incidentStopClockDateTime
        fjIncidentR["incidentStopClockDay"] = fjIncidentTimer?.incidentStopClockDay
        fjIncidentR["incidentStopClockHours"] = fjIncidentTimer?.incidentStopClockHours
        fjIncidentR["incidentStopClockMinutes"] = fjIncidentTimer?.incidentStopClockMinutes
        fjIncidentR["incidentStopClockMonth"] = fjIncidentTimer?.incidentStopClockMonth
        fjIncidentR["incidentStopClockSeconds"] = fjIncidentTimer?.incidentStopClockSeconds
        fjIncidentR["incidentStopClockYear"] = fjIncidentTimer?.incidentStopClockYear
        fjIncidentR["lastUnitSameDate"] = Int(fjIncidentTimer?.lastUnitSameDate ?? false)
        
        //        MARK: -ActionsTaken-
        let fjActionsTaken = self.actionsTakenDetails
        fjIncidentR["additionalThree"] = fjActionsTaken?.additionalThree
        fjIncidentR["additionalThreeNumber"] = fjActionsTaken?.additionalThreeNumber
        fjIncidentR["additionalTwo"] = fjActionsTaken?.additionalTwo
        fjIncidentR["additionalTwoNumber"] = fjActionsTaken?.additionalTwoNumber
        fjIncidentR["primaryAction"] = fjActionsTaken?.primaryAction
        fjIncidentR["primaryActionNumber"] = fjActionsTaken?.primaryActionNumber
        
        // TODO: -IncidentTags, IncidentTeams, Crews
        // IncidentTeam *_incidentTeam = (IncidentTeam *)self.teamMemberDetails
        //     NSMutableArray *team = [[NSMutableArray alloc] init]
        //     for(_incidentTeam in self.teamMemberDetails){
        //         [team addObject:_incidentTeam.teamMember]
        //     }
        //     _teamArray = [team copy]
        //     NSString *teaming = @""
        //     NSString *truncatedTString = @""
        //     if (!([_teamArray count] == 0)) {
        //         for(NSString *t in _teamArray){
        //             if(![t isEqualToString:@""])
        //                 teaming = [teaming stringByAppendingString:[NSString stringWithFormat:@"%@, ",t]]
        //         }
        //         if([teaming length]>2){
        //             truncatedTString = [teaming substringToIndex:[teaming length]-2]
        //         }
        //     }
        //     fjIncidentR["teamMembers"] = truncatedTString
        //
        //     IncidentTags *_incidentTags = (IncidentTags *)self.incidentTagDetails
        //     NSMutableArray *tag = [[NSMutableArray alloc] init]
        //     for(_incidentTags in self.incidentTagDetails){
        //         [tag addObject:_incidentTags.incidentTag]
        //     }
        //     _tagsArray = [tag copy]
        //     NSString *tagging = @""
        //     NSString *truncatedTagString = @""
        //     if (!([_tagsArray count] == 0)) {
        //         for(NSString *t in _tagsArray){
        //             if(![t isEqualToString:@""])
        //                 tagging = [tagging stringByAppendingString:[NSString stringWithFormat:@"%@, ",t]]
        //         }
        //         if([tagging length]>2){
        //             truncatedTagString = [tagging substringToIndex:[tagging length]-2]
        //         }
        //     }
        //     fjIncidentR["incidentTags"] = truncatedTagString
        //        end record
        return fjIncidentR
        
    }
    
    fileprivate func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"no big deal here"])
                print("Incident we have saved to the cloud")
            }
        } catch {
            let nserror = error as NSError
            
            let error = "The Incident+CustomAdditions context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
            print(error)
        }
    }
}
