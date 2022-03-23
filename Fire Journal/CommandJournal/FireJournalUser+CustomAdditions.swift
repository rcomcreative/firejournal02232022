//
//  FireJournalUser+CustomAdditions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/10/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreLocation

extension FireJournalUser {
    
    //    MARK: -FireJournalUser GUID-
    /// Create a formatted guid for the journal entry
    /// - Parameters:
    ///   - date: creation date of the ARCrossForm
    ///   - dateFormatter: dateformatter shared from the campaign page
    /// - Returns: returns unique guid with prefix of 01.
    func guidForFireJournalUser(_ date: Date, dateFormatter: DateFormatter)->String {
        let resourceDate = date
        var uuidA:String = NSUUID().uuidString.lowercased()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: resourceDate)
        uuidA = uuidA+dateFrom
        let uuidA1 = "00."+uuidA
        return uuidA1
    }
    
    
    //    MARK: -TIME FORMAT FOR FireJournalUser-
    /// Formatted date for journal entry date and time
    /// - Parameters:
    ///   - date: creationDate
    ///   - dateFormatter: dateFormatter from CampaignTVC
    /// - Returns: returns full date time in string format
    func fireJournalUserFullDateFormatted(_ date: Date, dateFormatter: DateFormatter) -> String {
        dateFormatter.dateFormat =  "MM/dd/YYYY HH:mm"
        let fullDate = dateFormatter.string(from: date)
        return fullDate
    }
    
    //    MARK: -NEW FIREJOURNALUSER TO CLOUD-
    /// Build CKRecord from new user
    /// - Parameter dateFormatter: DateFormatter
    /// - Returns: returns a CKRecord to send to the dashboard
    func newFireJournalUserForCloud(dateFormatter: DateFormatter) ->CKRecord {
        
        //        MARK: -Create CKRecord-
        var recordName: String = ""
        if let name = self.userGuid {
            recordName = name
        } else {
            if self.fjpUserModDate == nil {
                self.fjpUserModDate = Date()
            }
            let createDate = self.fjpUserModDate ?? Date()
            recordName = guidForFireJournalUser( createDate , dateFormatter: dateFormatter )
            self.userGuid = recordName
        }
        let fjuRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjuRID = CKRecord.ID(recordName: recordName, zoneID: fjuRZ.zoneID)
        let fjuCKRecord = CKRecord.init(recordType: "FireJournalUser", recordID: fjuRID)
        let fjuCKRecordReference = CKRecord.Reference(recordID: fjuRID, action: .deleteSelf)
        
        //        MARK: -STRINGS-
        fjuCKRecord["theEntity"] = "FireJournalUser"
        if let receipt = self.activeReceiptProductIdentifier {
            fjuCKRecord["activeReceiptProductIdentifier"] = receipt
        }
        if let identifier = self.activeReceiptTransactionIdentifier {
            fjuCKRecord["activeReceiptTransactionIdentifier"] = identifier
        }
        if let aGuid = self.apparatusGuid {
            fjuCKRecord["apparatusGuid"] = aGuid
        }
        if let oGuid = self.apparatusOvertimeGuid {
            fjuCKRecord["apparatusOvertimeGuid"] = oGuid
        }
        if let asGuid = self.assignmentGuid {
            fjuCKRecord["assignmentGuid"] = asGuid
        }
        if let asoGuid = self.assignmentOvertimeGuid {
            fjuCKRecord["assignmentOvertimeGuid"] = asoGuid
        }
        if let bat = self.battalion {
            fjuCKRecord["battalion"] = bat
        }
        //        MARK: -for profile image from contact list-
        if let cn = self.cnIdentifier {
            fjuCKRecord["cnIdentifier"] = cn
        }
        if let crewOver = self.crewOvertime {
            fjuCKRecord["crewOvertime"] = crewOver
        }
        if let crewOGuid = self.crewOvertimeGuid {
            fjuCKRecord["crewOvertimeGuid"] = crewOGuid
        }
        if let crewOName = self.crewOvertimeName {
            fjuCKRecord["crewOvertimeName"] = crewOName
        }
        if let crew = self.deafultCrewName {
            fjuCKRecord["deafultCrewName"] = crew
        }
        if let dcrew = self.defaultCrew {
            fjuCKRecord["defaultCrew"] = dcrew
        }
        if let dcrewGuid = self.defaultCrewGuid {
            fjuCKRecord["defaultCrewGuid"] = dcrewGuid
        }
        if let dresource = self.defaultResources {
            fjuCKRecord["defaultResources"] = dresource
        }
        if let dresourceName = self.defaultResourcesName {
            fjuCKRecord["defaultResourcesName"] = dresourceName
        }
        if let div = self.division {
            fjuCKRecord["division"] = div
        }
        if let email = self.emailAddress {
            fjuCKRecord["emailAddress"] = email
        }
        if let num = self.fdid {
            fjuCKRecord["fdid"] = num
        }
        if let fire = self.fireDepartment {
            fjuCKRecord["fireDepartment"] = fire
        }
        if let district = self.fireDistrict {
            fjuCKRecord["fireDistrict"] = district
        }
        if let station = self.fireStation {
            fjuCKRecord["fireStation"] = station
        }
        if let address = self.fireStationAddress {
            fjuCKRecord["fireStationAddress"] = address
        }
        if let address2 = self.fireStationAddressTwo {
            fjuCKRecord["fireStationAddressTwo"] = address2
        }
        if let city = self.fireStationCity {
            fjuCKRecord["fireStationCity"] = city
        }
        if let fsGuid = self.fireStationGuid {
            fjuCKRecord["fireStationGuid"] = fsGuid
        }
        if let fsoGuid = self.fireStationOvertimeGuid {
            fjuCKRecord["fireStationOvertimeGuid"] = fsoGuid
        }
        if let state = self.fireStationState {
            fjuCKRecord["fireStationState"] = state
        }
        if let name = self.fireStationStreetName {
            fjuCKRecord["fireStationStreetName"] = name
        }
        if let num = self.fireStationStreetNumber {
            fjuCKRecord["fireStationStreetNumber"] = num
        }
        if let web = self.fireStationWebSite {
            fjuCKRecord["fireStationWebSite"] = web
        }
        if let zip = self.fireStationZipCode {
            fjuCKRecord["fireStationZipCode"] = zip
        }
        if let first = self.firstName {
            fjuCKRecord["firstName"] = first
        }
        if let iApp = self.initialApparatus {
            fjuCKRecord["initialApparatus"] = iApp
        }
        if let iAss = self.initialAssignment {
            fjuCKRecord["initialAssignment"] = iAss
        }
        if let last = self.lastName {
            fjuCKRecord["lastName"] = last
        }
        if let middle = self.middleName {
            fjuCKRecord["middleName"] = middle
        }
        if let mobile = self.mobileNumber {
            fjuCKRecord["mobileNumber"] = mobile
        }
        if let pass = self.password {
            fjuCKRecord["password"] = pass
        }
        if let plat = self.platoon {
            fjuCKRecord["platoon"] = plat
        }
        if let pguid = self.platoonGuid {
            fjuCKRecord["platoonGuid"] = pguid
        }
        if let platoonOTG = self.platoonOverTimeGuid {
            fjuCKRecord["platoonOverTimeGuid"] = platoonOTG
        }
        if let r = self.rank {
            fjuCKRecord["rank"] = r
        }
        if let rguid = self.resourcesGuid {
            fjuCKRecord["resourcesGuid"] = rguid
        }
        if let roguid = self.resourcesOvertimeGuid {
            fjuCKRecord["resourcesOvertimeGuid"] = roguid
        }
        if let roname = self.resourcesOvertimeName {
            fjuCKRecord["resourcesOvertimeName"] = roname
        }
        if let tapp = self.tempApparatus {
            fjuCKRecord["tempApparatus"] = tapp
        }
        if let tass = self.tempAssignment {
            fjuCKRecord["tempAssignment"] = tass
        }
        if let tfstation = self.tempFireStation {
            fjuCKRecord["tempFireStation"] = tfstation
        }
        if let tplat = self.tempPlatoon {
            fjuCKRecord["tempPlatoon"] = tplat
        }
        if let tresource = self.tempResources {
            fjuCKRecord["tempResources"] = tresource
        }
        if let u = self.user {
            fjuCKRecord["user"] = u
        }
        if let uguid = self.userGuid {
            fjuCKRecord["userGuid"] = uguid
        }
        
        
        //        MARK: -BOOL-
        if self.apparatusDefault {
            fjuCKRecord["apparatusDefault"] = true
        } else {
            fjuCKRecord["apparatusDefault"] = false
        }
        if self.assignmentDefault {
            fjuCKRecord["assignmentDefault"] = true
        } else {
            fjuCKRecord["assignmentDefault"] = false
        }
        if self.crewDefault {
            fjuCKRecord["crewDefault"] = true
        } else {
            fjuCKRecord["crewDefault"] = false
        }
        if self.fireStationDefault {
            fjuCKRecord["fireStationDefault"] = true
        } else {
            fjuCKRecord["fireStationDefault"] = false
        }
        if self.fjpUserBackedUp == 1 {
            fjuCKRecord["fjpUserBackedUp"] = true
        } else {
            fjuCKRecord["fjpUserBackedUp"] = false
        }
        if self.platoonDefault {
            fjuCKRecord["platoonDefault"] = true
        } else {
            fjuCKRecord["platoonDefault"] = false
        }
        if self.resourcesDefault {
            fjuCKRecord["resourcesDefault"] = true
        } else {
            fjuCKRecord["resourcesDefault"] = false
        }
        if self.shiftStatusAMorOver {
            fjuCKRecord["shiftStatusAMorOver"] = true
        } else {
            fjuCKRecord["shiftStatusAMorOver"] = false
        }
        if self.subscriptionAccount {
            fjuCKRecord["subscriptionAccount"] = true
        } else {
            fjuCKRecord["subscriptionAccount"] = false
        }
        
        
        //        MARK: -INTEGER 32-
        fjuCKRecord["displayOrder"] = self.displayOrder
        
        
        //        MARK: -INTEGER 64-
        fjuCKRecord["fireJournalUserShift"] = self.fireJournalUserShift
        
        
        //        MARK: -DATES-
        if let areDate = self.activeReceiptExpirationDate {
            fjuCKRecord["activeReceiptExpirationDate"] = areDate
        }
        if let mod = self.fjpUserModDate {
            fjuCKRecord["fjpUserModDate"] = mod
        }
        if let search = self.fjpUserSearchDate {
            fjuCKRecord["fjpUserSearchDate"] = search
        }
        
        
        //        MARK: -OBJECT-
        /// location saved as Data with secureCodeing
        if self.fjuLocationSC != nil {
            
            if let location = self.fjuLocationSC {
                guard let  archivedData = location as? Data else { return fjuCKRecord }
                do {
                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return  fjuCKRecord }
                    let location:CLLocation = unarchivedLocation
                    fjuCKRecord["arcLocation"] = location
                } catch {
                    print("Unarchiver failed on fjuLocation")
                }

            }
            
        }
//        self.aFJUReference = fjuCKRecordReference
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: fjuCKRecordReference, requiringSecureCoding: true)
            self.aFJUReferenceSC = data as NSObject
            
        } catch {
            print("incidentRef to data failed line 514 Incident+Custom")
        }
        saveToCD()
        
        return fjuCKRecord
        
    }
    
    
    //    MARK: -Modify the CKRecord for FireJournalUser-
    /// Modify CKRecord pulled from fjuCKR with new user info
    /// - Parameter ckRecord: CKRecord
    /// - Returns: CKRecord modified ready to go to cloudkit
    func modifyCloudFromFireJournalUser(ckRecord: CKRecord ) -> CKRecord {
        let fjuCKRecord = ckRecord
        
        if let receipt = self.activeReceiptProductIdentifier {
            fjuCKRecord["activeReceiptProductIdentifier"] = receipt
        }
        if let identifier = self.activeReceiptTransactionIdentifier {
            fjuCKRecord["activeReceiptTransactionIdentifier"] = identifier
        }
        if let aGuid = self.apparatusGuid {
            fjuCKRecord["apparatusGuid"] = aGuid
        }
        if let oGuid = self.apparatusOvertimeGuid {
            fjuCKRecord["apparatusOvertimeGuid"] = oGuid
        }
        if let asGuid = self.assignmentGuid {
            fjuCKRecord["assignmentGuid"] = asGuid
        }
        if let asoGuid = self.assignmentOvertimeGuid {
            fjuCKRecord["assignmentOvertimeGuid"] = asoGuid
        }
        if let bat = self.battalion {
            fjuCKRecord["battalion"] = bat
        }
        if let cn = self.cnIdentifier {
            fjuCKRecord["cnIdentifier"] = cn
        }
        if let crewOver = self.crewOvertime {
            fjuCKRecord["crewOvertime"] = crewOver
        }
        if let crewOGuid = self.crewOvertimeGuid {
            fjuCKRecord["crewOvertimeGuid"] = crewOGuid
        }
        if let crewOName = self.crewOvertimeName {
            fjuCKRecord["crewOvertimeName"] = crewOName
        }
        if let crew = self.deafultCrewName {
            fjuCKRecord["deafultCrewName"] = crew
        }
        if let dcrew = self.defaultCrew {
            fjuCKRecord["defaultCrew"] = dcrew
        }
        if let dcrewGuid = self.defaultCrewGuid {
            fjuCKRecord["defaultCrewGuid"] = dcrewGuid
        }
        if let dresource = self.defaultResources {
            fjuCKRecord["defaultResources"] = dresource
        }
        if let dresourceName = self.defaultResourcesName {
            fjuCKRecord["defaultResourcesName"] = dresourceName
        }
        if let div = self.division {
            fjuCKRecord["division"] = div
        }
        if let email = self.emailAddress {
            fjuCKRecord["emailAddress"] = email
        }
        if let num = self.fdid {
            fjuCKRecord["fdid"] = num
        }
        if let fire = self.fireDepartment {
            fjuCKRecord["fireDepartment"] = fire
        }
        if let district = self.fireDistrict {
            fjuCKRecord["fireDistrict"] = district
        }
        if let station = self.fireStation {
            fjuCKRecord["fireStation"] = station
        }
        if let address = self.fireStationAddress {
            fjuCKRecord["fireStationAddress"] = address
        }
        if let address2 = self.fireStationAddressTwo {
            fjuCKRecord["fireStationAddressTwo"] = address2
        }
        if let city = self.fireStationCity {
            fjuCKRecord["fireStationCity"] = city
        }
        if let fsGuid = self.fireStationGuid {
            fjuCKRecord["fireStationGuid"] = fsGuid
        }
        if let fsoGuid = self.fireStationOvertimeGuid {
            fjuCKRecord["fireStationOvertimeGuid"] = fsoGuid
        }
        if let state = self.fireStationState {
            fjuCKRecord["fireStationState"] = state
        }
        if let name = self.fireStationStreetName {
            fjuCKRecord["fireStationStreetName"] = name
        }
        if let num = self.fireStationStreetNumber {
            fjuCKRecord["fireStationStreetNumber"] = num
        }
        if let web = self.fireStationWebSite {
            fjuCKRecord["fireStationWebSite"] = web
        }
        if let zip = self.fireStationZipCode {
            fjuCKRecord["fireStationZipCode"] = zip
        }
        if let first = self.firstName {
            fjuCKRecord["firstName"] = first
        }
        if let iApp = self.initialApparatus {
            fjuCKRecord["initialApparatus"] = iApp
        }
        if let iAss = self.initialAssignment {
            fjuCKRecord["initialAssignment"] = iAss
        }
        if let last = self.lastName {
            fjuCKRecord["lastName"] = last
        }
        if let middle = self.middleName {
            fjuCKRecord["middleName"] = middle
        }
        if let mobile = self.mobileNumber {
            fjuCKRecord["mobileNumber"] = mobile
        }
        if let pass = self.password {
            fjuCKRecord["password"] = pass
        }
        if let plat = self.platoon {
            fjuCKRecord["platoon"] = plat
        }
        if let pguid = self.platoonGuid {
            fjuCKRecord["platoonGuid"] = pguid
        }
        if let platoonOTG = self.platoonOverTimeGuid {
            fjuCKRecord["platoonOverTimeGuid"] = platoonOTG
        }
        if let r = self.rank {
            fjuCKRecord["rank"] = r
        }
        if let rguid = self.resourcesGuid {
            fjuCKRecord["resourcesGuid"] = rguid
        }
        if let roguid = self.resourcesOvertimeGuid {
            fjuCKRecord["resourcesOvertimeGuid"] = roguid
        }
        if let roname = self.resourcesOvertimeName {
            fjuCKRecord["resourcesOvertimeName"] = roname
        }
        if let tapp = self.tempApparatus {
            fjuCKRecord["tempApparatus"] = tapp
        }
        if let tass = self.tempAssignment {
            fjuCKRecord["tempAssignment"] = tass
        }
        if let tfstation = self.tempFireStation {
            fjuCKRecord["tempFireStation"] = tfstation
        }
        if let tplat = self.tempPlatoon {
            fjuCKRecord["tempPlatoon"] = tplat
        }
        if let tresource = self.tempResources {
            fjuCKRecord["tempResources"] = tresource
        }
        if let u = self.user {
            fjuCKRecord["user"] = u
        }
        
        
        //        MARK: -BOOL-
        if self.apparatusDefault {
            fjuCKRecord["apparatusDefault"] = true
        } else {
            fjuCKRecord["apparatusDefault"] = false
        }
        if self.assignmentDefault {
            fjuCKRecord["assignmentDefault"] = true
        } else {
            fjuCKRecord["assignmentDefault"] = false
        }
        if self.crewDefault {
            fjuCKRecord["crewDefault"] = true
        } else {
            fjuCKRecord["crewDefault"] = false
        }
        if self.fireStationDefault {
            fjuCKRecord["fireStationDefault"] = true
        } else {
            fjuCKRecord["fireStationDefault"] = false
        }
        if self.fjpUserBackedUp == 1 {
            fjuCKRecord["fjpUserBackedUp"] = true
        } else {
            fjuCKRecord["fjpUserBackedUp"] = false
        }
        if self.platoonDefault {
            fjuCKRecord["platoonDefault"] = true
        } else {
            fjuCKRecord["platoonDefault"] = false
        }
        if self.resourcesDefault {
            fjuCKRecord["resourcesDefault"] = true
        } else {
            fjuCKRecord["resourcesDefault"] = false
        }
        if self.shiftStatusAMorOver {
            fjuCKRecord["shiftStatusAMorOver"] = true
        } else {
            fjuCKRecord["shiftStatusAMorOver"] = false
        }
        if self.subscriptionAccount {
            fjuCKRecord["subscriptionAccount"] = true
        } else {
            fjuCKRecord["subscriptionAccount"] = false
        }
        
        
        //        MARK: -INTEGER 32-
        fjuCKRecord["displayOrder"] = self.displayOrder
        
        
        //        MARK: -INTEGER 64-
        fjuCKRecord["fireJournalUserShift"] = self.fireJournalUserShift
        
        
        //        MARK: -DATES-
        if let areDate = self.activeReceiptExpirationDate {
            fjuCKRecord["activeReceiptExpirationDate"] = areDate
        }
        if let mod = self.fjpUserModDate {
            fjuCKRecord["fjpUserModDate"] = mod
        }
        if let search = self.fjpUserSearchDate {
            fjuCKRecord["fjpUserSearchDate"] = search
        }
        
        
        //        MARK: -OBJECT-
        /// location saved as Data with secureCodeing
        if self.fjuLocationSC != nil {
            
            if let location = self.fjuLocationSC {
                guard let  archivedData = location as? Data else { return fjuCKRecord }
                do {
                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return  fjuCKRecord }
                    let location:CLLocation = unarchivedLocation
                    fjuCKRecord["arcLocation"] = location
                } catch {
                    print("Unarchiver failed on fjuLocation")
                }
            }
            
        }
        
        return fjuCKRecord
    }
    
    //    MARK: -FireJournalUser modified by CloudKit-
    func modifyFireJournalUserFromCloud(ckRecord: CKRecord) {
        let fjuCKRecord = ckRecord
        
        //        MARK: -STRINGS-
        if let receipt = fjuCKRecord["activeReceiptProductIdentifier"] as? String {
            self.activeReceiptProductIdentifier = receipt
        }
        if let identifier = fjuCKRecord["activeReceiptTransactionIdentifier"] as? String {
            self.activeReceiptTransactionIdentifier = identifier
        }
        if let aGuid = fjuCKRecord["apparatusGuid"] as? String {
            self.apparatusGuid = aGuid
        }
        if let oGuid = fjuCKRecord["apparatusOvertimeGuid"] as? String {
            self.apparatusOvertimeGuid = oGuid
        }
        if let asGuid = fjuCKRecord["assignmentGuid"] as? String {
            self.assignmentGuid = asGuid
        }
        if let asoGuid = fjuCKRecord["assignmentOvertimeGuid"] as? String {
            self.assignmentOvertimeGuid = asoGuid
        }
        if let bat = fjuCKRecord["battalion"] as? String {
            self.battalion = bat
        }
        //        MARK: -for profile image from contact list-
        if let cn = fjuCKRecord["cnIdentifier"] as? String {
            self.cnIdentifier = cn
        }
        if let crewOver = fjuCKRecord["crewOvertime"] as? String {
            self.crewOvertime = crewOver
        }
        if let crewOGuid = fjuCKRecord["crewOvertimeGuid"] as? String {
            self.crewOvertimeGuid = crewOGuid
        }
        if let crewOName = fjuCKRecord["crewOvertimeName"] as? String {
            self.crewOvertimeName = crewOName
        }
        if let crew = fjuCKRecord["deafultCrewName"] as? String {
            self.deafultCrewName = crew
        }
        if let dcrew = fjuCKRecord["defaultCrew"] as? String {
            self.defaultCrew = dcrew
        }
        if let dcrewGuid = fjuCKRecord["defaultCrewGuid"] as? String {
            self.defaultCrewGuid = dcrewGuid
        }
        if let dresource = fjuCKRecord["defaultResources"] as? String {
            self.defaultResources = dresource
        }
        if let dresourceName = fjuCKRecord["defaultResourcesName"] as? String {
            self.defaultResourcesName = dresourceName
        }
        if let div = fjuCKRecord["division"] as? String {
            self.division = div
        }
        if let email = fjuCKRecord["emailAddress"] as? String {
            self.emailAddress = email
        }
        if let num = fjuCKRecord["fdid"] as? String {
            self.fdid = num
        }
        if let fire = fjuCKRecord["fireDepartment"] as? String {
            self.fireDepartment = fire
        }
        if let district = fjuCKRecord["fireDistrict"] as? String {
            self.fireDistrict = district
        }
        if let station = fjuCKRecord["fireStation"] as? String {
            self.fireStation = station
        }
        if let address = fjuCKRecord["fireStationAddress"] as? String {
            self.fireStationAddress = address
        }
        if let address2 = fjuCKRecord["fireStationAddressTwo"] as? String {
            self.fireStationAddressTwo = address2
        }
        if let city = fjuCKRecord["fireStationCity"] as? String {
            self.fireStationCity = city
        }
        if let fsGuid = fjuCKRecord["fireStationGuid"] as? String {
            self.fireStationGuid = fsGuid
        }
        if let fsoGuid = fjuCKRecord["fireStationOvertimeGuid"] as? String {
            self.fireStationOvertimeGuid = fsoGuid
        }
        if let state = fjuCKRecord["fireStationState"] as? String {
            self.fireStationState = state
        }
        if let name = fjuCKRecord["fireStationStreetName"] as? String {
            self.fireStationStreetName = name
        }
        if let num = fjuCKRecord["fireStationStreetNumber"] as? String {
            self.fireStationStreetNumber = num
        }
        if let web = fjuCKRecord["fireStationWebSite"] as? String {
            self.fireStationWebSite = web
        }
        if let zip = fjuCKRecord["fireStationZipCode"] as? String {
            self.fireStationZipCode = zip
        }
        if let first = fjuCKRecord["firstName"] as? String {
            self.firstName = first
        }
        if let iApp = fjuCKRecord["initialApparatus"] as? String {
            self.initialApparatus = iApp
        }
        if let iAss = fjuCKRecord["initialAssignment"] as? String {
            self.initialAssignment = iAss
        }
        if let last = fjuCKRecord["lastName"] as? String {
            self.lastName = last
        }
        if let middle = fjuCKRecord["middleName"] as? String {
            self.middleName = middle
        }
        if let mobile = fjuCKRecord["mobileNumber"] as? String {
            self.mobileNumber = mobile
        }
        if let pass = fjuCKRecord["password"] as? String {
            self.password = pass
        }
        if let plat = fjuCKRecord["platoon"] as? String {
            self.platoon = plat
        }
        if let pguid = fjuCKRecord["platoonGuid"] as? String {
            self.platoonGuid = pguid
        }
        if let platoonOTG = fjuCKRecord["platoonOverTimeGuid"] as? String {
            self.platoonOverTimeGuid = platoonOTG
        }
        if let r = fjuCKRecord["rank"] as? String {
            self.rank = r
        }
        if let rguid = fjuCKRecord["resourcesGuid"] as? String {
            self.resourcesGuid = rguid
        }
        if let roguid = fjuCKRecord["resourcesOvertimeGuid"] as? String {
            self.resourcesOvertimeGuid = roguid
        }
        if let roname = fjuCKRecord["resourcesOvertimeName"] as? String {
            self.resourcesOvertimeName = roname
        }
        if let tapp = fjuCKRecord["tempApparatus"] as? String {
            self.tempApparatus = tapp
        }
        if let tass = fjuCKRecord["tempAssignment"] as? String {
            self.tempAssignment = tass
        }
        if let tfstation = fjuCKRecord["tempFireStation"] as? String {
            self.tempFireStation = tfstation
        }
        if let tplat = fjuCKRecord["tempPlatoon"] as? String {
            self.tempPlatoon = tplat
        }
        if let tresource = fjuCKRecord["tempResources"] as? String {
            self.tempResources = tresource
        }
        if let u = fjuCKRecord["user"] as? String {
            self.user = u
        }
        if let uguid = fjuCKRecord["userGuid"] as? String {
            self.userGuid = uguid
        }
        
        
        //        MARK: -BOOL-
        if fjuCKRecord["apparatusDefault"] ?? false {
        self.apparatusDefault = true
        } else {
            self.apparatusDefault = false
        }
        if fjuCKRecord["assignmentDefault"] ?? false {
        self.assignmentDefault = true
        } else {
            self.assignmentDefault = false
        }
        if fjuCKRecord["crewDefault"] ?? false {
        self.crewDefault = true
        } else {
            self.crewDefault = false
        }
        if fjuCKRecord["fireStationDefault"] ?? false {
        self.fireStationDefault = true
        } else {
            self.fireStationDefault = false
        }
        self.fjpUserBackedUp = true
        if fjuCKRecord["platoonDefault"] ?? false {
        self.platoonDefault = true
        } else {
            self.platoonDefault = false
        }
        if fjuCKRecord["resourcesDefault"] ?? false {
        self.resourcesDefault = true
        } else {
            self.resourcesDefault = false
        }
        if fjuCKRecord["shiftStatusAMorOver"] ?? false {
        self.shiftStatusAMorOver = true
        } else {
            self.shiftStatusAMorOver = true
        }
        if fjuCKRecord["subscriptionAccount"] ?? false {
        self.subscriptionAccount = true
        } else {
            self.subscriptionAccount = false
        }
        
        
        //        MARK: -INTEGER 32-
        if fjuCKRecord["displayOrder"] != nil {
            self.displayOrder = NSNumber(value: fjuCKRecord["displayOrder"] as! Int32)
        }
        
        //        MARK: -INTEGER 64-
        if fjuCKRecord["fireJournalUserShift"] != nil {
            self.fireJournalUserShift = fjuCKRecord["fireJournalUserShift"] as! Int64
        }
        
        //        MARK: -DATES-
        if let areDate = fjuCKRecord["activeReceiptExpirationDate"] as? Date {
            self.activeReceiptExpirationDate = areDate
        }
        if let mod = fjuCKRecord["fjpUserModDate"] as? Date {
            self.fjpUserModDate = mod
        }
        if let search = fjuCKRecord["fjpUserSearchDate"] as? Date {
            self.fjpUserSearchDate = search
        }
        
        
        //        MARK: -OBJECT-
        /// location saved as Data with secureCodeing
        if fjuCKRecord["fjuLocation"] != nil {
            
            let location = fjuCKRecord["fjuLocation"] as! CLLocation
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                self.fjuLocationSC = data as NSObject
            } catch {
                print("got an error here")
            }
            
        }
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjuCKRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.fjuCKR = data as NSObject
        saveToCD()
    }
    
    //    MARK: -save to context once arcFormCKR is built in download from CloudKit
    fileprivate func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            print("FireJournalUser+CustomAdditions.swift we have saved from the cloud")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"FireJournalUser save"])
            }
        } catch {
            
            let nserror = error as NSError
            
            let errorMessage = "FireJournalUser+CustomAdditions saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    
    /*func newFireJournalUserForCloud()->CKRecord {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDMMHHmmAAAAAAAA"
        let dateFormatted = dateFormatter.string(from: self.fjpUserModDate ?? Date())
        let name = "FireJournalUser \(dateFormatted)"
        let fjuRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjuRID = CKRecord.ID(recordName: name, zoneID: fjuRZ.zoneID)
        let fjuCKRecord = CKRecord.init(recordType: "Incident", recordID: fjuRID)
        let fjuRef = CKRecord.Reference(recordID: fjuRID, action: .deleteSelf)
        fjuCKRecord["aFJUReference"] = fjuRef
        fjuCKRecord["apparatusGuid"] = self.apparatusGuid
        fjuCKRecord["assignmentGuid"] = self.assignmentGuid
        fjuCKRecord["emailAddress"] = self.emailAddress
        fjuCKRecord["fdid"] = self.fdid
        fjuCKRecord["fireStation"] = self.fireStation
        fjuCKRecord["fireStationCity"] = self.fireStationCity
        fjuCKRecord["fireStationState"] = self.fireStationState
        fjuCKRecord["fireStationStreetName"] = self.fireStationStreetName
        fjuCKRecord["fireStationStreetNumber"] = self.fireStationStreetNumber
        fjuCKRecord["fireStationWebSite"] = self.fireStationWebSite
        fjuCKRecord["fireStationZipCode"] = self.fireStationZipCode
        fjuCKRecord["firstName"] = self.firstName
        fjuCKRecord["fjpUserBackedUp"] = true
        fjuCKRecord["fjpUserModDate"] = self.fjpUserModDate
        fjuCKRecord["fjpUserSearchDate"] = self.fjpUserSearchDate
        fjuCKRecord["initialApparatus"] = self.initialApparatus
        fjuCKRecord["initialAssignment"] = self.initialAssignment
        fjuCKRecord["lastName"] = self.lastName
        fjuCKRecord["mobileNumber"] = self.mobileNumber
        fjuCKRecord["platoon"] = self.platoon
        fjuCKRecord["platoonGuid"] = self.platoonGuid
        fjuCKRecord["rank"] = self.rank
        fjuCKRecord["shiftStatusAMorOver"] = self.shiftStatusAMorOver
        fjuCKRecord["tempApparatus"] = self.tempApparatus
        fjuCKRecord["tempAssignment"] = self.tempAssignment
        fjuCKRecord["tempFireStation"] = self.tempFireStation
        fjuCKRecord["tempPlatoon"] = self.tempPlatoon
        fjuCKRecord["userName"] = self.userName
        fjuCKRecord["crewDefault"] = self.crewDefault
        fjuCKRecord["crewOvertime"] = self.crewOvertime
        fjuCKRecord["crewOvertimeGuid"] = self.crewOvertimeGuid
        fjuCKRecord["crewOvertimeName"] = self.crewOvertimeName
        fjuCKRecord["deafultCrewName"] = self.deafultCrewName
        fjuCKRecord["defaultCrew"] = self.defaultCrew
        fjuCKRecord["defaultCrewGuid"] = self.defaultCrewGuid
        fjuCKRecord["defaultResources"] = self.defaultResources
        fjuCKRecord["defaultResourcesName"] = self.defaultResourcesName
        fjuCKRecord["resourcesDefault"] = self.resourcesDefault
        fjuCKRecord["resourcesGuid"] = self.resourcesGuid
        fjuCKRecord["resourcesOvertimeGuid"] = self.resourcesOvertimeGuid
        fjuCKRecord["resourcesOvertimeName"] = self.resourcesOvertimeName
        if self.fjuLocation != nil {
            fjuCKRecord["fjuLocation"] = self.fjuLocation as! CLLocation
        }
        fjuCKRecord["theEntity"] = "FireJournalUser"
        self.aFJUReference = fjuRef
        saveToCD()
        return fjuCKRecord
    }*/
    
/*    func updateUserFromCloud(ckRecord: CKRecord) {
        let fjuCKRecord = ckRecord
//        if let reference = fjuCKRecord["aFJUReference"] as? CKRecord.Reference {
//            self.aFJUReference = reference as? NSObject
//        } else {
//            let id = fjuCKRecord.recordID
//            let reference = CKRecord.Reference(recordID: id, action: .deleteSelf)
//            fjuCKRecord["aFJUReference"] = reference
//            self.aFJUReference = reference
//        }
        self.apparatusGuid = fjuCKRecord["apparatusGuid"]
        self.assignmentGuid = fjuCKRecord["assignmentGuid"]
        self.emailAddress = fjuCKRecord["emailAddress"]
        self.fdid = fjuCKRecord["fdid"]
        self.fireStation = fjuCKRecord["fireStation"]
        self.fireStationCity = fjuCKRecord["fireStationCity"]
        self.fireStationState = fjuCKRecord["fireStationState"]
        self.fireStationStreetName = fjuCKRecord["fireStationStreetName"]
        self.fireStationStreetNumber = fjuCKRecord["fireStationStreetNumber"]
        self.fireStationWebSite = fjuCKRecord["fireStationWebSite"]
        self.fireStationZipCode = fjuCKRecord["fireStationZipCode"]
        self.firstName = fjuCKRecord["firstName"]
        self.fjpUserBackedUp = true
        self.fjpUserModDate = fjuCKRecord["fjpUserModDate"]
        self.fjpUserSearchDate = fjuCKRecord["fjpUserSearchDate"]
        self.initialApparatus = fjuCKRecord["initialApparatus"]
        self.initialAssignment = fjuCKRecord["initialAssignment"]
        self.lastName = fjuCKRecord["lastName"]
        self.mobileNumber = fjuCKRecord["mobileNumber"]
        self.platoon = fjuCKRecord["platoon"]
        self.platoonGuid = fjuCKRecord["platoonGuid"]
        self.rank = fjuCKRecord["rank"]
        self.shiftStatusAMorOver = fjuCKRecord["shiftStatusAMorOver"] ?? false
        self.tempApparatus = fjuCKRecord["tempApparatus"]
        self.tempAssignment = fjuCKRecord["tempAssignment"]
        self.tempFireStation = fjuCKRecord["tempFireStation"]
        self.tempPlatoon = fjuCKRecord["tempPlatoon"]
        self.userName = fjuCKRecord["userName"]
        self.crewDefault = fjuCKRecord["crewDefault"] ?? true
        self.crewOvertime = fjuCKRecord["crewOvertime"]
        self.crewOvertimeGuid = fjuCKRecord["crewOvertimeGuid"]
        self.crewOvertimeName = fjuCKRecord["crewOvertimeName"]
        self.deafultCrewName = fjuCKRecord["deafultCrewName"]
        self.defaultCrew = fjuCKRecord["defaultCrew"]
        self.defaultCrewGuid = fjuCKRecord["defaultCrewGuid"]
        self.defaultResources = fjuCKRecord["defaultResources"]
        self.defaultResourcesName = fjuCKRecord["defaultResourcesName"]
        self.resourcesDefault = fjuCKRecord["resourcesDefault"] ?? true
        self.resourcesGuid = fjuCKRecord["resourcesGuid"]
        self.resourcesOvertimeGuid = fjuCKRecord["resourcesOvertimeGuid"]
        self.resourcesOvertimeName = fjuCKRecord["resourcesOvertimeName"]
        self.fjuLocation = fjuCKRecord["fjuLocation"] as? NSObject
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjuCKRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.fjuCKR = data as NSObject
        saveToCD()
    }
    
    func modifyIncidentForCloud(ckRecord:CKRecord)->CKRecord {
        let fjuCKRecord = ckRecord
//        if let reference:CKRecord.Reference = self.aFJUReference as? CKRecord.Reference {
//            fjuCKRecord["aFJUReference"] = reference
//        } else {
//            let id = fjuCKRecord.recordID
//            let reference = CKRecord.Reference(recordID: id, action: .deleteSelf)
//            fjuCKRecord["aFJUReference"] = reference
//            self.aFJUReference = reference
//            saveToCD()
//        }
        fjuCKRecord["apparatusGuid"] = self.apparatusGuid
        fjuCKRecord["assignmentGuid"] = self.assignmentGuid
        fjuCKRecord["emailAddress"] = self.emailAddress
        fjuCKRecord["fdid"] = self.fdid
        fjuCKRecord["fireStation"] = self.fireStation
        fjuCKRecord["fireStationCity"] = self.fireStationCity
        fjuCKRecord["fireStationState"] = self.fireStationState
        fjuCKRecord["fireStationStreetName"] = self.fireStationStreetName
        fjuCKRecord["fireStationStreetNumber"] = self.fireStationStreetNumber
        fjuCKRecord["fireStationWebSite"] = self.fireStationWebSite
        fjuCKRecord["fireStationZipCode"] = self.fireStationZipCode
        fjuCKRecord["firstName"] = self.firstName
        fjuCKRecord["fjpUserBackedUp"] = true
        fjuCKRecord["fjpUserModDate"] = self.fjpUserModDate
        fjuCKRecord["fjpUserSearchDate"] = self.fjpUserSearchDate
        fjuCKRecord["initialApparatus"] = self.initialApparatus
        fjuCKRecord["initialAssignment"] = self.initialAssignment
        fjuCKRecord["lastName"] = self.lastName
        fjuCKRecord["mobileNumber"] = self.mobileNumber
        fjuCKRecord["platoon"] = self.platoon
        fjuCKRecord["platoonGuid"] = self.platoonGuid
        fjuCKRecord["rank"] = self.rank
        fjuCKRecord["shiftStatusAMorOver"] = self.shiftStatusAMorOver
        fjuCKRecord["tempApparatus"] = self.tempApparatus
        fjuCKRecord["tempAssignment"] = self.tempAssignment
        fjuCKRecord["tempFireStation"] = self.tempFireStation
        fjuCKRecord["tempPlatoon"] = self.tempPlatoon
        fjuCKRecord["userName"] = self.userName
        fjuCKRecord["crewDefault"] = self.crewDefault
        fjuCKRecord["crewOvertime"] = self.crewOvertime
        fjuCKRecord["crewOvertimeGuid"] = self.crewOvertimeGuid
        fjuCKRecord["crewOvertimeName"] = self.crewOvertimeName
        fjuCKRecord["deafultCrewName"] = self.deafultCrewName
        fjuCKRecord["defaultCrew"] = self.defaultCrew
        fjuCKRecord["defaultCrewGuid"] = self.defaultCrewGuid
        fjuCKRecord["defaultResources"] = self.defaultResources
        fjuCKRecord["defaultResourcesName"] = self.defaultResourcesName
        fjuCKRecord["resourcesDefault"] = self.resourcesDefault
        fjuCKRecord["resourcesGuid"] = self.resourcesGuid
        fjuCKRecord["resourcesOvertimeGuid"] = self.resourcesOvertimeGuid
        fjuCKRecord["resourcesOvertimeName"] = self.resourcesOvertimeName
        if self.fjuLocation != nil {
            fjuCKRecord["fjuLocation"] = self.fjuLocation as! CLLocation
        }
        fjuCKRecord["theEntity"] = "FireJournalUser"
        return fjuCKRecord
    }
    
    private func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"no big deal here"])
            }
        } catch {
            
            let nserror = error as NSError
            
            let errorMessage = "FireJournalUser+CustomAdditions saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }*/
}
