//
//  BackgroundOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 9/29/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

class BackgroundOperation: FJOperation {

    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    let pendingOperations = PendingOperations()
    var thread:Thread!
    let nc = NotificationCenter.default
    
    var whatToDo : (() -> ())?
    var cleanup : (() -> ())?
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bkgrdContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        guard !self.isCancelled else { print("oops, cancelled"); return }
        guard let whatToDo = self.whatToDo else { return }
        guard !Thread.isMainThread else { fatalError("must be called in background!")}
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        executing(true)
            
        var bti : UIBackgroundTaskIdentifier = .invalid
        bti = UIApplication.shared.beginBackgroundTask {
            self.saveToCD()
            self.cleanup?()
            print("premature cleanup", self)
            UIApplication.shared.endBackgroundTask(bti) // cancellation
        }
        guard bti != .invalid else { return }
        whatToDo()
        print("end", self)
        UIApplication.shared.endBackgroundTask(bti) // completion
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
    }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    fileprivate func saveToCD() {
        do {
            try bkgrdContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"BackgroundOperation saveToCD Done"])
            }
            DispatchQueue.main.async {
                print("BackgroundOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
        }
    }
    
    func doOnMainQueueAndBlockUntilFinished(_ f:@escaping ()->()) {
        OperationQueue.main.addOperations([BlockOperation(block: f)], waitUntilFinished: true)
    }
    
}
