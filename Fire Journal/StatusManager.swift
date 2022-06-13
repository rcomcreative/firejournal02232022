//
//  StatusManager.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/25/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit

class StatusManager: NSObject {
    
    static let shared = StatusManager(name: FJkSTATUSCONTAINERNAME)
    
    var theStatus: Status!
    var statusName: String
    var context: NSManagedObjectContext!
    var container: CKContainer!
    var privateDatabase: CKDatabase!
    var bkgrdContext:NSManagedObjectContext!
    var thread:Thread!
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    
    lazy var statusProvider: StatusProvider = {
        let provider = StatusProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var statusContext: NSManagedObjectContext!
    
        //    MARK: -INIT-
    private init(name: String) {
        self.statusName = name
        self.container = CKContainer.init(identifier: self.statusName)
        self.privateDatabase = container.privateCloudDatabase
        super.init()
    }
    
    func getTheStatus(moc: NSManagedObjectContext, completionHandler: ( @escaping (_ status: Status) -> Void)) {
        self.context = moc
        let fetchRequest: NSFetchRequest<Status> = Status.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "agreementDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let fetched = try context.fetch(fetchRequest)
            if !fetched.isEmpty {
            let result = fetched.sorted(by: { return $0.agreementDate! < $1.agreementDate! })
                if !result.isEmpty {
                    theStatus = result.last
                    completionHandler(theStatus)
                }
            } else {
                DispatchQueue.global(qos: .background).async {
                    self.statusContext = self.statusProvider.persistentContainer.viewContext
                    self.statusProvider.getStatusFromCloud(self.statusContext) { status in
                        completionHandler(status)
                    }
                }
            }
            
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
}
