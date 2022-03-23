//
//  ARCrossForm+CustomAdditions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/19/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreLocation

struct ARCFormDashboardData {
    var alarmLatestCampaign: String = ""
    var alarmTotalCampaigns: Int = 0
    var alarmCampaignSmokeInstalled: Int = 0
    var alarmCampaignC02Installed: Int = 0
    var alarmTotalSmokeAlarmsInstalled: Int = 0
    var alarmTotalC02AlarmsInstalled: Int = 0
}

extension ARCrossForm {
    
    
    //    MARK: -CAMPAIGNGUID-
    /// Create a formatted guid for the ARCrossForm Master entry
    /// - Parameters:
    ///   - date: creation date of the ARCrossForm
    ///   - dateFormatter: dateformatter shared from the campaign page
    /// - Returns: returns unique guid with prefix of 41.
    func guidForCampaign(_ date: Date, dateFormatter: DateFormatter)->String {
        let resourceDate = date
        var uuidA:String = NSUUID().uuidString.lowercased()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: resourceDate)
        uuidA = uuidA+dateFrom
        let uuidA1 = "41."+uuidA
        return uuidA1
    }
    
    //    MARK: -ARCFORMGUID-
    /// Create a formatted guid for the ARCrossForm entry
    /// - Parameters:
    ///   - date: creation date of the ARCrossForm
    ///   - dateFormatter: dateformatter shared from the campaign page
    /// - Returns: returns unique guid with prefix of 40.
    func guidForARCForm(_ date: Date, dateFormatter: DateFormatter)->String {
        let resourceDate = date
        var uuidA:String = NSUUID().uuidString.lowercased()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: resourceDate)
        uuidA = uuidA+dateFrom
        let uuidA1 = "40."+uuidA
        return uuidA1
    }
    
    /// Create a formatted date of month,day,year and time
    /// - Parameters:
    ///   - date: Date()
    ///   - dateFormatter:dateFormatter from Form
    /// - Returns: returns formatted date
    func arcCrossFormFullDateFormatted(_ date: Date, dateFormatter: DateFormatter) -> String {
        dateFormatter.dateFormat =  "MM/dd/YYYY HH:mm"
        let fullDate = dateFormatter.string(from: date)
        return fullDate
    }
    
    func arcGetTheDashboardData(forms:[ARCrossForm])->ARCFormDashboardData {
        var data = ARCFormDashboardData.init()
        let total = forms.filter({ $0.arcMaster == true })
        data.alarmTotalCampaigns = total.count
        let last = total.last
        let latest = last?.campaignName
        data.alarmLatestCampaign = latest ?? ""
        let campaignSA = forms.filter({ $0.campaignName == latest })
        var count = 0
        var cArray = [Int]()
//        let saCount = campaignSA.filter({ Int($0.numNewSA ?? "0") ?? 0 > 0 })
        for form in campaignSA {
            if let countSA = form.numNewSA {
                cArray.append(Int(countSA) ?? 0)
            }
            count = cArray.reduce(0,+)
        }
        data.alarmCampaignSmokeInstalled = count
        data.alarmTotalC02AlarmsInstalled = 0
        data.alarmCampaignC02Installed = 0
        cArray.removeAll()
        count = 0
        for form in forms {
            if let countSA = form.numNewSA {
                cArray.append(Int(countSA) ?? 0)
            }
            count = cArray.reduce(0, +)
        }
        data.alarmTotalSmokeAlarmsInstalled = count
        return data
    }
    
    //    MARK: New ARCrossForm for cloud-
    /// Build CKRecord for ARCrossForm
    /// - Parameter dateFormatter: DateFormatter
    /// - Returns: returns a converted core data object as CKRecord
    func newARCrossFormForCloud(dateFormatter: DateFormatter) ->CKRecord {
        
        //        MARK: -Create CKRecord-
        var recordName: String = ""
        if let name = self.arcFormGuid {
            recordName = name
        } else {
            if self.arcCreationDate == nil {
                self.arcCreationDate = Date()
            }
            let createDate = self.arcCreationDate
            recordName = guidForARCForm(createDate!, dateFormatter: dateFormatter)
            self.arcFormGuid = recordName
        }
        let fjARCrossRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjARCrossRID = CKRecord.ID(recordName: recordName, zoneID: fjARCrossRZ.zoneID)
        let arcCKRecord = CKRecord.init(recordType: "ARCrossForm", recordID: fjARCrossRID)
        let _ = CKRecord.Reference(recordID: fjARCrossRID, action: .deleteSelf)
        
        //        MARK: -Build CKRecord with ARC Form Data-
        //        MARK: -STRING ENTRIES-
        arcCKRecord["theEntity"] = "ARCrossForm"
        if let admin = self.adminName {
            arcCKRecord["adminName"] = admin
        }
        if let guid = self.arcFormCampaignGuid {
            arcCKRecord["arcFormCampaignGuid"] = guid
        }
        if let guid = self.arcFormGuid {
            arcCKRecord["arcFormGuid"] = guid
        }
        if let address = self.arcLocationAddress {
            arcCKRecord["arcLocationAddress"] = address
        }
        if let apt = self.arcLocationAptMobile {
            arcCKRecord["arcLocationAptMobile"] = apt
        }
        if let city = self.arcLocationCity {
            arcCKRecord["arcLocationCity"] = city
        }
        if let lat = self.arcLocationLatitude {
            arcCKRecord["arcLocationLatitude"] = lat
        }
        if let long = self.arcLocationLongitude {
            arcCKRecord["arcLocationLongitude"] = long
        }
        if let state = self.arcLocaitonState {
            arcCKRecord["arcLocaitonState"] = state
        }
        if let street = self.arcLocationStreetName {
            arcCKRecord["arcLocationStreetName"] = street
        }
        if let num = self.arcLocationStreetNum {
            arcCKRecord["arcLocationStreetNum"] = num
        }
        if let zip = self.arcLocationZip {
            arcCKRecord["arcLocationZip"] = zip
        }
        if let portal = self.arcPortalSystem {
            arcCKRecord["arcPortalSystem"] = portal
        }
        if let name = self.campaignName {
            arcCKRecord["campaignName"] = name
        }
        if let residence = self.campaignResidenceType {
            arcCKRecord["campaignResidenceType"] = residence
        }
        if let guid = self.fjUserGuid {
            arcCKRecord["fjUserGuid"] = guid
        }
        if let hazard = self.hazard {
            arcCKRecord["hazard"] = hazard
        }
        if let ia17 = self.ia17Under {
            arcCKRecord["ia17Under"] = ia17
        }
        if let ia65 = self.ia65Over {
            arcCKRecord["ia65Over"] = ia65
        }
        if let how = self.iaHowOldSA {
            arcCKRecord["iaHowOldSA"] = how
        }
        if let note = self.iaNotes {
            arcCKRecord["iaNotes"] = note
        }
        if let num = self.iaNumPeople {
            arcCKRecord["iaNumPeople"] = num
        }
        if let pre = self.iaPrexistingSA {
            arcCKRecord["iaPrexistingSA"] = pre
        }
        if let vet = self.iaVets {
            arcCKRecord["iaVets"] = vet
        }
        if let work = self.iaWorkingSA {
            arcCKRecord["iaWorkingSA"] = work
        }
        if let disability = self.iaDisability {
            arcCKRecord["iaDisability"] = disability
        }
        if let installer = self.installerName {
            arcCKRecord["installerName"] = installer
        }
        if let jGuid = self.journalGuid {
            arcCKRecord["journalGuid"] = jGuid
        }
        if let partner = self.localPartner {
            arcCKRecord["localPartner"] = partner
        }
        if let national = self.nationalPartner {
            arcCKRecord["nationalPartner"] = national
        }
        if let batteries = self.numBatteries {
            arcCKRecord["numBatteries"] = batteries
        }
        if let shaker = self.numBedShaker {
            arcCKRecord["numBedShaker"] = shaker
        }
        if let detector = self.numC02detectors {
            arcCKRecord["numC02detectors"] = detector
        }
        if let new = self.numNewSA {
            arcCKRecord["numNewSA"] = new
        }
        if let option = self.option1 {
            arcCKRecord["option1"] = option
        }
        if let optionTwo = self.option2 {
            arcCKRecord["option2"] = optionTwo
        }
        if let cell = self.residentCellNum {
            arcCKRecord["residentCellNum"] = cell
        }
        if let email = self.residentEmail {
            arcCKRecord["residentEmail"] = email
        }
        if let name = self.residentName {
            arcCKRecord["residentName"] = name
        }
        if let phone = self.residentOtherPhone {
            arcCKRecord["residentOtherPhone"] = phone
        }
        
        //        MARK: -ARC dates-
        if let admin = self.adminDate {
            arcCKRecord["adminDate"] = admin
        }
        if let creation = self.arcCreationDate {
            arcCKRecord["arcCreationDate"] = creation
        }
        if let mod = self.arcModDate {
            arcCKRecord["arcModDate"] = mod
        }
        if let end = self.cEndDate {
            arcCKRecord["cEndDate"] = end
        }
        if let start = self.cStartDate {
            arcCKRecord["cStartDate"] = start
        }
        if let install = self.installerDate {
            arcCKRecord["installerDate"] = install
        }
        if let sign = self.residentSigDate {
            arcCKRecord["residentSigDate"] = sign
        }
        
        //        MARK: -ARC Bool Values-
        arcCKRecord["arcBackup"] = true
        if self.arcLocationAvailable {
            arcCKRecord["arcLocationAvailable"] = true
        } else {
            arcCKRecord["arcLocationAvailable"] = false
        }
        if self.arcMaster {
            arcCKRecord["arcMaster"] = true
        } else {
            arcCKRecord["arcMaster"] = false
        }
        if self.campaign {
            arcCKRecord["campaign"] = true
        } else {
            arcCKRecord["campaign"] = false
        }
        if self.cComplete {
            arcCKRecord["cComplete"] = true
        } else {
            arcCKRecord["cComplete"] = false
        }
        if self.createFEPlan {
            arcCKRecord["createFEPlan"] = true
        } else {
            arcCKRecord["createFEPlan"] = false
        }
        if self.installerSigend {
            arcCKRecord["installerSigend"] = true
        } else {
            arcCKRecord["installerSigend"] = false
        }
        if self.localHazard {
            arcCKRecord["localHazard"] = true
        } else {
            arcCKRecord["localHazard"] = false
        }
        if self.receiveSPM {
            arcCKRecord["receiveSPM"] = true
        } else {
            arcCKRecord["receiveSPM"] = false
        }
        if self.recieveEP {
            arcCKRecord["recieveEP"] = true
        } else {
            arcCKRecord["recieveEP"] = false
        }
        if self.residentContactInfo {
        arcCKRecord["residentContactInfo"] = true
        } else {
            arcCKRecord["residentContactInfo"] = false
        }
        if self.residentSigned {
            arcCKRecord["residentSigned"] = true
        } else {
            arcCKRecord["residentSigned"] = false
        }
        if self.reviewFEPlan {
        arcCKRecord["reviewFEPlan"] = true
        } else {
            arcCKRecord["reviewFEPlan"] = false
        }
        
        //        MARK: - ARC ASSETS-
        if self.installerSigend {
            if self.installerSignature != nil {
                arcCKRecord["installerSignature"] = imageForCloudKit(resOrInstall: "Installer")
            }
        }
        if self.residentSigned {
            if self.residentSignature != nil {
                arcCKRecord["residentSignature"] = imageForCloudKit(resOrInstall: "Resident")
            }
        }
        
        //        MARK: -INTEGER-
        arcCKRecord["campaignCount"] = self.campaignCount
        
        //        MARK: -LOCATION-
        if self.arcLocationSC != nil {
            if let location = self.arcLocationSC {
                guard let  archivedData = location as? Data else { return arcCKRecord }
                do {
                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return  arcCKRecord }
                    let location:CLLocation = unarchivedLocation
                     arcCKRecord["arcLocation"] = location
                } catch {
                    print("Unarchiver failed on arcLocation")
                }
            }
        }
        
        return arcCKRecord
    }
    
    //    MARK: -modify CKRecord on changes to ARCrossForm
    /// Modify CKRecord pulled from ARCrossForm CKR
    /// - Parameter ckRecord: CKRecord
    /// - Returns: modified CKRecord from Core Data Object
    func modifyARCrossFormForCloud(ckRecord:CKRecord)->CKRecord {
        let arcCKRecord = ckRecord
        
        //        MARK: -STRING ENTRIES-
        
        if let admin = self.adminName {
            arcCKRecord["adminName"] = admin
        }
        
        if let address = self.arcLocationAddress {
            arcCKRecord["arcLocationAddress"] = address
        }
        if let apt = self.arcLocationAptMobile {
            arcCKRecord["arcLocationAptMobile"] = apt
        }
        if let city = self.arcLocationCity {
            arcCKRecord["arcLocationCity"] = city
        }
        if let lat = self.arcLocationLatitude {
            arcCKRecord["arcLocationLatitude"] = lat
        }
        if let long = self.arcLocationLongitude {
            arcCKRecord["arcLocationLongitude"] = long
        }
        if let state = self.arcLocaitonState {
            arcCKRecord["arcLocaitonState"] = state
        }
        if let street = self.arcLocationStreetName {
            arcCKRecord["arcLocationStreetName"] = street
        }
        if let num = self.arcLocationStreetNum {
            arcCKRecord["arcLocationStreetNum"] = num
        }
        if let zip = self.arcLocationZip {
            arcCKRecord["arcLocationZip"] = zip
        }
        if let portal = self.arcPortalSystem {
            arcCKRecord["arcPortalSystem"] = portal
        }
        if let name = self.campaignName {
            arcCKRecord["campaignName"] = name
        }
        if let residence = self.campaignResidenceType {
            arcCKRecord["campaignResidenceType"] = residence
        }
        if let hazard = self.hazard {
            arcCKRecord["hazard"] = hazard
        }
        if let ia17 = self.ia17Under {
            arcCKRecord["ia17Under"] = ia17
        }
        if let ia65 = self.ia65Over {
            arcCKRecord["ia65Over"] = ia65
        }
        if let how = self.iaHowOldSA {
            arcCKRecord["iaHowOldSA"] = how
        }
        if let note = self.iaNotes {
            arcCKRecord["iaNotes"] = note
        }
        if let num = self.iaNumPeople {
            arcCKRecord["iaNumPeople"] = num
        }
        if let pre = self.iaPrexistingSA {
            arcCKRecord["iaPrexistingSA"] = pre
        }
        if let vet = self.iaVets {
            arcCKRecord["iaVets"] = vet
        }
        if let work = self.iaWorkingSA {
            arcCKRecord["iaWorkingSA"] = work
        }
        if let disability = self.iaDisability {
            arcCKRecord["iaDisability"] = disability
        }
        if let installer = self.installerName {
            arcCKRecord["installerName"] = installer
        }
        if let partner = self.localPartner {
            arcCKRecord["localPartner"] = partner
        }
        if let national = self.nationalPartner {
            arcCKRecord["nationalPartner"] = national
        }
        if let batteries = self.numBatteries {
            arcCKRecord["numBatteries"] = batteries
        }
        if let shaker = self.numBedShaker {
            arcCKRecord["numBedShaker"] = shaker
        }
        if let detector = self.numC02detectors {
            arcCKRecord["numC02detectors"] = detector
        }
        if let new = self.numNewSA {
            arcCKRecord["numNewSA"] = new
        }
        if let option = self.option1 {
            arcCKRecord["option1"] = option
        }
        if let optionTwo = self.option2 {
            arcCKRecord["option2"] = optionTwo
        }
        if let cell = self.residentCellNum {
            arcCKRecord["residentCellNum"] = cell
        }
        if let email = self.residentEmail {
            arcCKRecord["residentEmail"] = email
        }
        if let name = self.residentName {
            arcCKRecord["residentName"] = name
        }
        if let phone = self.residentOtherPhone {
            arcCKRecord["residentOtherPhone"] = phone
        }
        
        //        MARK: -ARC dates-
        if let admin = self.adminDate {
            arcCKRecord["adminDate"] = admin
        }
        if let mod = self.arcModDate {
            arcCKRecord["arcModDate"] = mod
        }
        if let end = self.cEndDate {
            arcCKRecord["cEndDate"] = end
        }
        if let start = self.cStartDate {
            arcCKRecord["cStartDate"] = start
        }
        if let install = self.installerDate {
            arcCKRecord["installerDate"] = install
        }
        if let sign = self.residentSigDate {
            arcCKRecord["residentSigDate"] = sign
        }
        
        //        MARK: -ARC Bool Values-
        arcCKRecord["arcBackup"] = true
        if self.arcLocationAvailable {
            arcCKRecord["arcLocationAvailable"] = true
        } else {
            arcCKRecord["arcLocationAvailable"] = false
        }
        if self.arcMaster {
            arcCKRecord["arcMaster"] = true
        } else {
            arcCKRecord["arcMaster"] = false
        }
        if self.campaign {
            arcCKRecord["campaign"] = true
        } else {
            arcCKRecord["campaign"] = false
        }
        if self.cComplete {
            arcCKRecord["cComplete"] = true
        } else {
            arcCKRecord["cComplete"] = false
        }
        if self.createFEPlan {
            arcCKRecord["createFEPlan"] = true
        } else {
            arcCKRecord["createFEPlan"] = false
        }
        if self.installerSigend {
            arcCKRecord["installerSigend"] = true
        } else {
            arcCKRecord["installerSigend"] = false
        }
        if self.localHazard {
            arcCKRecord["localHazard"] = true
        } else {
            arcCKRecord["localHazard"] = false
        }
        if self.receiveSPM {
            arcCKRecord["receiveSPM"] = true
        } else {
            arcCKRecord["receiveSPM"] = false
        }
        if self.recieveEP {
            arcCKRecord["recieveEP"] = true
        } else {
            arcCKRecord["recieveEP"] = false
        }
        if self.residentContactInfo {
        arcCKRecord["residentContactInfo"] = true
        } else {
            arcCKRecord["residentContactInfo"] = false
        }
        if self.residentSigned {
            arcCKRecord["residentSigned"] = true
        } else {
            arcCKRecord["residentSigned"] = false
        }
        if self.reviewFEPlan {
        arcCKRecord["reviewFEPlan"] = true
        } else {
            arcCKRecord["reviewFEPlan"] = false
        }
        
        //        MARK: - ARC ASSETS-
        if self.installerSigend {
            if self.installerSignature != nil {
                arcCKRecord["installerSignature"] = imageForCloudKit(resOrInstall: "Installer")
            }
        }
        if self.residentSigned {
            if self.residentSignature != nil {
                arcCKRecord["residentSignature"] = imageForCloudKit(resOrInstall: "Resident")
            }
        }
        
        //        MARK: -LOCATION-
        if self.arcLocationSC != nil {
            if let location = self.arcLocationSC {
                guard let  archivedData = location as? Data else { return arcCKRecord }
                do {
                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return  arcCKRecord }
                    let location:CLLocation = unarchivedLocation
                     arcCKRecord["arcLocation"] = location
                } catch {
                    print("Unarchiver failed on arcLocation")
                }
            }
        }
        
        return arcCKRecord
    }
    
    //    MARK: -update from CloudKit to ARCForm-
    /// Download from CloudKit CKRecord for Core Data Object
    /// - Parameter ckRecord: CKRecord
    func updateARCrossFormFromTheCloud(ckRecord: CKRecord) {
        let arcCKRecord = ckRecord
        
        //        MARK: -Build CKRecord with ARC Form Data-
        //        MARK: -STRING ENTRIES-
        if let admin =  arcCKRecord["adminName"] as? String {
            self.adminName = admin
        }
        if let guid = arcCKRecord["arcFormCampaignGuid"] as? String {
            self.arcFormCampaignGuid  = guid
        }
        if let guid = arcCKRecord["arcFormGuid"] as? String {
            self.arcFormGuid  = guid
        }
        if let address = arcCKRecord["arcLocationAddress"] as? String {
            self.arcLocationAddress = address
        }
        if let apt = arcCKRecord["arcLocationAptMobile"] as? String {
            self.arcLocationAptMobile = apt
        }
        if let city = arcCKRecord["arcLocationCity"] as? String {
            self.arcLocationCity = city
        }
        if let lat = arcCKRecord["arcLocationLatitude"] as? String {
            self.arcLocationLatitude = lat
        }
        if let long = arcCKRecord["arcLocationLongitude"] as? String {
            self.arcLocationLongitude = long
        }
        if let state = arcCKRecord["arcLocaitonState"] as? String{
            self.arcLocaitonState = state
        }
        if let street = arcCKRecord["arcLocationStreetName"] as? String {
            self.arcLocationStreetName = street
        }
        if let num = arcCKRecord["arcLocationStreetNum"] as? String {
            self.arcLocationStreetNum = num
        }
        if let zip = arcCKRecord["arcLocationZip"] as? String {
            self.arcLocationZip = zip
        }
        if let portal = arcCKRecord["arcPortalSystem"] as? String {
            self.arcPortalSystem = portal
        }
        if let name = arcCKRecord["campaignName"] as? String {
            self.campaignName = name
        }
        if let residence = arcCKRecord["campaignResidenceType"] as? String {
            self.campaignResidenceType = residence
        }
        if let guid = arcCKRecord["fjUserGuid"] as? String {
            self.fjUserGuid = guid
        }
        if let hazard = arcCKRecord["hazard"] as? String {
            self.hazard = hazard
        }
        if let ia17 = arcCKRecord["ia17Under"] as? String {
            self.ia17Under = ia17
        }
        if let ia65 = arcCKRecord["ia65Over"] as? String {
            self.ia65Over = ia65
        }
        if let how = arcCKRecord["iaHowOldSA"] as? String {
            self.iaHowOldSA = how
        }
        if let note = arcCKRecord["iaNotes"] as? String {
            self.iaNotes = note
        }
        if let num = arcCKRecord["iaNumPeople"] as? String {
            self.iaNumPeople = num
        }
        if let pre = arcCKRecord["iaPrexistingSA"] as? String {
            self.iaPrexistingSA = pre
        }
        if let vet = arcCKRecord["iaVets"] as? String {
            self.iaVets = vet
        }
        if let work = arcCKRecord["iaWorkingSA"] as? String {
            self.iaWorkingSA = work
        }
        if let disability = arcCKRecord["iaDisability"] as? String {
            self.iaDisability = disability
        }
        if let installer = arcCKRecord["installerName"] as? String {
            self.installerName = installer
        }
        if let jGuid = arcCKRecord["journalGuid"] as? String {
            self.journalGuid = jGuid
        }
        if let partner = arcCKRecord["localPartner"] as? String {
            self.localPartner = partner
        }
        if let national = arcCKRecord["nationalPartner"] as? String {
            self.nationalPartner = national
        }
        if let batteries = arcCKRecord["numBatteries"] as? String {
            self.numBatteries = batteries
        }
        if let shaker = arcCKRecord["numBedShaker"] as? String {
            self.numBedShaker = shaker
        }
        if let detector = arcCKRecord["numC02detectors"] as? String {
            self.numC02detectors = detector
        }
        if let new = arcCKRecord["numNewSA"] as? String {
            self.numNewSA = new
        }
        if let option = arcCKRecord["option1"] as? String {
            self.option1 = option
        }
        if let optionTwo = arcCKRecord["option2"] as? String {
            self.option2 = optionTwo
        }
        if let cell = arcCKRecord["residentCellNum"] as? String {
            self.residentCellNum = cell
        }
        if let email = arcCKRecord["residentEmail"] as? String {
            self.residentEmail = email
        }
        if let name = arcCKRecord["residentName"] as? String {
            self.residentName = name
        }
        if let phone = arcCKRecord["residentOtherPhone"] as? String {
            self.residentOtherPhone = phone
        }
        
        //        MARK: -ARC dates-
        if let admin = arcCKRecord["adminDate"] as? Date {
            self.adminDate = admin
        }
        if let creation = arcCKRecord["arcCreationDate"] as? Date {
            self.arcCreationDate = creation
        }
        if let mod = arcCKRecord["arcModDate"] as? Date {
            self.arcModDate = mod
        }
        if let end = arcCKRecord["cEndDate"] as? Date {
            self.cEndDate = end
        }
        if let start = arcCKRecord["cStartDate"] as? Date {
            self.cStartDate = start
        }
        if let install = arcCKRecord["installerDate"] as? Date {
            self.installerDate = install
        }
        if let sign = arcCKRecord["residentSigDate"] as? Date {
            self.residentSigDate = sign
        }
        
        //        MARK: -ARC Bool Values-
        self.arcBackup = true
        if arcCKRecord["arcLocationAvailable"] ?? false {
            self.arcLocationAvailable = true
        } else {
            self.arcLocationAvailable = false
        }
        if arcCKRecord["arcMaster"] ?? false {
            self.arcMaster = true
        } else {
            self.arcMaster = false
        }
        if arcCKRecord["campaign"] ?? false {
            self.campaign = true
        } else {
            self.campaign = true
        }
        if arcCKRecord["cComplete"] ?? false {
            self.cComplete = true
        } else {
            self.cComplete = false
        }
        if arcCKRecord["createFEPlan"] ?? false {
            self.createFEPlan = true
        } else {
            self.createFEPlan = false
        }
        if arcCKRecord["installerSigend"] ?? false {
            self.installerSigend = true
        } else {
            self.installerSigend = false
        }
        if arcCKRecord["localHazard"] ?? false {
            self.localHazard = true
        } else {
            self.localHazard = false
        }
        if arcCKRecord["receiveSPM"] ?? false {
            self.receiveSPM = true
        } else {
            self.receiveSPM = false
        }
        if arcCKRecord["recieveEP"] ?? false {
            self.recieveEP = true
        } else {
            self.recieveEP = false
        }
        if arcCKRecord["residentContactInfo"] ?? false {
            self.residentContactInfo = true
        } else {
            self.residentContactInfo = false
        }
        if arcCKRecord["residentSigned"] ?? false {
            self.residentSigned = true
        } else {
            self.residentSigned = false
        }
        if arcCKRecord["reviewFEPlan"] ?? false {
            self.reviewFEPlan = true
        } else {
            self.reviewFEPlan = true
        }
        
        //        MARK: - ARC ASSETS-
        if self.installerSigend {
            if let data: CKAsset = arcCKRecord["installerSignature"] {
                self.installerSignature = imageDataFromCloudKit(asset: data)
            }
        }
        if self.residentSigned {
            if let data: CKAsset = arcCKRecord["residentSignature"] {
                self.residentSignature = imageDataFromCloudKit(asset: data)
            }
        }
        
        //        MARK: -INTEGER-
        if arcCKRecord["campaignCount"] != nil {
            self.campaignCount = arcCKRecord["campaignCount"] as! Int64
        }
        //        MARK: -LOCATION-
        if arcCKRecord["arcLocation"] != nil {
            let location = arcCKRecord["arcLocation"] as! CLLocation
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                self.arcLocationSC = data as NSObject
            } catch {
                print("got an error here")
            }
        }
        
        
        
        //                MARK: -Save encoded ckrecord-
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        arcCKRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.arcFormCKR = data as NSObject
        
        
        saveToCD()
        
    }

    
    //    MARK: -Image to CKAsset-
    /// Create CKAsset from data of signature
    /// - Parameter resOrInstall: Resident : Installer
    /// - Returns: date converted to CKAsset
    func imageForCloudKit(resOrInstall: String ) ->CKAsset {
        var asset: CKAsset!
        var image: UIImage!
        var timeStamp = Date()
        if resOrInstall == "Resident" {
            timeStamp = self.residentSigDate ?? Date()
        } else if resOrInstall == "Installer" {
            timeStamp = self.installerDate ?? Date()
        }
        let fileManager = FileManager.default
        let documentsDirectory = getDirectoryPath()
        let ts = timeStamp.timeStamp()
        let photoName = "\(resOrInstall)_\(ts).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(photoName)
        var imageAvailable: Bool = false
        if resOrInstall == "Resident" {
            if self.residentSignature != nil {
                image = UIImage.init(data: self.residentSignature!)!
                imageAvailable = true
            }
        } else {
            if self.installerSignature != nil {
                image = UIImage.init(data: self.installerSignature!)!
                imageAvailable = true
            }
        }
        if let imageData = image.jpegData(compressionQuality: 1.0) , !fileManager.fileExists(atPath: fileURL.path)
        {
            do {
                try imageData.write(to: fileURL)
                print("file saved")
                asset = CKAsset.init(fileURL: fileURL)
            } catch {
                print("Error trying to saving resident image to directory \(error)")
            }
        }
        return asset
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
    
    //    MARK: -Get the directory path
    func getDirectoryPath() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory
    }
    
    //    MARK: -save to context once arcFormCKR is built in download from CloudKit
    fileprivate func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            print("ARCrossForm+CustomAdditions.swift we have saved from the cloud")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"ARCForm saved"])
            }
        } catch {
            
            let nserror = error as NSError
            
            let errorMessage = "ARCrossForm+CustomAdditions saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    
    /// old new arcCrossForm
    /// - Returns: deprecated
   /*func newARCrossFormToTheCloud()->CKRecord {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "YYYYDDDMMHHmmAAAAAAAA"
//        let dateFormatted = dateFormatter.string(from:self.arcCreationDate ?? Date())
//        let name = "ARCrossForm \(dateFormatted)"
        var recordName: String = ""
        if let name = self.arcFormGuid {
            recordName = name
        } else {
            let iGuidDate = GuidFormatter.init(date:self.arcCreationDate!)
            let iGuid:String = iGuidDate.formatGuid()
            self.arcFormGuid = "40."+iGuid
            recordName = "40."+iGuid
        }
        let fjARCrossRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjARCrossRID = CKRecord.ID(recordName: recordName, zoneID: fjARCrossRZ.zoneID)
        let fjARCrossRecord = CKRecord.init(recordType: "ARCrossForm", recordID: fjARCrossRID)
//        let fjARCrossRef = CKRecord.Reference(recordID: fjARCrossRID, action: .deleteSelf)
        
        //     MARK: -INTEGERS
        fjARCrossRecord["campaignCount"] = self.campaignCount
        //     MARK: -Strings
        if let adminName = self.adminName {
            fjARCrossRecord["adminName"] = adminName
        }
        if let arcFormCampaignGuid = self.arcFormCampaignGuid {
            fjARCrossRecord["arcFormCampaignGuid"] = arcFormCampaignGuid
        }
        if let arcFormGuid = self.arcFormGuid {
            fjARCrossRecord["arcFormGuid"] = arcFormGuid
        }
        if let arcLocaitonState = self.arcLocaitonState {
            fjARCrossRecord["arcLocaitonState"] = arcLocaitonState
        }
        if let arcLocationAddress = self.arcLocationAddress {
            fjARCrossRecord["arcLocationAddress"] = arcLocationAddress
        }
        if let arcLocationAptMobile = self.arcLocationAptMobile {
            fjARCrossRecord["arcLocationAptMobile"] = arcLocationAptMobile
        }
        if let arcLocationCity = self.arcLocationCity {
            fjARCrossRecord["arcLocationCity"] = arcLocationCity
        }
        if let arcLocationZip = self.arcLocationZip {
            fjARCrossRecord["arcLocationZip"] = arcLocationZip
        }
        if let campaignName = self.campaignName {
            fjARCrossRecord["campaignName"] = campaignName
        }
        if let fjUserGuid = self.fjUserGuid {
            fjARCrossRecord["fjUserGuid"] = fjUserGuid
        }
        if let hazard = self.hazard {
            fjARCrossRecord["hazard"] = hazard
        }
        if let ia17Under = self.ia17Under {
            fjARCrossRecord["ia17Under"] = ia17Under
        }
        if let ia65Over = self.ia65Over {
            fjARCrossRecord["ia65Over"] = ia65Over
        }
        if let iaDisability = self.iaDisability {
            fjARCrossRecord["iaDisability"] = iaDisability
        }
        if let iaNotes = self.iaNotes {
            fjARCrossRecord["iaNotes"] = iaNotes
        }
        if let iaNumPeople = self.iaNumPeople {
            fjARCrossRecord["iaNumPeople"] = iaNumPeople
        }
        if let iaPrexistingSA = self.iaPrexistingSA {
            fjARCrossRecord["iaPrexistingSA"] = iaPrexistingSA
        }
        if let iaVets = self.iaVets {
            fjARCrossRecord["iaVets"] = iaVets
        }
        if let iaWorkingSA = self.iaWorkingSA {
            fjARCrossRecord["iaWorkingSA"] = iaWorkingSA
        }
        if let installerName = self.installerName {
            fjARCrossRecord["installerName"] = installerName
        }
        if let journalGuid = self.journalGuid {
            fjARCrossRecord["journalGuid"] = journalGuid
        }
        if let localPartner = self.localPartner {
            fjARCrossRecord["localPartner"] = localPartner
        }
        if let nationalPartner = self.nationalPartner {
            fjARCrossRecord["nationalPartner"] = nationalPartner
        }
        if let numBatteries = self.numBatteries {
            fjARCrossRecord["numBatteries"] = numBatteries
        }
        if let numBedShaker = self.numBedShaker {
            fjARCrossRecord["numBedShaker"] = numBedShaker
        }
        if let numNewSA = self.numNewSA {
            fjARCrossRecord["numNewSA"] = numNewSA
        }
        if let option1 = self.option1 {
            fjARCrossRecord["option1"] = option1
        }
        if let option2 = self.option2 {
            fjARCrossRecord["option2"] = option2
        }
        if let residentCellNum = self.residentCellNum {
            fjARCrossRecord["residentCellNum"] = residentCellNum
        }
        if let residentEmail = self.residentEmail{
            fjARCrossRecord["residentEmail"] = residentEmail
        }
        if let residentName = self.residentName{
            fjARCrossRecord["residentName"] = residentName
        }
        if let residentOtherPhone = self.residentOtherPhone{
            fjARCrossRecord["residentOtherPhone"] = residentOtherPhone
        }
        // MARK: -theEntity
        fjARCrossRecord["theEntity"] = "ARCrossForm"
        //     MARK: -BOOL
        if self.arcBackup {
            fjARCrossRecord["arcBackup"] = true
        } else {
            fjARCrossRecord["arcBackup"] = false
        }
        if self.arcLocationAvailable {
            fjARCrossRecord["arcLocationAvailable"] = true
        } else {
            fjARCrossRecord["arcLocationAvailable"] = false
        }
        if self.arcMaster {
            fjARCrossRecord["arcMaster"] = true
        } else {
            fjARCrossRecord["arcMaster"] = false
        }
        if self.campaign {
            fjARCrossRecord["campaign"] = true
        } else {
            fjARCrossRecord["campaign"] = false
        }
        if self.cComplete {
            fjARCrossRecord["cComplete"] = true
        } else {
            fjARCrossRecord["cComplete"] = false
        }
        if self.createFEPlan {
            fjARCrossRecord["createFEPlan"] = true
        } else {
            fjARCrossRecord["createFEPlan"] = false
        }
        if self.installerSigend {
            fjARCrossRecord["installerSigend"] = true
        } else {
            fjARCrossRecord["installerSigend"] = false
        }
        if self.localHazard {
            fjARCrossRecord["localHazard"] = true
        } else {
            fjARCrossRecord["localHazard"] = false
        }
        if self.residentContactInfo {
            fjARCrossRecord["residentContactInfo"] = true
        } else {
            fjARCrossRecord["residentContactInfo"] = false
        }
        if self.residentSigned {
            fjARCrossRecord["residentSigned"] = true
        } else {
            fjARCrossRecord["residentSigned"] = false
        }
        if self.reviewFEPlan {
            fjARCrossRecord["reviewFEPlan"] = true
        } else {
            fjARCrossRecord["reviewFEPlan"] = false
        }
        //     MARK: -DATE
        if let adminDate:Date = self.adminDate {
            fjARCrossRecord["adminDate"] = adminDate
        }
        if let createDate:Date = self.arcCreationDate {
            fjARCrossRecord["arcCreationDate"] = createDate
        }
        if let modDate:Date = self.arcModDate {
            fjARCrossRecord["arcModDate"] = modDate
        }
        if let endDate:Date = self.cEndDate {
            fjARCrossRecord["cEndDate"] = endDate
        }
        if let startDate:Date = self.cStartDate {
            fjARCrossRecord["cStartDate"] = startDate
        }
        if let installerDate:Date = self.installerDate {
            fjARCrossRecord["installerDate"] = installerDate
        }
        if let residentSignDate:Date = self.residentSigDate {
            fjARCrossRecord["residentSigDate"] = residentSignDate
        }
        //     MARK: -ASSETS
        if self.installerSigend {
//            fjARCrossRecord["installerSignature"] = self.installerSignature
        }
        if self.residentSigned {
//            fjARCrossRecord["residentSignature"] = self.residentSignature
        }
        //     MARK: -TRANSFORM
        if self.arcLocation != nil {
            fjARCrossRecord["arcLocation"] = self.arcLocation as! CLLocation
        }
        
        return fjARCrossRecord
    }*/
    
    /// old modified arcForm
    /// - Parameter ckRecord:ckrecord
    /// - Returns: deprecated
    /*func modifyARCrossFormForCloud(ckRecord:CKRecord)->CKRecord {
        let fjARCrossRecord = ckRecord
        
        //     MARK: -INTEGERS
        fjARCrossRecord["campaignCount"] = self.campaignCount
        // MARK: -theEntity
        fjARCrossRecord["theEntity"] = "ARCrossForm"
        //     MARK: -Strings
        if let adminName = self.adminName {
            fjARCrossRecord["adminName"] = adminName
        }
        if let arcFormCampaignGuid = self.arcFormCampaignGuid {
            fjARCrossRecord["arcFormCampaignGuid"] = arcFormCampaignGuid
        }
        if let arcFormGuid = self.arcFormGuid {
            fjARCrossRecord["arcFormGuid"] = arcFormGuid
        }
        if let arcLocaitonState = self.arcLocaitonState {
            fjARCrossRecord["arcLocaitonState"] = arcLocaitonState
        }
        if let arcLocationAddress = self.arcLocationAddress {
            fjARCrossRecord["arcLocationAddress"] = arcLocationAddress
        }
        if let arcLocationAptMobile = self.arcLocationAptMobile {
            fjARCrossRecord["arcLocationAptMobile"] = arcLocationAptMobile
        }
        if let arcLocationCity = self.arcLocationCity {
            fjARCrossRecord["arcLocationCity"] = arcLocationCity
        }
        if let arcLocationZip = self.arcLocationZip {
            fjARCrossRecord["arcLocationZip"] = arcLocationZip
        }
        if let campaignName = self.campaignName {
            fjARCrossRecord["campaignName"] = campaignName
        }
        if let fjUserGuid = self.fjUserGuid {
            fjARCrossRecord["fjUserGuid"] = fjUserGuid
        }
        if let hazard = self.hazard {
            fjARCrossRecord["hazard"] = hazard
        }
        if let ia17Under = self.ia17Under {
            fjARCrossRecord["ia17Under"] = ia17Under
        }
        if let ia65Over = self.ia65Over {
            fjARCrossRecord["ia65Over"] = ia65Over
        }
        if let iaDisability = self.iaDisability {
            fjARCrossRecord["iaDisability"] = iaDisability
        }
        if let iaNotes = self.iaNotes {
            fjARCrossRecord["iaNotes"] = iaNotes
        }
        if let iaNumPeople = self.iaNumPeople {
            fjARCrossRecord["iaNumPeople"] = iaNumPeople
        }
        if let iaPrexistingSA = self.iaPrexistingSA {
            fjARCrossRecord["iaPrexistingSA"] = iaPrexistingSA
        }
        if let iaVets = self.iaVets {
            fjARCrossRecord["iaVets"] = iaVets
        }
        if let iaWorkingSA = self.iaWorkingSA {
            fjARCrossRecord["iaWorkingSA"] = iaWorkingSA
        }
        if let installerName = self.installerName {
            fjARCrossRecord["installerName"] = installerName
        }
        if let journalGuid = self.journalGuid {
            fjARCrossRecord["journalGuid"] = journalGuid
        }
        if let localPartner = self.localPartner {
            fjARCrossRecord["localPartner"] = localPartner
        }
        if let nationalPartner = self.nationalPartner {
            fjARCrossRecord["nationalPartner"] = nationalPartner
        }
        if let numBatteries = self.numBatteries {
            fjARCrossRecord["numBatteries"] = numBatteries
        }
        if let numBedShaker = self.numBedShaker {
            fjARCrossRecord["numBedShaker"] = numBedShaker
        }
        if let numNewSA = self.numNewSA {
            fjARCrossRecord["numNewSA"] = numNewSA
        }
        if let option1 = self.option1 {
            fjARCrossRecord["option1"] = option1
        }
        if let option2 = self.option2 {
            fjARCrossRecord["option2"] = option2
        }
        if let residentCellNum = self.residentCellNum {
            fjARCrossRecord["residentCellNum"] = residentCellNum
        }
        if let residentEmail = self.residentEmail{
            fjARCrossRecord["residentEmail"] = residentEmail
        }
        if let residentName = self.residentName{
            fjARCrossRecord["residentName"] = residentName
        }
        if let residentOtherPhone = self.residentOtherPhone{
            fjARCrossRecord["residentOtherPhone"] = residentOtherPhone
        }
        // MARK: -theEntity
        fjARCrossRecord["theEntity"] = "ARCrossForm"
        //     MARK: -BOOL
        if self.arcBackup {
            fjARCrossRecord["arcBackup"] = true
        } else {
            fjARCrossRecord["arcBackup"] = false
        }
        if self.arcLocationAvailable {
            fjARCrossRecord["arcLocationAvailable"] = true
        } else {
            fjARCrossRecord["arcLocationAvailable"] = false
        }
        if self.arcMaster {
            fjARCrossRecord["arcMaster"] = true
        } else {
            fjARCrossRecord["arcMaster"] = false
        }
        if self.campaign {
            fjARCrossRecord["campaign"] = true
        } else {
            fjARCrossRecord["campaign"] = false
        }
        if self.cComplete {
            fjARCrossRecord["cComplete"] = true
        } else {
            fjARCrossRecord["cComplete"] = false
        }
        if self.createFEPlan {
            fjARCrossRecord["createFEPlan"] = true
        } else {
            fjARCrossRecord["createFEPlan"] = false
        }
        if self.installerSigend {
            fjARCrossRecord["installerSigend"] = true
        } else {
            fjARCrossRecord["installerSigend"] = false
        }
        if self.localHazard {
            fjARCrossRecord["localHazard"] = true
        } else {
            fjARCrossRecord["localHazard"] = false
        }
        if self.residentContactInfo {
            fjARCrossRecord["residentContactInfo"] = true
        } else {
            fjARCrossRecord["residentContactInfo"] = false
        }
        if self.residentSigned {
            fjARCrossRecord["residentSigned"] = true
        } else {
            fjARCrossRecord["residentSigned"] = false
        }
        if self.reviewFEPlan {
            fjARCrossRecord["reviewFEPlan"] = true
        } else {
            fjARCrossRecord["reviewFEPlan"] = false
        }
        //     MARK: -DATE
        if let adminDate:Date = self.adminDate {
            fjARCrossRecord["adminDate"] = adminDate
        }
        if let createDate:Date = self.arcCreationDate {
            fjARCrossRecord["arcCreationDate"] = createDate
        }
        if let modDate:Date = self.arcModDate {
            fjARCrossRecord["arcModDate"] = modDate
        }
        if let endDate:Date = self.cEndDate {
            fjARCrossRecord["cEndDate"] = endDate
        }
        if let startDate:Date = self.cStartDate {
            fjARCrossRecord["cStartDate"] = startDate
        }
        if let installerDate:Date = self.installerDate {
            fjARCrossRecord["installerDate"] = installerDate
        }
        if let residentSignDate:Date = self.residentSigDate {
            fjARCrossRecord["residentSigDate"] = residentSignDate
        }
        //     MARK: -ASSETS
        // TODO: -signatures
        if self.installerSigend {
            let asset = imageForCloudKit(type: "installerSignature")
            fjARCrossRecord["installerSignature"] = asset
        }
        let residentSig: Bool = fjARCrossRecord["residentSigned"] ?? false
        if residentSig {
            let asset = imageForCloudKit(type: "residentSignature")
            fjARCrossRecord["residentSignature"] = asset
        }
        //     MARK: -TRANSFORM
        if self.arcLocation != nil {
            fjARCrossRecord["arcLocation"] = self.arcLocation as! CLLocation
        }
        return fjARCrossRecord
    }*/
    
    /// old from cloud to arcForm
    /// - Parameter ckRecord: deprecated
    /*func updateARCrossFormFromTheCloud(ckRecord: CKRecord) {
        let fjARCrossRecord = ckRecord
        
        //     MARK: -INTEGERS
        self.campaignCount = fjARCrossRecord["campaignCount"] ?? 0
        //     MARK: -Strings
        if let adminName:String = fjARCrossRecord["adminName"] {
            self.adminName = adminName
        }
        if let arcFormCampaignGuid:String = fjARCrossRecord["arcFormCampaignGuid"] {
            self.arcFormCampaignGuid = arcFormCampaignGuid
        }
        if let arcFormGuid:String = fjARCrossRecord["arcFormGuid"] {
            self.arcFormGuid = arcFormGuid
        }
        if let arcLocaitonState:String = fjARCrossRecord["arcLocaitonState"] {
            self.arcLocaitonState = arcLocaitonState
        }
        if let arcLocationAddress:String = fjARCrossRecord["arcLocationAddress"] {
            self.arcLocationAddress = arcLocationAddress
        }
        if let arcLocationAptMobile:String = fjARCrossRecord["arcLocationAptMobile"] {
            self.arcLocationAptMobile = arcLocationAptMobile
        }
        if let arcLocationCity:String = fjARCrossRecord["arcLocationCity"] {
            self.arcLocationCity = arcLocationCity
        }
        if let arcLocationZip:String = fjARCrossRecord["arcLocationZip"] {
            self.arcLocationZip = arcLocationZip
        }
        if let campaignName:String = fjARCrossRecord["campaignName"] {
            self.campaignName = campaignName
        }
        if let fjUserGuid:String = fjARCrossRecord["fjUserGuid"] {
            self.fjUserGuid = fjUserGuid
        }
        if let hazard:String = fjARCrossRecord["hazard"] {
            self.hazard = hazard
        }
        if let ia17Under:String = fjARCrossRecord["ia17Under"] {
            self.ia17Under = ia17Under
        }
        if let ia65Over:String = fjARCrossRecord["ia65Over"] {
            self.ia65Over = ia65Over
        }
        if let iaDisability:String = fjARCrossRecord["iaDisability"] {
            self.iaDisability = iaDisability
        }
        if let iaNotes:String = fjARCrossRecord["iaNotes"] {
            self.iaNotes = iaNotes
        }
        if let iaNumPeople:String = fjARCrossRecord["iaNumPeople"] {
            self.iaNumPeople = iaNumPeople
        }
        if let iaPrexistingSA:String = fjARCrossRecord["iaPrexistingSA"] {
            self.iaPrexistingSA = iaPrexistingSA
        }
        if let iaVets:String = fjARCrossRecord["iaVets"] {
            self.iaVets = iaVets
        }
        if let iaWorkingSA:String = fjARCrossRecord["iaWorkingSA"] {
            self.iaWorkingSA = iaWorkingSA
        }
        if let installerName:String = fjARCrossRecord["installerName"] {
            self.installerName = installerName
        }
        if let journalGuid:String = fjARCrossRecord["journalGuid"] {
            self.journalGuid = journalGuid
        }
        if let localPartner:String = fjARCrossRecord["localPartner"] {
            self.localPartner = localPartner
        }
        if let nationalPartner:String = fjARCrossRecord["nationalPartner"] {
            self.nationalPartner = nationalPartner
        }
        if let numBatteries:String = fjARCrossRecord["numBatteries"] {
            self.numBatteries = numBatteries
        }
        if let numBedShaker:String = fjARCrossRecord["numBedShaker"] {
            self.numBedShaker = numBedShaker
        }
        if let numNewSA:String = fjARCrossRecord["numNewSA"] {
            self.numNewSA = numNewSA
        }
        if let option1:String = fjARCrossRecord["option1"] {
            self.option1 = option1
        }
        if let option2:String = fjARCrossRecord["option2"] {
            self.option2 = option2
        }
        if let residentCellNum:String = fjARCrossRecord["residentCellNum"] {
            self.residentCellNum = residentCellNum
        }
        if let residentEmail:String = fjARCrossRecord["residentEmail"]{
            self.residentEmail = residentEmail
        }
        if let residentName:String = fjARCrossRecord["residentName"] {
            self.residentName = residentName
        }
        if let residentOtherPhone:String = fjARCrossRecord["residentOtherPhone"] {
            self.residentOtherPhone = residentOtherPhone
        }
        //     MARK: -BOOL
        self.arcBackup = fjARCrossRecord["arcBackup"] as? Bool ?? false
        self.arcLocationAvailable = fjARCrossRecord["arcLocationAvailable"] as? Bool ?? false
        self.arcMaster = fjARCrossRecord["arcMaster"] as? Bool ?? false
        self.campaign = fjARCrossRecord["campaign"] as? Bool ?? false
        self.cComplete = fjARCrossRecord["cComplete"] as? Bool ?? false
        self.createFEPlan = fjARCrossRecord["createFEPlan"] as? Bool ?? false
        self.installerSigend = fjARCrossRecord["installerSigend"] as? Bool ?? false
        self.localHazard = fjARCrossRecord["localHazard"] as? Bool ?? false
        self.residentContactInfo = fjARCrossRecord["residentContactInfo"] as? Bool ?? false
        self.residentSigned = fjARCrossRecord["residentSigned"] as? Bool ?? false
        self.reviewFEPlan = fjARCrossRecord["reviewFEPlan"] as? Bool ?? false
        //     MARK: -DATE
        if let adminDate:Date = fjARCrossRecord["adminDate"] {
            self.adminDate = adminDate
        }
        if let createDate:Date = fjARCrossRecord["arcCreationDate"] {
            self.arcCreationDate = createDate
        }
        if let modDate:Date = fjARCrossRecord["arcModDate"] {
            self.arcModDate = modDate
        }
        if let endDate:Date = fjARCrossRecord["cEndDate"] {
            self.cEndDate = endDate
        }
        if let startDate:Date = fjARCrossRecord["cStartDate"] {
            self.cStartDate = startDate
        }
        if let installerDate:Date = fjARCrossRecord["installerDate"] {
            self.installerDate = installerDate
        }
        if let residentSignDate:Date = fjARCrossRecord["residentSigDate"] {
            self.residentSigDate = residentSignDate
        }
        //     MARK: -ASSETS
        let installerSig: Bool = fjARCrossRecord["installerSigend"] ?? false
       if installerSig {
             self.installerSignature = imageDataFromCloudKit(asset: fjARCrossRecord["installerSignature"]!)
        }
        let residentSig: Bool = fjARCrossRecord["residentSigned"] ?? false
        if residentSig {
            self.residentSignature = imageDataFromCloudKit(asset: fjARCrossRecord["residentSignature"]!)
        }
        //     MARK: -TRANSFORM
        if fjARCrossRecord["arcLocation"] as? NSObject != nil {
            self.arcLocation = fjARCrossRecord["arcLocation"] as? NSObject
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjARCrossRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.arcFormCKR = data as NSObject
        saveToCD()
    }*/
    
   /* fileprivate func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            print("ARCrossForm+CustomAdditions.swift we have saved from the cloud")
        } catch {
            
            let nserror = error as NSError
            
            let errorMessage = "ARCrossForm+CustomAdditions saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }*/
    
    /*func imageForCloudKit(type: String) ->CKAsset {
        var asset: CKAsset!
        var image: UIImage!
        let timeStamp = self.arcCreationDate
        let fileManager = FileManager.default
        let documentsDirectory = getDirectoryPath()
        let ts = timeStamp!.timeStamp()
        let photoName = "\(type)_\(ts).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(photoName)
        if type == "residentSignature" {
            if (self.residentSignature != nil ) {
                image = UIImage.init(data: self.residentSignature!)
            }
        } else {
            if (self.installerSignature != nil) {
                image  = UIImage.init(data: self.installerSignature!)
            }
        }
        if let imageData = image.jpegData(compressionQuality: 1.0) , !fileManager.fileExists(atPath: fileURL.path)
        {
            do {
                try imageData.write(to: fileURL)
                print("file saved")
                asset = CKAsset.init(fileURL: fileURL)
            } catch {
                print("Error trying to saving resident image to directory \(error)")
            }
        }
        return asset
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

    func getDirectoryPath() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory
    }*/
}
