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
        if let guid = self.fjpIncGuidForReference {
            fjIncidentR["fjpIncGuidForReference"] = guid
        }
        if let dateSearch = self.fjpIncidentDateSearch {
            fjIncidentR["fjpIncidentDateSearch"] = dateSearch
        }
        if let modDate = self.fjpIncidentModifiedDate {
            fjIncidentR["fjpIncidentModifiedDate"] = modDate
        }
        
        if let form = self.formType {
            fjIncidentR["formType"] =  form
        }
        if let incidentCreationDate = self.incidentCreationDate {
            fjIncidentR["incidentCreationDate"] = incidentCreationDate
        }
        if let incidentDate = self.incidentDate {
            fjIncidentR["incidentDate"] = incidentDate
        }
        if let incidentDateSearch = self.incidentDateSearch {
            fjIncidentR["incidentDateSearch"] = incidentDateSearch
        }
        if let incidentDayOfWeek = self.incidentDayOfWeek {
            fjIncidentR["incidentDayOfWeek"] = incidentDayOfWeek
        }
        if let incidentDayOfYear = self.incidentDayOfYear {
            fjIncidentR["incidentDayOfYear"] = incidentDayOfYear
        }
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
        if self.arsonInvestigation {
            fjIncidentR["arsonInvestigation"] = 1
        } else {
            fjIncidentR["arsonInvestigation"] = 0
        }
        if self.incidentCancel {
            fjIncidentR["incidentCancel"] = 1
        } else {
            fjIncidentR["incidentCancel"] = 0
        }
        if self.incidentPhotoTaken != nil {
            if self.incidentPhotoTaken == 1 {
                fjIncidentR["incidentPhotoTaken"] = true
            } else {
                fjIncidentR["incidentPhotoTaken"] = false
            }
        }
        if let incidentEntryTypeImageName = self.incidentEntryTypeImageName {
            fjIncidentR["incidentEntryTypeImageName"] = incidentEntryTypeImageName
        }
        
        if let incidentModDate = self.incidentModDate {
            fjIncidentR["incidentModDate"] = incidentModDate
        }
        if let incidentNFIRSCompleted = self.incidentNFIRSCompleted {
            fjIncidentR["incidentNFIRSCompleted"] = incidentNFIRSCompleted
        }
        if let incidentNFIRSCompletedDate = self.incidentNFIRSCompletedDate {
            fjIncidentR["incidentNFIRSCompletedDate"] = incidentNFIRSCompletedDate
        }
        if let incidentNFIRSDataComplete = self.incidentNFIRSDataComplete {
            fjIncidentR["incidentNFIRSDataComplete"] = incidentNFIRSDataComplete
        }
        if let incidentNFIRSDataDate = self.incidentNFIRSDataDate {
            fjIncidentR["incidentNFIRSDataDate"] = incidentNFIRSDataDate
        }
        if let incidentNFIRSDataSaved = self.incidentNFIRSDataSaved {
            fjIncidentR["incidentNFIRSDataSaved"] = incidentNFIRSDataSaved
        }
        if let incidentNumber = self.incidentNumber {
            fjIncidentR["incidentNumber"] = incidentNumber
        }
        
        if let incidentSearchDate = self.incidentSearchDate {
            fjIncidentR["incidentSearchDate"] = incidentSearchDate
        }
        if let incidentTime = self.incidentTime {
            fjIncidentR["incidentTime"] = incidentTime
        }
        if let incidentType = self.incidentType {
            fjIncidentR["incidentType"] = incidentType
        }
        if let situationIncidentImage = self.situationIncidentImage {
            fjIncidentR["situationIncidentImage"] = situationIncidentImage
        }
        if let tempIncidentApparatus = self.tempIncidentApparatus {
            fjIncidentR["tempIncidentApparatus"] = tempIncidentApparatus
        }
        if let tempIncidentAssignment = self.tempIncidentAssignment {
            fjIncidentR["tempIncidentAssignment"] = tempIncidentAssignment
        }
        if let tempIncidentFireStation = self.tempIncidentFireStation {
            fjIncidentR["tempIncidentFireStation"] = tempIncidentFireStation
        }
        if let tempIncidentPlatoon = self.tempIncidentPlatoon {
            fjIncidentR["tempIncidentPlatoon"] = tempIncidentPlatoon
        }
        if let ics214Effort = self.ics214Effort {
            fjIncidentR["ics214Effort"] = ics214Effort
        }
        if let ics214MasterGuid = self.ics214MasterGuid {
            fjIncidentR["ics214MasterGuid"] = ics214MasterGuid
        }
        fjIncidentR["arsonInvestigation"] = Int(self.arsonInvestigation)
        
        
        if let fjuSections = self.formDetails {
            fjIncidentR["sectionA"] = Int(fjuSections.sectionA)
            fjIncidentR["sectionB"] = Int(fjuSections.sectionB )
            fjIncidentR["sectionC"] = Int(fjuSections.sectionC)
            fjIncidentR["sectionD"] = Int(fjuSections.sectionD)
            fjIncidentR["sectionE"] = Int(fjuSections.sectionE)
            fjIncidentR["sectionF"] = Int(fjuSections.sectionF)
            fjIncidentR["sectionG"] = Int(fjuSections.sectionG)
            fjIncidentR["sectionH"] = Int(fjuSections.sectionH)
            fjIncidentR["sectionI"] = Int(fjuSections.sectionI)
            fjIncidentR["sectionJ"] = Int(fjuSections.sectionJ)
            fjIncidentR["sectionK"] = Int(fjuSections.sectionK)
            fjIncidentR["sectionL"] = Int(fjuSections.sectionL)
            fjIncidentR["sectionM"] = Int(fjuSections.sectionM)
        }
        
        if let fjIncidentAddress = self.incidentAddressDetails {
            if let appSuiteRoom = fjIncidentAddress.appSuiteRoom {
                fjIncidentR["appSuiteRoom"] = appSuiteRoom
            }
            if let censusTract = fjIncidentAddress.censusTract {
                fjIncidentR["censusTract"] = censusTract
            }
            if let censusTract2 = fjIncidentAddress.censusTract2 {
                fjIncidentR["censusTract2"] = censusTract2
            }
            if let city = fjIncidentAddress.city {
                fjIncidentR["city"] = city
            }
            if let crossStreet = fjIncidentAddress.crossStreet {
                fjIncidentR["crossStreet"] = crossStreet
            }
            if let incidentState = fjIncidentAddress.incidentState {
                fjIncidentR["incidentState"] = incidentState
            }
            if let prefix = fjIncidentAddress.prefix {
                fjIncidentR["prefix"] = prefix
            }
            if let stagingAddress = fjIncidentAddress.stagingAddress {
                fjIncidentR["stagingAddress"] = stagingAddress
            }
            if let streetHighway = fjIncidentAddress.streetHighway {
                fjIncidentR["streetHighway"] = streetHighway
            }
            if let streetNumber = fjIncidentAddress.streetNumber {
                fjIncidentR["streetNumber"] = streetNumber
            }
            if let streetType = fjIncidentAddress.streetType {
                fjIncidentR["streetType"] = streetType
            }
            if let suffix = fjIncidentAddress.suffix {
                fjIncidentR["suffix"] = suffix
            }
            if let zip = fjIncidentAddress.zip {
                fjIncidentR["zip"] = zip
            }
            if let zipPlus4 = fjIncidentAddress.zipPlus4 {
                fjIncidentR["zipPlus4"] = zipPlus4
            }
            var num = ""
            var street = ""
            var zip = ""
            if let number = fjIncidentAddress.streetNumber {
                num = number
            }
            if let st = fjIncidentAddress.streetHighway {
                street = st
            }
            if let zipped = fjIncidentAddress.zip {
                zip = zipped
            }
            fjIncidentR["aadressForIncident"] = "\(num) \(street) \(zip)"
        }
        
            //MARK: -incidentLocal-
        if let fjIncidentLocal = self.incidentLocalDetails {
            if let incidentBattalion = fjIncidentLocal.incidentBattalion {
                fjIncidentR["incidentBattalion"] = incidentBattalion
            }
            if let incidentDivision = fjIncidentLocal.incidentDivision {
                fjIncidentR["incidentDivision"] = incidentDivision
            }
            if let incidentFireDistrict = fjIncidentLocal.incidentFireDistrict {
                fjIncidentR["incidentFireDistrict"] = incidentFireDistrict
            }
            if let incidentLocalType = fjIncidentLocal.incidentLocalType {
                fjIncidentR["incidentLocalType"] = incidentLocalType
            }
        }
        
            //MARK: -IncidentMap-
        if let fjIncidentMap = self.incidentMapDetails {
            if let incidentLatitude = fjIncidentMap.incidentLatitude {
                fjIncidentR["incidentLatitude"] = incidentLatitude
            }
            if let incidentLongitude = fjIncidentMap.incidentLongitude {
                fjIncidentR["incidentLongitude"] = incidentLongitude
            }
            if let stagingLatitude = fjIncidentMap.stagingLatitude {
                fjIncidentR["stagingLatitude"] = stagingLatitude
            }
            if let stagingLongitude = fjIncidentMap.stagingLongitude {
                fjIncidentR["stagingLongitude"] = stagingLongitude
            }
        }
        
            // MARK: -IncidentNFIRS-
        if  let fjIncidentNFIRS = self.incidentNFIRSDetails {
            if let fireStationState = fjIncidentNFIRS.fireStationState {
                fjIncidentR["fireStationState"] = fireStationState
            }
            if let incidentActionsTakenAdditionalThree = fjIncidentNFIRS.incidentActionsTakenAdditionalThree {
                fjIncidentR["incidentActionsTakenAdditionalThree"] = incidentActionsTakenAdditionalThree
            }
            if let incidentActionsTakenAdditionalTwo = fjIncidentNFIRS.incidentActionsTakenAdditionalTwo {
                fjIncidentR["incidentActionsTakenAdditionalTwo"] = incidentActionsTakenAdditionalTwo
            }
            if let incidentActionsTakenPrimary = fjIncidentNFIRS.incidentActionsTakenPrimary {
                fjIncidentR["incidentActionsTakenPrimary"] = incidentActionsTakenPrimary
            }
            if let incidentAidGiven = fjIncidentNFIRS.incidentAidGiven {
                fjIncidentR["incidentAidGiven"] = incidentAidGiven
            }
            if let incidentAidGivenFDID = fjIncidentNFIRS.incidentAidGivenFDID {
                fjIncidentR["incidentAidGivenFDID"] = incidentAidGivenFDID
            }
            if let incidentAidGivenIncidentNumber = fjIncidentNFIRS.incidentAidGivenIncidentNumber {
                fjIncidentR["incidentAidGivenIncidentNumber"] = incidentAidGivenIncidentNumber
            }
            if let incidentAidGivenNone = fjIncidentNFIRS.incidentAidGivenNone {
                fjIncidentR["incidentAidGivenNone"] = incidentAidGivenNone
            }
            if let incidentAidGivenState = fjIncidentNFIRS.incidentAidGivenState {
                fjIncidentR["incidentAidGivenState"] = incidentAidGivenState
            }
            if let incidentCasualtiesCivilianDeaths = fjIncidentNFIRS.incidentCasualtiesCivilianDeaths {
                fjIncidentR["incidentCasualtiesCivilianDeaths"] = incidentCasualtiesCivilianDeaths
            }
            if let incidentCasualtiesCivilianInjuries = fjIncidentNFIRS.incidentCasualtiesCivilianInjuries {
                fjIncidentR["incidentCasualtiesCivilianInjuries"] = incidentCasualtiesCivilianInjuries
            }
            if let incidentCasualtiesFireDeaths = fjIncidentNFIRS.incidentCasualtiesFireDeaths {
                fjIncidentR["incidentCasualtiesFireDeaths"] = incidentCasualtiesFireDeaths
            }
            if let incidentCasualtiesFireInjuries = fjIncidentNFIRS.incidentCasualtiesFireInjuries {
                fjIncidentR["incidentCasualtiesFireInjuries"] = incidentCasualtiesFireInjuries
            }
            if let incidentCasualtiesServiceDeaths = fjIncidentNFIRS.incidentCasualtiesServiceDeaths {
                fjIncidentR["incidentCasualtiesServiceDeaths"] = incidentCasualtiesServiceDeaths
            }
            if let incidentCasualtitesServideInjuries = fjIncidentNFIRS.incidentCasualtitesServideInjuries {
                fjIncidentR["incidentCasualtitesServideInjuries"] = incidentCasualtitesServideInjuries
            }
            if let incidentDetectorChosen = fjIncidentNFIRS.incidentDetectorChosen {
                fjIncidentR["incidentDetectorChosen"] = incidentDetectorChosen
            }
            if let incidentExposure = fjIncidentNFIRS.incidentExposure {
                fjIncidentR["incidentExposure"] = incidentExposure
            }
            if let incidentFDID = fjIncidentNFIRS.incidentFDID {
                fjIncidentR["incidentFDID"] = incidentFDID
            }
            if let incidentFDID1 = fjIncidentNFIRS.incidentFDID1 {
                fjIncidentR["incidentFDID1"] = incidentFDID1
            }
            if let incidentFireStation = fjIncidentNFIRS.incidentFireStation {
                fjIncidentR["incidentFireStation"] = incidentFireStation
            }
            if let incidentHazMat = fjIncidentNFIRS.incidentHazMat {
                fjIncidentR["incidentHazMat"] = incidentHazMat
            }
            if let incidentLocation = fjIncidentNFIRS.incidentLocation {
                fjIncidentR["incidentNFIRSLocation"] = incidentLocation
            }
            if let incidentPlatoon = fjIncidentNFIRS.incidentPlatoon {
                fjIncidentR["incidentPlatoon"] = incidentPlatoon
            }
            if let incidentPropertyNone = fjIncidentNFIRS.incidentPropertyNone {
                fjIncidentR["incidentPropertyNone"] = incidentPropertyNone
            }
            if let incidentPropertyOutside = fjIncidentNFIRS.incidentPropertyOutside {
                fjIncidentR["incidentPropertyOutside"] = incidentPropertyOutside
            }
            if let incidentPropertyOutsideNumber = fjIncidentNFIRS.incidentPropertyOutsideNumber {
                fjIncidentR["incidentPropertyOutsideNumber"] = incidentPropertyOutsideNumber
            }
            if let incidentPropertyStructure = fjIncidentNFIRS.incidentPropertyStructure {
                fjIncidentR["incidentPropertyStructure"] = incidentPropertyStructure
            }
            if let incidentPropertyStructureNumber = fjIncidentNFIRS.incidentPropertyStructureNumber {
                fjIncidentR["incidentPropertyStructureNumber"] = incidentPropertyStructureNumber
            }
            if let incidentPropertyUse = fjIncidentNFIRS.incidentPropertyUse {
                fjIncidentR["incidentPropertyUse"] = incidentPropertyUse
            }
            if let incidentPropertyUseNone = fjIncidentNFIRS.incidentPropertyUseNone {
                fjIncidentR["incidentPropertyUseNone"] = incidentPropertyUseNone
            }
            if let incidentPropertyUseNumber = fjIncidentNFIRS.incidentPropertyUseNumber {
                fjIncidentR["incidentPropertyUseNumber"] = incidentPropertyUseNumber
            }
            if let incidentResourceCheck = fjIncidentNFIRS.incidentResourceCheck {
                fjIncidentR["incidentResourceCheck"] = incidentResourceCheck
            }
            if let incidentResourcesEMSApparatus = fjIncidentNFIRS.incidentResourcesEMSApparatus {
                fjIncidentR["incidentResourcesEMSApparatus"] = incidentResourcesEMSApparatus
            }
            if let incidentResourcesEMSPersonnel = fjIncidentNFIRS.incidentResourcesEMSPersonnel {
                fjIncidentR["incidentResourcesEMSPersonnel"] = incidentResourcesEMSPersonnel
            }
            if let incidentResourcesOtherApparatus = fjIncidentNFIRS.incidentResourcesOtherApparatus {
                fjIncidentR["incidentResourcesOtherApparatus"] = incidentResourcesOtherApparatus
            }
            if let incidentResourcesOtherPersonnel = fjIncidentNFIRS.incidentResourcesOtherPersonnel {
                fjIncidentR["incidentResourcesOtherPersonnel"] = incidentResourcesOtherPersonnel
            }
            if let incidentResourcesSuppressionPersonnel = fjIncidentNFIRS.incidentResourcesSuppressionPersonnel {
                fjIncidentR["incidentResourcesSuppressionPersonnel"] = incidentResourcesSuppressionPersonnel
            }
            if let incidentResourcesSupressionApparatus = fjIncidentNFIRS.incidentResourcesSupressionApparatus {
                fjIncidentR["incidentResourcesSupressionApparatus"] = incidentResourcesSupressionApparatus
            }
            if let incidentTypeNumberNFRIS = fjIncidentNFIRS.incidentTypeNumberNFRIS {
                fjIncidentR["incidentTypeNumberNFRIS"] = incidentTypeNumberNFRIS
            }
            if let incidentTypeTextNFRIS = fjIncidentNFIRS.incidentTypeTextNFRIS {
                fjIncidentR["incidentTypeTextNFRIS"] = incidentTypeTextNFRIS
            }
            if let lossesContentDollars = fjIncidentNFIRS.lossesContentDollars {
                fjIncidentR["lossesContentDollars"] = lossesContentDollars
            }
            if let lossesPropertyDollars = fjIncidentNFIRS.lossesPropertyDollars {
                fjIncidentR["lossesPropertyDollars"] = lossesPropertyDollars
            }
            if let mixedUsePropertyType = fjIncidentNFIRS.mixedUsePropertyType {
                fjIncidentR["mixedUsePropertyType"] = mixedUsePropertyType
            }
            if let nfirsChangeDescription = fjIncidentNFIRS.nfirsChangeDescription {
                fjIncidentR["nfirsChangeDescription"] = nfirsChangeDescription
            }
            if let nfirsSectionOneSegment = fjIncidentNFIRS.nfirsSectionOneSegment {
                fjIncidentR["nfirsSectionOneSegment"] = nfirsSectionOneSegment
            }
            if let shiftAlarm = fjIncidentNFIRS.shiftAlarm {
                fjIncidentR["shiftAlarm"] = shiftAlarm
            }
            if let shiftDistrict = fjIncidentNFIRS.shiftDistrict {
                fjIncidentR["shiftDistrict"] = shiftDistrict
            }
            if let shiftOrPlatoon = fjIncidentNFIRS.shiftOrPlatoon {
                fjIncidentR["shiftOrPlatoon"] = shiftOrPlatoon
            }
            if let specialStudyID = fjIncidentNFIRS.specialStudyID {
                fjIncidentR["specialStudyID"] = specialStudyID
            }
            if let specialStudyValue = fjIncidentNFIRS.specialStudyValue {
                fjIncidentR["specialStudyValue"] = specialStudyValue
            }
            if let valueContentDollars = fjIncidentNFIRS.valueContentDollars {
                fjIncidentR["valueContentDollars"] = valueContentDollars
            }
            
            fjIncidentR["incidentHazMatNone"] = Int(fjIncidentNFIRS.incidentHazMatNone)
            fjIncidentR["valuePropertyDollars"] = fjIncidentNFIRS.valuePropertyDollars
            fjIncidentR["lossesContentNone"] = Int(fjIncidentNFIRS.lossesContentNone)
            fjIncidentR["lossesPropertyNone"] = Int(fjIncidentNFIRS.lossesPropertyNone)
            fjIncidentR["mixedUsePropertyNone"] = Int(fjIncidentNFIRS.mixedUsePropertyNone)
            fjIncidentR["propertyUseNone"] = Int(fjIncidentNFIRS.propertyUseNone)
            fjIncidentR["resourceCountsIncludeAidReceived"] = Int(fjIncidentNFIRS.resourceCountsIncludeAidReceived)
            fjIncidentR["skipSectionF"] = Int(fjIncidentNFIRS.skipSectionF)
            fjIncidentR["valueContentsNone"] = Int(fjIncidentNFIRS.valueContentsNone)
            fjIncidentR["valuePropertyNone"] = Int(fjIncidentNFIRS.valuePropertyNone)
            fjIncidentR["incidentCasualtiesNone"] = Int(fjIncidentNFIRS.incidentCasualtiesNone)
            
        }
        
            // MARK: -IncidentNFIRSKSec-
        if let fjIncidentNFIRSKSec = self.incidentNFIRSKSecDetails {
            if let kOwnerAptSuiteRoom = fjIncidentNFIRSKSec.kOwnerAptSuiteRoom {
                fjIncidentR["kOwnerAptSuiteRoom"] = kOwnerAptSuiteRoom
            }
            if let kOwnerAreaCode = fjIncidentNFIRSKSec.kOwnerAreaCode {
                fjIncidentR["kOwnerAreaCode"] = kOwnerAreaCode
            }
            if let kOwnerBusinessName = fjIncidentNFIRSKSec.kOwnerBusinessName {
                fjIncidentR["kOwnerBusinessName"] = kOwnerBusinessName
            }
            if let kOwnerCity = fjIncidentNFIRSKSec.kOwnerCity {
                fjIncidentR["kOwnerCity"] = kOwnerCity
            }
            if let kOwnerFirstName = fjIncidentNFIRSKSec.kOwnerFirstName {
                fjIncidentR["kOwnerFirstName"] = kOwnerFirstName
            }
            if let kOwnerLastName = fjIncidentNFIRSKSec.kOwnerLastName {
                fjIncidentR["kOwnerLastName"] = kOwnerLastName
            }
            if let kOwnerMI = fjIncidentNFIRSKSec.kOwnerMI {
                fjIncidentR["kOwnerMI"] = kOwnerMI
            }
            if let kOwnerNamePrefix = fjIncidentNFIRSKSec.kOwnerNamePrefix {
                fjIncidentR["kOwnerNamePrefix"] = kOwnerNamePrefix
            }
            if let kOwnerNameSuffix = fjIncidentNFIRSKSec.kOwnerNameSuffix {
                fjIncidentR["kOwnerNameSuffix"] = kOwnerNameSuffix
            }
            if let kOwnerPhoneLastFour = fjIncidentNFIRSKSec.kOwnerPhoneLastFour {
                fjIncidentR["kOwnerPhoneLastFour"] = kOwnerPhoneLastFour
            }
            if let kOwnerPhonePrefix = fjIncidentNFIRSKSec.kOwnerPhonePrefix {
                fjIncidentR["kOwnerPhonePrefix"] = kOwnerPhonePrefix
            }
            if let kOwnerPOBox = fjIncidentNFIRSKSec.kOwnerPOBox {
                fjIncidentR["kOwnerPOBox"] = kOwnerPOBox
            }
            if let kOwnerState = fjIncidentNFIRSKSec.kOwnerState {
                fjIncidentR["kOwnerState"] = kOwnerState
            }
            if let kOwnerStreetHyway = fjIncidentNFIRSKSec.kOwnerStreetHyway {
                fjIncidentR["kOwnerStreetHyway"] = kOwnerStreetHyway
            }
            if let kOwnerStreetNumber = fjIncidentNFIRSKSec.kOwnerStreetNumber {
                fjIncidentR["kOwnerStreetNumber"] = kOwnerStreetNumber
            }
            if let kOwnerStreetPrefix = fjIncidentNFIRSKSec.kOwnerStreetPrefix {
                fjIncidentR["kOwnerStreetPrefix"] = kOwnerStreetPrefix
            }
            if let kOwnerStreetSuffix = fjIncidentNFIRSKSec.kOwnerStreetSuffix {
                fjIncidentR["kOwnerStreetSuffix"] = kOwnerStreetSuffix
            }
            if let kOwnerStreetType = fjIncidentNFIRSKSec.kOwnerStreetType {
                fjIncidentR["kOwnerStreetType"] = kOwnerStreetType
            }
            if let kOwnerZip = fjIncidentNFIRSKSec.kOwnerZip {
                fjIncidentR["kOwnerZip"] = kOwnerZip
            }
            if let kOwnerZipPlusFour = fjIncidentNFIRSKSec.kOwnerZipPlusFour {
                fjIncidentR["kOwnerZipPlusFour"] = kOwnerZipPlusFour
            }
            if let kPersonAppSuiteRoom = fjIncidentNFIRSKSec.kPersonAppSuiteRoom {
                fjIncidentR["kPersonAppSuiteRoom"] = kPersonAppSuiteRoom
            }
            if let kPersonAreaCode = fjIncidentNFIRSKSec.kPersonAreaCode {
                fjIncidentR["kPersonAreaCode"] = kPersonAreaCode
            }
            if let kPersonBusinessName = fjIncidentNFIRSKSec.kPersonBusinessName {
                fjIncidentR["kPersonBusinessName"] = kPersonBusinessName
            }
            if let kPersonCity = fjIncidentNFIRSKSec.kPersonCity {
                fjIncidentR["kPersonCity"] = kPersonCity
            }
            if let kPersonFirstName = fjIncidentNFIRSKSec.kPersonFirstName {
                fjIncidentR["kPersonFirstName"] = kPersonFirstName
            }
            if let kPersonGender = fjIncidentNFIRSKSec.kPersonGender {
                fjIncidentR["kPersonGender"] = kPersonGender
            }
            if let kPersonLastName = fjIncidentNFIRSKSec.kPersonLastName {
                fjIncidentR["kPersonLastName"] = kPersonLastName
            }
            if let kPersonMI = fjIncidentNFIRSKSec.kPersonMI {
                fjIncidentR["kPersonMI"] = kPersonMI
            }
            if let kPersonNameSuffix = fjIncidentNFIRSKSec.kPersonNameSuffix {
                fjIncidentR["kPersonNameSuffix"] = kPersonNameSuffix
            }
            if let kPersonPhoneLastFour = fjIncidentNFIRSKSec.kPersonPhoneLastFour {
                fjIncidentR["kPersonPhoneLastFour"] = kPersonPhoneLastFour
            }
            if let kPersonPhonePrefix = fjIncidentNFIRSKSec.kPersonPhonePrefix {
                fjIncidentR["kPersonPhonePrefix"] = kPersonPhonePrefix
            }
            if let kPersonPOBox = fjIncidentNFIRSKSec.kPersonPOBox {
                fjIncidentR["kPersonPOBox"] = kPersonPOBox
            }
            if let kPersonPrefix = fjIncidentNFIRSKSec.kPersonPrefix {
                fjIncidentR["kPersonPrefix"] = kPersonPrefix
            }
            if let kPersonState = fjIncidentNFIRSKSec.kPersonState {
                fjIncidentR["kPersonState"] = kPersonState
            }
            if let kPersonStreetHyway = fjIncidentNFIRSKSec.kPersonStreetHyway {
                fjIncidentR["kPersonStreetHyway"] = kPersonStreetHyway
            }
            if let kPersonStreetNum = fjIncidentNFIRSKSec.kPersonStreetNum {
                fjIncidentR["kPersonStreetNum"] = kPersonStreetNum
            }
            if let kPersonStreetSuffix = fjIncidentNFIRSKSec.kPersonStreetSuffix {
                fjIncidentR["kPersonStreetSuffix"] = kPersonStreetSuffix
            }
            if let kPersonStreetType = fjIncidentNFIRSKSec.kPersonStreetType {
                fjIncidentR["kPersonStreetType"] = kPersonStreetType
            }
            if let kPersonZipCode = fjIncidentNFIRSKSec.kPersonZipCode {
                fjIncidentR["kPersonZipCode"] = kPersonZipCode
            }
            if let kPersonZipPlus4 = fjIncidentNFIRSKSec.kPersonZipPlus4 {
                fjIncidentR["kPersonZipPlus4"] = kPersonZipPlus4
            }
            
            fjIncidentR["kOwnerCheckBox"] = Int(fjIncidentNFIRSKSec.kOwnerCheckBox)
            fjIncidentR["kOwnerSameAsPerson"] = Int(fjIncidentNFIRSKSec.kOwnerSameAsPerson)
            fjIncidentR["kPersonCheckBox"] = Int(fjIncidentNFIRSKSec.kPersonCheckBox)
            fjIncidentR["kPersonMoreThanOne"] = Int(fjIncidentNFIRSKSec.kPersonMoreThanOne)
        }
        
        
        
        if let fjIncidentNFIRSsecL = self.sectionLDetails {
            fjIncidentR["incidentNFIRSSecLNotes"] = fjIncidentNFIRSsecL.lRemarks as? String
            fjIncidentR["incidentNFIRSSecLMoreRemarks"] = Int(fjIncidentNFIRSsecL.moreRemarks)
        }
        
        if let fjIncidentNFIRSsecM = self.sectionMDetails {
            if let memberAssignment = fjIncidentNFIRSsecM.memberAssignment {
                fjIncidentR["memberAssignment"] = memberAssignment
            }
            if let memberDate = fjIncidentNFIRSsecM.memberDate {
                fjIncidentR["memberDate"] = memberDate
            }
            if let memberMakingReportID = fjIncidentNFIRSsecM.memberMakingReportID {
                fjIncidentR["memberMakingReportID"] = memberMakingReportID
            }
            if let memberRankPosition = fjIncidentNFIRSsecM.memberRankPosition {
                fjIncidentR["memberRankPosition"] = memberRankPosition
            }
            if let officerAssignment = fjIncidentNFIRSsecM.officerAssignment {
                fjIncidentR["officerAssignment"] = officerAssignment
            }
            if let officerDate = fjIncidentNFIRSsecM.officerDate {
                fjIncidentR["officerDate"] = officerDate
            }
            if let officerInChargeID = fjIncidentNFIRSsecM.officerInChargeID {
                fjIncidentR["officerInChargeID"] = officerInChargeID
            }
            if let officerRankPosition = fjIncidentNFIRSsecM.officerRankPosition {
                fjIncidentR["officerRankPosition"] = officerRankPosition
            }
            if let signatureMember = fjIncidentNFIRSsecM.signatureMember {
                fjIncidentR["signatureMember"] = signatureMember
            }
            if let signatureOfficer = fjIncidentNFIRSsecM.signatureOfficer {
                fjIncidentR["signatureOfficer"] = signatureOfficer
            }
            
            fjIncidentR["memberSameAsOfficer"] = Int(fjIncidentNFIRSsecM.memberSameAsOfficer)
        }
        
        
            // MARK: -IncidentNotes-
        if let fjIncidentNotes = self.incidentNotesDetails {
            fjIncidentR["incidentSummaryNotes"] = fjIncidentNotes.incidentSummaryNotes as? String
            fjIncidentR["incidentNote"] = fjIncidentNotes.incidentNote
        }
        
            //        MARK: -POV NOTES FOR INCIDENT
        if let fjpPersonalJournalReference = self.fjpPersonalJournalReference {
            fjIncidentR["fjpPersonalJournalReference"] = fjpPersonalJournalReference
        }
        
            //        MARK: -IncidentTimer-
        if let fjIncidentTimer = self.incidentTimerDetails {
            
            fjIncidentR["arrivalSameDate"] = Int(fjIncidentTimer.arrivalSameDate)
            fjIncidentR["controlledSameDate"] = Int(fjIncidentTimer.controlledSameDate)
            fjIncidentR["lastUnitSameDate"] = Int(fjIncidentTimer.lastUnitSameDate)
            
            if let incidentAlarmNotes = fjIncidentTimer.incidentAlarmNotes as? String {
                fjIncidentR["incidentAlarmNotes"] = incidentAlarmNotes
            }
            if let incidentArrivalNotes = fjIncidentTimer.incidentArrivalNotes as? String {
                fjIncidentR["incidentArrivalNotes"] = incidentArrivalNotes
            }
            if let incidentControlledNotes = fjIncidentTimer.incidentControlledNotes as? String {
                fjIncidentR["incidentControlledNotes"] = incidentControlledNotes
            }
            if let incidentLastUnitClearedNotes = fjIncidentTimer.incidentLastUnitClearedNotes as? String {
                fjIncidentR["incidentLastUnitClearedNotes"] = incidentLastUnitClearedNotes
            }
            
            if let incidentAlarmCombinedDate = fjIncidentTimer.incidentAlarmCombinedDate {
                fjIncidentR["incidentAlarmCombinedDate"] = incidentAlarmCombinedDate
            }
            if let incidentAlarmDateTime = fjIncidentTimer.incidentAlarmDateTime {
                fjIncidentR["incidentAlarmDateTime"] = incidentAlarmDateTime
            }
            if let incidentAlarmDay = fjIncidentTimer.incidentAlarmDay {
                fjIncidentR["incidentAlarmDay"] = incidentAlarmDay
            }
            if let incidentAlarmHours = fjIncidentTimer.incidentAlarmHours {
                fjIncidentR["incidentAlarmHours"] = incidentAlarmHours
            }
            if let incidentAlarmMinutes = fjIncidentTimer.incidentAlarmMinutes {
                fjIncidentR["incidentAlarmMinutes"] = incidentAlarmMinutes
            }
            if let incidentAlarmMonth = fjIncidentTimer.incidentAlarmMonth {
                fjIncidentR["incidentAlarmMonth"] = incidentAlarmMonth
            }
            if let incidentAlarmYear = fjIncidentTimer.incidentAlarmYear {
                fjIncidentR["incidentAlarmYear"] = incidentAlarmYear
            }
            if let incidentArrivalCombinedDate = fjIncidentTimer.incidentArrivalCombinedDate {
                fjIncidentR["incidentArrivalCombinedDate"] = incidentArrivalCombinedDate
            }
            if let incidentArrivalDateTime = fjIncidentTimer.incidentArrivalDateTime {
                fjIncidentR["incidentArrivalDateTime"] = incidentArrivalDateTime
            }
            if let incidentArrivalDay = fjIncidentTimer.incidentArrivalDay {
                fjIncidentR["incidentArrivalDay"] = incidentArrivalDay
            }
            if let incidentArrivalHours = fjIncidentTimer.incidentArrivalHours {
                fjIncidentR["incidentArrivalHours"] = incidentArrivalHours
            }
            if let incidentArrivalMinutes = fjIncidentTimer.incidentArrivalMinutes {
                fjIncidentR["incidentArrivalMinutes"] = incidentArrivalMinutes
            }
            if let incidentArrivalMonth = fjIncidentTimer.incidentArrivalMonth {
                fjIncidentR["incidentArrivalMonth"] = incidentArrivalMonth
            }
            if let incidentArrivalYear = fjIncidentTimer.incidentArrivalYear {
                fjIncidentR["incidentArrivalYear"] = incidentArrivalYear
            }
            if let incidentControlledCombinedDate = fjIncidentTimer.incidentControlledCombinedDate {
                fjIncidentR["incidentControlledCombinedDate"] = incidentControlledCombinedDate
            }
            if let incidentControlDateTime = fjIncidentTimer.incidentControlDateTime {
                fjIncidentR["incidentControlDateTime"] = incidentControlDateTime
            }
            if let incidentControlledDay = fjIncidentTimer.incidentControlledDay {
                fjIncidentR["incidentControlledDay"] = incidentControlledDay
            }
            if let incidentControlledHours = fjIncidentTimer.incidentControlledHours {
                fjIncidentR["incidentControlledHours"] = incidentControlledHours
            }
            if let incidentControlledMinutes = fjIncidentTimer.incidentControlledMinutes {
                fjIncidentR["incidentControlledMinutes"] = incidentControlledMinutes
            }
            if let incidentControlledMonth = fjIncidentTimer.incidentControlledMonth {
                fjIncidentR["incidentControlledMonth"] = incidentControlledMonth
            }
            if let incidentControlledYear = fjIncidentTimer.incidentControlledYear {
                fjIncidentR["incidentControlledYear"] = incidentControlledYear
            }
            if let incidentElapsedTime = fjIncidentTimer.incidentElapsedTime {
                fjIncidentR["incidentElapsedTime"] = incidentElapsedTime
            }
            if let incidentLastUnitCalledCombinedDate = fjIncidentTimer.incidentLastUnitCalledCombinedDate {
                fjIncidentR["incidentLastUnitCalledCombinedDate"] = incidentLastUnitCalledCombinedDate
            }
            if let incidentLastUnitDateTime = fjIncidentTimer.incidentLastUnitDateTime {
                fjIncidentR["incidentLastUnitDateTime"] = incidentLastUnitDateTime
            }
            if let incidentLastUnitCalledDay = fjIncidentTimer.incidentLastUnitCalledDay {
                fjIncidentR["incidentLastUnitCalledDay"] = incidentLastUnitCalledDay
            }
            if let incidentLastUnitCalledHours = fjIncidentTimer.incidentLastUnitCalledHours {
                fjIncidentR["incidentLastUnitCalledHours"] = incidentLastUnitCalledHours
            }
            if let incidentLastUnitCalledMinutes = fjIncidentTimer.incidentLastUnitCalledMinutes {
                fjIncidentR["incidentLastUnitCalledMinutes"] = incidentLastUnitCalledMinutes
            }
            if let incidentLastUnitCalledMonth = fjIncidentTimer.incidentLastUnitCalledMonth {
                fjIncidentR["incidentLastUnitCalledMonth"] = incidentLastUnitCalledMonth
            }
            if let incidentLastUnitCalledYear = fjIncidentTimer.incidentLastUnitCalledYear {
                fjIncidentR["incidentLastUnitCalledYear"] = incidentLastUnitCalledYear
            }
            if let incidentStartClockCombinedDate = fjIncidentTimer.incidentStartClockCombinedDate {
                fjIncidentR["incidentStartClockCombinedDate"] = incidentStartClockCombinedDate
            }
            if let incidentStartClockDateTime = fjIncidentTimer.incidentStartClockDateTime {
                fjIncidentR["incidentStartClockDateTime"] = incidentStartClockDateTime
            }
            if let incidentStartClockDay = fjIncidentTimer.incidentStartClockDay {
                fjIncidentR["incidentStartClockDay"] = incidentStartClockDay
            }
            if let incidentStartClockHours = fjIncidentTimer.incidentStartClockHours {
                fjIncidentR["incidentStartClockHours"] = incidentStartClockHours
            }
            if let incidentStartClockMinutes = fjIncidentTimer.incidentStartClockMinutes {
                fjIncidentR["incidentStartClockMinutes"] = incidentStartClockMinutes
            }
            if let incidentStartClockMonth = fjIncidentTimer.incidentStartClockMonth {
                fjIncidentR["incidentStartClockMonth"] = incidentStartClockMonth
            }
            if let incidentStartClockSeconds = fjIncidentTimer.incidentStartClockSeconds {
                fjIncidentR["incidentStartClockSeconds"] = incidentStartClockSeconds
            }
            if let incidentStartClockYear = fjIncidentTimer.incidentStartClockYear {
                fjIncidentR["incidentStartClockYear"] = incidentStartClockYear
            }
            if let incidentStopClockCombinedDate = fjIncidentTimer.incidentStopClockCombinedDate {
                fjIncidentR["incidentStopClockCombinedDate"] = incidentStopClockCombinedDate
            }
            if let incidentStopClockDateTime = fjIncidentTimer.incidentStopClockDateTime {
                fjIncidentR["incidentStopCloudDateTime"] = incidentStopClockDateTime
            }
            if let incidentStopClockDay = fjIncidentTimer.incidentStopClockDay {
                fjIncidentR["incidentStopClockDay"] = incidentStopClockDay
            }
            if let incidentStopClockHours = fjIncidentTimer.incidentStopClockHours {
                fjIncidentR["incidentStopClockHours"] = incidentStopClockHours
            }
            if let incidentStopClockMinutes = fjIncidentTimer.incidentStopClockMinutes {
                fjIncidentR["incidentStopClockMinutes"] = incidentStopClockMinutes
            }
            if let incidentStopClockMonth = fjIncidentTimer.incidentStopClockMonth {
                fjIncidentR["incidentStopClockMonth"] = incidentStopClockMonth
            }
            if let incidentStopClockSeconds = fjIncidentTimer.incidentStopClockSeconds {
                fjIncidentR["incidentStopClockSeconds"] = incidentStopClockSeconds
            }
            if let incidentStopClockYear = fjIncidentTimer.incidentStopClockYear {
                fjIncidentR["incidentStopClockYear"] = incidentStopClockYear
            }
        }
        
            //        MARK: -ActionsTaken-
        if let fjActionsTaken = self.actionsTakenDetails {
            if let additionalThree = fjActionsTaken.additionalThree {
                fjIncidentR["additionalThree"] = additionalThree
            }
            if let additionalThreeNumber = fjActionsTaken.additionalThreeNumber {
                fjIncidentR["additionalThreeNumber"] = additionalThreeNumber
            }
            if let additionalTwo = fjActionsTaken.additionalTwo {
                fjIncidentR["additionalTwo"] = additionalTwo
            }
            if let additionalTwoNumber = fjActionsTaken.additionalTwoNumber {
                fjIncidentR["additionalTwoNumber"] = additionalTwoNumber
            }
            if let primaryAction = fjActionsTaken.primaryAction {
                fjIncidentR["primaryAction"] = primaryAction
            }
            if let primaryActionNumber = fjActionsTaken.primaryActionNumber {
                fjIncidentR["primaryActionNumber"] = primaryActionNumber
            }
        }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: incidentRef, requiringSecureCoding: true)
            self.anIncidentReferenceSC = data as NSObject
            
        } catch {
            print("incidentRef to data failed line 514 Incident+Custom")
        }
        
        saveToCD()
        
        return fjIncidentR
        
    }
    
    func modifyIncidentForCloud(ckRecord:CKRecord)->CKRecord {
        let fjIncidentR = ckRecord
        
        fjIncidentR["incidentBackedUp"] =  true
        fjIncidentR["theEntity"] = "Incident"
        if let guid = self.fjpIncGuidForReference {
            fjIncidentR["fjpIncGuidForReference"] = guid
        }
        if let dateSearch = self.fjpIncidentDateSearch {
            fjIncidentR["fjpIncidentDateSearch"] = dateSearch
        }
        if let modDate = self.fjpIncidentModifiedDate {
            fjIncidentR["fjpIncidentModifiedDate"] = modDate
        }
        
        if let form = self.formType {
            fjIncidentR["formType"] =  form
        }
        if let incidentCreationDate = self.incidentCreationDate {
            fjIncidentR["incidentCreationDate"] = incidentCreationDate
        }
        if let incidentDate = self.incidentDate {
            fjIncidentR["incidentDate"] = incidentDate
        }
        if let incidentDateSearch = self.incidentDateSearch {
            fjIncidentR["incidentDateSearch"] = incidentDateSearch
        }
        if let incidentDayOfWeek = self.incidentDayOfWeek {
            fjIncidentR["incidentDayOfWeek"] = incidentDayOfWeek
        }
        if let incidentDayOfYear = self.incidentDayOfYear {
            fjIncidentR["incidentDayOfYear"] = incidentDayOfYear
        }
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
        if self.arsonInvestigation {
            fjIncidentR["arsonInvestigation"] = 1
        } else {
            fjIncidentR["arsonInvestigation"] = 0
        }
        if self.incidentCancel {
            fjIncidentR["incidentCancel"] = 1
        } else {
            fjIncidentR["incidentCancel"] = 0
        }
        if let incidentEntryTypeImageName = self.incidentEntryTypeImageName {
            fjIncidentR["incidentEntryTypeImageName"] = incidentEntryTypeImageName
        }
        
        if let incidentModDate = self.incidentModDate {
            fjIncidentR["incidentModDate"] = incidentModDate
        }
        if let incidentNFIRSCompleted = self.incidentNFIRSCompleted {
            fjIncidentR["incidentNFIRSCompleted"] = incidentNFIRSCompleted
        }
        if let incidentNFIRSCompletedDate = self.incidentNFIRSCompletedDate {
            fjIncidentR["incidentNFIRSCompletedDate"] = incidentNFIRSCompletedDate
        }
        if let incidentNFIRSDataComplete = self.incidentNFIRSDataComplete {
            fjIncidentR["incidentNFIRSDataComplete"] = incidentNFIRSDataComplete
        }
        if let incidentNFIRSDataDate = self.incidentNFIRSDataDate {
            fjIncidentR["incidentNFIRSDataDate"] = incidentNFIRSDataDate
        }
        if let incidentNFIRSDataSaved = self.incidentNFIRSDataSaved {
            fjIncidentR["incidentNFIRSDataSaved"] = incidentNFIRSDataSaved
        }
        if let incidentNumber = self.incidentNumber {
            fjIncidentR["incidentNumber"] = incidentNumber
        }
        
        if let incidentSearchDate = self.incidentSearchDate {
            fjIncidentR["incidentSearchDate"] = incidentSearchDate
        }
        if let incidentTime = self.incidentTime {
            fjIncidentR["incidentTime"] = incidentTime
        }
        if let incidentType = self.incidentType {
            fjIncidentR["incidentType"] = incidentType
        }
        if let situationIncidentImage = self.situationIncidentImage {
            fjIncidentR["situationIncidentImage"] = situationIncidentImage
        }
        if let tempIncidentApparatus = self.tempIncidentApparatus {
            fjIncidentR["tempIncidentApparatus"] = tempIncidentApparatus
        }
        if let tempIncidentAssignment = self.tempIncidentAssignment {
            fjIncidentR["tempIncidentAssignment"] = tempIncidentAssignment
        }
        if let tempIncidentFireStation = self.tempIncidentFireStation {
            fjIncidentR["tempIncidentFireStation"] = tempIncidentFireStation
        }
        if let tempIncidentPlatoon = self.tempIncidentPlatoon {
            fjIncidentR["tempIncidentPlatoon"] = tempIncidentPlatoon
        }
        if let ics214Effort = self.ics214Effort {
            fjIncidentR["ics214Effort"] = ics214Effort
        }
        if let ics214MasterGuid = self.ics214MasterGuid {
            fjIncidentR["ics214MasterGuid"] = ics214MasterGuid
        }
        fjIncidentR["arsonInvestigation"] = Int(self.arsonInvestigation)
        
        
        if let fjuSections = self.formDetails {
            fjIncidentR["sectionA"] = Int(fjuSections.sectionA)
            fjIncidentR["sectionB"] = Int(fjuSections.sectionB )
            fjIncidentR["sectionC"] = Int(fjuSections.sectionC)
            fjIncidentR["sectionD"] = Int(fjuSections.sectionD)
            fjIncidentR["sectionE"] = Int(fjuSections.sectionE)
            fjIncidentR["sectionF"] = Int(fjuSections.sectionF)
            fjIncidentR["sectionG"] = Int(fjuSections.sectionG)
            fjIncidentR["sectionH"] = Int(fjuSections.sectionH)
            fjIncidentR["sectionI"] = Int(fjuSections.sectionI)
            fjIncidentR["sectionJ"] = Int(fjuSections.sectionJ)
            fjIncidentR["sectionK"] = Int(fjuSections.sectionK)
            fjIncidentR["sectionL"] = Int(fjuSections.sectionL)
            fjIncidentR["sectionM"] = Int(fjuSections.sectionM)
        }
        
        if let fjIncidentAddress = self.incidentAddressDetails {
            if let appSuiteRoom = fjIncidentAddress.appSuiteRoom {
                fjIncidentR["appSuiteRoom"] = appSuiteRoom
            }
            if let censusTract = fjIncidentAddress.censusTract {
                fjIncidentR["censusTract"] = censusTract
            }
            if let censusTract2 = fjIncidentAddress.censusTract2 {
                fjIncidentR["censusTract2"] = censusTract2
            }
            if let city = fjIncidentAddress.city {
                fjIncidentR["city"] = city
            }
            if let crossStreet = fjIncidentAddress.crossStreet {
                fjIncidentR["crossStreet"] = crossStreet
            }
            if let incidentState = fjIncidentAddress.incidentState {
                fjIncidentR["incidentState"] = incidentState
            }
            if let prefix = fjIncidentAddress.prefix {
                fjIncidentR["prefix"] = prefix
            }
            if let stagingAddress = fjIncidentAddress.stagingAddress {
                fjIncidentR["stagingAddress"] = stagingAddress
            }
            if let streetHighway = fjIncidentAddress.streetHighway {
                fjIncidentR["streetHighway"] = streetHighway
            }
            if let streetNumber = fjIncidentAddress.streetNumber {
                fjIncidentR["streetNumber"] = streetNumber
            }
            if let streetType = fjIncidentAddress.streetType {
                fjIncidentR["streetType"] = streetType
            }
            if let suffix = fjIncidentAddress.suffix {
                fjIncidentR["suffix"] = suffix
            }
            if let zip = fjIncidentAddress.zip {
                fjIncidentR["zip"] = zip
            }
            if let zipPlus4 = fjIncidentAddress.zipPlus4 {
                fjIncidentR["zipPlus4"] = zipPlus4
            }
            var num = ""
            var street = ""
            var zip = ""
            if let number = fjIncidentAddress.streetNumber {
                num = number
            }
            if let st = fjIncidentAddress.streetHighway {
                street = st
            }
            if let zipped = fjIncidentAddress.zip {
                zip = zipped
            }
            fjIncidentR["aadressForIncident"] = "\(num) \(street) \(zip)"
        }
        
            //MARK: -incidentLocal-
        if let fjIncidentLocal = self.incidentLocalDetails {
            if let incidentBattalion = fjIncidentLocal.incidentBattalion {
                fjIncidentR["incidentBattalion"] = incidentBattalion
            }
            if let incidentDivision = fjIncidentLocal.incidentDivision {
                fjIncidentR["incidentDivision"] = incidentDivision
            }
            if let incidentFireDistrict = fjIncidentLocal.incidentFireDistrict {
                fjIncidentR["incidentFireDistrict"] = incidentFireDistrict
            }
            if let incidentLocalType = fjIncidentLocal.incidentLocalType {
                fjIncidentR["incidentLocalType"] = incidentLocalType
            }
        }
        
            //MARK: -IncidentMap-
        if let fjIncidentMap = self.incidentMapDetails {
            if let incidentLatitude = fjIncidentMap.incidentLatitude {
                fjIncidentR["incidentLatitude"] = incidentLatitude
            }
            if let incidentLongitude = fjIncidentMap.incidentLongitude {
                fjIncidentR["incidentLongitude"] = incidentLongitude
            }
            if let stagingLatitude = fjIncidentMap.stagingLatitude {
                fjIncidentR["stagingLatitude"] = stagingLatitude
            }
            if let stagingLongitude = fjIncidentMap.stagingLongitude {
                fjIncidentR["stagingLongitude"] = stagingLongitude
            }
        }
        
            // MARK: -IncidentNFIRS-
        if  let fjIncidentNFIRS = self.incidentNFIRSDetails {
            if let fireStationState = fjIncidentNFIRS.fireStationState {
                fjIncidentR["fireStationState"] = fireStationState
            }
            if let incidentActionsTakenAdditionalThree = fjIncidentNFIRS.incidentActionsTakenAdditionalThree {
                fjIncidentR["incidentActionsTakenAdditionalThree"] = incidentActionsTakenAdditionalThree
            }
            if let incidentActionsTakenAdditionalTwo = fjIncidentNFIRS.incidentActionsTakenAdditionalTwo {
                fjIncidentR["incidentActionsTakenAdditionalTwo"] = incidentActionsTakenAdditionalTwo
            }
            if let incidentActionsTakenPrimary = fjIncidentNFIRS.incidentActionsTakenPrimary {
                fjIncidentR["incidentActionsTakenPrimary"] = incidentActionsTakenPrimary
            }
            if let incidentAidGiven = fjIncidentNFIRS.incidentAidGiven {
                fjIncidentR["incidentAidGiven"] = incidentAidGiven
            }
            if let incidentAidGivenFDID = fjIncidentNFIRS.incidentAidGivenFDID {
                fjIncidentR["incidentAidGivenFDID"] = incidentAidGivenFDID
            }
            if let incidentAidGivenIncidentNumber = fjIncidentNFIRS.incidentAidGivenIncidentNumber {
                fjIncidentR["incidentAidGivenIncidentNumber"] = incidentAidGivenIncidentNumber
            }
            if let incidentAidGivenNone = fjIncidentNFIRS.incidentAidGivenNone {
                fjIncidentR["incidentAidGivenNone"] = incidentAidGivenNone
            }
            if let incidentAidGivenState = fjIncidentNFIRS.incidentAidGivenState {
                fjIncidentR["incidentAidGivenState"] = incidentAidGivenState
            }
            if let incidentCasualtiesCivilianDeaths = fjIncidentNFIRS.incidentCasualtiesCivilianDeaths {
                fjIncidentR["incidentCasualtiesCivilianDeaths"] = incidentCasualtiesCivilianDeaths
            }
            if let incidentCasualtiesCivilianInjuries = fjIncidentNFIRS.incidentCasualtiesCivilianInjuries {
                fjIncidentR["incidentCasualtiesCivilianInjuries"] = incidentCasualtiesCivilianInjuries
            }
            if let incidentCasualtiesFireDeaths = fjIncidentNFIRS.incidentCasualtiesFireDeaths {
                fjIncidentR["incidentCasualtiesFireDeaths"] = incidentCasualtiesFireDeaths
            }
            if let incidentCasualtiesFireInjuries = fjIncidentNFIRS.incidentCasualtiesFireInjuries {
                fjIncidentR["incidentCasualtiesFireInjuries"] = incidentCasualtiesFireInjuries
            }
            if let incidentCasualtiesServiceDeaths = fjIncidentNFIRS.incidentCasualtiesServiceDeaths {
                fjIncidentR["incidentCasualtiesServiceDeaths"] = incidentCasualtiesServiceDeaths
            }
            if let incidentCasualtitesServideInjuries = fjIncidentNFIRS.incidentCasualtitesServideInjuries {
                fjIncidentR["incidentCasualtitesServideInjuries"] = incidentCasualtitesServideInjuries
            }
            if let incidentDetectorChosen = fjIncidentNFIRS.incidentDetectorChosen {
                fjIncidentR["incidentDetectorChosen"] = incidentDetectorChosen
            }
            if let incidentExposure = fjIncidentNFIRS.incidentExposure {
                fjIncidentR["incidentExposure"] = incidentExposure
            }
            if let incidentFDID = fjIncidentNFIRS.incidentFDID {
                fjIncidentR["incidentFDID"] = incidentFDID
            }
            if let incidentFDID1 = fjIncidentNFIRS.incidentFDID1 {
                fjIncidentR["incidentFDID1"] = incidentFDID1
            }
            if let incidentFireStation = fjIncidentNFIRS.incidentFireStation {
                fjIncidentR["incidentFireStation"] = incidentFireStation
            }
            if let incidentHazMat = fjIncidentNFIRS.incidentHazMat {
                fjIncidentR["incidentHazMat"] = incidentHazMat
            }
            if let incidentLocation = fjIncidentNFIRS.incidentLocation {
                fjIncidentR["incidentNFIRSLocation"] = incidentLocation
            }
            if let incidentPlatoon = fjIncidentNFIRS.incidentPlatoon {
                fjIncidentR["incidentPlatoon"] = incidentPlatoon
            }
            if let incidentPropertyNone = fjIncidentNFIRS.incidentPropertyNone {
                fjIncidentR["incidentPropertyNone"] = incidentPropertyNone
            }
            if let incidentPropertyOutside = fjIncidentNFIRS.incidentPropertyOutside {
                fjIncidentR["incidentPropertyOutside"] = incidentPropertyOutside
            }
            if let incidentPropertyOutsideNumber = fjIncidentNFIRS.incidentPropertyOutsideNumber {
                fjIncidentR["incidentPropertyOutsideNumber"] = incidentPropertyOutsideNumber
            }
            if let incidentPropertyStructure = fjIncidentNFIRS.incidentPropertyStructure {
                fjIncidentR["incidentPropertyStructure"] = incidentPropertyStructure
            }
            if let incidentPropertyStructureNumber = fjIncidentNFIRS.incidentPropertyStructureNumber {
                fjIncidentR["incidentPropertyStructureNumber"] = incidentPropertyStructureNumber
            }
            if let incidentPropertyUse = fjIncidentNFIRS.incidentPropertyUse {
                fjIncidentR["incidentPropertyUse"] = incidentPropertyUse
            }
            if let incidentPropertyUseNone = fjIncidentNFIRS.incidentPropertyUseNone {
                fjIncidentR["incidentPropertyUseNone"] = incidentPropertyUseNone
            }
            if let incidentPropertyUseNumber = fjIncidentNFIRS.incidentPropertyUseNumber {
                fjIncidentR["incidentPropertyUseNumber"] = incidentPropertyUseNumber
            }
            if let incidentResourceCheck = fjIncidentNFIRS.incidentResourceCheck {
                fjIncidentR["incidentResourceCheck"] = incidentResourceCheck
            }
            if let incidentResourcesEMSApparatus = fjIncidentNFIRS.incidentResourcesEMSApparatus {
                fjIncidentR["incidentResourcesEMSApparatus"] = incidentResourcesEMSApparatus
            }
            if let incidentResourcesEMSPersonnel = fjIncidentNFIRS.incidentResourcesEMSPersonnel {
                fjIncidentR["incidentResourcesEMSPersonnel"] = incidentResourcesEMSPersonnel
            }
            if let incidentResourcesOtherApparatus = fjIncidentNFIRS.incidentResourcesOtherApparatus {
                fjIncidentR["incidentResourcesOtherApparatus"] = incidentResourcesOtherApparatus
            }
            if let incidentResourcesOtherPersonnel = fjIncidentNFIRS.incidentResourcesOtherPersonnel {
                fjIncidentR["incidentResourcesOtherPersonnel"] = incidentResourcesOtherPersonnel
            }
            if let incidentResourcesSuppressionPersonnel = fjIncidentNFIRS.incidentResourcesSuppressionPersonnel {
                fjIncidentR["incidentResourcesSuppressionPersonnel"] = incidentResourcesSuppressionPersonnel
            }
            if let incidentResourcesSupressionApparatus = fjIncidentNFIRS.incidentResourcesSupressionApparatus {
                fjIncidentR["incidentResourcesSupressionApparatus"] = incidentResourcesSupressionApparatus
            }
            if let incidentTypeNumberNFRIS = fjIncidentNFIRS.incidentTypeNumberNFRIS {
                fjIncidentR["incidentTypeNumberNFRIS"] = incidentTypeNumberNFRIS
            }
            if let incidentTypeTextNFRIS = fjIncidentNFIRS.incidentTypeTextNFRIS {
                fjIncidentR["incidentTypeTextNFRIS"] = incidentTypeTextNFRIS
            }
            if let lossesContentDollars = fjIncidentNFIRS.lossesContentDollars {
                fjIncidentR["lossesContentDollars"] = lossesContentDollars
            }
            if let lossesPropertyDollars = fjIncidentNFIRS.lossesPropertyDollars {
                fjIncidentR["lossesPropertyDollars"] = lossesPropertyDollars
            }
            if let mixedUsePropertyType = fjIncidentNFIRS.mixedUsePropertyType {
                fjIncidentR["mixedUsePropertyType"] = mixedUsePropertyType
            }
            if let nfirsChangeDescription = fjIncidentNFIRS.nfirsChangeDescription {
                fjIncidentR["nfirsChangeDescription"] = nfirsChangeDescription
            }
            if let nfirsSectionOneSegment = fjIncidentNFIRS.nfirsSectionOneSegment {
                fjIncidentR["nfirsSectionOneSegment"] = nfirsSectionOneSegment
            }
            if let shiftAlarm = fjIncidentNFIRS.shiftAlarm {
                fjIncidentR["shiftAlarm"] = shiftAlarm
            }
            if let shiftDistrict = fjIncidentNFIRS.shiftDistrict {
                fjIncidentR["shiftDistrict"] = shiftDistrict
            }
            if let shiftOrPlatoon = fjIncidentNFIRS.shiftOrPlatoon {
                fjIncidentR["shiftOrPlatoon"] = shiftOrPlatoon
            }
            if let specialStudyID = fjIncidentNFIRS.specialStudyID {
                fjIncidentR["specialStudyID"] = specialStudyID
            }
            if let specialStudyValue = fjIncidentNFIRS.specialStudyValue {
                fjIncidentR["specialStudyValue"] = specialStudyValue
            }
            if let valueContentDollars = fjIncidentNFIRS.valueContentDollars {
                fjIncidentR["valueContentDollars"] = valueContentDollars
            }
            
            fjIncidentR["incidentHazMatNone"] = Int(fjIncidentNFIRS.incidentHazMatNone)
            fjIncidentR["valuePropertyDollars"] = fjIncidentNFIRS.valuePropertyDollars
            fjIncidentR["lossesContentNone"] = Int(fjIncidentNFIRS.lossesContentNone)
            fjIncidentR["lossesPropertyNone"] = Int(fjIncidentNFIRS.lossesPropertyNone)
            fjIncidentR["mixedUsePropertyNone"] = Int(fjIncidentNFIRS.mixedUsePropertyNone)
            fjIncidentR["propertyUseNone"] = Int(fjIncidentNFIRS.propertyUseNone)
            fjIncidentR["resourceCountsIncludeAidReceived"] = Int(fjIncidentNFIRS.resourceCountsIncludeAidReceived)
            fjIncidentR["skipSectionF"] = Int(fjIncidentNFIRS.skipSectionF)
            fjIncidentR["valueContentsNone"] = Int(fjIncidentNFIRS.valueContentsNone)
            fjIncidentR["valuePropertyNone"] = Int(fjIncidentNFIRS.valuePropertyNone)
            fjIncidentR["incidentCasualtiesNone"] = Int(fjIncidentNFIRS.incidentCasualtiesNone)
            
        }
        
            // MARK: -IncidentNFIRSKSec-
        if let fjIncidentNFIRSKSec = self.incidentNFIRSKSecDetails {
            if let kOwnerAptSuiteRoom = fjIncidentNFIRSKSec.kOwnerAptSuiteRoom {
                fjIncidentR["kOwnerAptSuiteRoom"] = kOwnerAptSuiteRoom
            }
            if let kOwnerAreaCode = fjIncidentNFIRSKSec.kOwnerAreaCode {
                fjIncidentR["kOwnerAreaCode"] = kOwnerAreaCode
            }
            if let kOwnerBusinessName = fjIncidentNFIRSKSec.kOwnerBusinessName {
                fjIncidentR["kOwnerBusinessName"] = kOwnerBusinessName
            }
            if let kOwnerCity = fjIncidentNFIRSKSec.kOwnerCity {
                fjIncidentR["kOwnerCity"] = kOwnerCity
            }
            if let kOwnerFirstName = fjIncidentNFIRSKSec.kOwnerFirstName {
                fjIncidentR["kOwnerFirstName"] = kOwnerFirstName
            }
            if let kOwnerLastName = fjIncidentNFIRSKSec.kOwnerLastName {
                fjIncidentR["kOwnerLastName"] = kOwnerLastName
            }
            if let kOwnerMI = fjIncidentNFIRSKSec.kOwnerMI {
                fjIncidentR["kOwnerMI"] = kOwnerMI
            }
            if let kOwnerNamePrefix = fjIncidentNFIRSKSec.kOwnerNamePrefix {
                fjIncidentR["kOwnerNamePrefix"] = kOwnerNamePrefix
            }
            if let kOwnerNameSuffix = fjIncidentNFIRSKSec.kOwnerNameSuffix {
                fjIncidentR["kOwnerNameSuffix"] = kOwnerNameSuffix
            }
            if let kOwnerPhoneLastFour = fjIncidentNFIRSKSec.kOwnerPhoneLastFour {
                fjIncidentR["kOwnerPhoneLastFour"] = kOwnerPhoneLastFour
            }
            if let kOwnerPhonePrefix = fjIncidentNFIRSKSec.kOwnerPhonePrefix {
                fjIncidentR["kOwnerPhonePrefix"] = kOwnerPhonePrefix
            }
            if let kOwnerPOBox = fjIncidentNFIRSKSec.kOwnerPOBox {
                fjIncidentR["kOwnerPOBox"] = kOwnerPOBox
            }
            if let kOwnerState = fjIncidentNFIRSKSec.kOwnerState {
                fjIncidentR["kOwnerState"] = kOwnerState
            }
            if let kOwnerStreetHyway = fjIncidentNFIRSKSec.kOwnerStreetHyway {
                fjIncidentR["kOwnerStreetHyway"] = kOwnerStreetHyway
            }
            if let kOwnerStreetNumber = fjIncidentNFIRSKSec.kOwnerStreetNumber {
                fjIncidentR["kOwnerStreetNumber"] = kOwnerStreetNumber
            }
            if let kOwnerStreetPrefix = fjIncidentNFIRSKSec.kOwnerStreetPrefix {
                fjIncidentR["kOwnerStreetPrefix"] = kOwnerStreetPrefix
            }
            if let kOwnerStreetSuffix = fjIncidentNFIRSKSec.kOwnerStreetSuffix {
                fjIncidentR["kOwnerStreetSuffix"] = kOwnerStreetSuffix
            }
            if let kOwnerStreetType = fjIncidentNFIRSKSec.kOwnerStreetType {
                fjIncidentR["kOwnerStreetType"] = kOwnerStreetType
            }
            if let kOwnerZip = fjIncidentNFIRSKSec.kOwnerZip {
                fjIncidentR["kOwnerZip"] = kOwnerZip
            }
            if let kOwnerZipPlusFour = fjIncidentNFIRSKSec.kOwnerZipPlusFour {
                fjIncidentR["kOwnerZipPlusFour"] = kOwnerZipPlusFour
            }
            if let kPersonAppSuiteRoom = fjIncidentNFIRSKSec.kPersonAppSuiteRoom {
                fjIncidentR["kPersonAppSuiteRoom"] = kPersonAppSuiteRoom
            }
            if let kPersonAreaCode = fjIncidentNFIRSKSec.kPersonAreaCode {
                fjIncidentR["kPersonAreaCode"] = kPersonAreaCode
            }
            if let kPersonBusinessName = fjIncidentNFIRSKSec.kPersonBusinessName {
                fjIncidentR["kPersonBusinessName"] = kPersonBusinessName
            }
            if let kPersonCity = fjIncidentNFIRSKSec.kPersonCity {
                fjIncidentR["kPersonCity"] = kPersonCity
            }
            if let kPersonFirstName = fjIncidentNFIRSKSec.kPersonFirstName {
                fjIncidentR["kPersonFirstName"] = kPersonFirstName
            }
            if let kPersonGender = fjIncidentNFIRSKSec.kPersonGender {
                fjIncidentR["kPersonGender"] = kPersonGender
            }
            if let kPersonLastName = fjIncidentNFIRSKSec.kPersonLastName {
                fjIncidentR["kPersonLastName"] = kPersonLastName
            }
            if let kPersonMI = fjIncidentNFIRSKSec.kPersonMI {
                fjIncidentR["kPersonMI"] = kPersonMI
            }
            if let kPersonNameSuffix = fjIncidentNFIRSKSec.kPersonNameSuffix {
                fjIncidentR["kPersonNameSuffix"] = kPersonNameSuffix
            }
            if let kPersonPhoneLastFour = fjIncidentNFIRSKSec.kPersonPhoneLastFour {
                fjIncidentR["kPersonPhoneLastFour"] = kPersonPhoneLastFour
            }
            if let kPersonPhonePrefix = fjIncidentNFIRSKSec.kPersonPhonePrefix {
                fjIncidentR["kPersonPhonePrefix"] = kPersonPhonePrefix
            }
            if let kPersonPOBox = fjIncidentNFIRSKSec.kPersonPOBox {
                fjIncidentR["kPersonPOBox"] = kPersonPOBox
            }
            if let kPersonPrefix = fjIncidentNFIRSKSec.kPersonPrefix {
                fjIncidentR["kPersonPrefix"] = kPersonPrefix
            }
            if let kPersonState = fjIncidentNFIRSKSec.kPersonState {
                fjIncidentR["kPersonState"] = kPersonState
            }
            if let kPersonStreetHyway = fjIncidentNFIRSKSec.kPersonStreetHyway {
                fjIncidentR["kPersonStreetHyway"] = kPersonStreetHyway
            }
            if let kPersonStreetNum = fjIncidentNFIRSKSec.kPersonStreetNum {
                fjIncidentR["kPersonStreetNum"] = kPersonStreetNum
            }
            if let kPersonStreetSuffix = fjIncidentNFIRSKSec.kPersonStreetSuffix {
                fjIncidentR["kPersonStreetSuffix"] = kPersonStreetSuffix
            }
            if let kPersonStreetType = fjIncidentNFIRSKSec.kPersonStreetType {
                fjIncidentR["kPersonStreetType"] = kPersonStreetType
            }
            if let kPersonZipCode = fjIncidentNFIRSKSec.kPersonZipCode {
                fjIncidentR["kPersonZipCode"] = kPersonZipCode
            }
            if let kPersonZipPlus4 = fjIncidentNFIRSKSec.kPersonZipPlus4 {
                fjIncidentR["kPersonZipPlus4"] = kPersonZipPlus4
            }
            
            fjIncidentR["kOwnerCheckBox"] = Int(fjIncidentNFIRSKSec.kOwnerCheckBox)
            fjIncidentR["kOwnerSameAsPerson"] = Int(fjIncidentNFIRSKSec.kOwnerSameAsPerson)
            fjIncidentR["kPersonCheckBox"] = Int(fjIncidentNFIRSKSec.kPersonCheckBox)
            fjIncidentR["kPersonMoreThanOne"] = Int(fjIncidentNFIRSKSec.kPersonMoreThanOne)
        }
        
        
        
        if let fjIncidentNFIRSsecL = self.sectionLDetails {
            fjIncidentR["incidentNFIRSSecLNotes"] = fjIncidentNFIRSsecL.lRemarks as? String
            fjIncidentR["incidentNFIRSSecLMoreRemarks"] = Int(fjIncidentNFIRSsecL.moreRemarks)
        }
        
        if let fjIncidentNFIRSsecM = self.sectionMDetails {
            if let memberAssignment = fjIncidentNFIRSsecM.memberAssignment {
                fjIncidentR["memberAssignment"] = memberAssignment
            }
            if let memberDate = fjIncidentNFIRSsecM.memberDate {
                fjIncidentR["memberDate"] = memberDate
            }
            if let memberMakingReportID = fjIncidentNFIRSsecM.memberMakingReportID {
                fjIncidentR["memberMakingReportID"] = memberMakingReportID
            }
            if let memberRankPosition = fjIncidentNFIRSsecM.memberRankPosition {
                fjIncidentR["memberRankPosition"] = memberRankPosition
            }
            if let officerAssignment = fjIncidentNFIRSsecM.officerAssignment {
                fjIncidentR["officerAssignment"] = officerAssignment
            }
            if let officerDate = fjIncidentNFIRSsecM.officerDate {
                fjIncidentR["officerDate"] = officerDate
            }
            if let officerInChargeID = fjIncidentNFIRSsecM.officerInChargeID {
                fjIncidentR["officerInChargeID"] = officerInChargeID
            }
            if let officerRankPosition = fjIncidentNFIRSsecM.officerRankPosition {
                fjIncidentR["officerRankPosition"] = officerRankPosition
            }
            if let signatureMember = fjIncidentNFIRSsecM.signatureMember {
                fjIncidentR["signatureMember"] = signatureMember
            }
            if let signatureOfficer = fjIncidentNFIRSsecM.signatureOfficer {
                fjIncidentR["signatureOfficer"] = signatureOfficer
            }
            
            fjIncidentR["memberSameAsOfficer"] = Int(fjIncidentNFIRSsecM.memberSameAsOfficer)
        }
        
        
            // MARK: -IncidentNotes-
        if let fjIncidentNotes = self.incidentNotesDetails {
            fjIncidentR["incidentSummaryNotes"] = fjIncidentNotes.incidentSummaryNotes as? String
            fjIncidentR["incidentNote"] = fjIncidentNotes.incidentNote
        }
        
            //        MARK: -POV NOTES FOR INCIDENT
        if let fjpPersonalJournalReference = self.fjpPersonalJournalReference {
            fjIncidentR["fjpPersonalJournalReference"] = fjpPersonalJournalReference
        }
        
            //        MARK: -IncidentTimer-
        if let fjIncidentTimer = self.incidentTimerDetails {
            
            fjIncidentR["arrivalSameDate"] = Int(fjIncidentTimer.arrivalSameDate)
            fjIncidentR["controlledSameDate"] = Int(fjIncidentTimer.controlledSameDate)
            fjIncidentR["lastUnitSameDate"] = Int(fjIncidentTimer.lastUnitSameDate)
            
            if let incidentAlarmNotes = fjIncidentTimer.incidentAlarmNotes as? String {
                fjIncidentR["incidentAlarmNotes"] = incidentAlarmNotes
            }
            if let incidentArrivalNotes = fjIncidentTimer.incidentArrivalNotes as? String {
                fjIncidentR["incidentArrivalNotes"] = incidentArrivalNotes
            }
            if let incidentControlledNotes = fjIncidentTimer.incidentControlledNotes as? String {
                fjIncidentR["incidentControlledNotes"] = incidentControlledNotes
            }
            if let incidentLastUnitClearedNotes = fjIncidentTimer.incidentLastUnitClearedNotes as? String {
                fjIncidentR["incidentLastUnitClearedNotes"] = incidentLastUnitClearedNotes
            }
            
            if let incidentAlarmCombinedDate = fjIncidentTimer.incidentAlarmCombinedDate {
                fjIncidentR["incidentAlarmCombinedDate"] = incidentAlarmCombinedDate
            }
            if let incidentAlarmDateTime = fjIncidentTimer.incidentAlarmDateTime {
                fjIncidentR["incidentAlarmDateTime"] = incidentAlarmDateTime
            }
            if let incidentAlarmDay = fjIncidentTimer.incidentAlarmDay {
                fjIncidentR["incidentAlarmDay"] = incidentAlarmDay
            }
            if let incidentAlarmHours = fjIncidentTimer.incidentAlarmHours {
                fjIncidentR["incidentAlarmHours"] = incidentAlarmHours
            }
            if let incidentAlarmMinutes = fjIncidentTimer.incidentAlarmMinutes {
                fjIncidentR["incidentAlarmMinutes"] = incidentAlarmMinutes
            }
            if let incidentAlarmMonth = fjIncidentTimer.incidentAlarmMonth {
                fjIncidentR["incidentAlarmMonth"] = incidentAlarmMonth
            }
            if let incidentAlarmYear = fjIncidentTimer.incidentAlarmYear {
                fjIncidentR["incidentAlarmYear"] = incidentAlarmYear
            }
            if let incidentArrivalCombinedDate = fjIncidentTimer.incidentArrivalCombinedDate {
                fjIncidentR["incidentArrivalCombinedDate"] = incidentArrivalCombinedDate
            }
            if let incidentArrivalDateTime = fjIncidentTimer.incidentArrivalDateTime {
                fjIncidentR["incidentArrivalDateTime"] = incidentArrivalDateTime
            }
            if let incidentArrivalDay = fjIncidentTimer.incidentArrivalDay {
                fjIncidentR["incidentArrivalDay"] = incidentArrivalDay
            }
            if let incidentArrivalHours = fjIncidentTimer.incidentArrivalHours {
                fjIncidentR["incidentArrivalHours"] = incidentArrivalHours
            }
            if let incidentArrivalMinutes = fjIncidentTimer.incidentArrivalMinutes {
                fjIncidentR["incidentArrivalMinutes"] = incidentArrivalMinutes
            }
            if let incidentArrivalMonth = fjIncidentTimer.incidentArrivalMonth {
                fjIncidentR["incidentArrivalMonth"] = incidentArrivalMonth
            }
            if let incidentArrivalYear = fjIncidentTimer.incidentArrivalYear {
                fjIncidentR["incidentArrivalYear"] = incidentArrivalYear
            }
            if let incidentControlledCombinedDate = fjIncidentTimer.incidentControlledCombinedDate {
                fjIncidentR["incidentControlledCombinedDate"] = incidentControlledCombinedDate
            }
            if let incidentControlDateTime = fjIncidentTimer.incidentControlDateTime {
                fjIncidentR["incidentControlDateTime"] = incidentControlDateTime
            }
            if let incidentControlledDay = fjIncidentTimer.incidentControlledDay {
                fjIncidentR["incidentControlledDay"] = incidentControlledDay
            }
            if let incidentControlledHours = fjIncidentTimer.incidentControlledHours {
                fjIncidentR["incidentControlledHours"] = incidentControlledHours
            }
            if let incidentControlledMinutes = fjIncidentTimer.incidentControlledMinutes {
                fjIncidentR["incidentControlledMinutes"] = incidentControlledMinutes
            }
            if let incidentControlledMonth = fjIncidentTimer.incidentControlledMonth {
                fjIncidentR["incidentControlledMonth"] = incidentControlledMonth
            }
            if let incidentControlledYear = fjIncidentTimer.incidentControlledYear {
                fjIncidentR["incidentControlledYear"] = incidentControlledYear
            }
            if let incidentElapsedTime = fjIncidentTimer.incidentElapsedTime {
                fjIncidentR["incidentElapsedTime"] = incidentElapsedTime
            }
            if let incidentLastUnitCalledCombinedDate = fjIncidentTimer.incidentLastUnitCalledCombinedDate {
                fjIncidentR["incidentLastUnitCalledCombinedDate"] = incidentLastUnitCalledCombinedDate
            }
            if let incidentLastUnitDateTime = fjIncidentTimer.incidentLastUnitDateTime {
                fjIncidentR["incidentLastUnitDateTime"] = incidentLastUnitDateTime
            }
            if let incidentLastUnitCalledDay = fjIncidentTimer.incidentLastUnitCalledDay {
                fjIncidentR["incidentLastUnitCalledDay"] = incidentLastUnitCalledDay
            }
            if let incidentLastUnitCalledHours = fjIncidentTimer.incidentLastUnitCalledHours {
                fjIncidentR["incidentLastUnitCalledHours"] = incidentLastUnitCalledHours
            }
            if let incidentLastUnitCalledMinutes = fjIncidentTimer.incidentLastUnitCalledMinutes {
                fjIncidentR["incidentLastUnitCalledMinutes"] = incidentLastUnitCalledMinutes
            }
            if let incidentLastUnitCalledMonth = fjIncidentTimer.incidentLastUnitCalledMonth {
                fjIncidentR["incidentLastUnitCalledMonth"] = incidentLastUnitCalledMonth
            }
            if let incidentLastUnitCalledYear = fjIncidentTimer.incidentLastUnitCalledYear {
                fjIncidentR["incidentLastUnitCalledYear"] = incidentLastUnitCalledYear
            }
            if let incidentStartClockCombinedDate = fjIncidentTimer.incidentStartClockCombinedDate {
                fjIncidentR["incidentStartClockCombinedDate"] = incidentStartClockCombinedDate
            }
            if let incidentStartClockDateTime = fjIncidentTimer.incidentStartClockDateTime {
                fjIncidentR["incidentStartClockDateTime"] = incidentStartClockDateTime
            }
            if let incidentStartClockDay = fjIncidentTimer.incidentStartClockDay {
                fjIncidentR["incidentStartClockDay"] = incidentStartClockDay
            }
            if let incidentStartClockHours = fjIncidentTimer.incidentStartClockHours {
                fjIncidentR["incidentStartClockHours"] = incidentStartClockHours
            }
            if let incidentStartClockMinutes = fjIncidentTimer.incidentStartClockMinutes {
                fjIncidentR["incidentStartClockMinutes"] = incidentStartClockMinutes
            }
            if let incidentStartClockMonth = fjIncidentTimer.incidentStartClockMonth {
                fjIncidentR["incidentStartClockMonth"] = incidentStartClockMonth
            }
            if let incidentStartClockSeconds = fjIncidentTimer.incidentStartClockSeconds {
                fjIncidentR["incidentStartClockSeconds"] = incidentStartClockSeconds
            }
            if let incidentStartClockYear = fjIncidentTimer.incidentStartClockYear {
                fjIncidentR["incidentStartClockYear"] = incidentStartClockYear
            }
            if let incidentStopClockCombinedDate = fjIncidentTimer.incidentStopClockCombinedDate {
                fjIncidentR["incidentStopClockCombinedDate"] = incidentStopClockCombinedDate
            }
            if let incidentStopClockDateTime = fjIncidentTimer.incidentStopClockDateTime {
                fjIncidentR["incidentStopCloudDateTime"] = incidentStopClockDateTime
            }
            if let incidentStopClockDay = fjIncidentTimer.incidentStopClockDay {
                fjIncidentR["incidentStopClockDay"] = incidentStopClockDay
            }
            if let incidentStopClockHours = fjIncidentTimer.incidentStopClockHours {
                fjIncidentR["incidentStopClockHours"] = incidentStopClockHours
            }
            if let incidentStopClockMinutes = fjIncidentTimer.incidentStopClockMinutes {
                fjIncidentR["incidentStopClockMinutes"] = incidentStopClockMinutes
            }
            if let incidentStopClockMonth = fjIncidentTimer.incidentStopClockMonth {
                fjIncidentR["incidentStopClockMonth"] = incidentStopClockMonth
            }
            if let incidentStopClockSeconds = fjIncidentTimer.incidentStopClockSeconds {
                fjIncidentR["incidentStopClockSeconds"] = incidentStopClockSeconds
            }
            if let incidentStopClockYear = fjIncidentTimer.incidentStopClockYear {
                fjIncidentR["incidentStopClockYear"] = incidentStopClockYear
            }
        }
        
            //        MARK: -ActionsTaken-
        if let fjActionsTaken = self.actionsTakenDetails {
            if let additionalThree = fjActionsTaken.additionalThree {
                fjIncidentR["additionalThree"] = additionalThree
            }
            if let additionalThreeNumber = fjActionsTaken.additionalThreeNumber {
                fjIncidentR["additionalThreeNumber"] = additionalThreeNumber
            }
            if let additionalTwo = fjActionsTaken.additionalTwo {
                fjIncidentR["additionalTwo"] = additionalTwo
            }
            if let additionalTwoNumber = fjActionsTaken.additionalTwoNumber {
                fjIncidentR["additionalTwoNumber"] = additionalTwoNumber
            }
            if let primaryAction = fjActionsTaken.primaryAction {
                fjIncidentR["primaryAction"] = primaryAction
            }
            if let primaryActionNumber = fjActionsTaken.primaryActionNumber {
                fjIncidentR["primaryActionNumber"] = primaryActionNumber
            }
        }
        
        
        return fjIncidentR
        
    }
    
    func updateIncidentFromCloud(ckRecord: CKRecord) {
        let fjIncidentR = ckRecord
        
        if let formType = fjIncidentR["formType"] as? String {
            self.formType = formType
        }
        if let incidentCreationDate = fjIncidentR["incidentCreationDate"] as? Date {
            self.incidentCreationDate = incidentCreationDate
        }
        if let incidentDate = fjIncidentR["incidentDate"] as? String {
            self.incidentDate = incidentDate
        }
        if let incidentDateSearch = fjIncidentR["incidentDateSearch"] as? String {
            self.incidentDateSearch = incidentDateSearch
        }
        if let incidentDayOfWeek = fjIncidentR["incidentDayOfWeek"] as? String {
            self.incidentDayOfWeek = incidentDayOfWeek
        }
        if let incidentDayOfYear = fjIncidentR["incidentDayOfYear"] as? Double {
            self.incidentDayOfYear = incidentDayOfYear as NSNumber
        }
        if let incidentEntryTypeImageName = fjIncidentR["incidentEntryTypeImageName"] as? String {
            self.incidentEntryTypeImageName = incidentEntryTypeImageName
        }
        
        if let incidentNFIRSCompleted = fjIncidentR["incidentNFIRSCompleted"] as? Double {
            self.incidentNFIRSCompleted = incidentNFIRSCompleted as NSNumber
        }
        if let incidentNFIRSCompletedDate = fjIncidentR["incidentNFIRSCompletedDate"] as? Date {
            self.incidentNFIRSCompletedDate = incidentNFIRSCompletedDate
        }
        if let incidentNFIRSDataComplete = fjIncidentR["incidentNFIRSDataComplete"] as? Double {
            self.incidentNFIRSDataComplete = incidentNFIRSDataComplete as NSNumber
        }
        if let incidentNFIRSDataDate = fjIncidentR["incidentNFIRSDataDate"] as? String {
            self.incidentNFIRSDataDate = incidentNFIRSDataDate
        }
        if let incidentNFIRSDataSaved = fjIncidentR["incidentNFIRSDataSaved"] as? String {
            self.incidentNFIRSDataSaved = incidentNFIRSDataSaved
        }
        
        if let arsonInvestigation = fjIncidentR["arsonInvestigation"] as? Double {
            self.arsonInvestigation = Bool(truncating: arsonInvestigation as NSNumber)
        }
        
        if let incidentCancel = fjIncidentR["incidentCancel"] as? Double {
            self.incidentCancel = Bool(truncating: incidentCancel as NSNumber)
        }
        if let incidentNumber = fjIncidentR["incidentNumber"] as? String {
            self.incidentNumber = incidentNumber
        }
        if let incidentPhotoTaken = fjIncidentR["incidentPhotoTaken"] as? Double {
            self.incidentPhotoTaken = incidentPhotoTaken as NSNumber
        }
        if let locationAvailable = fjIncidentR["locationAvailable"] as? Double {
            if locationAvailable == 1 {
                self.locationAvailable = true
            } else {
                self.locationAvailable = false
            }
        }
        if let incidentTagsAvailable = fjIncidentR["incidentTagsAvailable"] as? Double {
            if incidentTagsAvailable == 1 {
                self.incidentTagsAvailable = true
            } else {
                self.incidentTagsAvailable = false
            }
        }
        if let incidentSearchDate = fjIncidentR["incidentSearchDate"] as? String {
            self.incidentSearchDate = incidentSearchDate
        }
        if let incidentStreetHyway = fjIncidentR["incidentStreetHyway"] as? String {
            self.incidentStreetHyway = incidentStreetHyway
        }
        if let incidentStreetNumber = fjIncidentR["incidentStreetNumber"] as? String {
            self.incidentStreetNumber = incidentStreetNumber
        }
        if let incidentTime = fjIncidentR["incidentTime"] as? String {
            self.incidentTime = incidentTime
        }
        if let incidentType = fjIncidentR["incidentType"] as? String {
            self.incidentType = incidentType
        }
        if let incidentZipCode = fjIncidentR["incidentZipCode"] as? String {
            self.incidentZipCode = incidentZipCode
        }
        if let incidentZipPlus4 = fjIncidentR["incidentZipPlus4"] as? String {
            self.incidentZipPlus4 = incidentZipPlus4
        }
        if let situationIncidentImage = fjIncidentR["situationIncidentImage"] as? String {
            self.situationIncidentImage = situationIncidentImage
        }
        if let tempIncidentApparatus = fjIncidentR["tempIncidentApparatus"] as? String {
            self.tempIncidentApparatus = tempIncidentApparatus
        }
        if let tempIncidentAssignment = fjIncidentR["tempIncidentAssignment"] as? String {
            self.tempIncidentAssignment = tempIncidentAssignment
        }
        if let tempIncidentFireStation = fjIncidentR["tempIncidentFireStation"] as? String {
            self.tempIncidentFireStation = tempIncidentFireStation
        }
        if let tempIncidentPlatoon = fjIncidentR["tempIncidentPlatoon"] as? String {
            self.tempIncidentPlatoon = tempIncidentPlatoon
        }
        if let arsonInvestigation = fjIncidentR["arsonInvestigation"] as? Bool {
            self.arsonInvestigation = arsonInvestigation
        }
        
        if let fjuSections = self.formDetails {
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
        }
        
        if  let fjIncidentAddress = self.incidentAddressDetails {
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
        }
        
            //MARK: -incidentLocal-
        if let fjIncidentLocal = self.incidentLocalDetails {
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
        }
        
            //MARK: -incidentMap-
        if let fjIncidentMap = self.incidentMapDetails {
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
        }
        
            //MARK: -IncidentNFIRS-
        if let fjIncidentNFIRS = self.incidentNFIRSDetails {
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
        }
        
            // TODO: -CompletedModules-
            // MARK: -IncidentNFIRSKSec-
        if let fjIncidentNFIRSKSec = self.incidentNFIRSKSecDetails {
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
        }
        
            // TODO: -REQUIREDMODULES
            // MARK: -IncidentNFIRSsecL-
        if let fjIncidentNFIRSsecL = self.sectionLDetails {
            if let lRemarks = fjIncidentR["incidentNFIRSSecLNotes"] as? String {
                fjIncidentNFIRSsecL.lRemarks = lRemarks as NSObject
            }
            if let moreRemarks = fjIncidentR["incidentNFIRSSecLMoreRemarks"] as? Bool {
                fjIncidentNFIRSsecL.moreRemarks = moreRemarks
            }
        }
        
            // MARK: -IncidentNFIRSsecM-
        if let fjIncidentNFIRSsecM = self.sectionMDetails {
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
        }
        
            // MARK: -IncidentNotes-
        if let fjIncidentNotes = self.incidentNotesDetails {
            if let incidentSummaryNotesSC = fjIncidentR["incidentSummaryNotes"] as? NSObject {
                fjIncidentNotes.incidentSummaryNotesSC = incidentSummaryNotesSC
            }
            if let note = fjIncidentR["incidentNote"] as? String {
                fjIncidentNotes.incidentNote = note
            }
        }
        
            // TODO: -IncidentResources-
            // MARK: -IncidentTimer-
        if let fjIncidentTimer = self.incidentTimerDetails {
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
        }
        
            // MARK: -ActionsTaken-
        if let fjActionsTaken = self.actionsTakenDetails {
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
        }
        
            // TODO: -IncidentTeam, IncidentTags, UserCrew
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjIncidentR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.fjIncidentCKR = data as NSObject
        print("incident number here is self \(self.incidentNumber ?? "no incident number")")
        saveToCD()
    }
    
        //    MARK: -SINGLE INCIDENT FROM THE CLOUD-
        /// Updates journal entry from cloud
        /// - Parameters:
        ///   - ckRecord: CKRcord
        ///   - dateFormatter: DateFormatter
    
    func singleIncidentFromTheCloud(ckRecord: CKRecord, dateFormatter: DateFormatter, completionHandler: (() -> Void)? = nil) {
        
        let fjIncidentR = ckRecord
        
        if let formType = fjIncidentR["formType"] as? String {
            self.formType = formType
        }
        if let incidentCreationDate = fjIncidentR["incidentCreationDate"] as? Date {
            self.incidentCreationDate = incidentCreationDate
        }
        if let incidentDate = fjIncidentR["incidentDate"] as? String {
            self.incidentDate = incidentDate
        }
        if let incidentDateSearch = fjIncidentR["incidentDateSearch"] as? String {
            self.incidentDateSearch = incidentDateSearch
        }
        if let incidentDayOfWeek = fjIncidentR["incidentDayOfWeek"] as? String {
            self.incidentDayOfWeek = incidentDayOfWeek
        }
        if let incidentDayOfYear = fjIncidentR["incidentDayOfYear"] as? Double {
            self.incidentDayOfYear = incidentDayOfYear as NSNumber
        }
        if let incidentEntryTypeImageName = fjIncidentR["incidentEntryTypeImageName"] as? String {
            self.incidentEntryTypeImageName = incidentEntryTypeImageName
        }
        
        if let incidentNFIRSCompleted = fjIncidentR["incidentNFIRSCompleted"] as? Double {
            self.incidentNFIRSCompleted = incidentNFIRSCompleted as NSNumber
        }
        if let incidentNFIRSCompletedDate = fjIncidentR["incidentNFIRSCompletedDate"] as? Date {
            self.incidentNFIRSCompletedDate = incidentNFIRSCompletedDate
        }
        if let incidentNFIRSDataComplete = fjIncidentR["incidentNFIRSDataComplete"] as? Double {
            self.incidentNFIRSDataComplete = incidentNFIRSDataComplete as NSNumber
        }
        
        if let arsonInvestigation = fjIncidentR["arsonInvestigation"] as? Double {
            self.arsonInvestigation = Bool(truncating: arsonInvestigation as NSNumber)
        }
        
        if let incidentCancel = fjIncidentR["incidentCancel"] as? Double {
            self.incidentCancel = Bool(truncating: incidentCancel as NSNumber)
        }
        if let incidentNFIRSDataDate = fjIncidentR["incidentNFIRSDataDate"] as? String {
            self.incidentNFIRSDataDate = incidentNFIRSDataDate
        }
        if let incidentNFIRSDataSaved = fjIncidentR["incidentNFIRSDataSaved"] as? String {
            self.incidentNFIRSDataSaved = incidentNFIRSDataSaved
        }
        if let incidentNumber = fjIncidentR["incidentNumber"] as? String {
            self.incidentNumber = incidentNumber
        }
        if let incidentPhotoTaken = fjIncidentR["incidentPhotoTaken"] as? Double {
            self.incidentPhotoTaken = incidentPhotoTaken as NSNumber
        }
        if let locationAvailable = fjIncidentR["locationAvailable"] as? Double {
            if locationAvailable == 1 {
                self.locationAvailable = true
            } else {
                self.locationAvailable = false
            }
        }
        if let incidentTagsAvailable = fjIncidentR["incidentTagsAvailable"] as? Double {
            if incidentTagsAvailable == 1 {
                self.incidentTagsAvailable = true
            } else {
                self.incidentTagsAvailable = false
            }
        }
        if let incidentSearchDate = fjIncidentR["incidentSearchDate"] as? String {
            self.incidentSearchDate = incidentSearchDate
        }
        if let incidentStreetHyway = fjIncidentR["incidentStreetHyway"] as? String {
            self.incidentStreetHyway = incidentStreetHyway
        }
        if let incidentStreetNumber = fjIncidentR["incidentStreetNumber"] as? String {
            self.incidentStreetNumber = incidentStreetNumber
        }
        if let incidentTime = fjIncidentR["incidentTime"] as? String {
            self.incidentTime = incidentTime
        }
        if let incidentType = fjIncidentR["incidentType"] as? String {
            self.incidentType = incidentType
        }
        if let incidentZipCode = fjIncidentR["incidentZipCode"] as? String {
            self.incidentZipCode = incidentZipCode
        }
        if let incidentZipPlus4 = fjIncidentR["incidentZipPlus4"] as? String {
            self.incidentZipPlus4 = incidentZipPlus4
        }
        if let situationIncidentImage = fjIncidentR["situationIncidentImage"] as? String {
            self.situationIncidentImage = situationIncidentImage
        }
        if let tempIncidentApparatus = fjIncidentR["tempIncidentApparatus"] as? String {
            self.tempIncidentApparatus = tempIncidentApparatus
        }
        if let tempIncidentAssignment = fjIncidentR["tempIncidentAssignment"] as? String {
            self.tempIncidentAssignment = tempIncidentAssignment
        }
        if let tempIncidentFireStation = fjIncidentR["tempIncidentFireStation"] as? String {
            self.tempIncidentFireStation = tempIncidentFireStation
        }
        if let tempIncidentPlatoon = fjIncidentR["tempIncidentPlatoon"] as? String {
            self.tempIncidentPlatoon = tempIncidentPlatoon
        }
        if let arsonInvestigation = fjIncidentR["arsonInvestigation"] as? Bool {
            self.arsonInvestigation = arsonInvestigation
        }
        
        if let fjuSections = self.formDetails {
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
        }
        
        if  let fjIncidentAddress = self.incidentAddressDetails {
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
        }
        
            //MARK: -incidentLocal-
        if let fjIncidentLocal = self.incidentLocalDetails {
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
        }
        
            //MARK: -incidentMap-
        if let fjIncidentMap = self.incidentMapDetails {
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
        }
        
            //MARK: -IncidentNFIRS-
        if let fjIncidentNFIRS = self.incidentNFIRSDetails {
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
        }
        
            // TODO: -CompletedModules-
            // MARK: -IncidentNFIRSKSec-
        if let fjIncidentNFIRSKSec = self.incidentNFIRSKSecDetails {
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
        }
        
            // TODO: -REQUIREDMODULES
            // MARK: -IncidentNFIRSsecL-
        if let fjIncidentNFIRSsecL = self.sectionLDetails {
            if let lRemarks = fjIncidentR["incidentNFIRSSecLNotes"] as? String {
                fjIncidentNFIRSsecL.lRemarks = lRemarks as NSObject
            }
            if let moreRemarks = fjIncidentR["incidentNFIRSSecLMoreRemarks"] as? Bool {
                fjIncidentNFIRSsecL.moreRemarks = moreRemarks
            }
        }
        
            // MARK: -IncidentNFIRSsecM-
        if let fjIncidentNFIRSsecM = self.sectionMDetails {
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
        }
        
            // MARK: -IncidentNotes-
        if let fjIncidentNotes = self.incidentNotesDetails {
            if let incidentSummaryNotesSC = fjIncidentR["incidentSummaryNotes"] as? NSObject {
                fjIncidentNotes.incidentSummaryNotesSC = incidentSummaryNotesSC
            }
            if let note = fjIncidentR["incidentNote"] as? String {
                fjIncidentNotes.incidentNote = note
            }
        }
        
            // TODO: -IncidentResources-
            // MARK: -IncidentTimer-
        if let fjIncidentTimer = self.incidentTimerDetails {
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
        }
        
            // MARK: -ActionsTaken-
        if let fjActionsTaken = self.actionsTakenDetails {
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
        }
        
            // TODO: -IncidentTeam, IncidentTags, UserCrew
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjIncidentR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.fjIncidentCKR = data as NSObject
        
        saveTheSingleCD() {_ in
            completionHandler?()
        }
    }
    
    private func saveTheSingleCD(withCompletion completion: @escaping (String) -> Void) {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"Incident Saved"])
                print("incident we have saved to the cloud")
            }
            completion("Success")
        } catch {
            let nserror = error as NSError
            
            let error = "The Incident+CustomAdditions context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
            print(error)
            completion("Error")
        }
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
