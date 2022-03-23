//
//  Journal+CustomAdditions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/9/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreLocation

extension Journal {
    
    func getTheUser() ->FireJournalUser {
        var fju:FireJournalUser? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "userGuid", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        
        do {
            let fetched = try managedObjectContext?.fetch(fetchRequest) as! [FireJournalUser]
            fju = fetched.last
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
        return fju!
    }
    
    //    MARK: -JOURNAL GUID-
    /// Create a formatted guid for the journal entry
    /// - Parameters:
    ///   - date: creation date of the ARCrossForm
    ///   - dateFormatter: dateformatter shared from the campaign page
    /// - Returns: returns unique guid with prefix of 01.
    func guidForJournal(_ date: Date, dateFormatter: DateFormatter)->String {
        let resourceDate = date
        var uuidA:String = NSUUID().uuidString.lowercased()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        let dateFrom = dateFormatter.string(from: resourceDate)
        uuidA = uuidA+dateFrom
        let uuidA1 = "01."+uuidA
        return uuidA1
    }
    
    //    MARK: -TIME FORMAT FOR JOURNAL-
    /// Formatted date for journal entry date and time
    /// - Parameters:
    ///   - date: creationDate from ARCrossForm
    ///   - dateFormatter: dateFormatter from CampaignTVC
    /// - Returns: returns full date time in string format
    func journalFullDateFormatted(_ date: Date, dateFormatter: DateFormatter) -> String {
        dateFormatter.dateFormat =  "MM/dd/YYYY HH:mm"
        let fullDate = dateFormatter.string(from: date)
        return fullDate
    }
    
    //    MARK: -journal Search Date format
    /// create a formatted date for journalSearchDate
    /// - Parameters:
    ///   - date: Date
    ///   - dateFormatter: DateFormatter
    /// - Returns: returns string that fits format for journalSearchDate
    func formatSearchDate(_ date: Date, dateFormatter: DateFormatter ) -> String {
        dateFormatter.dateFormat =  "MMM dd,YYYY"
        let fullDate = dateFormatter.string(from: date)
        return fullDate
    }
    
    //    MARK: -NEW JOURNAL FOR CLOUD-
    /// Build new journal entry as ckrecord
    /// - Parameter dateFormatter: DateFormatter
    /// - Returns: creates and build CKRecord for CloudKit out of the Journal object
    func newJournalForCloud(dateFormatter: DateFormatter)->CKRecord {
        
        //        MARK: -Create CKRecord-
        var recordName: String = ""
        if let name = self.fjpJGuidForReference{
            recordName = name
        } else {
            if self.journalCreationDate == nil {
                self.journalCreationDate = Date()
            }
            let createDate = self.journalCreationDate ?? Date()
            recordName = guidForJournal(createDate, dateFormatter: dateFormatter)
            self.fjpJGuidForReference = recordName
        }
        let journalRecordZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjJournalRID = CKRecord.ID(recordName: recordName, zoneID: journalRecordZ.zoneID)
        let journalRecord = CKRecord.init(recordType: "Journal", recordID: fjJournalRID)
        let _ = CKRecord.Reference(recordID: fjJournalRID, action: .deleteSelf)
        
        //        MARK: -The Entity
        journalRecord["theEntity"] = "Journal"
        journalRecord["journalBackedUp"] = true
        
        if let iguid =  self.fjpIncReference {
            journalRecord["fjpIncReference"] = iguid
        }
        if let guid = self.fjpJGuidForReference {
            journalRecord["fjpJGuidForReference"] = guid
        }
        if let create = self.journalCreationDate {
            journalRecord["journalCreationDate"] = create
        }
        if let create = self.journalCreationDate {
            dateFormatter.dateFormat = "MMM dd,YYYY"
            let searchDate = dateFormatter.string(from: create)
            journalRecord["journalDateSearch"] = searchDate
        }
        if let discuss = self.journalDiscussion as? String {
            journalRecord["journalDiscussion"] = discuss
        }
        if let type = self.journalEntryType {
            journalRecord["journalEntryType"] = type
        }
        if let imageName = self.journalEntryTypeImageName {
            journalRecord["journalEntryTypeImageName"] = imageName
        }
        if let fireStation = self.journalFireStation {
            journalRecord["journalFireStation"] = fireStation
        }
        if let header = self.journalHeader {
            journalRecord["journalHeader"] = header
        }
        if let mod = self.journalModDate {
            journalRecord["journalModDate"] = mod
        }
        if let next = self.journalNextSteps as? String {
            journalRecord["journalNextSteps"] = next
        }
        if let over = self.journalOverview as? String {
            journalRecord["journalOverview"] = over
        }
        if self.journalPhotoTaken != nil {
            journalRecord["journalPhotoTaken"] = true
        } else {
            journalRecord["journalPhotoTaken"] = false
        }
        if self.journalPrivate {
            journalRecord["journalPrivate"]  = true
        } else {
            journalRecord["journalPrivate"] = false
        }
        if let summary = self.journalSummary as? String {
            journalRecord["journalSummary"] = summary
        }
        if let app = self.journalTempApparatus {
            journalRecord["journalTempApparatus"] = app
        }
        if let assign = self.journalTempAssignment {
            journalRecord["journalTempAssignment"] = assign
        }
        if let fire = self.journalTempFireStation {
            journalRecord["journalTempFireStation"] = fire
        }
        if let platoon = self.journalTempPlatoon {
            journalRecord["journalTempPlatoon"] = platoon
        }
        
//        MARK: -LOCATION-
        /// journalLocation unarchived by secureCoding
        if self.journalLocationSC != nil {
            
            if let location = self.journalLocationSC {
                guard let  archivedData = location as? Data else { return journalRecord }
                do {
                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return  journalRecord }
                    let location:CLLocation = unarchivedLocation
                     journalRecord["arcLocation"] = location
                } catch {
                    print("Unarchiver failed on arcLocation")
                }
            }
            
            if let lat = self.journalLatitude {
                journalRecord["journalLatitude"] = lat
            }
            if let long = self.journalLongitude {
                journalRecord["journalLongitude"] = long
            }
            if let name = self.journalStreetName {
                journalRecord["journalStreetName"] = name
            }
            if let num = self.journalStreetNumber {
                journalRecord["journalStreetNumber"] = num
            }
            if let city = self.journalCity {
                journalRecord["journalCity"] = city
            }
            if let state = self.journalState {
                journalRecord["journalState"] = state
            }
            if let zip = self.journalZip {
                journalRecord["journalZip"] = zip
            }
        }
        
        
        return journalRecord
    }

    //    MARK -MODIFIED JOURNAL TO CLOUDKIT-
    /// Build updated cloudkit from journalCRK for upload to CloudKit
    /// - Parameter ckRecord: CKRecord
    /// - Returns: update CKRecord with location information  for journal
    func modifiedJournalToCloudKit(ckRecord: CKRecord ) -> CKRecord {
        
        let journalRecord = ckRecord
        //        MARK: -The Entity
        journalRecord["journalBackedUp"] = true
        
        if let discuss = self.journalDiscussion as? String {
            journalRecord["journalDiscussion"] = discuss
        }
        if let type = self.journalEntryType {
            journalRecord["journalEntryType"] = type
        }
        if let imageName = self.journalEntryTypeImageName {
            journalRecord["journalEntryTypeImageName"] = imageName
        }
        if let fireStation = self.journalFireStation {
            journalRecord["journalFireStation"] = fireStation
        }
        if let header = self.journalHeader {
            journalRecord["journalHeader"] = header
        }
        if let mod = self.journalModDate {
            journalRecord["journalModDate"] = mod
        }
        if let next = self.journalNextSteps as? String {
            journalRecord["journalNextSteps"] = next
        }
        if let over = self.journalOverview as? String {
            journalRecord["journalOverview"] = over
        }
        if self.journalPhotoTaken != nil {
            journalRecord["journalPhotoTaken"] = true
        } else {
            journalRecord["journalPhotoTaken"] = false
        }
        if self.journalPrivate {
            journalRecord["journalPrivate"]  = true
        } else {
            journalRecord["journalPrivate"] = false
        }
        if let summary = self.journalSummary as? String {
            journalRecord["journalSummary"] = summary
        }
        if let app = self.journalTempApparatus {
            journalRecord["journalTempApparatus"] = app
        }
        if let assign = self.journalTempAssignment {
            journalRecord["journalTempAssignment"] = assign
        }
        if let fire = self.journalTempFireStation {
            journalRecord["journalTempFireStation"] = fire
        }
        if let platoon = self.journalTempPlatoon {
            journalRecord["journalTempPlatoon"] = platoon
        }
        
//        MARK: -LOCATION-
        /// journalLocation unarchived by secureCoding
        if self.journalLocationSC != nil {
            
            if let location = self.journalLocationSC {
                guard let  archivedData = location as? Data else { return journalRecord }
                do {
                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return  journalRecord }
                    let location:CLLocation = unarchivedLocation
                     journalRecord["arcLocation"] = location
                } catch {
                    print("Unarchiver failed on arcLocation")
                }
            }
            
            if let lat = self.journalLatitude {
                journalRecord["journalLatitude"] = lat
            }
            if let long = self.journalLongitude {
                journalRecord["journalLongitude"] = long
            }
            if let name = self.journalStreetName {
                journalRecord["journalStreetName"] = name
            }
            if let num = self.journalStreetNumber {
                journalRecord["journalStreetNumber"] = num
            }
            if let city = self.journalCity {
                journalRecord["journalCity"] = city
            }
            if let state = self.journalState {
                journalRecord["journalState"] = state
            }
            if let zip = self.journalZip {
                journalRecord["journalZip"] = zip
            }
        }
        
        
        return journalRecord
    }
    
    //    MARK: -JOURNAL FROM THE CLOUD
    /// Updates journal entry from cloud
    /// - Parameters:
    ///   - ckRecord: CKRcord
    ///   - dateFormatter: DateFormatter
    func updateJournalFromTheCloud(ckRecord: CKRecord, dateFormatter: DateFormatter) {
        
        //        var entryExists: Bool = false
        let journalRecord = ckRecord
        
        self.journalBackedUp = true
        
        if let iguid =   journalRecord["fjpIncReference"] as? String {
            self.fjpIncReference = iguid
        }
        if let create =  journalRecord["journalCreationDate"] as? Date {
            self.journalCreationDate = create
        } else {
            self.journalCreationDate = Date()
        }
        if let guid = journalRecord["fjpJGuidForReference"] as? String {
            self.fjpJGuidForReference = guid
        } else {
            if let date = self.journalCreationDate {
                self.fjpJGuidForReference = guidForJournal(date, dateFormatter: dateFormatter )
            }
        }
        
        if let searchDate = journalRecord["journalDateSearch"] as? String {
            self.journalDateSearch = searchDate
        } else {
            self.journalDateSearch = formatSearchDate( self.journalCreationDate! , dateFormatter: dateFormatter)
        }
        if let discuss = journalRecord["journalDiscussion"] as? String {
            self.journalDiscussion = discuss as NSObject
        }
        if let type = journalRecord["journalEntryType"] as? String {
            self.journalEntryType  = type
        }
        if let imageName = journalRecord["journalEntryTypeImageName"] as? String {
            self.journalEntryTypeImageName = imageName
        }
        if let fireStation = journalRecord["journalFireStation"] as? String  {
            self.journalFireStation = fireStation
        }
        if let header = journalRecord["journalHeader"] as? String {
            self.journalHeader = header
        }
        
//        MARK: -LOCATION-
        /// journalLocation archived with SecureCoding
        if journalRecord["journalLocation"] != nil {
            
                let location = journalRecord["journalLocation"] as! CLLocation
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                    self.journalLocationSC = data as NSObject
                } catch {
                    print("got an error here")
                }
            if let lat = journalRecord["journalLatitude"] as? String {
                self.journalLatitude = lat
            }
            if let long = journalRecord["journalLongitude"] as? String {
                self.journalLongitude = long
            }
            if let name = journalRecord["journalStreetName"] as? String {
                self.journalStreetName = name
            }
            if let num = journalRecord["journalStreetNumber"] as? String {
                self.journalStreetNumber = num
            }
            if let city = journalRecord["journalCity"] as? String {
                self.journalCity = city
            }
            if let state = journalRecord["journalState"] as? String {
                self.journalState = state
            }
            if let zip = journalRecord["journalZip"] as? String {
                self.journalZip = zip
            }
        }
        
        if let mod =  journalRecord["journalModDate"] as? Date {
            self.journalModDate = mod
        }
        if let next = journalRecord["journalNextSteps"] as? String {
            self.journalNextSteps = next as NSObject
        }
        if let over =  journalRecord["journalOverview"] as? String {
            self.journalOverview = over as NSObject
        }
        if journalRecord["journalPhotoTaken"]  ?? false {
            self.journalPhotoTaken = true
        } else {
            self.journalPhotoTaken = false
        }
        if journalRecord["journalPrivate"] ?? false {
            self.journalPrivate = true
        } else {
            self.journalPrivate = false
        }
        if let summary = journalRecord["journalSummary"] as? String {
            self.journalSummary = summary as NSObject
        }
        if let app = journalRecord["journalTempApparatus"] as? String {
            self.journalTempApparatus = app
        }
        if let assign = journalRecord["journalTempAssignment"] as? String {
            self.journalTempAssignment = assign
        }
        if let fire = journalRecord["journalTempFireStation"] as? String {
            self.journalTempFireStation = fire
        }
        if let platoon = journalRecord["journalTempPlatoon"] as? String {
            self.journalTempPlatoon = platoon
        }
        
        //                MARK: -Save encoded ckrecord-
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        journalRecord.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.fjJournalCKR = data as NSObject
        
        saveToCD()
        
    }
    
    //    MARK: -save to core data-
    private func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"Journal Saved"])
                print("journal we have saved to the cloud")
            }
        } catch {
            let nserror = error as NSError
            
            let error = "The Journal+CustomAdditions context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
            print(error)
        }
    }
    
   /* func modifyJournalForCloud(ckRecord:CKRecord)->CKRecord {
        
        let fjJournalR = ckRecord
        fjJournalR["fjpJGuidForReference"] = self.fjpJGuidForReference
        fjJournalR["fjpIncReference"] = self.fjpIncReference
        let fju = getTheUser()
        fjJournalR["fjpUserReference"] = fju.aFJUReference as? CKRecord.Reference
        fjJournalR["journalAttendee"] = ""
        fjJournalR["journalBackedUp"] = true
        fjJournalR["journalCity"] = self.journalCity
        fjJournalR["journalCreationDate"] = self.journalCreationDate
        fjJournalR["journalDateSearch"] = self.journalDateSearch
        fjJournalR["journalDiscussion"] = self.journalDiscussion as? String
        fjJournalR["journalEntryType"] = self.journalEntryType
        fjJournalR["journalEntryTypeImageName"] = self.journalEntryTypeImageName
        fjJournalR["journalFireStation"] = self.journalFireStation
        fjJournalR["journalHeader"] = self.journalHeader
        if self.journalLocation != nil {
            fjJournalR["journalLocation"] = self.journalLocation as! CLLocation
            fjJournalR["journalLatitude"] = self.journalLatitude ?? ""
            fjJournalR["journalLongitude"] = self.journalLongitude ?? ""
        }
        fjJournalR["journalModDate"] = self.journalModDate
        fjJournalR["journalNextSteps"] = self.journalNextSteps as? String
        fjJournalR["journalOverview"] = self.journalOverview as? String
        fjJournalR["journalPhotoTaken"] = false
        fjJournalR["journalPrivate"] = self.journalPrivate
        fjJournalR["journalState"] = self.journalState
        fjJournalR["journalStreetName"] = self.journalStreetName
        fjJournalR["journalStreetNumber"] = self.journalStreetNumber
        fjJournalR["journalSummary"] = self.journalSummary as? String
        fjJournalR["journalTag"] = ""
        fjJournalR["journalTempApparatus"] = self.journalTempApparatus
        fjJournalR["journalTempAssignment"] = self.journalTempAssignment
        fjJournalR["journalTempFireStation"] = self.journalTempFireStation
        fjJournalR["journalTempPlatoon"] = self.journalTempPlatoon
        fjJournalR["journalZip"] = self.journalZip
        fjJournalR["theEntity"] = "Journal"
        
        return fjJournalR
    }*/

  /*  func newJournalForCloud()->CKRecord {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "YYYYDDDMMHHmmAAAAAAAA"
//        let dateFormatted = dateFormatter.string(from: self.journalModDate ?? Date())
//        let name = "Journal \(dateFormatted)"
        
        var recordName: String = ""
        if let name = self.fjpJGuidForReference {
            recordName = name
        } else {
            let jGuidDate = GuidFormatter.init(date:self.journalCreationDate!)
            let jGuid:String = jGuidDate.formatGuid()
            self.fjpJGuidForReference = "01."+jGuid
            recordName = "01."+jGuid
        }
        let JournalRZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjJournalRID = CKRecord.ID(recordName: recordName, zoneID: JournalRZ.zoneID)
        let fjJournalR = CKRecord.init(recordType: "Journal", recordID: fjJournalRID)
        let fjJournalRef = CKRecord.Reference(recordID: fjJournalRID, action: .deleteSelf)
        _ = getTheUser()
        fjJournalR["fjpIncReference"] = self.fjpIncReference
//        fjJournalR["fjpUserReference"] = fju.aFJUReference as! CKRecord.Reference        
        fjJournalR["fjpJGuidForReference"] = self.fjpJGuidForReference
        fjJournalR["journalAttendee"] = ""
        fjJournalR["journalBackedUp"] = true
        fjJournalR["journalCity"] = self.journalCity
        fjJournalR["journalCreationDate"] = self.journalCreationDate
        fjJournalR["journalDateSearch"] = self.journalDateSearch
        fjJournalR["journalDiscussion"] = self.journalDiscussion as? String
        fjJournalR["journalEntryType"] = self.journalEntryType
        fjJournalR["journalEntryTypeImageName"] = self.journalEntryTypeImageName
        fjJournalR["journalFireStation"] = self.journalFireStation
        fjJournalR["journalHeader"] = self.journalHeader
        if self.journalLocation != nil {
            fjJournalR["journalLocation"] = self.journalLocation as! CLLocation
            fjJournalR["journalLatitude"] = self.journalLatitude ?? ""
            fjJournalR["journalLongitude"] = self.journalLongitude ?? ""
        }
        fjJournalR["journalModDate"] = self.journalModDate
        fjJournalR["journalNextSteps"] = self.journalNextSteps as? String
        fjJournalR["journalOverview"] = self.journalOverview as? String
        fjJournalR["journalPhotoTaken"] = false
        fjJournalR["journalPrivate"] = self.journalPrivate
        fjJournalR["journalState"] = self.journalState
        fjJournalR["journalStreetName"] = self.journalStreetName
        fjJournalR["journalStreetNumber"] = self.journalStreetNumber
        fjJournalR["journalSummary"] = self.journalSummary as? String
        fjJournalR["journalTag"] = ""
        fjJournalR["journalTempApparatus"] = self.journalTempApparatus
        fjJournalR["journalTempAssignment"] = self.journalTempAssignment
        fjJournalR["journalTempFireStation"] = self.journalTempFireStation
        fjJournalR["journalTempPlatoon"] = self.journalTempPlatoon
        fjJournalR["journalZip"] = self.journalZip
        fjJournalR["theEntity"] = "Journal"
        
        self.aJournalReference = fjJournalRef
        saveToCD()
        return fjJournalR
    }*/
    
    /*func updateJournalFromCloud(ckRecord: CKRecord) {
        let fjJournalR = ckRecord
        if let jReference:String = fjJournalR["fjpIncReference"] {
            self.fjpIncReference = jReference
        }
        if let _:String = fjJournalR["fjpUserReference"] {
            let fju = getTheUser()
            if let guid = fju.userGuid {
                self.fjpUserReference = guid
            }
        }
        fjJournalR["fjpJGuidForReference"] = self.fjpJGuidForReference
        //        TODO: -attendees for journal-
        //        self.journalAttendee = fjJournalR["journalAttendee"]
        self.journalBackedUp = fjJournalR["journalBackedUp"] ?? 0
        if let city:String = fjJournalR["journalCity"] {
            self.journalCity = city
        }
        self.journalCreationDate = fjJournalR["journalCreationDate"]  ?? Date()
        if let dateSearch:String = fjJournalR["journalDateSearch"] {
            self.journalDateSearch = dateSearch
        }
        if let discuss:String = fjJournalR["journalDiscussion"] {
            self.journalDiscussion = discuss as NSObject
        }
        if let type:String = fjJournalR["journalEntryType"] {
            let journalType:String = type
            if journalType == "Station" {
                self.journalEntryType = "Station"
                self.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
                self.journalPrivate = true
            } else if journalType == "Community" {
                self.journalEntryType = "Community"
                self.journalEntryTypeImageName = "ICONS_communityboard color"
                self.journalPrivate = true
            } else if journalType == "Members" {
                self.journalEntryType = "Community"
                self.journalEntryTypeImageName = "ICONS_Membersboard color"
                self.journalPrivate = true
            } else if journalType == "PRIVATE" {
                self.journalEntryType = "PRIVATE"
                self.journalEntryTypeImageName = "ICONS_BBLUELOCK"
                self.journalPrivate = false
            }
            else if journalType == "Fire" || journalType == "EMS" || journalType == "Rescue" {
                self.journalEntryType = journalType
                self.journalEntryTypeImageName = "NOTJournal"
            }
        }
        if let fireStation:String = fjJournalR["journalFireStation"] {
            self.journalFireStation = fireStation
        }
        if let header:String = fjJournalR["journalHeader"] {
            self.journalHeader = header
        }
        if fjJournalR["journalLocation"] != nil {
            self.journalLocation = fjJournalR["journalLocation"] as? NSObject
            self.journalLatitude = fjJournalR["journalLatitude"] ?? ""
            self.journalLongitude = fjJournalR["journalLongitude"] ?? ""
        }
        self.journalModDate = fjJournalR["journalModDate"] ?? Date()
        if let next:String = fjJournalR["journalNextSteps"] {
            self.journalNextSteps = next as NSObject
        }
        if let overView:String = fjJournalR["journalOverview"] {
            self.journalOverview = overView as NSObject
        }
        self.journalPhotoTaken = fjJournalR["journalPhotoTaken"] ?? 0
        if let state:String = fjJournalR["journalState"] {
            self.journalState = state
        }
        if let stName:String = fjJournalR["journalStreetName"] {
            self.journalStreetName = stName
        }
        if let num:String = fjJournalR["journalStreetNumber"] {
            self.journalStreetNumber = num
        }
        if let summary:String = fjJournalR["journalStreetNumber"] {
            self.journalSummary = summary as NSObject
        }
        //        TODO: -JOURNAL TAGS-
        //        self.journalTag = fjJournalR["journalTag"]
        if let tempApp:String = fjJournalR["journalTempApparatus"] {
            self.journalTempApparatus = tempApp
        }
        if let tempAss:String = fjJournalR["journalTempAssignment"] {
            self.journalTempAssignment = tempAss
        }
        if let tempFS:String = fjJournalR["journalTempFireStation"] {
            self.journalTempFireStation = tempFS
        }
        if let tempP:String = fjJournalR["journalTempPlatoon"] {
            self.journalTempPlatoon = tempP
        }
        if let zip:String = fjJournalR["journalZip"] {
            self.journalZip = zip
        }
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjJournalR.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.fjJournalCKR = data as NSObject
        saveToCD()
    }
    
    private func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"no big deal here"])
                print("journal we have saved to the cloud")
            }
        } catch {
            let nserror = error as NSError
            
            let error = "The Journal+CustomAdditions context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
            print(error)
        }
    }*/
}
