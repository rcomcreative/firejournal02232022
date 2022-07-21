    //
    //  DeleteCoreDataForUserOperation.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 7/15/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import CoreData
import CloudKit

class DeleteCoreDataForUserOperation: FJOperation {
    
    lazy var userTimeProvider: UserTimeProvider = {
        let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userTimeContext: NSManagedObjectContext!
    var userTimeModal: NSManagedObjectModel!
    var context: NSManagedObjectContext!
    let nc = NotificationCenter.default
    var thread:Thread!
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
        self.userTimeContext = self.userTimeProvider.persistentContainer.newBackgroundContext()
        self.userTimeModal = self.userTimeProvider.persistentContainer.managedObjectModel
    }
    
    override func main() {
        
            //        MARK: -FJOperation operation-
        operation = "DeleteZoneIDOperatio"
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
        thread = Thread(target:self, selector:#selector(checkTheThread), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.userTimeContext)
        executing(true)
        let entityNames = self.userTimeModal.entities.map({ $0.name!})
        takeDownCoreData(entityNames: entityNames) {
            DispatchQueue.main.async {
                self.nc.post(name: .fConCDSuccess, object:nil)
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                return
            }
        }
        
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
    }
    
    private func takeDownCoreData(entityNames: [String],completionBlock: () -> ()) {
        entityNames.forEach { [weak self] entityName in
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            do {
                try self?.userTimeContext.execute(deleteRequest)
                try self?.userTimeContext.save()
            } catch {
                let error = error as NSError
                let message = "There was an error trying to delete your data: \(error.localizedDescription)"
                DispatchQueue.main.async {
                    self?.nc.post(name: .fConCDFailure, object:nil, userInfo: ["errorMessage": message])
                    self?.executing(false)
                    self?.finish(true)
                    self?.nc.removeObserver(self as Any, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }
        completionBlock()
        
    }
    
        //    MARK:- MAKE SURE OPERATION IS ON BACKGROUND THREAD
    @objc func checkTheThread() {
        let testThread: Bool = thread.isMainThread
        if testThread == false {
            print("this thread is on the main")
            executing(false)
            finish(true)
            return
        }
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
}
