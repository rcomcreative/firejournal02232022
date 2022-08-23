//
//  ICS214ToCloud.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/28/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ICS214ToCloud: NSObject {
    
    var objectID: NSManagedObjectID!
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var ics214: ICS214Form!
    var thread:Thread!
    let nc = NotificationCenter.default
    let dayFormat = DateFormatter()
    var formBody = [ String: Any ]()
    let FIRECLOUD_URL = "https://www.firejournalcloud.com/forms/api/ics214.php"
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
        self.bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        self.thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        self.nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
    }
    
    //    MARK: -THREAD CHECK-
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    // MARK: -Core Data
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func buildToShare(_ objectID: NSManagedObjectID) ->[ String : Any ] {
        self.ics214 = bkgrdContext.object(with: objectID) as? ICS214Form
        var theGuid = ""
        var theEffort = ""
        var thePosition = ""
        if let guid = self.ics214.ics214Guid {
            theGuid = guid
        }
        if let effort = self.ics214.ics214Effort {
            theEffort = effort
        }
        if let position = self.ics214.ics214ICSPosition {
            thePosition = position
        }
        
        dayFormat.dateFormat = "MMMM d, YYYY"
        var fromDate = ""
        if let fDate = self.ics214.ics214FromTime {
            let dateString = dayFormat.string(from:fDate)
            fromDate = dateString
        }
        var toDate = ""
        if let fDate = self.ics214.ics214ToTime {
            let dateString = dayFormat.string(from:fDate)
            toDate = dateString
        }
        var signatureDate = ""
        if let fDate = self.ics214.ics214SignatureDate {
            let dateString = dayFormat.string(from:fDate)
            signatureDate = dateString
        }

        dayFormat.dateFormat = "HH:mm"
        var fromTime = ""
        if let fDate = self.ics214.ics214FromTime {
            let dateString = dayFormat.string(from:fDate)
            fromTime = dateString
        }
        var toTime = ""
        if let fDate = self.ics214.ics214ToTime {
            let dateString = dayFormat.string(from:fDate)
            toTime = dateString
        }
        var latitude = ""
        if let lat = self.ics214.ics214Latitude {
            latitude = lat
        }
        var longitude = ""
        if let long = self.ics214.ics214Longitude {
            longitude = long
        }
        var theIncidentName = ""
        if let name = self.ics214.ics214IncidentName {
            theIncidentName = name
        }
        var theIncidentNumber = ""
        if let number = self.ics214.ics214LocalIncidentNumber {
            theIncidentNumber = number
        }
        var theTeamName = ""
        if let team = self.ics214.ics214TeamName {
            theTeamName = team
        }
        var theUserName = ""
        if let user = self.ics214.ics214UserName {
            theUserName = user
        }
        var theHomeAgency = ""
        if let agency = self.ics214.ics241HomeAgency {
            theHomeAgency = agency
        }
        var thePreparerPosition = ""
        if let prePosition = self.ics214.icsPreparedPosition {
            thePreparerPosition = prePosition
        }
        var thePrepareName = ""
        if let person = self.ics214.icsPreparfedName {
            thePrepareName = person
        }
        var campaignCount = ""
        campaignCount = "\(self.ics214.ics214Count)"
        var effortMaster = ""
        if self.ics214.ics214EffortMaster {
            effortMaster = "1"
        } else {
            effortMaster = "0"
        }
        var agencyArray = [String]()
        var positionArray = [String]()
        var nameArray = [String]()
        if let guid = self.ics214.ics214Guid {
            let array = getPersonnelBase(guid: guid)
            for attendee in array {
                if attendee.userAttendeeGuid != "" {
                    let attendee: UserAttendees = getAttendee(attendeeGuid:attendee.userAttendeeGuid ?? "")
                    if let attendee = attendee.attendee {
                        nameArray.append(attendee)
                    } else {
                        nameArray.append("NA")
                    }
                    if let agency = attendee.attendeeHomeAgency {
                        agencyArray.append(agency)
                    } else {
                        agencyArray.append("NA")
                    }
                    if let position = attendee.attendeeICSPosition {
                        positionArray.append(position)
                    } else {
                        positionArray.append("NA")
                    }
                }
            }
        }
        
        var theLogTimesArray = [String]()
        var theLogNotableActivitiesArray = [String]()
        let result = self.ics214.ics214ActivityDetail?.allObjects as! [ICS214ActivityLog]
        if !result.isEmpty {
            for log in result {
                if let theDate = log.ics214ActivityDate {
                    dayFormat.dateFormat = "MMMM d, YYYY HH:mm"
                    let dateString = dayFormat.string(from: theDate) + "HR"
                    theLogTimesArray.append(dateString)
                } else {
                    let dateString = "Date/Time not available"
                    theLogTimesArray.append(dateString)
                }
                if let activity = log.ics214ActivityLog {
                    theLogNotableActivitiesArray.append(activity)
                } else {
                    let activity = "The activity log was not was not available"
                    theLogNotableActivitiesArray.append(activity)
                }
            }
        }
        
        var imageData: Data = Data()
        if self.ics214.ics214SignatureAdded {
            imageData = imageForCloudKit()
        }
        
       formBody = [
                "ics214Guid": theGuid,
                "ics214Effort": theEffort,
                "ics214ICSPosition": thePosition,
                "ics214FromDate": fromDate,
                "ics214FromTime": fromTime,
                "ics214ToDate": toDate,
                "ics214ToTime": toTime,
                "ics214SignatureDate": signatureDate,
                "ics214Latitude": latitude,
                "ics214Longitude": longitude,
                "ics214IncidentName": theIncidentName,
                "ics214LocalIncidentNumber": theIncidentNumber,
                "ics214TeamName": theTeamName,
                "ics214UserName": theUserName,
                "ics241HomeAgency": theHomeAgency,
                "icsPreparedPosition": thePreparerPosition,
                "icsPreparedName": thePrepareName,
                "ics214Count": campaignCount,
                "ics214EffortMaster": effortMaster,
                "resourcesNames": nameArray,
                "resourcesAgency": agencyArray,
                "resourcesPosition": positionArray,
                "activityLogTimes": theLogTimesArray,
                "activityLogNotableActivities": theLogNotableActivitiesArray,
            ]
        
        if !imageData.isEmpty {
            formBody["signatureImageData"] = imageData.base64EncodedString()
        }
        
        guard JSONSerialization.isValidJSONObject(formBody) else {  return ["nothing": "not valid"]  }
        print(formBody)
        return formBody
    }
    
    func setTheData(dataCompletionHander: @escaping ( String, Error? ) -> Void ) {
        
    }
    
    func sendAndRecieve(dataCompletionHander: @escaping ( String, Error? ) -> Void ) {
        
        do {
            
            let bodyData = try JSONSerialization.data(withJSONObject: formBody, options: [])
            
            let validationURLString = FIRECLOUD_URL
            guard let validationURL = URL(string: validationURLString) else {  return  }
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForResource = TimeInterval(180)
            let session = URLSession(configuration: sessionConfig)
            
            var request = URLRequest.init(url: validationURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 180)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = bodyData
            
            let task = session.uploadTask(with: request, from: bodyData) { (data, response, error) in
                
                    print("here is the data \(String(describing: data)) here is the error \(String(describing: error))")
                if let data = data , error == nil {
                    do {
                        let appReceiptJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments )  as! [ String:Any ]
//                        let appReceiptJSON = try JSONSerialization.jsonObject(with: data, options: [])  as! [ String:Any ]
                        print("here is appReceiptJSON \(appReceiptJSON)")
                        let pdfLink: String = (appReceiptJSON["pdf"] as! String)
                        DispatchQueue.main.async {
                            self.nc.post(name: Notification.Name(rawValue: FJkLINKFROMCLOUDFORICS214TOSHARE),
                                         object: nil, userInfo: ["pdfLink":pdfLink])
                        }
                        dataCompletionHander( pdfLink , nil )
                        
                    } catch {
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
            }
            task.resume()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
    }

    func getDirectoryPath() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory
    }
    
    func imageForCloudKit() ->Data {
        var image: UIImage!
        var imageData: Data!
        image = UIImage.init(data: self.ics214.ics214Signature!)!
        imageData = image.pngData()
        return imageData
   }
    
    func getTheActivityLogTime(theLogs: [ICS214ActivityLog] ) ->[String] {
        var logTime = [String]()
        for log in theLogs {
            dayFormat.dateFormat = "MMMM d, YYYY HH:mm"
            let fDate = log.ics214ActivityDate ?? Date()
            let dateString = dayFormat.string(from:fDate)
            logTime.append(dateString)
        }
        return logTime
    }
    
    func getTheActivityNotableActivity(theLogs: [ICS214ActivityLog]) -> [String] {
        var notableLogs = [String]()
        for log in theLogs {
            if let notable = log.ics214ActivityLog {
                notableLogs.append(notable)
            }
        }
        return notableLogs
    }
    
    func getTheSet() -> [ICS214ActivityLog] {
           let logs = ics214.ics214ActivityDetail as! Set<ICS214ActivityLog>
           var logArray = [ICS214ActivityLog]()
           for log in logs {
               logArray.append(log)
           }
           return logArray
       }
    
    private func getPersonnelBase(guid:String)->Array<ICS214Personnel> {
        var array = [ICS214Personnel]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ICS214Personnel" )
        let predicate = NSPredicate(format: "%K = %@", "ics214Guid",guid)
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let fetched = try self.bkgrdContext.fetch(fetchRequest) as! [ICS214Personnel]
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
            let fetched = try self.bkgrdContext.fetch(fetchRequest) as! [UserAttendees]
            if !fetched.isEmpty {
                userAttendee = fetched.last!
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return userAttendee!
    }
    
}
