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
//    MARK: -PHOTO-
    func getThePhotos() -> [Photo] {
        var thePhotos = [Photo]()
        guard let photos = self.photo?.allObjects as? [Photo] else {
            return thePhotos
        }
        thePhotos = photos
        return thePhotos
    }
}

extension Journal {
//    MARK: -CLOUDKIT
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
        if self.journalTagsAvailable {
            journalRecord["journalTagsAvailable"] = true
        } else {
            journalRecord["journalTagsAvailable"] = false
        }
        if self.locationAvailable {
            journalRecord["locationAvailable"] = 1
        } else {
            journalRecord["locationAvailable"] = 0
        }
        if self.journalPhotoTaken != nil {
            journalRecord["journalPhotoTaken"] = 1
        } else {
            journalRecord["journalPhotoTaken"] = 0
        }
        if self.journalPrivate {
            journalRecord["journalPrivate"]  = 1
        } else {
            journalRecord["journalPrivate"] = 0
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
        if self.journalTagsAvailable {
            journalRecord["journalTagsAvailable"] = 1
        } else {
            journalRecord["journalTagsAvailable"] = 0
        }
        if self.locationAvailable {
            journalRecord["locationAvailable"] = 1
        } else {
            journalRecord["locationAvailable"] = 0
        }
        if self.journalPhotoTaken != nil {
            journalRecord["journalPhotoTaken"] = 1
        } else {
            journalRecord["journalPhotoTaken"] = 0
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
        if journalRecord["locationAvailable"]  ?? false {
            self.locationAvailable = true
        } else {
            self.locationAvailable = false
        }
        if journalRecord["journalTagsAvailable"]  ?? false {
            self.journalTagsAvailable = true
        } else {
            self.journalTagsAvailable = false
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
    
        //    MARK: -JOURNAL FROM THE CLOUD
        /// Updates journal entry from cloud
        /// - Parameters:
        ///   - ckRecord: CKRcord
        ///   - dateFormatter: DateFormatter
    func singleJournalFromTheCloud(ckRecord: CKRecord, dateFormatter: DateFormatter, completionHandler: (() -> Void)? = nil) {
            
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
            if journalRecord["locationAvailable"]  ?? false {
                self.locationAvailable = true
            } else {
                self.locationAvailable = false
            }
            if journalRecord["journalTagsAvailable"]  ?? false {
                self.journalTagsAvailable = true
            } else {
                self.journalTagsAvailable = false
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
            
        saveTheSingleCD() {_ in 
            completionHandler?()
        }
        
            
        }
    
    private func saveTheSingleCD(withCompletion completion: @escaping (String) -> Void) {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"Journal Saved"])
                print("journal we have saved to the cloud")
            }
            completion("Success")
        } catch {
            let nserror = error as NSError
            
            let error = "The Journal+CustomAdditions context was unable to save due to: \(nserror.localizedDescription) \(nserror.userInfo)"
            print(error)
            completion("Error")
        }
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
    
  
}
