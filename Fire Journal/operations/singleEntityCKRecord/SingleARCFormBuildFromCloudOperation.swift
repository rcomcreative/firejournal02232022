//
//  SingleARCFormBuildFromCloudOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/8/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class SingleARCFormBuildFromCloudOperation: FJOperation {
    
    lazy var arCrossFormProvider: ARCFormProvider = {
        let provider = ARCFormProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theARCFormProviderContext: NSManagedObjectContext!
    
    var ckRecord: CKRecord
    var theARCForm: ARCrossForm!
    var theUserTimeID: NSManagedObjectID
    var theUserTime: UserTime!
    let nc = NotificationCenter.default
    var thread:Thread!
    var context: NSManagedObjectContext!
    let dateFormatter = DateFormatter()
    
    init( _ ckRecord: CKRecord,_ userTimeID: NSManagedObjectID,_ context: NSManagedObjectContext) {
        self.ckRecord = ckRecord
        self.theUserTimeID = userTimeID
        self.context = context
        super.init()
        self.theARCFormProviderContext = arCrossFormProvider.persistentContainer.newBackgroundContext()
    }
    
    override func main() {
        
            //        MARK: -FJOperation operation-
            operation = "SingleARCFormBuildFromCloudOperation"
            
            guard isCancelled == false else {
                executing(false)
                finish(true)
                return
            }
            
            thread = Thread(target:self, selector:#selector(checkTheThread), object: nil)
            nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.theARCFormProviderContext)
            executing(true)
        
        theUserTime = self.theARCFormProviderContext.object(with: theUserTimeID) as? UserTime
        buildNewARCrossFormFromCloud(record: ckRecord) {
            if self.theARCForm != nil {
                self.theUserTime.addToArcForm(self.theARCForm)
                self.saveToCD()
                DispatchQueue.main.async {
                    print("SingleARCFormBuildFromCloudOperation has run and now if finished")
                    self.executing(false)
                    self.finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            } else {
                DispatchQueue.main.async {
                    print("SingleARCFormBuildFromCloudOperation has run and now if finished")
                    self.executing(false)
                    self.finish(true)
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
            }
        }
        
        
        guard isCancelled == false else {
            executing(false)
            finish(true)
            return
        }
        
    }
    
    
    func buildNewARCrossFormFromCloud(record: CKRecord, completionHandler: (() -> Void)? = nil) {
        theARCForm = ARCrossForm(context: self.theARCFormProviderContext)
        arCrossFormProvider.singleARCrossFromTheCloud(ckRecord: ckRecord, dateFormatter: dateFormatter, theARCForm, self.theARCFormProviderContext) {
            completionHandler?()
        }
    }
    
        // MARK: -
        // MARK: Notification Handling
        @objc func managedObjectContextDidSave(notification: Notification) {
            DispatchQueue.main.async {
                self.context.mergeChanges(fromContextDidSave: notification)
            }
        }
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("here is testThread \(testThread) and \(Thread.current)")
    }
    
    fileprivate func saveToCD() {
        do {
            try self.theARCFormProviderContext.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.theARCFormProviderContext,userInfo:["info":"SingleARCrossFormBuildFromCloudOperation"])
            }
        } catch {
            let nserror = error as NSError
            print("The context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo)")
            DispatchQueue.main.async {
                print("SingleARCrossFormBuildFromCloudOperation has run and now if finished")
                self.executing(false)
                self.finish(true)
                self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        }
    }

}
