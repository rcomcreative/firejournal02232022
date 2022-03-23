//
//  ICS214Form+CustomAdditions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 12/18/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit
import CoreLocation

struct ICS214DashboardData {
    var ics214LastCampaign: String = ""
    var ics214LastEffort: String = ""
    var ics214TotalCampaigns: Int = 0
    var ics214Incomplete: Int = 0
    var ics214Complete: Int = 0
}

extension ICS214Form {
    
    func getTheDashboardCounts(forms:[ICS214Form])->ICS214DashboardData {
        var data = ICS214DashboardData.init()
        let total = forms.filter({ $0.ics214EffortMaster == true })
        data.ics214TotalCampaigns = total.count
        let complete = forms.filter({ $0.ics214Completed == true })
        data.ics214Complete = complete.count
        let incomplete = forms.filter({ $0.ics214Completed == false })
        data.ics214Incomplete = incomplete.count
        let campaign = total.last
        let campaignName = campaign?.ics214IncidentName
        data.ics214LastCampaign = campaignName ?? ""
        let effort = campaign?.ics214Effort
        data.ics214LastEffort = effort ?? ""
        return data
    }
    
    func newICS214ToTheCloud()->CKRecord {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "YYYYDDDMMHHmmAAAAAAAA"
//        let dateFormatted = dateFormatter.string(from:self.ics214FromTime ?? Date())
//        let name = "ICS214 \(dateFormatted)"
        var recordName: String = ""
        if let name = self.ics214Guid {
            recordName = name
        } else {
            let iGuidDate = GuidFormatter.init(date:self.ics214ToTime!)
            let iGuid:String = iGuidDate.formatGuid()
            self.ics214Guid = "30."+iGuid
            recordName = "30."+iGuid
        }
        let fjICS214RZ = CKRecordZone.init(zoneName: "FireJournalShare")
        let fjICS214RID = CKRecord.ID(recordName: recordName, zoneID: fjICS214RZ.zoneID)
        let fjICS214Record = CKRecord.init(recordType: "ICS214Form", recordID: fjICS214RID)
        let fjICS214Ref = CKRecord.Reference(recordID: fjICS214RID, action: .deleteSelf)
        // MARK: -Integer
        
        fjICS214Record["ics214Count"] = self.ics214Count 
        
        
        // MARK: -BOOLEANS
        if self.ics214BackedUp {
            fjICS214Record["ics214BackedUp"] = true
        } else {
            fjICS214Record["ics214BackedUp"] = false
        }
        
        if self.ics214Completed {
            fjICS214Record["ics214Completed"] = true
        } else {
            fjICS214Record["ics214Completed"] = false
        }
        
        if self.ics214EffortMaster {
            fjICS214Record["ics214EffortMaster"] = true
        } else {
            fjICS214Record["ics214EffortMaster"] = false
        }
        
        self.ics214SignatureAdded = false
        
        if self.ics214SignatureAdded {
            fjICS214Record["ics214SignatureAdded"] = true
        } else {
            fjICS214Record["ics214SignatureAdded"] = false
        }
        
        if self.ics214Updated {
            fjICS214Record["ics214Updated"] = true
        } else {
            fjICS214Record["ics214Updated"] = false
        }
        
        // MARK: -Dates
        if let comp = self.ics214CompletionDate {
            fjICS214Record["ics214CompletionDate"] = comp
        }
        if let from = self.ics214FromTime {
            fjICS214Record["ics214FromTime"] = from
        }
        if let modDate = self.ics214ModDate {
            fjICS214Record["ics214ModDate"] = modDate
        }
        if let sigDate = self.ics214SignatureDate {
            fjICS214Record["ics214SignatureDate"] = sigDate
        }
        if let toTime = self.ics214ToTime {
            fjICS214Record["ics214ToTime"] = toTime
        }
        
        //        MARK: -LOCATION-
        /// ics214Location unarchived from secureCoding for ckRecord
        if self.ics214LocationSC != nil {
            if let location = self.ics214LocationSC {
                guard let  archivedData = location as? Data else { return fjICS214Record }
                do {
                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return  fjICS214Record }
                    let location:CLLocation = unarchivedLocation
                    fjICS214Record["ics214Location"] = location
                } catch {
                    print("Unarchiver failed on arcLocation")
                }
            }
        }
        
        if let lat = self.ics214Latitude {
            fjICS214Record["ics214Latitude"] = lat
        }
        if let long = self.ics214Longitude {
            fjICS214Record["ics214Longitude"] = long
        }
        // MARK: -Asset
        if self.ics214SignatureAdded {
            fjICS214Record["ics214Signature"] = imageForCloudKit(type: "inspector")
        }
        // MARK: -Strings
        fjICS214Record["theEntity"] = "ICS214Form"
        if let effort = self.ics214Effort {
            fjICS214Record["ics214Effort"] = effort
        }
        if let guid = self.ics214Guid {
            fjICS214Record["ics214Guid"] = guid
        }
        if let position = self.ics214ICSPosition {
            fjICS214Record["ics214ICSPosition"] = position
        }
        if let incName = self.ics214IncidentName {
            fjICS214Record["ics214IncidentName"] = incName
        }
        if let incNum = self.ics214LocalIncidentNumber {
            fjICS214Record["ics214LocalIncidentNumber"] = incNum
        }
        if let masterGuid = self.ics214MasterGuid {
            fjICS214Record["ics214MasterGuid"] = masterGuid
        }
        if let positionType = self.ics214PositionType {
            fjICS214Record["ics214PositionType"] = positionType
        }
        if let teamName = self.ics214TeamName {
            fjICS214Record["ics214TeamName"] = teamName
        }
        if let userName = self.ics214UserName {
            fjICS214Record["ics214UserName"] = userName
        }
        if let homeAgency = self.ics241HomeAgency {
            fjICS214Record["ics241HomeAgency"] = homeAgency
        }
        if let preparedPosition = self.icsPreparedPosition {
            fjICS214Record["icsPreparedPosition"] = preparedPosition
        }
        if let preparedName = self.icsPreparfedName {
            fjICS214Record["icsPreparfedName"] = preparedName
        }
        if let incGuid = self.incidentGuid {
            fjICS214Record["incidentGuid"] = incGuid
        }
        if let journalGuid = self.journalGuid {
            fjICS214Record["journalGuid"] = journalGuid
        }
        if let fromTime = self.ics214FromTime {
            var dateString = ""
            let dated = fromTime
            let dayOfWeekNumberFormat = DateFormatter()
            dayOfWeekNumberFormat.dateFormat = "MMMM d, YYYY HH:mm"
            dateString = dayOfWeekNumberFormat.string(from:dated)
            fjICS214Record["operationalPeriod"] = dateString
        }
        //    fjICS214Record["personnelHomeBase"] = self.ics241HomeAgency
        //    fjICS214Record["personnelICSPosition"] = self.icsPreparedPosition
        //    fjICS214Record["personnelName"] = self.ics214UserName
        if let userName = self.ics214UserName {
            fjICS214Record["preparedBy"] = userName
        }
        if let unitLeader = self.ics214UserName {
            fjICS214Record["unitLeader"] = unitLeader
        }
//        self.ics214CKReference = fjICS214Ref
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: fjICS214Ref, requiringSecureCoding: true)
            self.ics214CKReferenceSC = data as NSObject
            
        } catch {
            print("incidentRef to data failed line 514 Incident+Custom")
        }
        saveToCD()
        
        return fjICS214Record
    }
    
    func modifyICS214ForCloud(ckRecord:CKRecord)->CKRecord {
        let fjICS214Record = ckRecord
        // MARK: -Integer
        
        fjICS214Record["ics214Count"] = self.ics214Count
        
        
        // MARK: -BOOLEANS
        if self.ics214BackedUp {
            fjICS214Record["ics214BackedUp"] = true
        } else {
            fjICS214Record["ics214BackedUp"] = false
        }
        
        if self.ics214Completed {
            fjICS214Record["ics214Completed"] = true
        } else {
            fjICS214Record["ics214Completed"] = false
        }
        
        if self.ics214EffortMaster {
            fjICS214Record["ics214EffortMaster"] = true
        } else {
            fjICS214Record["ics214EffortMaster"] = false
        }
        
        if self.ics214SignatureAdded {
            fjICS214Record["ics214SignatureAdded"] = true
        } else {
            fjICS214Record["ics214SignatureAdded"] = false
        }
        
        if self.ics214Updated {
            fjICS214Record["ics214Updated"] = true
        } else {
            fjICS214Record["ics214Updated"] = false
        }
        
        // MARK: -Dates
        if let comp = self.ics214CompletionDate {
            fjICS214Record["ics214CompletionDate"] = comp
        }
        if let from = self.ics214FromTime {
            fjICS214Record["ics214FromTime"] = from
        }
        if let modDate = self.ics214ModDate {
            fjICS214Record["ics214ModDate"] = modDate
        }
        if let sigDate = self.ics214SignatureDate {
            fjICS214Record["ics214SignatureDate"] = sigDate
        }
        if let toTime = self.ics214ToTime {
            fjICS214Record["ics214ToTime"] = toTime
        }
        
        //        MARK: -LOCATION-
        /// ics214Location unarchived from secureCoding for ckRecord
        if self.ics214LocationSC != nil {
            if let location = self.ics214LocationSC {
                guard let  archivedData = location as? Data else { return fjICS214Record }
                do {
                    guard let unarchivedLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self , from: archivedData) else { return  fjICS214Record }
                    let location:CLLocation = unarchivedLocation
                    fjICS214Record["ics214Location"] = location
                } catch {
                    print("Unarchiver failed on arcLocation")
                }
            }
        }
        
        if let lat = self.ics214Latitude {
            fjICS214Record["ics214Latitude"] = lat
        }
        if let long = self.ics214Longitude {
            fjICS214Record["ics214Longitude"] = long
        }
        // MARK: -Asset
        if self.ics214SignatureAdded {
            fjICS214Record["ics214Signature"] = imageForCloudKit(type: "inspector")
        }
        
        // MARK: -Strings
        fjICS214Record["theEntity"] = "ICS214Form"
        if let effort = self.ics214Effort {
            fjICS214Record["ics214Effort"] = effort
        }
        if let guid = self.ics214Guid {
            fjICS214Record["ics214Guid"] = guid
        }
        if let position = self.ics214ICSPosition {
            fjICS214Record["ics214ICSPosition"] = position
        }
        if let incName = self.ics214IncidentName {
            fjICS214Record["ics214IncidentName"] = incName
        }
        if let incNum = self.ics214LocalIncidentNumber {
            fjICS214Record["ics214LocalIncidentNumber"] = incNum
        }
        if let masterGuid = self.ics214MasterGuid {
            fjICS214Record["ics214MasterGuid"] = masterGuid
        }
        if let positionType = self.ics214PositionType {
            fjICS214Record["ics214PositionType"] = positionType
        }
        if let teamName = self.ics214TeamName {
            fjICS214Record["ics214TeamName"] = teamName
        }
        if let userName = self.ics214UserName {
            fjICS214Record["ics214UserName"] = userName
        }
        if let homeAgency = self.ics241HomeAgency {
            fjICS214Record["ics241HomeAgency"] = homeAgency
        }
        if let preparedPosition = self.icsPreparedPosition {
            fjICS214Record["icsPreparedPosition"] = preparedPosition
        }
        if let preparedName = self.icsPreparfedName {
            fjICS214Record["icsPreparfedName"] = preparedName
        }
        if let incGuid = self.incidentGuid {
            fjICS214Record["incidentGuid"] = incGuid
        }
        if let journalGuid = self.journalGuid {
            fjICS214Record["journalGuid"] = journalGuid
        }
        if let fromTime = self.ics214FromTime {
            var dateString = ""
            let dated = fromTime
            let dayOfWeekNumberFormat = DateFormatter()
            dayOfWeekNumberFormat.dateFormat = "MMMM d, YYYY HH:mm"
            dateString = dayOfWeekNumberFormat.string(from:dated)
            fjICS214Record["operationalPeriod"] = dateString
        }
        
        let array = getPersonnelBase(guid:self.ics214Guid!)
        var agencyArray = [String]()
        var positionArray = [String]()
        var nameArray = [String]()
        for attendee in array {
            if attendee.userAttendeeGuid != "" {
                let attendee:UserAttendees = getAttendee(attendeeGuid:attendee.userAttendeeGuid ?? "")
                nameArray.append(attendee.attendee ?? "")
                agencyArray.append(attendee.attendeeHomeAgency ?? "")
                positionArray.append(attendee.attendeeICSPosition ?? "")
            }
        }
        fjICS214Record["personnelHomeBase"] = agencyArray
        fjICS214Record["personnelICSPosition"] = positionArray
        fjICS214Record["personnelName"] = nameArray
        if let userName = self.ics214UserName {
            fjICS214Record["preparedBy"] = userName
        }
        if let unitLeader = self.ics214UserName {
            fjICS214Record["unitLeader"] = unitLeader
        }
        return fjICS214Record
    }
    
    func updateICS214FromTheCloud(ckRecord: CKRecord) {
        let fjICS214Record = ckRecord
        
        self.ics214Count = fjICS214Record["ics214Count"] ?? 0
        
        
        // MARK: -BOOLEANS
        
        self.ics214BackedUp = true
        
        if fjICS214Record["ics214Completed"] ?? false {
            self.ics214Completed = true
        } else {
            self.ics214Completed = false
        }
        
        if fjICS214Record["ics214EffortMaster"] ?? false {
            self.ics214EffortMaster = true
        } else {
            self.ics214EffortMaster = false
        }
        
        if fjICS214Record["ics214SignatureAdded"] ?? false {
            self.ics214SignatureAdded = true
        } else {
            self.ics214SignatureAdded = false
        }
        
        if fjICS214Record["ics214Updated"]  ?? false{
            self.ics214Updated = true
        } else {
            self.ics214Updated = false
        }
        
        // MARK: -Dates
        if let comp:Date = fjICS214Record["ics214CompletionDate"] {
            self.ics214CompletionDate = comp
        }
        if let from:Date = fjICS214Record["ics214FromTime"] {
            self.ics214FromTime = from
        }
        if let modDate:Date = fjICS214Record["ics214ModDate"] {
            self.ics214ModDate = modDate
        }
        if let sigDate:Date = fjICS214Record["ics214SignatureDate"] {
            self.ics214SignatureDate = sigDate
        }
        if let toTime:Date = fjICS214Record["ics214ToTime"] {
            self.ics214ToTime = toTime
        }
        if let lat: String = fjICS214Record["ics214Latitude"] {
            self.ics214Latitude = lat
        }
        if let long: String = fjICS214Record["ics214Longitude"] {
             self.ics214Longitude = long
        }
        // MARK: -Asset
        if self.ics214SignatureAdded {
            if fjICS214Record["ics214Signature"] as? CKAsset != nil {
                self.ics214Signature = imageDataFromCloudKit(asset: fjICS214Record["ics214Signature"]!)
            }
        }
        // MARK: -Strings
        if let effort:String = fjICS214Record["ics214Effort"] {
            self.ics214Effort = effort
        }
        if let guid:String = fjICS214Record["ics214Guid"] {
            self.ics214Guid = guid
        }
        if let position:String = fjICS214Record["ics214ICSPosition"] {
            self.ics214ICSPosition = position
        }
        if let incName:String = fjICS214Record["ics214IncidentName"] {
            self.ics214IncidentName = incName
        }
        if let incNum:String = fjICS214Record["ics214LocalIncidentNumber"] {
            self.ics214LocalIncidentNumber = incNum
        }
        if let masterGuid:String = fjICS214Record["ics214MasterGuid"] {
            self.ics214MasterGuid = masterGuid
        }
        if let positionType:String = fjICS214Record["ics214PositionType"] {
            self.ics214PositionType = positionType
        }
        if let teamName:String = fjICS214Record["ics214TeamName"] {
            self.ics214TeamName = teamName
        }
        if let userName:String = fjICS214Record["ics214UserName"] {
            self.ics214UserName = userName
        }
        if let homeAgency:String = fjICS214Record["ics241HomeAgency"] {
            self.ics241HomeAgency = homeAgency
        }
        if let preparedPosition:String = fjICS214Record["icsPreparedPosition"] {
            self.icsPreparedPosition = preparedPosition
        }
        if let preparedName:String = fjICS214Record["icsPreparfedName"] {
            self.icsPreparfedName = preparedName
        }
        if let incGuid:String = fjICS214Record["incidentGuid"] {
            self.incidentGuid = incGuid
        }
        if let journalGuid:String = fjICS214Record["journalGuid"] {
            self.journalGuid = journalGuid
        }
        
        //        MARK: -LOCATION-
        /// ics214Location archived with data from CKRecord
        if fjICS214Record["ics214Location"] != nil {
            let location = fjICS214Record["ics214Location"] as! CLLocation
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
                self.ics214LocationSC = data as NSObject
            } catch {
                print("got an error here")
            }
        }
        
//        self.ics214CKReference = fjICS214Record["fjICS214Ref"] as? NSObject
    
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        fjICS214Record.encodeSystemFields(with: coder)
        let data = coder.encodedData
        self.ics214CKR = data as NSObject
        
        saveToCD()
}


    private func saveToCD() {
        do {
            try self.managedObjectContext?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.managedObjectContext,userInfo:["info":"no big deal here"])
            }
        } catch {
            
            let nserror = error as NSError
            
            let errorMessage = "ICS214Form+CustomAdditions saveToCD() Unresolved error \(nserror)"
            print(errorMessage)
            
        }
    }
    
    private func getPersonnelBase(guid:String)->Array<ICS214Personnel> {
        var array = [ICS214Personnel]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Personnel" )
        let predicate = NSPredicate(format: "%K = %@", "ics214Guid",guid)
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        do {
            let fetched = try self.managedObjectContext?.fetch(fetchRequest) as! [ICS214Personnel]
            let ics214Personnel = fetched
            for person in ics214Personnel {
                array.append(person)
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return array
    }
    
    private func getAttendee(attendeeGuid:String)->UserAttendees {
        var userAttendee: UserAttendees?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttendees" )
        let predicate = NSPredicate(format: "%K = %@", "attendeeGuid",attendeeGuid)
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        do {
            let fetched = try self.managedObjectContext?.fetch(fetchRequest) as! [UserAttendees]
            userAttendee = fetched.last!
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return userAttendee!
    }
    
    func imageForCloudKit(type: String) ->CKAsset {
        var asset: CKAsset!
        var image: UIImage!
        let timeStamp = self.ics214FromTime
        let fileManager = FileManager.default
        let documentsDirectory = getDirectoryPath()
        let ts = timeStamp!.timeStamp()
        let photoName = "\(type)_\(ts).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(photoName)
        image = UIImage.init(data: self.ics214Signature!)!
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
    }
}
