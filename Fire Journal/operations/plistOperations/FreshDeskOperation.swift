//
//  FreshDeskOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 1/11/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class FreshDeskOperation: FJOperation, URLSessionDelegate {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var privateDatabase:CKDatabase!
    var fireJournalUsersA = [FireJournalUser]()
    var fju:FireJournalUser!
    var ckRecordA = [CKRecord]()
    var count: Int = 0
    var stop:Bool = false
    var recordID:String = ""
    var counter = 0
    let userDefaults = UserDefaults.standard
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    let freshDeskCreds = "b7KAfGtLjfwXOKAPmdzF:X"
    var fname = ""
    var userName = ""
    var email = ""
    var phone = ""
    var rank = ""
    var platoon = ""
    var fireDepartment = ""
    var fireStation = ""
    var freshDeskDict = [String:Any]()
    var freshDeskCustomDict = [String: String]()
    var sessionFailureCount:Int = 0
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        self.privateDatabase = self.myContainer.privateCloudDatabase
        super.init()
    }
    
    override func main() {
        //        MARK: -FJOperation operation-
        operation = "FreshDeskOperation"
        
        guard isCancelled == false else {
            self.executing(false)
            finish(true)
            return
        }
        
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        let nc = NotificationCenter.default
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        executing(true)
        getTheUser()
        let authData = freshDeskCreds.data(using: .utf8)
        let authValue = authData?.base64EncodedString()
        let configuration = URLSessionConfiguration.default
        let session = URLSession.init(configuration: configuration, delegate: self, delegateQueue: nil)
        let url = URL(string: "https://purecommand.freshdesk.com/api/v2/contacts")
        var request = URLRequest.init(url: url!)
//        configuration.httpAdditionalHeaders = ["Authorization":authValue as Any]
        request.addValue(authValue!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        do {
            let data = try JSONSerialization.data(withJSONObject: freshDeskDict, options: [])
            request.httpBody = data
            let _ = session.dataTask(with: request) { data, response, error in
                print(response as Any)
                if error != nil {
                    let errorMessage = "class FreshDeskOperation: FJOperation JSONSerialization errored out sending your data \(String(describing: error?.localizedDescription)) please copy and report to info@purecommand.com"
                    print(errorMessage)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FJkFRESHDESK_UPDATED), object: nil, userInfo:["freshDesk": false])
                    }
                    
                    self.executing(false)
                    self.finish(true)
                    
                } else {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: FJkFRESHDESK_UPDATED), object: nil, userInfo:["freshDesk": true])
                    }
                    
                    self.executing(false)
                    self.finish(true)
                }
            }.resume()
        } catch let error as NSError {
            print("FreshDeskOperation line 92 Fetch Error: \(error.localizedDescription)")
        }
        
        
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("did we get a challenge \(challenge)")
//        if sessionFailureCount == 0 {
            let cred = URLCredential.init(user: "b7KAfGtLjfwXOKAPmdzF", password: "X", persistence: .forSession)
            print(cred)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, cred)
//        }
        sessionFailureCount += 1
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func getTheUser() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", "userGuid", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
            self.fju = fetched.last
            if let firstName = fju.firstName {
                fname = firstName
            }
            if let lname = fju.lastName {
                userName = "\(fname) \(lname)"
            }
            if let emailAddress = fju.emailAddress {
                email = emailAddress
            }
            if let mobile = fju.mobileNumber {
                phone = mobile
            }
            if let jobTitle = fju.rank {
                rank = jobTitle
            }
            if let pla = fju.platoon {
                platoon = pla
            }
            if let fireD = fju.fireDepartment {
                fireDepartment = fireD
            }
            if let fireS = fju.fireStation {
                fireStation = fireS
            }
            freshDeskCustomDict = ["platoon":platoon,"fire_department":fireDepartment,"fire_station":fireStation]
            freshDeskDict = ["name":userName,"email":email,"mobile":phone,"job_title":rank,"custom_fields":freshDeskCustomDict]
            
            
            
        } catch let error as NSError {
            print("FreshDeskOperation line 171 Fetch Error: \(error.localizedDescription)")
        }
    }

}
