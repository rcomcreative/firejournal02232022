//
//  NFIRSFormOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/2/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NFIRSFormList {
    var displayOrder:Int
    let entryState = EntryState.new
    var theFormName:String
    var theFormType:String
    var theFormDescription:String
    var theFormDate:Date
    var theFormGuid:String
    var theFormVisible:Bool = false
    init(display:Int, name:String, description:String, type:String, visible: Bool, date:Date) {
        self.displayOrder = display
        self.theFormName = name
        self.theFormDescription = description
        self.theFormType = type
        self.theFormDate = date
        self.theFormVisible = visible
        let guidDate = GuidFormatter.init(date:date)
        let guid = guidDate.formatGuid()
        self.theFormGuid = "65."+guid
    }
}

class NFIRSFormLoader: FJOperation {
    let context: NSManagedObjectContext
    var bkgrdContext:NSManagedObjectContext!
    var names = [String]()
    var descriptions = [String]()
    var types = [String]()
    var visible = [Bool]()
    var displayOrders = [Int]()
    var count: Int = 0
    var stop:Bool = false
    let nc = NotificationCenter.default
    
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
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
        
        executing(true)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Forms" )
        var count = 0
        do{
            count = try bkgrdContext.count(for:fetchRequest)
        } catch let error as NSError {
            let nserror = error as NSError
            let errorMessage = "class NFIRSFormOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
            print(errorMessage)
        }
        if count > 0 {
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do{
                try bkgrdContext.execute(deleteRequest)
                do {
                    try bkgrdContext.save()
                    DispatchQueue.main.async {
                        self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NFIRS Form Operation"])
                    }
                } catch let error as NSError {
                    let nserror = error as NSError
                    let errorMessage = "class NFIRSFormOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                    print(errorMessage)
                }
                plowThroughThePlist()
            } catch let error as NSError {
                let nserror = error as NSError
                let errorMessage = "class NFIRSFormOperation: FJOperation saveToCD context was unable to save due to \(nserror.localizedDescription) \(nserror.userInfo) please copy and report to info@purecommand.com"
                print(errorMessage)
            }
        } else {
            plowThroughThePlist()
        }
        
        
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
    }
    
    func plowThroughThePlist() {
        
        guard let path = Bundle.main.path(forResource: "NFIRSForm", ofType:"plist") else {return}
        let dict = NSDictionary(contentsOfFile:path)
        names = dict?["formName"] as! Array<String>
        descriptions = dict?["formDescriptions"] as! Array<String>
        types = dict?["formImageType"] as! Array<String>
        visible = dict?["formVisible"] as! Array<Bool>
        displayOrders = dict?["displayOrder"] as! Array<Int>
        count = displayOrders.count
        
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        if dict != nil {
            for (index, value) in displayOrders.enumerated() {
                let display = value
                let name = names[index]
                let description = descriptions[index]
                let type = types[index]
                let vis = visible[index]
                
                let list = NFIRSFormList.init(display: display, name: name, description: description, type: type, visible: vis, date: Date())
                
                let form = Forms.init(entity: NSEntityDescription.entity(forEntityName: "Forms", in: bkgrdContext)!, insertInto: bkgrdContext)
                form.displayOrder = Int64(list.displayOrder)
                form.entryState = list.entryState.rawValue
                form.formName = list.theFormName
                form.formDescription = list.theFormDescription
                form.formImageType = list.theFormType
                form.formGuid = list.theFormGuid
                form.formModDate = list.theFormDate
                form.formVisible = list.theFormVisible
                form.formBackup = false
            }
            saveToCD()
        }
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
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.bkgrdContext,userInfo:["info":"NFIRS Form Operation"])
            }
            let nc = NotificationCenter.default
            DispatchQueue.main.async {
                nc.post(name:Notification.Name(rawValue:FJkPLISTSCALLED),
                        object: nil,
                        userInfo: ["plist":PlistsToLoad.fjkPLISTNFIRSFormLoader])
                self.executing(false)
                self.finish(true)
                nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
            }
        } catch let error as NSError {
            print("NFIRSFormOperation line 157 Fetch Error: \(error.localizedDescription)")
        }
    }
}
